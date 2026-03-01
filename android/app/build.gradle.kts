
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    throw GradleException("key.properties file not found at ${keystorePropertiesFile.absolutePath}")
}


android {
    namespace = "com.undergradproj.roam_and_report"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.undergradproj.roam_and_report"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
    create("release") {
        val storeFilePath = keystoreProperties["storeFile"]?.toString()
        val storePasswordValue = keystoreProperties["storePassword"]?.toString()
        val keyAliasValue = keystoreProperties["keyAlias"]?.toString()
        val keyPasswordValue = keystoreProperties["keyPassword"]?.toString()

        require(
            storeFilePath != null &&
            storePasswordValue != null &&
            keyAliasValue != null &&
            keyPasswordValue != null
        ) { "Missing values in key.properties" }

        storeFile = rootProject.file("$storeFilePath")
        storePassword = storePasswordValue
        keyAlias = keyAliasValue
        keyPassword = keyPasswordValue
    }
}

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
