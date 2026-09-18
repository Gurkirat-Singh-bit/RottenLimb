plugins {
    id("com.android.application")
}

android {
    namespace = "local.reservation.instagram"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.instagram.android"
        minSdk = 26
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }
}
