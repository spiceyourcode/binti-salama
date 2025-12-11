import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/panic_alert.dart';
import '../models/trusted_contact.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';
import 'database_service.dart';

class PanicButtonService {
  final DatabaseService databaseService;
  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;
  List<DateTime> _shakeTimes = [];
  bool _isListening = false;
  VoidCallback? _onPanicTriggered;
  String? _currentTriggerType;
  DateTime? _lastTapTime;
  int _tapCount = 0;
  Timer? _tapTimer;
  bool _volumeButtonPressed = false;
  int _accelerometerEventCount = 0;
  UserAccelerometerEvent? _lastAccelerometerEvent;

  PanicButtonService({required this.databaseService});

  /// Initialize panic button trigger based on type
  void initializePanicTrigger(
      String triggerType, VoidCallback onPanicTriggered) {
    AppLogger.info('🔧 Initializing panic trigger: $triggerType');

    // Stop any existing trigger first
    stopPanicTrigger();

    _onPanicTriggered = onPanicTriggered;
    _currentTriggerType = triggerType;
    _isListening = true;

    switch (triggerType) {
      case AppConstants.panicTriggerShake:
        AppLogger.info('📱 Setting up shake detection...');
        _initializeShakeDetection();
        break;
      case AppConstants.panicTriggerDoubleTap:
        // Double tap is handled by widget gesture detector
        AppLogger.info('👆 Setting up double tap detection...');
        AppLogger.info('Double tap trigger initialized');
        break;
      case AppConstants.panicTriggerVolume:
        AppLogger.info('🔊 Setting up volume button detection...');
        _initializeVolumeButtonDetection();
        break;
      default:
        AppLogger.info('⚠️ Unknown trigger type: $triggerType');
        AppLogger.warning('Unknown trigger type: $triggerType');
    }

    AppLogger.info(
        '✅ Panic trigger initialized: $triggerType, isListening: $_isListening');
  }

  /// Initialize shake detection for panic button
  void _initializeShakeDetection() {
    _shakeTimes = [];
    _accelerometerEventCount = 0; // Reset counter

    AppLogger.info('🔔 Initializing shake detection...');

    try {
      _accelerometerSubscription = userAccelerometerEventStream().listen(
        _handleAccelerometerEvent,
        onError: (error) {
          AppLogger.info('❌ Accelerometer error: $error');
          AppLogger.error('Accelerometer error', error: error);
        },
        cancelOnError: false,
      );

      AppLogger.info(
          '✅ Shake detection initialized - listening for accelerometer events');
      AppLogger.info(
          '📊 Threshold: ${AppConstants.shakeThreshold}, Delta: ${AppConstants.shakeDeltaThreshold}, Required shakes: ${AppConstants.requiredShakes}, Window: ${AppConstants.shakeWindowSeconds}s');
      AppLogger.info('Shake detection initialized');
    } catch (e) {
      AppLogger.info('❌ Failed to initialize accelerometer: $e');
      AppLogger.error('Failed to initialize accelerometer', error: e);
    }
  }

  void _handleAccelerometerEvent(UserAccelerometerEvent event) {
    if (_currentTriggerType != AppConstants.panicTriggerShake ||
        !_isListening) {
      return;
    }

    final double magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    final double deltaMagnitude = _lastAccelerometerEvent == null
        ? 0.0
        : sqrt(
            pow(event.x - _lastAccelerometerEvent!.x, 2) +
                pow(event.y - _lastAccelerometerEvent!.y, 2) +
                pow(event.z - _lastAccelerometerEvent!.z, 2),
          );
    _lastAccelerometerEvent = event;

    // Debug: Print first few events to verify stream is working
    _accelerometerEventCount++;
    if (_accelerometerEventCount <= 5 ||
        magnitude > 10.0 ||
        deltaMagnitude > 6.0) {
      AppLogger.info(
          '📱 Accelerometer event #$_accelerometerEventCount - X: ${event.x.toStringAsFixed(2)}, Y: ${event.y.toStringAsFixed(2)}, Z: ${event.z.toStringAsFixed(2)}, Magnitude: ${magnitude.toStringAsFixed(2)}, ΔMag: ${deltaMagnitude.toStringAsFixed(2)}, Threshold: ${AppConstants.shakeThreshold}/${AppConstants.shakeDeltaThreshold}');
    }

    if (magnitude >= AppConstants.shakeThreshold ||
        deltaMagnitude >= AppConstants.shakeDeltaThreshold) {
      final now = DateTime.now();
      _shakeTimes.add(now);

      AppLogger.info(
          '💥 Shake detected! Magnitude: ${magnitude.toStringAsFixed(2)}, Shakes so far: ${_shakeTimes.length}');

      // Remove old shake events outside the time window
      _shakeTimes.removeWhere((time) {
        final difference = now.difference(time);
        return difference.inSeconds > AppConstants.shakeWindowSeconds;
      });

      AppLogger.info(
          '📊 Shakes in window: ${_shakeTimes.length}/${AppConstants.requiredShakes}');

      // Check if required number of shakes detected
      if (_shakeTimes.length >= AppConstants.requiredShakes) {
        _shakeTimes.clear();
        AppLogger.info('🚨 PANIC ALERT TRIGGERED! Shake count reached threshold');
        AppLogger.info('Shake detected - triggering panic alert');
        _onPanicTriggered?.call();
      }
    }
  }

  /// Handle double tap gesture (called from widget)
  void handleDoubleTap() {
    if (_currentTriggerType != AppConstants.panicTriggerDoubleTap) return;

    final now = DateTime.now();

    if (_lastTapTime == null) {
      _lastTapTime = now;
      _tapCount = 1;
      _tapTimer?.cancel();
      _tapTimer = Timer(const Duration(milliseconds: 500), () {
        _tapCount = 0;
        _lastTapTime = null;
      });
    } else {
      final difference = now.difference(_lastTapTime!);
      if (difference.inMilliseconds < 500) {
        _tapCount++;
        if (_tapCount >= 2) {
          _tapTimer?.cancel();
          _tapCount = 0;
          _lastTapTime = null;
          AppLogger.info('Double tap detected - triggering panic alert');
          _onPanicTriggered?.call();
        }
      } else {
        _lastTapTime = now;
        _tapCount = 1;
        _tapTimer?.cancel();
        _tapTimer = Timer(const Duration(milliseconds: 500), () {
          _tapCount = 0;
          _lastTapTime = null;
        });
      }
    }
  }

  /// Initialize volume button detection
  void _initializeVolumeButtonDetection() {
    // Use RawKeyboardListener or platform channels for volume buttons
    // For now, we'll use a method that can be called from the widget
    AppLogger.info('Volume button detection initialized');
    // Note: Volume button detection requires platform-specific implementation
    // We'll handle this through a widget that captures volume button presses
  }

  /// Handle volume button press (called from platform channel or widget)
  void handleVolumeButtonPress() {
    if (_currentTriggerType != AppConstants.panicTriggerVolume) return;

    if (!_volumeButtonPressed) {
      _volumeButtonPressed = true;
      AppLogger.info('Volume button pressed - triggering panic alert');
      _onPanicTriggered?.call();

      // Reset after a delay to prevent multiple triggers
      Future.delayed(const Duration(seconds: 2), () {
        _volumeButtonPressed = false;
      });
    }
  }

  /// Stop all panic trigger detection
  void stopPanicTrigger() {
    AppLogger.info('🛑 Stopping panic trigger detection...');
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _isListening = false;
    _lastAccelerometerEvent = null;
    _shakeTimes.clear();
    _tapTimer?.cancel();
    _tapTimer = null;
    _tapCount = 0;
    _lastTapTime = null;
    _volumeButtonPressed = false;
    _currentTriggerType = null;
    AppLogger.info('✅ Panic trigger detection stopped');
  }

  /// Legacy method for backward compatibility
  void initializeShakeDetection(VoidCallback onPanicTriggered) {
    initializePanicTrigger(AppConstants.panicTriggerShake, onPanicTriggered);
  }

  /// Legacy method for backward compatibility
  void stopShakeDetection() {
    stopPanicTrigger();
  }

  /// Trigger panic alert and send SMS to emergency contacts
  Future<PanicAlert> triggerPanicAlert(
    String userId,
    List<TrustedContact> emergencyContacts, {
    Position? userLocation,
  }) async {
    final alertId = const Uuid().v4();
    final triggeredAt = DateTime.now();
    int contactsAlerted = 0;
    bool success = false;
    String? errorMessage;

    try {
      // Get current location if not provided
      Position? location = userLocation;
      if (location == null) {
        try {
          location = await _getCurrentLocation();
        } catch (e) {
          AppLogger.warning('Failed to get location: $e');
          // Continue without location
        }
      }

      // Send SMS to each emergency contact
      final List<String> phoneNumbers = emergencyContacts
          .where((contact) => contact.isEmergency)
          .map((contact) => _formatPhoneNumber(contact.phoneNumber))
          .toList();

      if (phoneNumbers.isEmpty) {
        throw Exception('No emergency contacts configured');
      }

      final alertMessage = _buildAlertMessage(location);

      try {
        await _sendSMS(phoneNumbers, alertMessage);
        contactsAlerted = phoneNumbers.length;
        success = true;
      } catch (e) {
        errorMessage = 'SMS sending failed: $e';
        throw Exception(errorMessage);
      }
    } catch (e) {
      errorMessage = e.toString();
      success = false;
    }

    // Log the panic alert
    final alert = PanicAlert(
      id: alertId,
      userId: userId,
      triggeredAt: triggeredAt,
      latitude: userLocation?.latitude,
      longitude: userLocation?.longitude,
      contactsAlerted: contactsAlerted,
      success: success,
      errorMessage: errorMessage,
    );

    await databaseService.insertPanicAlert(alert);

    if (!success) {
      throw Exception(errorMessage ?? 'Panic alert failed');
    }

    return alert;
  }

  /// Get current GPS location
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    // Get current location with timeout
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  /// Build emergency alert message
  String _buildAlertMessage(Position? location) {
    if (location != null) {
      final googleMapsUrl =
          'https://maps.google.com/?q=${location.latitude},${location.longitude}';
      return 'EMERGENCY ALERT from Binti Salama: I need urgent help. '
          'My location: $googleMapsUrl. '
          'Please contact emergency services or nearest hospital immediately.';
    } else {
      return 'EMERGENCY ALERT from Binti Salama: I need urgent help. '
          'Location unavailable. '
          'Please contact emergency services or nearest hospital immediately.';
    }
  }

  /// Send SMS to multiple recipients using system SMS app
  Future<void> _sendSMS(List<String> phoneNumbers, String message) async {
    try {
      // Open SMS app with pre-filled message for each contact
      // This ensures reliability across all Android versions and no permission issues
      for (String phone in phoneNumbers) {
        final Uri smsUri = Uri(
          scheme: 'sms',
          path: phone,
          queryParameters: {'body': message},
        );

        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri);
          // Add small delay between opening multiple SMS compose screens
          if (phoneNumbers.length > 1) {
            await Future.delayed(const Duration(seconds: 2));
          }
        } else {
          throw Exception('Could not launch SMS app for $phone');
        }
      }

      AppLogger.info(
        'SMS compose screen opened for ${phoneNumbers.length} recipients',
      );
    } catch (e) {
      AppLogger.error('SMS error', error: e);
      throw Exception('Failed to open SMS: $e');
    }
  }

  /// Format phone number to Kenyan standard
  String _formatPhoneNumber(String phoneNumber) {
    // Remove spaces and special characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Convert to +254 format
    if (cleaned.startsWith('0')) {
      cleaned = '+254${cleaned.substring(1)}';
    } else if (!cleaned.startsWith('+')) {
      cleaned = '+254$cleaned';
    }

    return cleaned;
  }

  /// Test panic button functionality without actually sending SMS
  Future<bool> testPanicButton() async {
    try {
      final position = await _getCurrentLocation();
      AppLogger.info(
        'Location obtained: ${position.latitude}, ${position.longitude}',
      );

      final message = _buildAlertMessage(position);
      AppLogger.info('Alert message: $message');

      return true;
    } catch (e) {
      AppLogger.error('Test failed', error: e);
      return false;
    }
  }

  /// Get panic alert history
  Future<List<PanicAlert>> getPanicHistory(String userId) async {
    return await databaseService.getPanicAlerts(userId);
  }

  /// Check if shake detection is active
  bool get isListening => _isListening;

  /// Dispose of resources
  void dispose() {
    stopShakeDetection();
  }
}

