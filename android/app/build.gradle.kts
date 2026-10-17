import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

/// 读 local.properties。
///
/// 这个文件不进版本库（见 .gitignore），所以密钥、签名路径这类东西都放这儿，
/// 通过 manifestPlaceholders 或 buildConfigField 注入到代码里，不硬编码。
val localProperties = Properties().apply {
    val file = rootProject.file("local.properties")
    if (file.exists()) {
        file.inputStream().use { load(it) }
    }
}

/// 正式签名配置。android/key.properties 不进版本库（见 .gitignore）。
///
/// 没配置时 release 仍然能构建（继续用 debug 签名），但**绝不能分发**：
/// debug keystore 是公开的，任何人都能伪造同签名升级包。
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) {
        file.inputStream().use { load(it) }
    }
}
val releaseStoreFile = keystoreProperties
    .getProperty("storeFile")
    ?.let { rootProject.file(it) }
val hasReleaseSigning = releaseStoreFile?.exists() == true

android {
    namespace = "com.simple.lifelog"
    // 固定为 37（而不是 flutter.compileSdkVersion，默认是 36）：
    // receive_sharing_intent 1.9.0 编译时需要 android-37 平台。
    // AGP 9.1.0 官方只声明支持到 36，所以还要在 gradle.properties 里
    // 打开 android.suppressUnsupportedCompileSdk 才会放行。
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications 的定时通知需要 desugaring
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        multiDexEnabled = true
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.simple.lifelog"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 把高德 Key 注入 AndroidManifest 里的 ${AMAP_KEY} 占位符。
        // 没在 local.properties 里配的话是空字符串 —— 地图显示不出来，
        // 但不影响其它功能（收集箱 / AI 整理 / 日程都能正常用）。
        manifestPlaceholders["AMAP_KEY"] =
            localProperties.getProperty("AMAP_KEY") ?: ""
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = releaseStoreFile
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // 配了 key.properties 就用正式签名；否则退回 debug，仅方便本地跑
            // `flutter run --release`，这种包不可对外分发。
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "⚠️ 未配置 android/key.properties：release 包正在使用 debug 签名，" +
                        "仅限本地测试，请勿分发。参考 android/key.properties.example。"
                )
                signingConfigs.getByName("debug")
            }

            // 显式打开混淆，并挂上我们的 keep 规则。
            //
            // 注意：不能省掉 proguard-rules.pro —— 高德的 .so 原生库会按
            // 原始类名做 JNI 反射查找，不 keep 的话 release 版一进地图就闪退
            // （JNI DETECTED ERROR: java_class == null）。详见该文件顶部注释。
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    // flutter_local_notifications 的定时通知需要 Java 8+ API desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // 高德地图 SDK。
    // 刻意不走 amap_flutter_map 那类 Flutter 插件 —— 官方插件 2022 年起停更，
    // 在 AGP 8+ / 新 Flutter 上编译不过。自己用 PlatformView 包一层，
    // 只用到「显示地图 + 画线 + 移动镜头」三个能力，长期最稳。
    implementation("com.amap.api:3dmap:10.0.600")
}

flutter {
    source = "../.."
}
