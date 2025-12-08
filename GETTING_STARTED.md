# Getting Started with Binti Salama Development

Quick start guide for developers joining the Binti Salama project.

## 🚀 Quick Setup (5 Minutes)

### 1. Install Prerequisites

**Flutter & Dart:**
```bash
# Install Flutter (includes Dart)
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

**Android Studio:**
- Download from https://developer.android.com/studio
- Install Android SDK and emulator

### 2. Clone and Setup Project

```bash
# Clone repository
git clone <your-repo-url>
cd binti-salama

# Get dependencies
flutter pub get

# Verify setup
flutter doctor
```

### 3. Run the App

```bash
# List available devices
flutter devices

# Run on connected device/emulator
flutter run

# Or run in debug mode
flutter run --debug
```

## 📁 Project Overview

### Key Directories

- **`lib/models/`** - Data structures (User, Service, IncidentLog, etc.)
- **`lib/services/`** - Business logic (authentication, panic button, database)
- **`lib/screens/`** - UI screens (home, login, service locator, etc.)
- **`lib/widgets/`** - Reusable UI components
- **`lib/utils/`** - Helpers (constants, validators, localization)
- **`assets/data/`** - Embedded services database (JSON)

### Architecture Flow

```
User Interface (Screens & Widgets)
        ↓
    Provider (State Management)
        ↓
    Services (Business Logic)
        ↓
    Database (SQLite)
```

## 🔧 Development Workflow

### 1. Create a New Feature

```bash
# Create a new branch
git checkout -b feature/your-feature-name

# Make changes
# ...

# Run tests
flutter test

# Commit
git add .
git commit -m "Add: your feature description"

# Push
git push origin feature/your-feature-name
```

### 2. Common Development Commands

```bash
# Hot reload (while app is running)
# Press 'r' in terminal

# Hot restart
# Press 'R' in terminal

# Run tests
flutter test

# Check for issues
flutter analyze

# Format code
dart format .

# Clean build
flutter clean && flutter pub get
```

### 3. Debugging

**VS Code:**
- Install Flutter extension
- Set breakpoints by clicking line numbers
- Press F5 to start debugging

**Android Studio:**
- Open project
- Set breakpoints
- Click Debug button

**Print Debugging:**
```dart
print('Debug: $variableName');
debugPrint('This appears in debug mode only');
```

## 📊 Understanding the Core Features

### 1. Panic Button (Most Critical)

**Location:** `lib/services/panic_button_service.dart`

**How it works:**
1. Listens to accelerometer for shake pattern
2. Triggers callback when 3 shakes detected within 2 seconds
3. Gets user's GPS location
4. Retrieves emergency contacts from database
5. Sends SMS with location link to all contacts
6. Logs alert in database

**Testing:**
```dart
// Test shake detection
final panicService = PanicButtonService(...);
panicService.initializeShakeDetection(() {
  print('Panic triggered!');
});

// Test panic alert (without actually sending SMS)
await panicService.testPanicButton();
```

### 2. Service Locator

**Location:** `lib/services/service_locator_service.dart`

**How it works:**
1. Loads services from embedded JSON database
2. Gets user's current GPS location
3. Calculates distance to each service using Haversine formula
4. Sorts by distance
5. Filters by type, county, or youth-friendly status

**Adding a new service:**
Edit `assets/data/services.json`:
```json
{
  "id": "srv_new",
  "name": "Service Name",
  "type": "GBVRC",
  "county": "Mombasa",
  "address": "...",
  "phoneNumber": "+254...",
  "latitude": -4.0435,
  "longitude": 39.6682,
  "operatingHours": "24/7",
  "servicesOffered": ["Service 1", "Service 2"],
  "youthFriendly": true
}
```

### 3. Authentication & Security

**Location:** `lib/services/authentication_service.dart`

**How it works:**
1. PIN is hashed with SHA-256
2. Hash stored in FlutterSecureStorage (encrypted)
3. Session tracked with timestamps
4. Auto-lock after configurable inactivity
5. All data in SQLite is encrypted

**Creating a user:**
```dart
final authService = AuthenticationService(...);
final user = await authService.createAccount('1234');
```

## 🧪 Testing Your Changes

### Unit Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/authentication_service_test.dart

# Run with coverage
flutter test --coverage
```

### Widget Tests

```dart
testWidgets('Button displays correctly', (tester) async {
  await tester.pumpWidget(MyWidget());
  expect(find.text('Button'), findsOneWidget);
  
  await tester.tap(find.text('Button'));
  await tester.pump();
  
  expect(find.text('Clicked'), findsOneWidget);
});
```

### Manual Testing

1. **Test on Real Device:**
   ```bash
   flutter run --release
   ```

2. **Critical Tests:**
   - [ ] Shake phone to trigger panic button
   - [ ] Verify SMS sent
   - [ ] Check GPS location accuracy
   - [ ] Test offline functionality
   - [ ] Verify PIN security

## 🐛 Common Issues & Solutions

### Issue: "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Issue: "Package not found"
```bash
flutter pub get
flutter pub upgrade
```

### Issue: "GPS not working"
- Check AndroidManifest.xml permissions
- Enable location on device
- Test outdoors for better signal

### Issue: "SMS not sending"
- Verify SMS permission granted
- Check phone number format (+254)
- Test with actual SIM card

## 📚 Learning Resources

### Flutter Basics
- [Flutter Official Docs](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)

### Project-Specific
- **README.md** - Project overview
- **IMPLEMENTATION_GUIDE.md** - Detailed code explanation
- **TESTING_GUIDE.md** - Testing strategies
- **DEPLOYMENT_GUIDE.md** - Building and releasing

### Key Packages Used
- [Provider](https://pub.dev/packages/provider) - State management
- [sqflite](https://pub.dev/packages/sqflite) - SQLite database
- [geolocator](https://pub.dev/packages/geolocator) - GPS location
- [flutter_sms](https://pub.dev/packages/flutter_sms) - SMS sending
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) - Encrypted storage

## 🎯 Development Best Practices

### Code Style

```dart
// Good: Clear names, proper formatting
Future<void> sendPanicAlert(List<TrustedContact> contacts) async {
  try {
    for (final contact in contacts) {
      await _sendSMS(contact.phoneNumber);
    }
  } catch (e) {
    _handleError(e);
  }
}

// Bad: Unclear names, poor formatting
Future<void> send(List c) async {
  for(var x in c){await sms(x.p);}
}
```

### Error Handling

```dart
// Always handle errors gracefully
try {
  await riskyOperation();
} catch (e) {
  print('Error: $e'); // Log for debugging
  _showUserFriendlyError(); // Show to user
}
```

### Security

```dart
// Never log sensitive data
print('PIN: $pin'); // ❌ NO!
print('User logged in'); // ✅ YES

// Always validate user input
if (!Validators.isValidPin(pin)) {
  throw Exception('Invalid PIN');
}
```

## 🤝 Contributing

### Before Submitting PR

1. Run `flutter analyze` (no issues)
2. Run `flutter test` (all pass)
3. Test on physical device
4. Update documentation if needed
5. Follow trauma-informed design principles

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing
- [ ] Unit tests added/updated
- [ ] Tested on Android device
- [ ] Tested offline mode
- [ ] No security issues introduced

## Screenshots (if UI changes)
[Add screenshots here]
```

## 🆘 Getting Help

1. **Check Documentation** - README, guides
2. **Search Issues** - Might be answered already
3. **Ask Team** - Slack/Discord channel
4. **Stack Overflow** - For general Flutter questions

## 🎓 Next Steps

1. **Run the app** and explore all features
2. **Read IMPLEMENTATION_GUIDE.md** for code details
3. **Pick a "good first issue"** from GitHub
4. **Make your first contribution!**

---

Welcome to the team! Together we're building a life-saving application. Every line of code matters. 💜

