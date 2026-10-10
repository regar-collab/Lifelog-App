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

android {
    namespace = "com.simple.lifelog"
    // 固定为 37（而不是 flutter.compileSdkVersion，默认是 36）：
    // receive_sharing_intent 1.9.0 编译时需要 android-37 平台。
    // AGP 9.1.0 官方只声明支持到 36，所以还要在 gradle.properties 里
    // 打开 android.suppressUnsupportedCompileSdk 才会放行。
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
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

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    // 高德地图 SDK。
    // 刻意不走 amap_flutter_map 那类 Flutter 插件 —— 官方插件 2022 年起停更，
    // 在 AGP 8+ / 新 Flutter 上编译不过。自己用 PlatformView 包一层，
    // 只用到「显示地图 + 画线 + 移动镜头」三个能力，长期最稳。
    implementation("com.amap.api:3dmap:10.0.600")
}

flutter {
    source = "../.."
}
