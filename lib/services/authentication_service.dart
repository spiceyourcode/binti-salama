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

  // ============ Security Questions for PIN Recovery ============

  /// Hash a security answer (normalize: lowercase, trim whitespace)
  String _hashAnswer(String answer) {
    final normalized = answer.toLowerCase().trim();
    final bytes = utf8.encode(normalized);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Set up security questions for PIN recovery
  Future<void> setupSecurityQuestions(List<Map<String, String>> questionsAndAnswers) async {
    final String? odId = await getCurrentUserId();
    if (odId == null) {
      throw Exception('No user logged in');
    }

    if (questionsAndAnswers.length < 2) {
      throw Exception('At least 2 security questions are required');
    }

    // Delete any existing security questions
    await databaseService.deleteSecurityQuestions(odId);

    // Insert new security questions
    for (var qa in questionsAndAnswers) {
      final question = qa['question'];
      final answer = qa['answer'];
      
      if (question == null || answer == null || answer.trim().isEmpty) {
        throw Exception('Question and answer are required');
      }

      final answerHash = _hashAnswer(answer);
      final id = const Uuid().v4();
      
      await databaseService.insertSecurityQuestion(id, odId, question, answerHash);
    }
  }

  /// Check if user has security questions set up
  Future<bool> hasSecurityQuestions() async {
    final String? odId = await getCurrentUserId();
    if (odId == null) return false;
    return await databaseService.hasSecurityQuestions(odId);
  }

  /// Get the security questions for the current user (without answers)
  Future<List<String>> getSecurityQuestionsList() async {
    final String? odId = await getCurrentUserId();
    if (odId == null) return [];
    
    final questions = await databaseService.getSecurityQuestions(odId);
    return questions.map((q) => q['question'] as String).toList();
  }

  /// Verify security answers and reset PIN if correct
  Future<bool> verifySecurityAnswersAndResetPin(
    List<Map<String, String>> questionsAndAnswers,
    String newPin,
  ) async {
    final String? odId = await getCurrentUserId();
    if (odId == null) {
      throw Exception('No user found');
    }

    if (!_isValidPin(newPin)) {
      throw Exception(AppConstants.errorInvalidPin);
    }

    // Get stored security questions
    final storedQuestions = await databaseService.getSecurityQuestions(odId);
    
    if (storedQuestions.isEmpty) {
      throw Exception('No security questions set up');
    }

    // Verify all answers
    int correctAnswers = 0;
    for (var qa in questionsAndAnswers) {
      final question = qa['question'];
      final answer = qa['answer'];
      
      if (question == null || answer == null) continue;
      
      final answerHash = _hashAnswer(answer);
      
      // Find matching question
      for (var stored in storedQuestions) {
        if (stored['question'] == question && stored['answer_hash'] == answerHash) {
          correctAnswers++;
          break;
        }
      }
    }

    // Require all answers to be correct
    if (correctAnswers < storedQuestions.length) {
      return false;
    }

    // All answers correct - reset PIN
    final String newPinHash = _hashPin(newPin);

    // Update in secure storage
    await _secureStorage.write(
      key: AppConstants.keyPinHash,
      value: newPinHash,
    );

    // Update in database
    final user = await databaseService.getUserById(odId);
    if (user != null) {
      final updatedUser = user.copyWith(pinHash: newPinHash);
      await databaseService.updateUser(updatedUser);
    }

    return true;
  }
}

