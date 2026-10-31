plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "in.agritrace.agritrace"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications (M12 reminders) needs core library desugaring for its java.time scheduling.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // shortcut: application id is the flutter create default (in.agritrace.agritrace); fix the final Play id
        //   before the first store upload (M13), it cannot change afterwards.
        applicationId = "in.agritrace.agritrace"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // DECISION D-002: Android 8+ (API 26) and iOS 13+ only.
        //   ADV: one modern baseline for camera, WorkManager and TLS; the pilot phones are Android 8 or newer.
        //   COMPROMISE: Android 7 and older phones cannot install the app.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // M13 size (PLAN §13 D1): R8 minify and resource shrinking are already on for release, set by the Flutter
            //   Gradle plugin (FlutterPlugin.kt, unless built with --no-shrink); plugins ship their own consumer
            //   ProGuard rules. The AAB splits per ABI, density and language by default (bundle { abi.enableSplit }).
            //   Measured by tool/size_check.sh (docs/agents/reports/M13.md).
            // shortcut: release is signed with the debug keys so `flutter run --release` works; M13 adds the
            //   upload keystore from CI secrets before any build leaves the team.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Backports java.time for flutter_local_notifications on API 26+ (M12). GPL-2.0 with the Classpath Exception,
    // accepted for this library only by the D-018 amendment of 2026-10-31 (docs/LIBRARIES.md row).
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
