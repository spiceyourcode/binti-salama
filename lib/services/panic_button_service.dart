import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/panic_alert.dart';
import '../models/trusted_contact.dart';
import '../utils/constants.dart';
import 'database_service.dart';

class PanicButtonService {
  final DatabaseService databaseService;
  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;
  List<DateTime> _shakeTimes = [];
  bool _isListening = false;
  VoidCallback? _onPanicTriggered;

  PanicButtonService({required this.databaseService});

  /// Initialize shake detection for panic button
  void initializeShakeDetection(VoidCallback onPanicTriggered) {
    if (_isListening) return;

    _onPanicTriggered = onPanicTriggered;
    _shakeTimes = [];
    _isListening = true;

    _accelerometerSubscription = userAccelerometerEventStream().listen(
      _handleAccelerometerEvent,
      onError: (error) {
        print('Accelerometer error: $error');
      },
    );
  }

  void _handleAccelerometerEvent(UserAccelerometerEvent event) {
    final double magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    if (magnitude > AppConstants.shakeThreshold) {
      final now = DateTime.now();
      _shakeTimes.add(now);

      // Remove old shake events outside the time window
      _shakeTimes.removeWhere((time) {
        final difference = now.difference(time);
        return difference.inSeconds > AppConstants.shakeWindowSeconds;
      });

      // Check if required number of shakes detected
      if (_shakeTimes.length >= AppConstants.requiredShakes) {
        _shakeTimes.clear();
        _onPanicTriggered?.call();
      }
    }
  }

  /// Stop shake detection
  void stopShakeDetection() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _isListening = false;
    _shakeTimes.clear();
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
          print('Failed to get location: $e');
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
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
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

      print('SMS compose screen opened for ${phoneNumbers.length} recipients');
    } catch (e) {
      print('SMS error: $e');
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
      print('Location obtained: ${position.latitude}, ${position.longitude}');

      final message = _buildAlertMessage(position);
      print('Alert message: $message');

      return true;
    } catch (e) {
      print('Test failed: $e');
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
