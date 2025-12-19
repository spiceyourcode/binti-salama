import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import '../utils/logger.dart';

/// Service for handling biometric authentication (fingerprint/face ID)
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      final result = canCheck || isSupported;
      AppLogger.info('Biometric support check: canCheck=$canCheck, isSupported=$isSupported, result=$result');
      return result;
    } catch (e) {
      AppLogger.warning('Error checking biometric support: $e');
      return false;
    }
  }

  /// Check if biometrics are properly set up (device supports AND has enrolled biometrics)
  Future<bool> isBiometricReady() async {
    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) return false;

      final availableBiometrics = await getAvailableBiometrics();
      final hasEnrolled = availableBiometrics.isNotEmpty;
      
      AppLogger.info('Biometric ready check: isSupported=$isSupported, hasEnrolled=$hasEnrolled, types=$availableBiometrics');
      return hasEnrolled;
    } catch (e) {
      AppLogger.warning('Error checking biometric readiness: $e');
      return false;
    }
  }

  /// Get available biometric types on the device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      AppLogger.warning('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate using biometrics
  /// Returns true if authentication succeeds, false otherwise
  Future<bool> authenticate({
    String reason = 'Authenticate to access the app',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      // First check if device supports biometrics
      final isAvailable = await isDeviceSupported();
      if (!isAvailable) {
        AppLogger.warning('Biometric authentication not available on this device');
        return false;
      }

      // Check if there are any enrolled biometrics
      final availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        AppLogger.warning('No biometrics enrolled on this device');
        return false;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false, // Allow fallback to device PIN/pattern if needed
        ),
      );

      if (didAuthenticate) {
        AppLogger.info('Biometric authentication successful');
      } else {
        AppLogger.info('Biometric authentication failed or cancelled');
      }

      return didAuthenticate;
    } on PlatformException catch (e) {
      AppLogger.error('Biometric authentication error: ${e.code} - ${e.message}', error: e);
      // Return more specific error information
      if (e.code == 'NotAvailable') {
        AppLogger.warning('Biometric authentication not available');
      } else if (e.code == 'NotEnrolled') {
        AppLogger.warning('No biometrics enrolled on device');
      } else if (e.code == 'LockedOut') {
        AppLogger.warning('Biometric authentication locked out');
      } else if (e.code == 'PermanentlyLockedOut') {
        AppLogger.warning('Biometric authentication permanently locked out');
      }
      return false;
    } catch (e) {
      AppLogger.error('Unexpected error during biometric authentication', error: e);
      return false;
    }
  }

  /// Stop any ongoing authentication
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      AppLogger.warning('Error stopping authentication: $e');
    }
  }

  /// Get a user-friendly name for the biometric type
  String getBiometricTypeName(List<BiometricType> types) {
    if (types.isEmpty) return 'Biometric';
    
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (types.contains(BiometricType.strong)) {
      return 'Biometric';
    } else if (types.contains(BiometricType.weak)) {
      return 'Biometric';
    }
    
    return 'Biometric';
  }
}

