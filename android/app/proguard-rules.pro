# ══════════════════════════════════════════════════════════
#  R8 / ProGuard 规则
# ══════════════════════════════════════════════════════════
#
# 这里的规则不是「优化」，是「保命」。
#
# 为什么高德必须 keep：
#   高德的 .so 原生库（libAMapOpenMap.so 等）在渲染地图时，会用 JNI
#   按**原始类名**反射查找 Java 类。R8 一旦把这些类名混淆成 ej / je0
#   这种，原生库就找不到类，直接 abort ——
#   表现就是「一进轨迹页就闪退」，而且 logcat 里只有一行
#   `JNI DETECTED ERROR: java_class == null`，非常难查。
#
# 症状复现路径：
#   release 版 → 打开轨迹 Tab → MapView 的 GLSurfaceView 回调
#   → System.loadLibrary → JNI 找不到混淆后的类 → SIGABRT

# ── 高德地图 SDK ──────────────────────────────────────────
-keep class com.amap.api.** { *; }
-keep class com.autonavi.** { *; }
-keep class com.loc.** { *; }
-keep class com.amap.api.col.** { *; }

# 原生库通过 JNI 反查的那些成员也别动
-keepclassmembers class com.amap.api.** {
    native <methods>;
    *** get*();
}
-keepclasseswithmembernames class com.amap.api.** {
    native <methods>;
}

-dontwarn com.amap.api.**
-dontwarn com.autonavi.**
-dontwarn com.loc.**

# ── 前台服务插件 ──────────────────────────────────────────
# 它的 Service 是在 AndroidManifest 里按全限定名注册的，
# 被混淆改名的话系统就找不到这个 Service 了。
-keep class com.pravera.flutter_foreground_task.** { *; }

# ── 计步插件 ──────────────────────────────────────────────
-keep class com.example.pedometer.** { *; }

# ── 分享接收插件 ──────────────────────────────────────────
-keep class com.kasem.receive_sharing_intent.** { *; }

# ── Android 原生组件（Service / Activity / Receiver）──────
# 这些类名写在 AndroidManifest 里，被混淆就找不到。
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.Application

# ── 保留行号，崩溃栈才能定位到源码 ────────────────────────
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
