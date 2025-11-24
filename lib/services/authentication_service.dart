import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/app_settings.dart';
import '../utils/constants.dart';
import 'database_service.dart';

class AuthenticationService {
  final DatabaseService databaseService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthenticationService({required this.databaseService});

  /// Create a new user account with PIN
  Future<User> createAccount(String pin) async {
    if (!_isValidPin(pin)) {
      throw Exception(AppConstants.errorInvalidPin);
    }

    final String userId = const Uuid().v4();
    final String pinHash = _hashPin(pin);
    final now = DateTime.now();

    final user = User(
      id: userId,
      pinHash: pinHash,
      createdAt: now,
      lastLogin: now,
    );

    await databaseService.insertUser(user);

    // Create default settings for user
    final settings = AppSettings(
      id: const Uuid().v4(),
      userId: userId,
    );
    await databaseService.insertAppSettings(settings);

    // Store current user ID securely
    await _secureStorage.write(
      key: AppConstants.keyCurrentUserId,
      value: userId,
    );

    await _secureStorage.write(
      key: AppConstants.keyPinHash,
      value: pinHash,
    );

    await _secureStorage.write(
      key: AppConstants.keyLastLoginTime,
      value: now.toIso8601String(),
    );

    return user;
  }

  /// Verify PIN and log in user
  Future<bool> login(String pin) async {
    final String? storedPinHash = await _secureStorage.read(
      key: AppConstants.keyPinHash,
    );

    if (storedPinHash == null) {
      return false;
    }

    final String enteredPinHash = _hashPin(pin);

    if (enteredPinHash == storedPinHash) {
      // Update last login time
      final String? userId = await _secureStorage.read(
        key: AppConstants.keyCurrentUserId,
      );

      if (userId != null) {
        final user = await databaseService.getUserById(userId);
        if (user != null) {
          final updatedUser = user.copyWith(lastLogin: DateTime.now());
          await databaseService.updateUser(updatedUser);
        }
      }

      await _secureStorage.write(
        key: AppConstants.keyLastLoginTime,
        value: DateTime.now().toIso8601String(),
      );

      return true;
    }

    return false;
  }

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated() async {
    final String? lastLoginString = await _secureStorage.read(
      key: AppConstants.keyLastLoginTime,
    );

    if (lastLoginString == null) {
      return false;
    }

    try {
      final lastLogin = DateTime.parse(lastLoginString);
      final now = DateTime.now();
      final difference = now.difference(lastLogin);

      // Check if auto-lock timeout has passed
      final settings = await getCurrentUserSettings();
      final autoLockMinutes = settings?.autoLockMinutes ?? AppConstants.autoLockDefaultMinutes;

      return difference.inMinutes < autoLockMinutes;
    } catch (e) {
      return false;
    }
  }

  /// Log out user
  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.keyLastLoginTime);
  }

  /// Change PIN
  Future<void> changePin(String oldPin, String newPin) async {
    if (!await login(oldPin)) {
      throw Exception('Current PIN is incorrect');
    }

    if (!_isValidPin(newPin)) {
      throw Exception(AppConstants.errorInvalidPin);
    }

    final String newPinHash = _hashPin(newPin);

    // Update in secure storage
    await _secureStorage.write(
      key: AppConstants.keyPinHash,
      value: newPinHash,
    );

    // Update in database
    final String? userId = await _secureStorage.read(
      key: AppConstants.keyCurrentUserId,
    );

    if (userId != null) {
      final user = await databaseService.getUserById(userId);
      if (user != null) {
        final updatedUser = user.copyWith(pinHash: newPinHash);
        await databaseService.updateUser(updatedUser);
      }
    }
  }

  /// Get current user ID
  Future<String?> getCurrentUserId() async {
    return await _secureStorage.read(key: AppConstants.keyCurrentUserId);
  }

  /// Get current user
  Future<User?> getCurrentUser() async {
    final String? userId = await getCurrentUserId();
    if (userId == null) return null;
    return await databaseService.getUserById(userId);
  }

  /// Get current user settings
  Future<AppSettings?> getCurrentUserSettings() async {
    final String? userId = await getCurrentUserId();
    if (userId == null) return null;
    return await databaseService.getAppSettings(userId);
  }

  /// Check if account exists
  Future<bool> hasAccount() async {
    final String? pinHash = await _secureStorage.read(key: AppConstants.keyPinHash);
    return pinHash != null;
  }

  /// Delete account and all data
  Future<void> deleteAccount(String pin) async {
    if (!await login(pin)) {
      throw Exception('Incorrect PIN');
    }

    final String? userId = await getCurrentUserId();
    if (userId != null) {
      await databaseService.clearAllData(userId);
    }

    await _secureStorage.deleteAll();
  }

  /// Hash PIN using SHA-256
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validate PIN format
  bool _isValidPin(String pin) {
    if (pin.length < AppConstants.minPinLength ||
        pin.length > AppConstants.maxPinLength) {
      return false;
    }

    // Check if PIN contains only digits
    final regex = RegExp(r'^\d+$');
    return regex.hasMatch(pin);
  }

  /// Reset last login time (refresh session)
  Future<void> refreshSession() async {
    await _secureStorage.write(
      key: AppConstants.keyLastLoginTime,
      value: DateTime.now().toIso8601String(),
    );
  }
}

