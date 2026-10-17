# Lifelog

一个纯本地优先的安卓 App：**随手收集 → AI 整理成日程 → AI 助手直接操作 App → 全天记录轨迹与步数**。

所有业务数据保存在手机本地 SQLite；AI 聊天记录、长期记忆、知识库保存在本地 JSON。
没有自建服务器、不上传云端，AI 与地图使用你自己配置的第三方 API。

当前版本：**0.2.0 (versionCode 2003)**

---

## 功能

### 📥 收集箱

- 文字、截图、图片随手记
- **一条记录可以放多张图片**：新建时多选，编辑时可继续加图或单独移除某张
- **从系统分享菜单直接分享进来**（微信、相册、浏览器都行），一次分享多张图会归为一条记录
- 每条都有完整的**变更历史**：像聊天记录一样，能看到什么时候改了什么
- 归档不是删除：右上角可以查看「已归档」，随时取消归档
- 三个点菜单里可以「重新整理」或「不再整理」某一条

### ✨ AI 整理

- 支持多个 AI 供应商，不再绑定单一模型：
  - DeepSeek、OpenAI、Anthropic Claude、Google Gemini
  - Kimi（Moonshot）、智谱 GLM、通义千问（DashScope）
  - 硅基流动、OpenRouter、豆包（火山方舟）、Ollama、自定义 OpenAI 兼容接口
- 每个供应商独立保存 Base URL、主模型、视觉模型和 API Key
- **自动提炼**：啰嗦的口语 → 简短的标题
- **自动拆分**：「早上买豆浆，晚上喝八宝粥」→ 拆成两条独立日程
- **两阶段流程**：先生成草案给你看，确认之后才写进日程表
- 重新整理会替换这些条目之前由 AI 生成的旧日程，避免新旧两份并存
- 编辑过的条目会自动退回「待整理」，下次整理能带上它
- 带图片时整次整理只发**一次**请求给视觉模型（文字和图片一起发），
  不会拆成“文字给主模型、图片给视觉模型”的两次请求；视觉模型留空则复用主模型

### 🤖 AI 助手（0.2.0 新增）

底部导航正中间的 **AI** Tab，不只是一个聊天框，它能直接操作 App：

- 聊天、配置**名字 / 头像 / 人设 / 说话风格**
- **长期记忆**：可以在设置里手动添加，也可以聊天时说“记住……”让 AI 写入
- **知识库**：添加习惯、项目背景、常用信息，聊天时会作为上下文
- 聊天记录、记忆、知识库全部保存在手机本地
- 可以帮用户：
  - 打开任意页面、带用户去某个功能并给出提示
  - 往收集箱写笔记
  - 创建日程（自动带提醒）
  - 查询今天步数、轨迹、未来日程、收集箱内容
  - 搜索收集箱和日程
  - 开始/停止轨迹记录、切换轨迹精度、打开系统定位设置
  - 标记日程完成、打开某条日程的编辑页
  - 记住/忘记长期信息、写入知识库

> AI 使用统一的 JSON 动作协议，不依赖各厂商原生 function calling，
> 因此 DeepSeek / Claude / Gemini / OpenAI 兼容接口都能用同一套能力。
> 如果所选模型不擅长严格输出 JSON，可能只聊天不执行操作，换更强的模型即可。

### 📅 日程

- 周视图，左侧时间轴当坐标
- 日程按真实时刻定位、按持续时长决定高度，不是课表那种等高格子
- 时间重叠的日程自动并排摆开
- 双击气泡展开，查看这条日程来自哪条原始笔记
- 手动新建 / 编辑 / 删除
- 支持跨夜日程（例如 23:00–次日 01:00），保存前会校验结束时间
- **日程提醒**：开始前 10 分钟通知；全天日程当天 09:00 提醒；点通知直接打开对应日程
- 日程变更会自动同步提醒：新建、编辑、删除、标记完成、AI 整理写入都会自动处理
- 重启手机或应用更新后，定时通知会自动恢复
- 整理记录可以点开查看完整 Prompt、模型原始返回和来源条目
- 轨迹历史可以点开查看每一次会话的详情和轨迹地图

### 🗺 定位轨迹（需要自备高德 Key）

- 全天记录 GPS 轨迹，画在高德地图上
- 前台服务保活，锁屏、切后台都能继续记录
- WGS84 → GCJ-02 坐标转换（不转的话轨迹会偏 500 多米）
- 三档精度可选：省电（50 米）/ 平衡（15 米）/ 高精度（10 米）
- 后台保活自检页，逐项检查权限并一键跳转系统设置
- 今日统计按会话分组计算，过滤 GPS 漂移和异常跳点
- App 被系统杀掉后，下次启动会自动收尾残留的 recording 会话
- 地图 `+ / −` 缩放控件已修复；不在轨迹 Tab 时不会创建地图，减少显存占用

### 🚶 计步（不需要任何 Key）

- 读手机硬件计步芯片，和微信运动同源
- 不用 GPS、不额外耗电
- 传感器事件串行处理，避免异步回调导致步数偏低
- 当天数据先放内存、节流写库，不再每走一步读写一次数据库
- 跨天时按时间比例拆给昨天和今天，替代原来“12 小时内全算今天”的粗糙逻辑

---

## 快速开始

### 环境要求

| 工具        | 版本                       |
| ----------- | -------------------------- |
| Flutter     | 3.44+（开发用 3.47.7）     |
| Dart        | 3.12+                      |
| Android SDK | platforms 35 / 36 / **37** |
| JDK         | 17                         |

> 为什么需要 SDK 37：`receive_sharing_intent` 要求 `compileSdk 37`。
> AGP 9.1.0 官方只声明支持到 36，所以 `android/gradle.properties` 里有一行
> `android.suppressUnsupportedCompileSdk=37` 来放行。

### 跑起来

```bash
flutter pub get
flutter run
```

首次构建会自动下载依赖，高德地图 SDK 从 maven 拉取。

---

## 配置

### AI 供应商（必须配置一个 Key）

在 App 内 **设置 → AI 模型** 里选择供应商，填写 API Key、Base URL、模型名称。

- 每个供应商的 Key、Base URL、模型独立保存
- 旧版 DeepSeek Key 会自动迁移
- API Key 加密保存在手机本地，不进代码、不进版本库
- 如果整理带图片，需要选择支持视觉的模型，或单独填写「视觉模型」
- 纯文本整理使用主模型；任意一条带图时整次整理使用视觉模型

### 高德地图 Key（只有轨迹功能需要）

1. 去 <https://lbs.amap.com/> 注册并实名认证
2. 控制台 → 应用管理 → 我的应用 → 创建新应用
3. 添加 Key，服务平台选 **Android 平台**
4. 填写 **PackageName**：`com.simple.lifelog`
5. 填写 **发布版安全码 SHA1**：

```bash
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android
```

在 `android/local.properties` 里加一行（该文件已被 gitignore）：

```properties
AMAP_KEY=你的高德Key
```

也可以在 App 设置页里填写高德 Key（运行时注入）。
换成正式签名后 SHA1 会变，需要重新申请 Key。

### 正式发布签名

`android/app/build.gradle.kts` 会读取 `android/key.properties`：

```properties
storeFile=lifelog-release.jks
storePassword=你的密码
keyAlias=lifelog
keyPassword=你的密码
```

参考 `android/key.properties.example`。未配置时 release 构建会退回 debug 签名并打印警告，**这种包不可分发**。

### 通知与精确闹钟

日程提醒需要通知权限。Android 12+ 如果没有允许「闹钟和提醒」，
提醒可能延迟几分钟；代码会自动退回非精确模式，不会跳过提醒。

### 升级注意

- 覆盖安装前请确认新包的 `versionCode` 不低于手机上的版本（当前为 2003）
- 本项目是纯本地应用，卸载会清空本地数据；升级时请覆盖安装，不要卸载
- 备份规则已排除 `flutter_secure_storage` 的 SharedPreferences，
  避免换机恢复后 API Key 变成无法解密的密文

---

## 项目结构

```
lib/
├── main.dart                 入口：初始化前台服务、缓存图片根目录
├── app.dart                  MaterialApp + 主题 + 路由 + 启动后台服务
│
├── core/
│   ├── constants/            全局常量（存储键名等）
│   ├── theme/                Material 3 主题
│   ├── router/               路由表 + 底部五 Tab 外壳
│   └── utils/
│       ├── coordinate.dart   WGS84 ⇄ GCJ-02 坐标转换 + 距离计算
│       └── date_utils.dart   时间格式化
│
├── data/
│   ├── db/
│   │   ├── app_database.dart Drift 主库 + 迁移
│   │   ├── tables/           表定义
│   │   └── daos/             每个模块的 SQL 操作
│   └── services/
│       ├── ai/
│       │   ├── ai_service.dart           统一 AI 接口（OpenAI / Claude / Gemini）
│       │   └── ai_provider_presets.dart  供应商预设
│       ├── reminder_service.dart         日程提醒（监听日程表自动同步）
│       ├── media_storage.dart            图片落盘、多图路径编解码
│       ├── secure_settings.dart          密钥加密存储
│       └── share_intent_service.dart     接收系统分享
│
├── features/
│   ├── inbox/                收集箱
│   ├── ai_organize/          AI 整理
│   ├── ai_chat/              AI 助手（聊天、动作协议、人设、记忆、知识库）
│   ├── schedule/             日程表 + 提醒
│   ├── track/                定位轨迹
│   ├── steps/                计步
│   └── settings/             设置（AI 供应商、高德、轨迹精度、提醒）
│
└── shared/widgets/           通用 UI 组件

android/app/src/main/kotlin/com/simple/lifelog/
└── amap/                     高德地图 PlatformView 封装
```

分层规矩：

1. UI 只跟 Provider 说话，不直接碰 Repository，更不碰 DAO
2. 业务规则只写在 Repository 层

---

## 技术栈

| 类别     | 用的什么                                                     |
| -------- | ------------------------------------------------------------ |
| 框架     | Flutter 3.47.7 / Dart 3.13.5 / Kotlin 2.4.0                  |
| 状态管理 | Riverpod 3.4.3                                               |
| 路由     | go_router 18.0.2                                             |
| 数据库   | Drift 2.35.2（SQLite）                                       |
| 网络     | Dio 5.11.1                                                   |
| 定位     | geolocator 14.1.1                                            |
| 保活     | flutter_foreground_task 11.0.3                               |
| 计步     | pedometer 4.2.0                                              |
| 密钥存储 | flutter_secure_storage 11.2.0                                |
| 本地通知 | flutter_local_notifications 22.3.2 + timezone / flutter_timezone |
| 地图     | 高德 Android SDK 10.0.600（自封装 PlatformView）             |
| AI       | OpenAI 兼容 / Anthropic / Google Gemini 多供应商             |

高德地图自己封装 PlatformView，而不是用停更的 Flutter 插件；
只用了「显示地图 + 画线 + 移动镜头」三个能力，长期更稳。

---

## 数据与隐私

- 业务数据：SQLite / Drift，本地保存
- 收集箱图片：应用私有目录，数据库里只存相对路径
- 多图：`inbox_items.image_path` 存单路径或 JSON 数组（兼容旧数据）
- AI 聊天记录、长期记忆、知识库：应用私有目录 JSON 文件
- API Key：`flutter_secure_storage` 加密存储
- 所有数据都在手机上，没有云端同步

---

## v0.2.0 更新记录

### 新增

- AI 助手：底部中央 AI Tab，人设、头像、名字、长期记忆、知识库
- AI 助手可以直接操作 App：导航、建笔记、建日程、查数据、搜索、
  开始/停止轨迹、切换精度、打开定位设置、完成/打开日程、记住/忘记、写知识库
- 多 AI 供应商支持（DeepSeek / OpenAI / Claude / Gemini / Kimi / 智谱 /
  通义千问 / 硅基流动 / OpenRouter / 豆包 / Ollama / 自定义）
- 收集箱单条多图片；分享多图归为一条
- 日程提醒通知（开始前 10 分钟 / 全天 09:00）
- AI 整理记录详情查看、轨迹历史会话详情查看

### 修复

- 换图/删除条目时旧图先删后存导致永久丢图
- 重新整理后旧日程不消失、新旧两份并存
- 高德地图初始化顺序错误、App 内 Key 不生效、`+ / −` 被提示层遮挡
- 今日轨迹里程跨会话相加、GPS 漂移制造虚假里程
- 轨迹会话异常退出后残留 recording、启动失败后前台服务无法停止
- 日程结束时间早于开始时间、跨周日程整条消失
- AI 整理落库非事务、重复日程、单条草案格式错误导致整批失败
- 计步异步竞态、跨天归属错误、每步读写数据库
- 分享导入失败不重置、多图分享不可用
- 地图不在轨迹 Tab 时仍常驻占用大量显存
- 整理记录把完整 prompt/原始返回全部加载进内存

### 工程

- release 签名配置化（`key.properties`）
- 备份规则排除 secure storage
- 新增单元测试：草案解析、坐标转换、多图路径编解码、AI 动作协议

---

## 已知限制

- AI 助手使用 JSON 动作协议，模型能力不足时可能只聊天不执行操作
- AI 目前不能直接删除或编辑已有条目/日程，会帮你打开编辑页手动修改
- 轨迹记录仍需每天手动开始，未做自动跨天切分；App 被划掉后采集可能中断，
  下次启动会自动收尾会话并标记 interrupted
- AI 图片请求有单张/总量上限，超限图片会跳过，尚未做本地压缩
- 日程提醒文案根据日程标题/时间/地点生成，暂未使用 AI 个性化生成
- `pedometer` 插件仍使用旧式 Kotlin Gradle Plugin，未来 Flutter 版本可能构建失败
- 只做了 Android，iOS 未适配

---

## License

MIT
