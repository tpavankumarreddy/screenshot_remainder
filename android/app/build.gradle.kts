plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Ensure Flutter plugin is applied last
}

android {
    namespace = "com.example.screenshot_remainder"
    compileSdk = 34 // Explicit compile SDK version

    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.screenshot_remainder"
        minSdk = 21 // Adjust based on your plugin requirements
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// ✅ Move dependencies OUTSIDE the android block
dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.24")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}

// ✅ Move flutter block OUTSIDE the android block
flutter {
    source = "../.."
}
