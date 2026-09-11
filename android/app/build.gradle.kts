//plugins {
//    id("com.android.application")
//    id("org.jetbrains.kotlin.android")
//    id("dev.flutter.flutter-gradle-plugin")
//}
//
//android {
//    namespace = "com.thevaults.customer"
//    compileSdk = flutter.compileSdkVersion
//    ndkVersion = flutter.ndkVersion
//
//    compileOptions {
//        sourceCompatibility = JavaVersion.VERSION_17
//        targetCompatibility = JavaVersion.VERSION_17
//    }
//
////    kotlinOptions {
////        jvmTarget = JavaVersion.VERSION_17.toString()
////    }
//
//    defaultConfig {
//        applicationId = "com.thevaults.customer"
//        minSdk = flutter.minSdkVersion
//        targetSdk = flutter.targetSdkVersion
//        versionCode = flutter.versionCode
//        versionName = flutter.versionName
//    }
//
//    flavorDimensions += "environment"
//
//    productFlavors {
//        create("dev") {
//            dimension = "environment"
//            applicationIdSuffix = ".dev"
//            versionNameSuffix = "-dev"
//            resValue("string", "app_name", "Vaults DEV")
//        }
//        create("staging") {
//            dimension = "environment"
//            applicationIdSuffix = ".staging"
//            versionNameSuffix = "-staging"
//            resValue("string", "app_name", "Vaults STG")
//        }
//        create("prod") {
//            dimension = "environment"
//            resValue("string", "app_name", "Vaults")
//        }
//    }
//
//    buildTypes {
//        release {
//            signingConfig = signingConfigs.getByName("debug")
//        }
//    }
//    kotlin {
//        compilerOptions {
//            jvmTarget.set(JvmTarget.JVM_17)
//        }
//    }
//}
//
//
//
//flutter {
//    source = "../.."
//}
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("keystore.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.thevaults.customer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.thevaults.customer"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Vaults DEV")
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "Vaults STG")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "Vaults")
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}