# Binti Salama - Implementation Guide

This document provides a detailed walkthrough of the Binti Salama codebase, explaining the architecture, design decisions, and implementation details.

## 📁 Project Structure

```
binti_salama/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   │   ├── user.dart
│   │   ├── trusted_contact.dart
│   │   ├── service.dart
│   │   ├── incident_log.dart
│   │   ├── app_settings.dart
│   │   └── panic_alert.dart
│   ├── services/                 # Business logic
│   │   ├── database_service.dart
│   │   ├── authentication_service.dart
│   │   ├── panic_button_service.dart
│   │   ├── service_locator_service.dart
│   │   ├── incident_log_service.dart
│   │   └── settings_service.dart
│   ├── screens/                  # UI screens
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   ├── service_locator_screen.dart
│   │   ├── first_response_screen.dart
│   │   ├── incident_log_screen.dart
│   │   ├── resources_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/                  # Reusable widgets
│   │   └── panic_button_widget.dart
│   └── utils/                    # Utilities
│       ├── constants.dart
│       ├── validators.dart
│       └── localization.dart
├── assets/
│   └── data/
│       └── services.json         # Embedded services database
├── pubspec.yaml                  # Dependencies
└── README.md                     # Project overview
```

## 🏗️ Architecture

### Design Pattern: Provider + Service Layer

```
┌─────────────┐
│   UI Layer  │ (Screens & Widgets)
└─────┬───────┘
      │ Provider
┌─────▼───────┐
│   Services  │ (Business Logic)
└─────┬───────┘
      │
┌─────▼───────┐
│   Models    │ (Data Structures)
└─────┬───────┘
      │
┌─────▼───────┐
│  Database   │ (SQLite)
└─────────────┘
```

**Separation of Concerns:**
- **UI Layer:** Pure presentation logic, no business rules
- **Service Layer:** All business logic, data transformations, API calls
- **Model Layer:** Data structures with serialization
- **Database Layer:** Data persistence with encryption

## 🔑 Key Components

### 1. Authentication Service

**File:** `lib/services/authentication_service.dart`

**Purpose:** Manages user authentication, PIN verification, and session management.

**Key Methods:**
- `createAccount(String pin)` - Creates new user with encrypted PIN
- `login(String pin)` - Verifies PIN and establishes session
- `isAuthenticated()` - Checks if session is valid
- `changePin(String oldPin, String newPin)` - Updates user PIN
- `deleteAccount(String pin)` - Permanently removes all user data

**Security Implementation:**
```dart
// PIN is hashed using SHA-256
String _hashPin(String pin) {
  final bytes = utf8.encode(pin);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
```

**Auto-Lock:**
- Tracks last activity time
- Automatically logs out after configured duration
- Implemented via `WidgetsBindingObserver` in screens

### 2. Panic Button Service

**File:** `lib/services/panic_button_service.dart`

**Purpose:** Detects shake gestures and sends emergency SMS alerts.

**Shake Detection Algorithm:**
```dart
void _handleAccelerometerEvent(UserAccelerometerEvent event) {
  // Calculate acceleration magnitude
  final double magnitude = sqrt(
    event.x * event.x + event.y * event.y + event.z * event.z
  );

  // Threshold-based detection
  if (magnitude > AppConstants.shakeThreshold) {
    final now = DateTime.now();
    _shakeTimes.add(now);
    
    // Remove old shake events outside window
    _shakeTimes.removeWhere((time) {
      return now.difference(time) > shakeWindow;
    });
    
    // Trigger if required shakes detected
    if (_shakeTimes.length >= AppConstants.requiredShakes) {
      _onPanicTriggered?.call();
    }
  }
}
```

**SMS Sending:**
- Uses `flutter_sms` package
- Formats phone numbers to +254 (Kenya)
- Includes GPS coordinates in Google Maps link
- Logs all alerts to database for history

### 3. Service Locator Service

**File:** `lib/services/service_locator_service.dart`

**Purpose:** Finds and displays nearby GBV services.

**Haversine Distance Formula:**
```dart
double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371; // Earth radius in km
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  
  final a = sin(dLat / 2) * sin(dLat / 2) +
            cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
  
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}
```

**Service Filtering:**
- By type (GBVRC, clinic, police, rescue_center)
- By county (Mombasa, Kilifi, Kwale)
- By youth-friendly status
- By maximum distance
- Full-text search across name and address

### 4. Incident Log Service

**File:** `lib/services/incident_log_service.dart`

**Purpose:** Securely documents incidents with legal-quality reports.

**Key Features:**
- Automatic GPS location and reverse geocoding
- Timestamps all entries
- Tracks evidence preservation status
- Records police reports (OB numbers)
- Generates formatted legal reports
- Calculates time remaining for PEP/EC windows

**Export Format:**
```dart
String exportIncidentLog(IncidentLog incident) {
  return '''
CONFIDENTIAL INCIDENT REPORT
Generated: ${incident.incidentDate}
Incident ID: ${incident.id}

INCIDENT DETAILS:
Date & Time: ${incident.incidentDate}
Location: ${incident.locationAddress}
...
  ''';
}
```

### 5. Database Service

**File:** `lib/services/database_service.dart`

**Purpose:** Manages all SQLite operations with encryption.

**Schema:**
- `users` - User accounts with hashed PINs
- `trusted_contacts` - Emergency contacts
- `incident_logs` - Documented incidents
- `app_settings` - User preferences
- `services` - Static GBVRC/clinic/police data
- `panic_alerts` - Alert history

**Indexes for Performance:**
```sql
CREATE INDEX idx_trusted_contacts_user ON trusted_contacts(user_id);
CREATE INDEX idx_incident_logs_user ON incident_logs(user_id);
CREATE INDEX idx_services_county ON services(county);
CREATE INDEX idx_services_type ON services(type);
```

**Initial Data Loading:**
- Loads services from `assets/data/services.json`
- Executed on database creation
- Batch insert for efficiency

## 🎨 UI Implementation

### Material Design 3

**Theme Configuration:**
```dart
ThemeData(
  primaryColor: AppConstants.primaryColor,
  colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
  useMaterial3: true,
  // Custom button, card, input themes
)
```

### Navigation

**Flow:**
```
Splash → Onboarding (new users) → Home
     └→ Login (existing users) → Home
```

**Screen Management:**
- `Navigator.pushReplacement()` for auth transitions
- `Navigator.push()` for feature screens
- Back button disabled on auth screens for security

### State Management (Provider)

**Setup in main.dart:**
```dart
MultiProvider(
  providers: [
    Provider<DatabaseService>.value(value: databaseService),
    ProxyProvider<DatabaseService, AuthenticationService>(...),
    ProxyProvider<DatabaseService, PanicButtonService>(...),
    // ... other services
  ],
  child: MaterialApp(...)
)
```

**Usage in Screens:**
```dart
final authService = Provider.of<AuthenticationService>(context, listen: false);
final userId = await authService.getCurrentUserId();
```

## 🔐 Security Implementation

### 1. PIN Protection

- **Storage:** Hashed with SHA-256, stored in FlutterSecureStorage
- **Validation:** 4-6 digits only
- **Lockout:** 5 failed attempts, 15-minute cooldown
- **Auto-lock:** Configurable timeout (1-30 minutes)

### 2. Data Encryption

**At Rest:**
- SQLite database encrypted
- FlutterSecureStorage for sensitive keys
- No plaintext sensitive data

**Key Storage:**
```dart
final secureStorage = FlutterSecureStorage();
await secureStorage.write(key: 'pin_hash', value: hashedPin);
```

### 3. Privacy Features

- **No Analytics:** Zero tracking or telemetry
- **No Cloud:** All data stays on device
- **Disguise Mode:** Option to hide app name/icon
- **Auto-Lock:** Prevents unauthorized access
- **Local Only:** No internet calls for core functionality

## 📱 Offline-First Design

### Strategies:

1. **Embedded Services Database**
   - 20+ services pre-loaded in assets
   - No API calls required
   - Always available

2. **Local Storage**
   - SQLite for all data
   - No server dependencies
   - Works without internet

3. **Graceful Degradation**
   - GPS optional (continue without location)
   - SMS-only panic button (no data needed)
   - Offline resource content

4. **Data Efficiency**
   - Minimal package sizes
   - Compressed assets
   - Optimized for 2G/3G networks

## 🌍 Kenyan Context

### Phone Number Formatting

```dart
String _formatPhoneNumber(String phoneNumber) {
  String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
  
  if (cleaned.startsWith('254')) {
    return '+$cleaned';
  } else if (cleaned.startsWith('0')) {
    return '+254${cleaned.substring(1)}';
  } else if (cleaned.startsWith('7') || cleaned.startsWith('1')) {
    return '+254$cleaned';
  }
  
  return phoneNumber;
}
```

### Time Zone Handling

- All timestamps stored in UTC (ISO 8601)
- Displayed in EAT (UTC+3) using `intl` package
- No daylight saving time considerations needed

### Language Support

- English (primary)
- Swahili (secondary)
- Stored in `utils/localization.dart`
- Switchable in settings

## 🧪 Testing Strategy

### Unit Tests
- Model serialization/deserialization
- Service business logic
- Validators
- Distance calculations

### Widget Tests
- Button interactions
- Form validations
- Navigation flows

### Integration Tests
- Complete user journeys
- Database operations
- SMS functionality (mocked)

## 🚀 Performance Optimizations

1. **Database Indexes:** Fast queries on foreign keys
2. **Pagination:** Load incidents in batches
3. **Lazy Loading:** Services loaded on demand
4. **Image Optimization:** Minimal assets, vector icons
5. **Build Optimization:** ProGuard/R8 enabled for Android

## 🐛 Error Handling

### Strategy:
```dart
try {
  await riskyOperation();
} catch (e) {
  print('Error: $e'); // Log for debugging
  _showError('User-friendly message'); // Display to user
  rethrow; // If critical, propagate upwards
}
```

### User-Facing Errors:
- Always show actionable error messages
- Never expose technical details
- Provide recovery options
- Log errors for debugging

## 📝 Code Style

- **Dart Style Guide:** Official Dart formatting
- **Linting:** `flutter_lints` package enabled
- **Naming:** camelCase for variables, PascalCase for classes
- **Comments:** Inline for complex logic, doc comments for public APIs

## 🔄 Data Flow Example: Panic Alert

```
1. User shakes phone
   ↓
2. PanicButtonService detects shake pattern
   ↓
3. Shows confirmation dialog
   ↓
4. User confirms
   ↓
5. Get GPS location (if available)
   ↓
6. Fetch emergency contacts from database
   ↓
7. Format alert message with location
   ↓
8. Send SMS to each contact via flutter_sms
   ↓
9. Log alert in panic_alerts table
   ↓
10. Show success/failure message
```

## 💡 Best Practices

1. **Trauma-Informed Design**
   - Simple, clear language
   - No judgment or blame
   - Emphasize user control
   - Provide hope and support

2. **Security First**
   - Never log sensitive data
   - Encrypt everything
   - Minimize data collection
   - Secure by default

3. **Accessibility**
   - High contrast colors
   - Large touch targets
   - Clear typography
   - Screen reader support

4. **Reliability**
   - Graceful error handling
   - Fallback mechanisms
   - Offline functionality
   - Tested edge cases

## 🔧 Customization

### Adding New Services

Edit `assets/data/services.json`:
```json
{
  "id": "srv_999",
  "name": "New Service Name",
  "type": "GBVRC",
  "county": "Mombasa",
  "address": "Service Address",
  "phoneNumber": "+254XXXXXXXXX",
  "latitude": -4.0435,
  "longitude": 39.6682,
  "operatingHours": "24/7",
  "servicesOffered": ["Service 1", "Service 2"],
  "youthFriendly": true
}
```

### Adding New Languages

1. Add translations to `utils/localization.dart`
2. Update `AppConstants.supportedLanguages`
3. Add language option in settings

### Changing Theme

Edit `utils/constants.dart`:
```dart
static const Color primaryColor = Color(0xFF6B4CE6);
static const Color secondaryColor = Color(0xFFFF6B9D);
// ... other colors
```

## 📚 Further Reading

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [SQLite in Flutter](https://docs.flutter.dev/cookbook/persistence/sqlite)
- [Flutter Security Best Practices](https://flutter.dev/docs/deployment/android#reviewing-the-gradle-build-configuration)
- [Kenya Data Protection Act 2019](https://www.odpc.go.ke/)

---

For questions or contributions, please refer to the README.md contributing section.

