# Binti Salama (Safe Girl)

**A Confidential Crisis Response and Referral App for Adolescent Girls**

Binti Salama is a life-saving mobile application designed to help vulnerable adolescent girls experiencing sexual violence in Kenya's coastal region (Mombasa, Kilifi, and Kwale counties).

## 🌟 Overview

This trauma-informed app provides:
- **Disguise Mode** appearing as a functional calculator
- **Instant Emergency Alerts** via SMS with GPS location
- **Service Locator** for GBVRCs, clinics, police, and rescue centers
- **First Response Guidance** with critical 72-hour PEP window emphasis
- **Secure Incident Documentation** with PIN/Biometric protection and encryption
- **Trusted Contacts Management** for emergency notifications
- **Complete Privacy** with offline-first design and local encryption
- **Multi-language Support** (English & Swahili)

## 🚀 Key Features

### 1. 🎭 Stealth Disguise Interface
- **Calculator Disguise**: App launches as a fully functional calculator to hide its true purpose.
- **Secret Access**: Access the real app only by entering a specific code sequence (default: `159=`).
- **Shake-to-Hide**: Quickly switch back to disguise mode by shaking the device.

### 2. 🚨 Panic Button & Emergency Response
- **One-Touch Alert**: Sends emergency SMS with precise GPS coordinates to trusted contacts.
- **Multi-Channel Delivery**: Uses native SMS telephony and Africa's Talking API for reliable delivery.
- **Shake Detection**: Trigger alerts by shaking the phone (configurable sensitivity).
- **Offline Queuing**: If offline, alerts are queued and sent as soon as connection is restored.

### 3. 🗺️ Smart Service Locator
- **Verified Directory**: Database of 20+ verified services in coastal counties (Hospitals, Police, NGOs).
- **Google Maps Integration**: Visualize services with turn-by-turn directions.
- **Offline Caching**: Maps and service details remain accessible without internet.
- **Smart Filtering**: Filter by type, county, and 'youth-friendly' status.
- **Geocoding**: Automatically converts GPS coordinates to readable street addresses.

### 4. 📝 Secure Incident Log
- **Encrypted Diary**: AES-256 encrypted storage for documenting incidents.
- **Detailed Reporting**: Record date, location, perpetrator details, witnesses, and medical actions.
- **Evidence Checklist**: Track preservation of evidence (clothing, DNA) and police report filing (OB Number).
- **Export & Share**: Generate and share secure reports for legal or medical use.
- **Searchable History**: Easily find past records with search capability.

### 5. 🏥 First Response Guidance
- **Trauma-Informed Guide**: Step-by-step instructions on what to do immediately after an assault.
- **Critical Windows**: Clear alerts for PEP (72 hours) and Emergency Contraception (120 hours).
- **Rights Information**: Know Your Rights section for legal awareness.
- **One-Tap Hotlines**: Direct dial to National Emergency (999), Gender Violence Hotline (1195), and Child Helpline (116).

### 6. 🔒 Privacy & Security Features
- **Biometric Login**: Support for Fingerprint and Face ID authentication.
- **PIN Recovery**: Secure PIN reset mechanism using trusted contacts.
- **Zero-Knowledge**: No cloud storage of incident data; everything is stored locally on the device.
- **Auto-Lock**: App locks automatically after short inactivity.
- **Data Encryption**: Utilizes `flutter_secure_storage` and `encrypt` packages for military-grade security.

## 🛠️ Technology Stack

- **Language:** Dart
- **Framework:** Flutter 3.x
- **Database:** SQLite with encryption (sqflite)
- **Security:** 
  - `flutter_secure_storage` (Key management)
  - `local_auth` (Biometrics)
  - `encrypt` (AES Encryption)
- **Location & Maps:** 
  - `geolocator`
  - `google_maps_flutter`
  - `google_places_service`
- **Communications:** 
  - `another_telephony` (Native SMS)
  - Africa's Talking API (Cloud SMS)
- **State Management:** Provider
- **Sensors:** `sensors_plus` (Shake detection)
- **Connectivity:** `connectivity_plus`

## 📋 Requirements

- Android SDK 21+ (Android 5.0 Lollipop)
- iOS 12.0+
- GPS enabled device
- SIM card for SMS features

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

### 3. Environment Setup

Create a `.env` file in the root directory:

```env
GOOGLE_MAPS_API_KEY=your_api_key_here
AFRICAS_TALKING_API_KEY=your_key_here
AFRICAS_TALKING_USERNAME=your_username
```

### 4. Configure Maps API (Android)

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

### 5. Run the App

```bash
flutter run
```

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
