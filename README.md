# Lifelog

一个纯本地优先的安卓 App：**随手收集 → AI 整理成日程 → 全天记录轨迹**。

所有数据存在手机本地 SQLite 里，没有自建服务器、不上传云端。AI 和地图走第三方 API。

---

## 功能

### 📥 收集箱
- 文字、截图、图片随手记
- **从系统分享菜单直接分享进来**（微信、相册、浏览器都行）
- 每条都有完整的**变更历史**——像聊天记录一样，能看到什么时候改了什么内容
- 编辑时文字和图片都能改，旧的图片文件会自动清理
- 三个点菜单里可以「重新整理」或「不再整理」某一条

### ✨ AI 整理
- 把攒下的零散内容发给 DeepSeek，整理成结构化日程
- **自动提炼**：啰嗦的口语 → 简短的标题
- **自动拆分**：「早上记得买杯豆浆，晚上记得喝杯八宝粥」→ 拆成两条独立日程
- **两阶段流程**：先生成草案给你看，确认之后才写进日程表
- 编辑过的条目会自动退回「待整理」，下次整理能带上它

### 📅 日程表
- 周视图，左侧时间轴当坐标
- 日程**按真实时刻定位、按持续时长决定高度**——30 分钟是一道窄条，3 小时是一根长条，不是课表那种等高格子
- 时间重叠的日程自动并排摆开
- **双击气泡展开**，看这条日程来自哪条原始笔记
- 手动新建 / 编辑 / 删除

### 🗺 定位轨迹（需要自备高德 Key）
- 全天记录 GPS 轨迹，画在高德地图上
- **前台服务保活**，锁屏、切后台都能继续记录
- WGS84 → GCJ-02 坐标转换（不转的话轨迹会偏 500 多米）
- **三档精度可选**：省电（50 米）/ 平衡（15 米）/ 高精度（10 米）
- 后台保活自检页，逐项检查权限并一键跳转系统设置

### 🚶 计步（不需要任何 Key）
- 读手机硬件计步芯片，**和微信运动同源**
- 不用 GPS、不额外耗电

---

## 快速开始

### 环境要求

| 工具 | 版本 |
|---|---|
| Flutter | 3.44+（开发用 3.47.7） |
| Dart | 3.12+ |
| Android SDK | platforms 35 / 36 / **37** |
| JDK | 17 |

> **为什么需要 SDK 37**：`receive_sharing_intent` 要求 `compileSdk 37`。
> 但 AGP 9.1.0 官方只声明支持到 36，所以 `android/gradle.properties` 里有一行
> `android.suppressUnsupportedCompileSdk=37` 来放行。

### 跑起来

```bash
flutter pub get
flutter run
```

首次构建会自动下载依赖，高德地图 SDK 从 maven 拉取。

---

## 配置（重要）

### 核心功能**不需要任何配置**

收集箱、AI 整理、日程表、计步——装完就能用。

要让 **AI 整理**真正工作，需要一个 DeepSeek API Key，在 **App 内的设置页**填写，
它会加密存在手机本地（EncryptedSharedPreferences），**不会进代码、不会进版本库**。

### 高德地图 Key（只有轨迹功能需要）

轨迹功能需要高德地图底图，得自己申请一个 Key。

> **不配也能用**：其他功能全部正常，只有轨迹页的地图显示不出来。

**申请步骤：**

1. 去 <https://lbs.amap.com/> 注册并实名认证
2. 控制台 → 应用管理 → 我的应用 → 创建新应用
3. 添加 Key，服务平台选 **Android 平台**
4. 填两项：
   - **PackageName**：`com.simple.lifelog`（或你改成的包名）
   - **发布版安全码 SHA1**：用下面的命令取

```bash
# 取调试签名的 SHA1
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android
```

**配置方式**：在 `android/local.properties` 里加一行（这个文件已被 gitignore，不会提交）：

```properties
AMAP_KEY=你的高德Key
```

Key 由 `android/app/build.gradle.kts` 注入到 `AndroidManifest.xml` 的 `${AMAP_KEY}` 占位符。

> ⚠️ 换成正式签名（出 release 版）后 SHA1 会变，需要重新申请一个 Key。

---

## 项目结构

```
lib/
├── main.dart                 入口：初始化前台服务、缓存图片根目录
├── app.dart                  MaterialApp + 主题 + 路由 + 启动后台服务
│
├── core/                     跨模块公共设施
│   ├── constants/            全局常量（模型名、存储键名）
│   ├── theme/                Material 3 主题
│   ├── router/               路由表 + 底部四 Tab 外壳
│   └── utils/
│       ├── coordinate.dart   WGS84 ⇄ GCJ-02 坐标转换 + 距离计算
│       └── date_utils.dart   时间格式化
│
├── data/                     全局数据层
│   ├── db/
│   │   ├── app_database.dart Drift 主库 + 迁移
│   │   ├── tables/           八张表的定义
│   │   └── daos/             每个模块的 SQL 操作
│   └── services/
│       ├── deepseek_service.dart     DeepSeek API 客户端（含多模态）
│       ├── media_storage.dart        图片落盘
│       ├── secure_settings.dart      密钥加密存储
│       └── share_intent_service.dart 接收系统分享
│
├── features/                 按业务模块切分，每个模块自包含四层
│   ├── inbox/                收集箱
│   ├── ai_organize/          AI 整理
│   ├── schedule/             日程表
│   ├── track/                定位轨迹
│   ├── steps/                计步
│   └── settings/             设置
│
└── shared/widgets/           通用 UI 组件

android/app/src/main/kotlin/com/simple/lifelog/
└── amap/                     高德地图的 PlatformView 封装
    ├── AmapPlatformView.kt   地图视图（画轨迹线、起终点标记）
    └── AmapViewFactory.kt    注册给 Flutter
```

**分层规矩**（改代码时请遵守）：

1. UI 只跟 Provider 说话，不直接碰 Repository，更不碰 DAO
2. 业务规则只写在 Repository 层

---

## 技术栈

| 类别 | 用的什么 |
|---|---|
| 框架 | Flutter 3.47.7 / Dart 3.13.5 / Kotlin 2.4.0 |
| 状态管理 | Riverpod 3.4.3 |
| 路由 | go_router 18.0.2 |
| 数据库 | Drift 2.35.2（SQLite） |
| 网络 | Dio 5.11.1 |
| 定位 | geolocator 14.1.1 |
| 保活 | flutter_foreground_task 11.0.3 |
| 计步 | pedometer 4.2.0 |
| 密钥存储 | flutter_secure_storage 11.2.0 |
| 地图 | 高德 Android SDK 10.0.600（自封装 PlatformView） |
| AI | DeepSeek API（模型 `deepseek-flash`） |

**为什么高德地图自己封装 PlatformView，而不是用现成的 Flutter 插件**：
官方 `amap_flutter_map` 2022 年起停更，在 AGP 8+ / 新 Flutter 上编译不过。
自己包一层只用了「显示地图 + 画线 + 移动镜头」三个能力，约 300 行 Kotlin，不受插件停更影响。

---

## 数据库

`schemaVersion = 3`，八张表：

| 表 | 作用 |
|---|---|
| `inbox_items` | 收集箱条目 |
| `inbox_item_revisions` | 条目变更历史 |
| `schedules` | 日程 |
| `ai_runs` | 每次 AI 整理的记录（含原始返回，便于排查） |
| `track_sessions` | 轨迹会话 |
| `track_points` | 轨迹点（同时存 WGS84 和 GCJ-02 两套坐标） |
| `daily_steps` | 每日步数 |
| `app_settings` | 非敏感配置的键值对 |

更多架构细节见 [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)，
可视化蓝图见 [`docs/blueprint.html`](docs/blueprint.html)（浏览器打开）。

---

## 已知限制

- **计步在 App 未打开时不计数**。硬件芯片只报「开机以来总步数」，App 重新打开会把这段补上——建议每天打开一次 App。
- **AI 整理的提炼/拆分效果依赖模型**，prompt 不一定 100% 被遵守。
- **轨迹会话不会自动跨天切分**，全天记录需要每天点一次「开始记录」。
- **`pedometer` 插件用了旧式 Kotlin Gradle Plugin**。目前只是构建警告，未来 Flutter 版本会变成构建失败，届时需升级或自封装。
- 只做了 Android，iOS 未适配。

---

## 踩过的坑（备查）

| 坑 | 解决 |
|---|---|
| Android SDK 37 官方包的 `ApiLevel` 写成了浮点 `37.0`，构建报找不到 `android-37` | 改成整数 `37` |
| AGP 9.1.0 不支持 compileSdk 37 | `gradle.properties` 加 `android.suppressUnsupportedCompileSdk=37` |
| `riverpod_generator` 解析不了 Drift 生成的行类 | 涉及 Drift 行类的 Provider 全部手写 |
| 返回 `const []` 导致 `sort()` 崩 `Unsupported operation` | 返回 `<T>[]` |
| 高德 SDK 地图只有灰网格且不报错 | 必须先调 `updatePrivacyShow` + `updatePrivacyAgree` |
| 高德地图上轨迹偏 570 米 | WGS84 → GCJ-02 转换 |
| App 退后台轨迹就断 | 前台服务 + `foregroundServiceType="location"` |

---

## License

MIT
