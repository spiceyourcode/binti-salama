import java.util.Properties
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.bintisalama.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Binti Salama - Crisis response app for Kenya
        applicationId = "com.bintisalama.app"
        // Minimum SDK 23 (Android 6.0) for runtime permissions and SMS features
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
        
        // Enable multidex for large app
        multiDexEnabled = true

                // Load Google Maps API Key from local.properties or project property
        val localProperties = Properties()
        val localPropertiesFile = rootProject.file("local.properties")

        if (localPropertiesFile.exists()) {
            localPropertiesFile.reader().use { localProperties.load(it) }
        }

        // Try project property, then local.properties, else ""
        val projectKey = project.findProperty("GOOGLE_MAPS_API_KEY") as String?
        val localKey = localProperties.getProperty("GOOGLE_MAPS_API_KEY")

        val googleMapsApiKey = projectKey ?: localKey ?: ""

        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = googleMapsApiKey

    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring for Java 8+ APIs on older Android versions
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
