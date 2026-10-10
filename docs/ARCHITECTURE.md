# Lifelog 技术栈与架构

> 一个纯本地优先的安卓个人信息管理 App：随手收集 → AI 整理成日程 → 全天记录轨迹。
> 没有自己的服务器，所有数据存在手机本地；AI 和地图走第三方 API。

---

## 一、技术栈全清单

### 1.1 框架与语言

| 名称 | 版本 | 用途 |
|---|---|---|
| Flutter | 3.47.7 | UI 框架 |
| Dart | 3.13.5 | 开发语言 |
| Kotlin | 2.4.0 | Android 原生侧（PlatformView 封装） |

### 1.2 运行时依赖（pubspec.yaml）

| 包 | 版本 | 用来做什么 |
|---|---|---|
| `flutter_riverpod` | 3.4.3 | 状态管理。所有跨页面共享的状态都走它 |
| `go_router` | 18.0.2 | 路由。四个 Tab 用 `StatefulShellRoute` 各自保留导航栈 |
| `drift` | 2.35.2 | SQLite 的类型安全封装，编译期生成查询代码 |
| `drift_flutter` | 0.3.1 | Drift 的 Flutter 集成（数据库文件路径等） |
| `dio` | 5.11.1 | HTTP 客户端，调 DeepSeek API |
| `geolocator` | 14.1.1 | 拿 GPS 位置流 |
| `flutter_foreground_task` | 11.0.3 | 前台服务，让轨迹能在锁屏/后台继续记录 |
| `pedometer` | 4.2.0 | 读硬件计步传感器 |
| `flutter_secure_storage` | 11.2.0 | 加密存 API Key（Android 上是 EncryptedSharedPreferences） |
| `permission_handler` | 12.0.0 | 申请通知/后台定位/身体活动等权限 |
| `image_picker` | 1.2.4 | 从相册选图 |
| `receive_sharing_intent` | 1.9.0 | 接收系统分享菜单发过来的图片/文字 |
| `intl` | 0.20.3 | 时间格式化 |
| **高德地图 SDK** | **10.0.600** | **不走 pub，直接引 maven（见 §3.3）** |

### 1.3 开发期依赖

`build_runner` / `drift_dev` / `riverpod_generator` / `json_serializable` / `flutter_lints`

### 1.4 外部服务

| 服务 | 用途 | Key 存放在哪 |
|---|---|---|
| DeepSeek API | AI 整理（模型 `deepseek-flash`） | `flutter_secure_storage`，加密存本机 |
| 高德开放平台 | 地图底图 + 轨迹绘制 | `AndroidManifest.xml` 的 meta-data |

### 1.5 构建工具链

| 工具 | 版本 | 备注 |
|---|---|---|
| Android SDK | platforms 35 / 36 / **37** | 37 是 `receive_sharing_intent` 要求的 |
| AGP | 9.1.0 | 官方只声明支持到 compileSdk 36，37 需要 `suppressUnsupportedCompileSdk` |
| Gradle | 9.3.1 | 走腾讯云镜像下载 |
| JDK | 17 | 装在 `<开发目录>\JDK17` |

---

## 二、分层架构

```
┌──────────────────────────────────────────────────────┐
│  presentation/   页面与组件                            │
│  （inbox_page / schedule_page / track_page / ...）     │
└───────────────────────┬──────────────────────────────┘
                        │ ref.watch / ref.read
┌───────────────────────▼──────────────────────────────┐
│  application/   Provider & Notifier                   │
│  （inbox_providers / track_recorder / step_tracker）   │
│  职责：状态编排、生命周期、把 Repository 暴露给 UI      │
└───────────────────────┬──────────────────────────────┘
                        │ 方法调用
┌───────────────────────▼──────────────────────────────┐
│  data/   Repository                                   │
│  （inbox_repository / organize_repository / ...）      │
│  职责：业务规则（比如「改过的条目自动退回待整理」）      │
└──────────┬────────────────────────────┬──────────────┘
           │                            │
┌──────────▼──────────┐    ┌────────────▼─────────────┐
│  db/daos/           │    │  services/                │
│  Drift DAO          │    │  DeepSeekService          │
│  只管 SQL，不含业务   │    │  MediaStorage             │
└──────────┬──────────┘    │  SecureSettings           │
           │               │  ShareIntentService       │
           │               │  TrackForegroundService   │
           │               └────────────┬─────────────┘
┌──────────▼────────────────────────────▼──────────────┐
│  SQLite (Drift)      │  DeepSeek API  │  高德 SDK     │
│                      │                │  传感器        │
└──────────────────────────────────────────────────────┘
```

**两条规矩：**

1. **UI 只跟 Provider 说话**，不直接碰 Repository，更不碰 DAO
2. **业务规则写在 Repository 层**，比如「编辑已整理的条目要退回待整理」——这样 UI 和 DAO 都不需要知道这条规则

---

## 三、数据模型

### 3.1 表结构（schemaVersion = 3）

```
inbox_items ──────────┐  收集箱条目（文字/图片/截图）
  id, type, content,  │
  image_path,         │  1:N（改一次记一条）
  ocr_text, status,   │
  organize_policy,    ▼
  created_at,      inbox_item_revisions   变更历史（像聊天记录）
  updated_at         id, item_id, kind, content, recorded_at

schedules ────────────┐  日程表
  id, title, desc,    │
  start_at, end_at,   │  N:1（多条日程可来自同一次整理）
  is_all_day,         │
  location, priority, │
  status, origin,     ▼
  ai_run_id ──────► ai_runs                每次 AI 整理的记录
  source_item_ids      id, status, model, request_prompt,
                       raw_response, created_count, error_message
                       └─ source_item_ids 指回收集箱条目（溯源）

track_sessions ───────┐  轨迹会话（一天一段 / 手动开关切分）
  id, start_at,       │
  end_at, point_count,│  1:N
  distance_m, status  ▼
                    track_points           轨迹点
                      id, session_id,
                      lat_wgs, lng_wgs,    ← GPS 原始坐标
                      lat_gcj, lng_gcj,    ← 转成高德用的加密坐标
                      altitude, accuracy, speed, bearing,
                      provider, recorded_at

daily_steps           每日步数
  date_key(PK), steps, last_raw, updated_at

app_settings          非敏感配置的键值对
  key(PK), value
```

### 3.2 关键设计决策

| 决策 | 为什么 |
|---|---|
| 轨迹点**同时存 WGS84 和 GCJ-02** | WGS84 是真值（导出 GPX、换地图用），GCJ-02 是高德底图要的。国内两者差 500+ 米，不转换轨迹会跑偏到隔壁街 |
| `daily_steps` 存 `last_raw` | 传感器只报"开机以来总数"，重启清零。存原始值才能算增量和识别重启 |
| `inbox_items.organize_policy` | 用户可以屏蔽某条不参与 AI 整理 |
| `schedules.source_item_ids` 是 JSON 数组 | 一条日程可能来自多条笔记，一个条目也可能拆出多条日程 |
| 图片只存**相对路径** | 应用私有目录的绝对路径换设备会变 |

---

## 四、四条核心流程

### 4.1 收集箱：记一笔 → 落库

```
用户点「记一笔」
    │
    ├─ 纯文字 ──────────────┐
    │                       │
    └─ 选了图片             │
         │                  │
         ▼                  │
   MediaStorage.saveImage   │   复制进应用私有目录
   （返回相对路径）          │   得到 images/2026/10/xxx.jpg
         │                  │
         └──────────┬───────┘
                    ▼
            InboxDao.insertItem
                    │
                    ▼
           写一条 created 历史
                    │
                    ▼
           列表自动刷新（Drift Stream 推送）
```

**从系统分享进来**是另一条入口（`ShareIntentService`），处理冷启动和热启动两种情况，最终落到同一个 Repository 方法。

---

### 4.2 编辑条目 → 自动回流

```
用户改文字 / 换图 / 删图
    │
    ▼
InboxRepository.updateItem
    │
    ├─ 内容没变？ ──→ 直接返回，不写库（避免历史塞满空记录）
    │
    ├─ 换了图？ ──→ 删旧文件 + 存新文件
    │
    ▼
写一条 edited 历史
    │
    ▼
原来是 processed（已整理过）？
    │
    ├─ 是 ──→ status 改回 pending   ★ 关键：否则改动永远白改
    │
    └─ 否 ──→ status 不变
    │
    ▼
UI 提示「已退回待整理」
```

---

### 4.3 AI 整理（两阶段，刻意分开）

```
【第一阶段：生成草案】

点「开始整理」
    │
    ▼
取所有 status=pending 且 policy=auto 的条目
    │
    ▼
在 ai_runs 插入一条 running 记录
    │
    ▼
组装 prompt
  ├─ 注入当前时间（否则模型算不出"明天下午三点"）
  ├─ 要求提炼（用户原话啰嗦 → 浓缩成短标题）
  └─ 要求拆分（"早上买豆浆晚上喝粥" → 两条日程）
    │
    ▼
有条目带图？
  ├─ 是 ──→ 读图转 base64 → chatWithImages
  └─ 否 ──→ chat
    │
    ▼
  调 DeepSeek（json 模式）
    │
    ▼
解析 JSON → List<OrganizeDraft>
    │
    ├─ 成功 ──→ ai_runs 更新为 success，返回草案
    └─ 失败 ──→ ai_runs 更新为 failed，抛出异常
    │
    ▼
【第二阶段：用户确认后落库】

底部弹窗展示草案（默认全选，可取消）
    │
    ▼
用户点「写入日程」
    │
    ├─ 批量插入 schedules（带 ai_run_id 和 source_item_ids）
    ├─ 参与整理的收集箱条目 → status=processed
    └─ 返回写入条数
```

**为什么分两阶段**：模型会抽风。草案先给用户看，确认之前绝不写日程表。

---

### 4.4 轨迹采集（全天记录）

```
点「开始记录」
    │
    ▼
① 检查定位权限 ──→ 没有就申请
    │
    ▼
② 申请后台定位（Android 11+ 要单独走一次）
    │
    ▼
③ 申请通知权限（Android 13+ 前台服务必须有通知）
    │
    ▼
④ 引导关闭电池优化
    │
    ▼
⑤ 启动前台服务（type=location）
    │
    ▼
⑥ 建会话 → track_sessions 插一条 recording
    │
    ▼
⑦ 订阅 geolocator 位置流
     accuracy 和 distanceFilter 由设置里的档位决定：
       省电   → low    / 移动 50 米采一个点
       平衡   → medium / 移动 15 米采一个点
       高精度 → high   / 移动 10 米采一个点
    │
    ▼
⑧ 每次回调：
     坐标 WGS84 → 转 GCJ-02
     两个坐标都存进内存缓冲
     （攒够 5 个点 或 满 30 秒 → 批量写库）
    │
    ▼
⑨ 前台服务保活
     锁屏 / 切后台 → App 进程不被冻结 → 位置流继续
     通知栏常驻显示「已记录 X 公里 · N 个点」
    │
    ▼
点「停止记录」
    │
    ▼
落掉缓冲 → 结算里程和点数 → 关掉前台服务
```

---

### 4.5 计步（和轨迹是两套独立机制）

```
App 启动
    │
    ▼
申请「身体活动」权限
    │
    ▼
订阅 Pedometer.stepCountStream （硬件计步芯片）
    │
    ▼
每次回调：
    读今天的 daily_steps 记录
    │
    ├─ 今天还没有记录
    │    ├─ 12 小时内有过记录？ ──→ 用上次的 last_raw 当基线
    │    │                          （能补上隔夜走的步数）
    │    └─ 隔太久了 ──────────→ 用当前值当基线，从 0 开始
    │                                 （宁可少算，不虚高）
    │
    └─ 有记录 ──→ 增量 = 当前值 - last_raw
                   ├─ 增量 < 0  ──→ 手机重启过，重设基线
                   ├─ 增量 > 2 万 ──→ 异常，丢弃
                   └─ 正常 ──────→ steps += 增量
    │
    ▼
写回 daily_steps，UI 刷新
```

**和轨迹的本质区别：**

|  | 计步 | 轨迹 |
|---|---|---|
| 硬件 | 计步芯片（协处理器） | GPS 芯片 |
| 耗电 | <1% | 5~15% |
| 需要前台服务 | ❌ | ✅ |
| 需要定位权限 | ❌ | ✅ |
| 数据含义 | 步数 | 经纬度序列 |

---

## 五、项目创作流程（实际走过的路）

```
① 需求确认
   ├─ 四个模块：收集箱 / AI 整理 / 日程 / 轨迹
   ├─ 约束：纯安卓、无服务器、数据本地、AI 用 DeepSeek、地图用高德
   └─ 确认关键选型：图片直传 DeepSeek 视觉模型、地图自封装 PlatformView

② 环境搭建（全部装在 开发盘）
   ├─ Flutter 3.47.7 → <开发目录>\flutter
   ├─ Android SDK 35/36/37 → <开发目录>\android-sdk
   ├─ Gradle 缓存 → <开发目录>\gradle-home
   └─ 配国内镜像（pub / flutter / gradle / maven）

③ 阶段 0：地基
   ├─ flutter create（包名 com.simple.lifelog）
   ├─ 6 张表 + 索引
   ├─ 四 Tab 壳 + 设置页
   └─ 验收：真机跑起来

④ 模块 1 收集箱
   ├─ 文字 / 图片 / 截图
   ├─ 系统分享接收（冷启动 + 热启动）
   └─ 验收：真机存数据 → 查数据库确认落库

⑤ 模块 2 AI 整理
   ├─ DeepSeek 客户端
   ├─ prompt 设计（提炼 + 拆分）
   ├─ 两阶段流程（草案 → 确认 → 落库）
   └─ 验收：真机跑一次，对比 raw_response 和 schedules 表

⑥ 模块 3 日程表
   ├─ 周视图（时间轴固定 + 7 列横滑）
   ├─ 气泡按真实时刻定位
   └─ 验收：真机截图

⑦ 模块 4 轨迹
   ├─ 坐标转换（WGS84 → GCJ-02）
   ├─ 采集 + 前台服务保活
   ├─ 高德地图 PlatformView
   ├─ 权限自检页
   └─ 计步（读硬件传感器）

⑧ 每轮循环
   写代码 → flutter analyze → flutter build apk → adb install → 真机验证
```

### 5.1 每轮的验证方法

| 层次 | 手段 |
|---|---|
| 语法/类型 | `flutter analyze`（目标：No issues found） |
| 编译 | `flutter build apk --debug` |
| 装到手机 | `adb install -r` |
| 运行时 | `adb logcat` 抓 FATAL / E/flutter |
| **数据是否正确** | **`adb shell run-as com.simple.lifelog sqlite3 <db> '<SQL>'` 直接查库** |
| UI 是否正确 | `adb exec-out screencap -p` 截图 + 看图 |

**最重要的一条**：光看 UI 不够，一定要**查数据库**确认数据真的写对了。

---

## 六、踩过的坑（备查）

| 坑 | 现象 | 解决 |
|---|---|---|
| Android SDK 37 元数据 bug | 报找不到 `android-37` | 官方包的 `ApiLevel` 写成了浮点 `37.0`，改成整数 |
| AGP 不支持 compileSdk 37 | 构建直接中断 | `gradle.properties` 加 `android.suppressUnsupportedCompileSdk=37` |
| riverpod_generator 解析不了 Drift 行类 | `InvalidTypeException` | 涉及 Drift 行类的 provider 全部手写 |
| `const []` 不可变 | `Unsupported operation` 崩溃 | 返回 `<T>[]` 而不是 `const []` |
| 高德 SDK 不显示地图 | 只有灰色网格 | 必须先调 `updatePrivacyShow` + `updatePrivacyAgree` |
| 高德坐标偏移 | 轨迹偏 570 米 | WGS84 → GCJ-02 转换 |
| App 退后台轨迹断 | 位置流停止 | 前台服务 + `foregroundServiceType=location` |
| Flutter 自动重装坏 SDK 包 | 反复出现 | 见「Android SDK 37 元数据 bug」那条 |

---

## 七、已知限制

1. **计步在 App 未打开时不计**——传感器只报"开机以来总数"，App 重新打开时会补上这段。建议每天打开一次 App。
2. **AI 整理的 prompt 效果依赖模型**——"提炼"和"拆分"两条指令模型不一定 100% 遵守，需要实测调优。
3. **轨迹会话不会自动跨天切分**——目前一次「开始/停止」算一段，全天记录需要一天点一次。
4. **`pedometer` 插件用了旧式 Kotlin Gradle Plugin**——现在只是构建警告，未来 Flutter 版本会变成失败，届时需要升级插件或自封装。
