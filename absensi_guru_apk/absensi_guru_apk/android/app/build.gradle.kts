plugins {
    id "com.android.application"
    id "kotlin-android"
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services"  // Firebase — requires google-services.json
}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader("UTF-8") { reader ->
        localProperties.load(reader)
    }
}

def flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
def flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.absensi.guru"
    compileSdk = 34
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.absensi.guru"
        minSdk = 23  // Required for firebase_messaging 15.x
        targetSdk = 34
        versionCode = flutterVersionCode.toInteger()
        versionName = flutterVersionName
    }

    signingConfigs {
        release {
            keyAlias = keystoreProperties["keyAlias"]
            keyPassword = keystoreProperties["keyPassword"]
            storeFile = keystoreProperties["storeFile"] ? file(keystoreProperties["storeFile"]) : null
            storePassword = keystoreProperties["storePassword"]
        }
    }

    buildTypes {
        release {
            // Untuk production build, gunakan signingConfigs.release.
            // Buat keystore via: `keytool -genkey -v -keystore ~/keystore.jks ...`
            // dan letakkan path-nya di android/key.properties (jangan commit!).
            signingConfig = keystoreProperties["storeFile"] != null
                ? signingConfigs.release
                : signingConfigs.debug

            minifyEnabled = true
            shrinkResources = true
            proguardFiles getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BoM — version diturunkan dari google-services.json
    implementation platform("com.google.firebase:firebase-bom:33.4.0")
    implementation "com.google.firebase:firebase-messaging"
}
