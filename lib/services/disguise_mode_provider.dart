import 'package:flutter/material.dart';
import 'authentication_service.dart';
import 'settings_service.dart';

/// Constants for disguise mode appearance
class DisguiseConstants {
  // Disguised app identity (looks like a calculator app)
  static const String disguisedAppName = 'Calculator';
  static const String disguisedTagline = 'Simple & Fast';
  static const IconData disguisedIcon = Icons.calculate_outlined;
  static const Color disguisedPrimaryColor = Color(0xFF607D8B); // Blue Grey
  static const Color disguisedAccentColor = Color(0xFF78909C);

  // Normal app identity
  static const String normalAppName = 'Binti Salama';
  static const String normalTagline = 'Safe Girl - Your Confidential Support';
  static const IconData normalIcon = Icons.security;
  static const Color normalPrimaryColor = Color(0xFF6B4CE6);
  static const Color normalAccentColor = Color(0xFF00C9B7);
}

/// Provider that manages disguise mode state across the app
class DisguiseModeProvider extends ChangeNotifier {
  bool _isDisguised = false;
  bool _isLoaded = false;

  AuthenticationService? _authService;
  SettingsService? _settingsService;

  bool get isDisguised => _isDisguised;
  bool get isLoaded => _isLoaded;

  // Getters for current app appearance based on disguise mode
  String get appName => _isDisguised 
      ? DisguiseConstants.disguisedAppName 
      : DisguiseConstants.normalAppName;

  String get appTagline => _isDisguised 
      ? DisguiseConstants.disguisedTagline 
      : DisguiseConstants.normalTagline;

  IconData get appIcon => _isDisguised 
      ? DisguiseConstants.disguisedIcon 
      : DisguiseConstants.normalIcon;

  Color get primaryColor => _isDisguised 
      ? DisguiseConstants.disguisedPrimaryColor 
      : DisguiseConstants.normalPrimaryColor;

  Color get accentColor => _isDisguised 
      ? DisguiseConstants.disguisedAccentColor 
      : DisguiseConstants.normalAccentColor;

  /// Set dependencies (called from ProxyProvider)
  void setDependencies(AuthenticationService auth, SettingsService settings) {
    _authService = auth;
    _settingsService = settings;
  }

  /// Load the disguise mode setting from storage
  Future<void> loadDisguiseMode() async {
    if (_authService == null || _settingsService == null) {
      _isLoaded = true;
      return;
    }

    try {
      final userId = await _authService!.getCurrentUserId();
      if (userId != null) {
        _isDisguised = await _settingsService!.isDisguiseModeEnabled(userId);
      }
    } catch (e) {
      // If loading fails, default to not disguised
      _isDisguised = false;
    }
    
    _isLoaded = true;
    notifyListeners();
  }

  /// Update the disguise mode setting
  Future<void> setDisguiseMode(bool enabled) async {
    if (_authService == null || _settingsService == null) return;

    try {
      final userId = await _authService!.getCurrentUserId();
      if (userId != null) {
        await _settingsService!.updateDisguiseMode(userId, enabled);
        _isDisguised = enabled;
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// Toggle disguise mode
  Future<void> toggleDisguiseMode() async {
    await setDisguiseMode(!_isDisguised);
  }

  /// Refresh the disguise mode from storage (call after settings change)
  Future<void> refresh() async {
    await loadDisguiseMode();
  }
}

