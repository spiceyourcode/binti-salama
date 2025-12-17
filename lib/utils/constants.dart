import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Binti Salama';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Safe Girl - Your Confidential Support';

  // Colors
  static const Color primaryColor = Color(0xFF6B4CE6);
  static const Color secondaryColor = Color(0xFFFF6B9D);
  static const Color accentColor = Color(0xFF00C9B7);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFB8C00);
  static const Color successColor = Color(0xFF43A047);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);

  // Emergency Colors
  static const Color emergencyRed = Color(0xFFD32F2F);
  static const Color safeGreen = Color(0xFF388E3C);

  // Timing Constants (in seconds)
  static const int autoLockDefaultMinutes = 5;
  static const int panicAlertTimeoutSeconds = 30;
  static const int splashScreenDurationSeconds = 3;

  // Shake Detection Constants (standardized for reliability)
  // These thresholds require deliberate, vigorous shaking to trigger
  // Tested on standard accelerometer (includes gravity ~9.8 m/s²)
  static const double shakeThreshold =
      50.0; // High threshold for time-normalized acceleration
  static const double shakeDeltaThreshold =
      15.0; // Minimum magnitude change to count as shake
  static const int requiredShakes = 5; // Require 5 distinct shakes
  static const int shakeWindowSeconds = 3; // Within 3 second window
  static const int shakeDebounceMs = 150; // Minimum ms between shake detections

  // Distance Constants (in kilometers)
  static const double maxServiceDisplayDistance = 100.0;
  static const double nearbyServiceThreshold = 10.0;

  // Counties
  static const List<String> counties = ['Mombasa', 'Kilifi', 'Kwale'];

  // Service Types
  static const String serviceTypeGBVRC = 'GBVRC';
  static const String serviceTypeClinic = 'clinic';
  static const String serviceTypePolice = 'police';
  static const String serviceTypeRescueCenter = 'rescue_center';

  static const List<String> serviceTypes = [
    serviceTypeGBVRC,
    serviceTypeClinic,
    serviceTypePolice,
    serviceTypeRescueCenter,
  ];

  // Contact Types
  static const String contactTypeFamily = 'family';
  static const String contactTypeFriend = 'friend';
  static const String contactTypeMobilizer = 'mobilizer';

  static const List<String> contactTypes = [
    contactTypeFamily,
    contactTypeFriend,
    contactTypeMobilizer,
  ];

  // Languages
  static const String languageEnglish = 'en';
  static const String languageSwahili = 'sw';

  static const List<String> supportedLanguages = [
    languageEnglish,
    languageSwahili,
  ];

  // Panic Trigger Types
  static const String panicTriggerShake = 'shake';
  static const String panicTriggerDoubleTap = 'double_tap';
  static const String panicTriggerVolume = 'volume';

  static const List<String> panicTriggerTypes = [
    panicTriggerShake,
    panicTriggerDoubleTap,
    panicTriggerVolume,
  ];

  // Emergency Hotlines (Kenya)
  static const String nationalEmergencyNumber = '999';
  static const String policeEmergencyNumber = '112';
  static const String genderViolenceHotline = '1195';
  static const String childHelplineKenya = '116';

  // Phone Number Format
  static const String kenyaCountryCode = '+254';
  static const String kenyaPhoneRegex = r'^(\+254|0)[17]\d{8}$';

  // Critical Time Windows
  static const int pepWindowHours = 72;
  static const int emergencyContraceptionHours = 120;

  // Database
  static const String databaseName = 'binti_salama.db';
  static const int databaseVersion = 2; // Upgraded for security questions

  // Security Questions
  static const List<String> securityQuestions = [
    'What is your mother\'s first name?',
    'What city were you born in?',
    'What is your favorite color?',
    'What is the name of your best friend?',
    'What is your favorite food?',
    'What is your pet\'s name?',
  ];

  // Encryption
  static const String encryptionKeyName = 'binti_salama_encryption_key';

  // Secure Storage Keys
  static const String keyPinHash = 'pin_hash';
  static const String keyCurrentUserId = 'current_user_id';
  static const String keyLastLoginTime = 'last_login_time';
  static const String keyAutoLockEnabled = 'auto_lock_enabled';

  // Preferences Keys
  static const String prefLanguage = 'language';
  static const String prefPanicTrigger = 'panic_trigger';
  static const String prefNotificationsEnabled = 'notifications_enabled';
  static const String prefDisguiseMode = 'disguise_mode';
  static const String prefAutoLockMinutes = 'auto_lock_minutes';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardElevation = 2.0;

  // Map Constants
  static const double defaultMapZoom = 14.0;
  static const double detailMapZoom = 16.0;

  // Message Templates
  static String getEmergencyAlertMessage(double lat, double lon) {
    final String googleMapsUrl = 'https://maps.google.com/?q=$lat,$lon';
    return 'EMERGENCY ALERT from Binti Salama: I need help urgently. '
        'My location: $googleMapsUrl. '
        'Please contact emergency services or nearest hospital immediately.';
  }

  // Resource Sections
  static const List<String> resourceSections = [
    'What is Sexual Violence',
    'Your Rights After Assault',
    'Health & Medical Support',
    'Legal Rights & Reporting',
    'Psychological Support',
    'Myths vs Facts',
  ];

  // First Response Steps
  static const List<String> firstResponseSteps = [
    'Get to Safety',
    'Preserve Evidence',
    'Seek Medical Care',
    'Report to Police',
    'Document Everything',
    'Seek Support',
  ];

  // App Security Settings
  static const int maxPinAttempts = 5;
  static const int pinLockoutMinutes = 15;
  static const int minPinLength = 4;
  static const int maxPinLength = 6;

  // Network Settings
  static const int connectionTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;

  // Google API Configuration
  // API key is loaded from environment variables for security
  // Set GOOGLE_MAPS_API_KEY in your .env file or android/local.properties
  static String? googleMapsApiKey;
  
  /// Initialize API key from environment
  static void initializeApiKey(String? apiKey) {
    googleMapsApiKey = apiKey;
  }

  // Google Places API Settings
  static const double placesSearchRadiusMeters = 10000.0; // 10km
  static const int maxPlacesResults = 20;
  
  // Data source priority flags
  static const bool enableGooglePlacesApi = true;
  static const bool enableOfflineFallback = true;

  // Validation Messages
  static const String errorInvalidPin = 'PIN must be 4-6 digits';
  static const String errorPinMismatch = 'PINs do not match';
  static const String errorInvalidPhoneNumber = 'Invalid phone number format';
  static const String errorEmptyField = 'This field is required';
  static const String errorLocationPermission = 'Location permission required';
  static const String errorSmsPermission = 'SMS permission required';
}
