# Binti Salama (Safe Girl)

**A Confidential Crisis Response and Referral App for Adolescent Girls**

Binti Salama is a life-saving mobile application designed to help vulnerable adolescent girls experiencing sexual violence in Kenya's coastal region (Mombasa, Kilifi, and Kwale counties).

## 🌟 Overview

This trauma-informed app provides:
- **Instant Emergency Alerts** via SMS with GPS location
- **Service Locator** for GBVRCs, clinics, police, and rescue centers
- **First Response Guidance** with critical 72-hour PEP window emphasis
- **Secure Incident Documentation** with PIN protection and encryption
- **Trusted Contacts Management** for emergency notifications
- **Complete Privacy** with offline-first design and local encryption

## 🚀 Features

### 1. Stealth Panic Button
- Hidden activation via shake detection or volume buttons
- Sends emergency SMS with GPS coordinates to trusted contacts
- Silent operation for maximum discretion
- Works across all Kenyan mobile networks (Safaricom, Airtel, Telkom)

### 2. Service Locator
- Database of 20+ verified services in coastal counties
- Real-time distance calculation using Haversine formula
- Interactive map with directions
- One-tap calling to services
- Filter by type, county, and youth-friendly status

### 3. First Response Guidance
- Step-by-step trauma-informed instructions
- Critical time windows for PEP (72 hours) and EC (120 hours)
- Emergency hotlines (999, 112, 1195, 116)
- Know Your Rights information
- Offline accessible

### 4. Secure Incident Log
- PIN-protected encrypted diary
- Document incidents with timestamps and GPS
- Track medical visits, police reports (OB numbers)
- Export reports for legal proceedings
- Search and filter functionality

### 5. Privacy & Security
- AES encryption for all local data
- PIN-based authentication
- Auto-lock after inactivity
- No cloud storage or tracking
- Compliant with Kenya Data Protection Act

## 🛠️ Technology Stack

- **Language:** Dart
- **Framework:** Flutter 3.x
- **Database:** SQLite with encryption (sqflite)
- **Security:** flutter_secure_storage, encrypt
- **Location:** geolocator, geocoding
- **Maps:** google_maps_flutter
- **SMS:** flutter_sms
- **State Management:** Provider
- **Sensors:** sensors_plus (shake detection)

## 📋 Requirements

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android SDK 21+ (Android 5.0 Lollipop)
- iOS 12.0+
- Google Maps API Key (for map functionality)

## 🔧 Installation

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/binti-salama.git
cd binti-salama
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Google Maps API

**Android:** Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

**iOS:** Add to `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

### 4. Run the App

```bash
flutter run
```

## 📱 Building for Production

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Google Play)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
flutter build ios --release
```

## 🧪 Testing

Run all tests:
```bash
flutter test
```

Run integration tests:
```bash
flutter test integration_test/
```

## 📖 Documentation

- **[IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)** - Detailed code walkthrough
- **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Testing strategies and examples
- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Production deployment steps

## 🔒 Security Considerations

1. **No Hardcoded Secrets:** Use environment variables for API keys
2. **Data Encryption:** All sensitive data encrypted at rest
3. **Secure Communication:** HTTPS for all network requests
4. **PIN Protection:** Minimum 4 digits, lockout after failed attempts
5. **Auto-Lock:** Configurable timeout for app security

## 🌍 Kenyan Context

- **Phone Format:** +254 (country code)
- **Time Zone:** East Africa Time (EAT - UTC+3)
- **Legal Framework:** Sexual Offences Act 2006, Kenya Data Protection Act 2019
- **Medical Guidelines:** Ministry of Health Post-Rape Care protocols
- **Counties Covered:** Mombasa, Kilifi, Kwale

## 🤝 Contributing

This is a sensitive application serving vulnerable populations. Contributions must:
- Maintain trauma-informed design principles
- Respect user privacy and security
- Follow Flutter/Dart best practices
- Include comprehensive tests
- Update documentation

## 📞 Emergency Contacts (Kenya)

- **National Emergency:** 999
- **Police Emergency:** 112
- **Gender Violence Hotline:** 1195
- **Child Helpline:** 116

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## ⚠️ Disclaimer

This app is a support tool and not a replacement for professional medical, legal, or psychological services. Always seek professional help in crisis situations.

## 🙏 Acknowledgments

Built with trauma-informed principles and in consultation with GBV survivors and support organizations in Kenya's coastal region.

---

**For emergencies, always call 999 or visit the nearest hospital.**

