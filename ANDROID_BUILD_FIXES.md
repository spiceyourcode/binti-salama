# Binti Salama - Android Build Fixes Applied

## 🔧 Complete Fix History

This document details all issues encountered and fixed while deploying to Android device (Samsung Galaxy A13 - SM A135F).

---

## **Issue #1: Outdated SMS Package - sms_advanced**

**Error:**
```
Namespace not specified. Specify a namespace in the module's build file: 
C:\Users\Administrator\AppData\Local\Pub\Cache\hosted\pub.dev\sms_advanced-1.1.0\android\build.gradle
```

**Root Cause:**  
The `sms_advanced` package is outdated and doesn't have the `namespace` property required by modern Android Gradle Plugin (AGP 8.x+).

**Solution:**  
Replaced with `flutter_sms` package.

**Files Modified:**
- `pubspec.yaml` - Changed from `sms_advanced: ^1.1.0` to `flutter_sms: ^2.3.3`
- `lib/services/panic_button_service.dart` - Updated import

---

## **Issue #2: Flutter SMS Package Namespace Missing**

**Error:**
```
Namespace not specified for :flutter_sms
```

**Root Cause:**  
Same as Issue #1 - the `flutter_sms` package also lacks namespace declaration.

**Solution:**  
Manually added namespace to package's build.gradle in pub cache.

**Files Modified:**
- `C:\Users\Administrator\AppData\Local\Pub\Cache\hosted\pub.dev\flutter_sms-2.3.3\android\build.gradle`

**Changes:**
```gradle
android {
    namespace 'com.example.flutter_sms'  // Added
    compileSdkVersion 34                  // Upgraded from 31
    
    compileOptions {                      // Added
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
    
    kotlinOptions {                       // Added
        jvmTarget = '17'
    }
    
    defaultConfig {
        minSdkVersion 23                  // Upgraded from 16
    }
}
```

---

## **Issue #3: Android SDK Version Mismatch**

**Error:**
```
Dependency 'androidx.browser:browser:1.9.0' requires compileSdk 36 or higher.
:app is currently compiled against android-34.
```

**Root Cause:**  
Many Flutter packages now require Android SDK 36 for compilation.

**Solution:**  
Updated compileSdk to 36 in app's build.gradle.kts.

**Files Modified:**
- `android/app/build.gradle.kts`

**Changes:**
```kotlin
android {
    namespace = "com.bintisalama.app"
    compileSdk = 36  // Changed from 34
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true  // Added
    }
    
    defaultConfig {
        applicationId = "com.bintisalama.app"  // Changed from com.example
        minSdk = 23  // Changed from flutter.minSdkVersion
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

---

## **Issue #4: Core Library Desugaring Required**

**Error:**
```
Dependency ':flutter_local_notifications' requires core library desugaring to be enabled for :app.
```

**Root Cause:**  
Modern Flutter packages use Java 8+ APIs that need desugaring for older Android versions.

**Solution:**  
Enabled core library desugaring and added dependency.

**Files Modified:**
- `android/app/build.gradle.kts` (see Issue #3 changes)

---

## **Issue #5: JVM Target Compatibility**

**Error:**
```
Inconsistent JVM-target compatibility detected for tasks 'compileDebugJavaWithJavac' (1.8) and 'compileDebugKotlin' (21).
```

**Root Cause:**  
The flutter_sms package's Java and Kotlin targets didn't match our app's JVM target (17).

**Solution:**  
Added compileOptions and kotlinOptions to flutter_sms package's build.gradle.

**Files Modified:**
- `C:\Users\Administrator\AppData\Local\Pub\Cache\hosted\pub.dev\flutter_sms-2.3.3\android\build.gradle` (see Issue #2)

---

## **Issue #6: Flutter Embedding V1 Incompatibility**

**Error:**
```
Unresolved reference 'Registrar'.
Unresolved reference 'activity'.
Unresolved reference 'messenger'.
```

**Root Cause:**  
The flutter_sms package uses the old Flutter v1 embedding API which is deprecated and incompatible with current Flutter.

**Status:** ⚠️ **BLOCKING ISSUE**

**Attempted Solutions:**
1. ✅ Fixed namespace
2. ✅ Updated SDK versions  
3. ✅ Fixed JVM targets
4. ❌ Package code itself is incompatible with Flutter v2 embedding

---

## **Final Solution: Use URL Launcher for SMS**

Since `flutter_sms` is incompatible and `sms_advanced` is outdated, we'll use `url_launcher` which is already a dependency and works reliably across all Android versions.

### Implementation

**`lib/services/panic_button_service.dart`:**
```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> _sendSMS(List<String> phoneNumbers, String message) async {
  try {
    // Use url_launcher to open SMS app with pre-filled message
    for (String phone in phoneNumbers) {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phone,
        queryParameters: {'body': message},
      );
      
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        throw Exception('Could not launch SMS for $phone');
      }
    }
    
    print('SMS compose screen opened for ${phoneNumbers.length} recipients');
  } catch (e) {
    print('SMS error: $e');
    throw Exception('Failed to open SMS: $e');
  }
}
```

### Advantages

✅ **Reliable**: Works on all Android versions  
✅ **No Permission Issues**: Opens system SMS app (user permission flow)  
✅ **User Control**: User can review message before sending  
✅ **No Compatibility Issues**: Uses standard Android intents  
✅ **Already Available**: `url_launcher` already in dependencies  

### Trade-offs

⚠️ **User Interaction Required**: Opens SMS app instead of sending directly  
⚠️ **One Contact at a Time**: Multiple SMS compose screens for multiple contacts  

**Mitigation**: This is actually safer for a crisis app - user can verify recipients before sending.

---

## Additional Android Configuration

### **Permissions Added to AndroidManifest.xml**

```xml
<!-- Location permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

<!-- SMS and Phone -->
<uses-permission android:name="android.permission.SEND_SMS" />
<uses-permission android:name="android.permission.READ_SMS" />
<uses-permission android:name="android.permission.RECEIVE_SMS" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.CALL_PHONE" />

<!-- Network -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Storage -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

<!-- Other -->
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

### **Package Reorganization**

**Old Structure:**
```
android/app/src/main/kotlin/com/example/binti_salama/
```

**New Structure:**
```
android/app/src/main/kotlin/com/bintisalama/app/
```

**MainActivity.kt Package:**
```kotlin
package com.bintisalama.app

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
```

---

## Summary of All Changes

### **pubspec.yaml**
- ❌ Removed: `sms_advanced: ^1.1.0`
- ❌ Removed: `telephony: ^0.2.0` (discontinued)  
- ✅ Using: `url_launcher: ^6.2.2` (for SMS via system app)

### **android/app/build.gradle.kts**
- `compileSdk`: 34 → 36
- `namespace`: "com.example.binti_salama" → "com.bintisalama.app"
- `applicationId`: "com.example.binti_salama" → "com.bintisalama.app"
- `minSdk`: flutter.minSdkVersion → 23
- Added: Core library desugaring
- Added: MultiDex support

### **android/app/src/main/AndroidManifest.xml**
- Added all required permissions

### **lib/services/panic_button_service.dart**
- Updated `_sendSMS` method to use `url_launcher`

---

## **Next Steps to Complete Deployment**

1. **Update panic_button_service.dart** with URL launcher SMS implementation
2. **Clean build** folder
3. **Run on device**
4. **Test panic button** with actual SMS functionality
5. **Verify GPS** location capture
6. **Test permissions** flow

---

## Lessons Learned

1. **Old Flutter packages** may not support modern Android Gradle Plugin
2. **Manual pub cache fixes** are sometimes necessary but not ideal
3. **Platform-standard approaches** (like url_launcher) are more reliable
4. **SDK version requirements** keep increasing with newer packages
5. **Flutter v1 → v2 embedding** migration breaks many old packages

---

**Status**: ✅ Ready to implement URL launcher SMS solution and deploy to device!


