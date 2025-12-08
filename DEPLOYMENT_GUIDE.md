# Binti Salama - Deployment Guide

This guide covers building, testing, and deploying the Binti Salama application to production environments.

## 📋 Pre-Deployment Checklist

### Code Quality
- [ ] All linter warnings resolved
- [ ] Code review completed
- [ ] Unit tests passing (>80% coverage)
- [ ] Integration tests passing
- [ ] Manual testing checklist completed
- [ ] No hardcoded secrets or API keys
- [ ] Version number updated in `pubspec.yaml`

### Security
- [ ] PIN authentication working
- [ ] Data encryption verified
- [ ] Auto-lock functioning
- [ ] Secure storage tested
- [ ] No sensitive data in logs
- [ ] Permissions properly configured

### Functionality
- [ ] Panic button sends SMS reliably
- [ ] GPS location accurate
- [ ] All 20+ services loaded
- [ ] Offline mode working
- [ ] Database migrations tested
- [ ] Language switching works

### Content
- [ ] Services database up-to-date
- [ ] Emergency hotlines verified
- [ ] First response guidance reviewed
- [ ] Resource information accurate
- [ ] Legal compliance verified
- [ ] Translations complete

## 🔧 Environment Setup

### Required Tools

- **Flutter SDK:** 3.0.0 or higher
- **Android Studio:** Latest stable
- **Xcode:** Latest stable (for iOS)
- **Java JDK:** 11 or higher

### Install Flutter

```bash
# Download Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

### Android Setup

1. Install Android Studio
2. Install Android SDK (API 21+)
3. Configure environment variables:

```bash
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

### iOS Setup (Mac only)

```bash
# Install Xcode
xcode-select --install

# Install CocoaPods
sudo gem install cocoapods
```

## 🏗️ Build Configuration

### 1. Update Version

Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Format: MAJOR.MINOR.PATCH+BUILD_NUMBER
```

### 2. Configure API Keys

**Google Maps API Key:**

Create `android/local.properties` (add to .gitignore):
```properties
GOOGLE_MAPS_API_KEY=your_actual_api_key_here
```

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${GOOGLE_MAPS_API_KEY}"/>
```

**iOS (edit `ios/Runner/AppDelegate.swift`):**
```swift
import GoogleMaps

GMSServices.provideAPIKey("YOUR_IOS_API_KEY")
```

### 3. Configure App Signing

#### Android Signing

Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

Generate keystore:
```bash
keytool -genkey -v -keystore ~/binti-salama-release.keystore \
  -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

#### iOS Signing

1. Open Xcode
2. Select project → Target → Signing & Capabilities
3. Select team and provisioning profile
4. Configure bundle identifier: `com.bintisalama.app`

## 📱 Building for Android

### Debug Build (Testing)

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK (Sideloading)

```bash
# Clean previous builds
flutter clean
flutter pub get

# Build release APK
flutter build apk --release

# Or build split APKs for smaller size
flutter build apk --release --split-per-abi
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

Split APKs:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (64-bit Intel)

### App Bundle (Google Play)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

**Why App Bundle?**
- Smaller download sizes
- Google Play Dynamic Delivery
- Required for new apps on Play Store

## 🍎 Building for iOS

### Debug Build

```bash
flutter build ios --debug
```

### Release Build

```bash
# Clean build
flutter clean
flutter pub get

# Build release
flutter build ios --release

# Build archive (for App Store)
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath build/Runner.xcarchive \
  archive
```

### Create IPA

```bash
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportPath build/ipa \
  -exportOptionsPlist ExportOptions.plist
```

## 🧪 Pre-Release Testing

### 1. Install on Physical Device

**Android:**
```bash
# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Or via Flutter
flutter install --release
```

**iOS:**
- Open Xcode
- Window → Devices and Simulators
- Select device
- Drag IPA to Installed Apps

### 2. Test Critical Functions

- [ ] Panic button sends SMS
- [ ] GPS location works
- [ ] All screens accessible
- [ ] Database operations work
- [ ] PIN login functional
- [ ] Services load correctly
- [ ] Offline mode works
- [ ] No crashes or ANRs

### 3. Performance Testing

```bash
# Profile mode
flutter run --profile

# Check app size
flutter build apk --release --analyze-size
```

**Targets:**
- APK size: <50MB
- Cold start: <3 seconds
- Memory usage: <150MB
- Battery drain: <5% per hour

## 📦 Distribution Methods

### 1. Direct Distribution (APK)

**Best for:**
- Pilot testing
- Community distribution
- Areas with limited Play Store access

**Steps:**
1. Build release APK
2. Host on secure server or share via trusted channels
3. Users enable "Install from Unknown Sources"
4. Install APK

**Security Note:** Provide SHA-256 checksum for verification:
```bash
shasum -a 256 app-release.apk
```

### 2. Google Play Store

**Prerequisites:**
- Google Play Developer account ($25 one-time)
- Privacy policy URL
- App content ratings
- Target API level 31+ (Android 12)

**Steps:**

1. **Create App Listing**
   - App name: Binti Salama
   - Short description (80 chars)
   - Full description (4000 chars)
   - Screenshots (2-8 images)
   - Feature graphic (1024x500)
   - App icon (512x512)

2. **Upload App Bundle**
   ```bash
   flutter build appbundle --release
   ```
   Upload `app-release.aab` to Play Console

3. **Content Rating**
   - Complete questionnaire
   - Expect: PEGI 12 / ESRB Teen (sensitive content)

4. **Set Pricing**
   - Free (recommended)

5. **Review and Publish**
   - Submit for review
   - Usually approved within 3-7 days

### 3. Apple App Store

**Prerequisites:**
- Apple Developer account ($99/year)
- Privacy policy
- App Store screenshots
- App icon

**Steps:**

1. **Create App in App Store Connect**
   - Bundle ID: com.bintisalama.app
   - App name: Binti Salama
   - Category: Health & Fitness or Medical

2. **Upload Build**
   ```bash
   flutter build ipa
   # Use Xcode → Product → Archive → Distribute App
   ```

3. **Complete App Information**
   - Description
   - Keywords
   - Support URL
   - Privacy policy URL
   - Age rating (12+)

4. **Screenshots**
   - 6.5" iPhone (1284 x 2778)
   - 5.5" iPhone (1242 x 2208)
   - 12.9" iPad Pro (2048 x 2732)

5. **Submit for Review**
   - Provide demo account (if applicable)
   - App Review notes
   - Wait 1-3 days for review

### 4. Internal Distribution (TestFlight/Firebase)

**Firebase App Distribution:**

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize
firebase init appdistribution

# Upload
firebase appdistribution:distribute app-release.apk \
  --app APP_ID \
  --groups testers \
  --release-notes "Bug fixes and improvements"
```

**Apple TestFlight:**
- Upload via App Store Connect
- Add internal/external testers
- Distribute for testing

## 🔒 Security Considerations

### 1. Code Obfuscation (Android)

Enable in `android/app/build.gradle`:
```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
}
```

### 2. Remove Debug Code

```dart
// Use kReleaseMode to disable debug features
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  print('Debug information');
}
```

### 3. Secure API Keys

Never commit:
- `android/key.properties`
- `android/local.properties`
- `.env` files
- Keystore files

### 4. HTTPS Only

Enforce in `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:usesCleartextTraffic="false">
```

## 📊 Monitoring & Analytics

### Crash Reporting (Optional)

**Firebase Crashlytics:**

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.0.0
  firebase_crashlytics: ^3.0.0
```

```dart
// main.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kReleaseMode) {
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }
  
  runApp(MyApp());
}
```

**Privacy Note:** Only enable if compliant with privacy policy and user consent.

## 🔄 Update Strategy

### Version Numbering

Follow semantic versioning:
- **MAJOR:** Breaking changes
- **MINOR:** New features (backward compatible)
- **PATCH:** Bug fixes

Example: `1.2.3+10`
- Version: 1.2.3
- Build number: 10

### In-App Updates (Android)

```yaml
dependencies:
  in_app_update: ^4.0.0
```

```dart
InAppUpdate.checkForUpdate().then((info) {
  if (info.updateAvailability == UpdateAvailability.updateAvailable) {
    InAppUpdate.performImmediateUpdate();
  }
});
```

### Update Notification (iOS)

Check version via API and prompt user to update.

## 🐛 Troubleshooting

### Common Build Issues

**Issue:** "Gradle build failed"
```bash
# Solution:
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

**Issue:** "Missing API key"
```bash
# Verify local.properties exists
# Check AndroidManifest.xml has meta-data
```

**Issue:** "iOS build failed - pods"
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter build ios
```

**Issue:** "App not installing"
```bash
# Check minimum SDK version
# Verify signing configuration
# Check device compatibility
```

## 📝 Release Checklist

- [ ] Version number updated
- [ ] Changelog created
- [ ] All tests passing
- [ ] No hardcoded credentials
- [ ] API keys configured
- [ ] Signing keys ready
- [ ] Build successful
- [ ] Installed and tested on device
- [ ] Performance acceptable
- [ ] App size reasonable
- [ ] Privacy policy updated
- [ ] Store listing prepared
- [ ] Screenshots captured
- [ ] Release notes written
- [ ] Backup of keystore secured

## 📞 Support & Maintenance

### Post-Release Monitoring

- Monitor crash reports (first 48 hours critical)
- Check user reviews and ratings
- Track SMS delivery success rate
- Monitor GPS accuracy
- Check battery consumption

### Update Schedule

- **Critical bugs:** Hotfix within 24-48 hours
- **Security issues:** Immediate patch
- **Minor bugs:** Bi-weekly updates
- **Features:** Monthly releases

### Rollback Plan

If critical issue found:
1. Remove from stores (emergency)
2. Fix issue
3. Test thoroughly
4. Release patched version
5. Notify users

## 🌐 Multi-Region Deployment

For expansion beyond coastal Kenya:

1. Update services database with new regions
2. Add county options to filters
3. Update emergency hotlines
4. Translate to local languages
5. Adjust legal references
6. Test with local SIM cards

## 📚 Resources

- [Flutter Deployment Docs](https://flutter.dev/docs/deployment)
- [Google Play Console](https://play.google.com/console)
- [App Store Connect](https://appstoreconnect.apple.com)
- [Firebase Console](https://console.firebase.google.com)

---

**Final Note:** This app serves a vulnerable population. Every release should be treated with the utmost care and responsibility. When in doubt, test more, release later.

