import 'package:flutter/foundation.dart';
import '../utils/localization.dart';
import 'settings_service.dart';
import 'authentication_service.dart';

/// Provides current app language and a localized helper.
class LanguageProvider extends ChangeNotifier {
  SettingsService? settingsService;
  AuthenticationService? authenticationService;

  String _languageCode = 'en';

  LanguageProvider({this.settingsService, this.authenticationService});

  String get languageCode => _languageCode;

  AppLocalizations get t => AppLocalizations(_languageCode);

  /// Initialize language from settings for current user if available.
  Future<void> loadInitialLanguage() async {
    try {
      final userId = await authenticationService?.getCurrentUserId();
      if (userId != null && settingsService != null) {
        final lang = await settingsService!.getLanguage(userId);
        _languageCode = lang;
        notifyListeners();
      }
    } catch (_) {
      // ignore and keep default
    }
  }

  /// Update language both locally and in persistent settings (if services available).
  Future<void> setLanguage(String language) async {
    _languageCode = language;
    notifyListeners();

    try {
      final userId = await authenticationService?.getCurrentUserId();
      if (userId != null && settingsService != null) {
        await settingsService!.updateLanguage(userId, language);
      }
    } catch (_) {
      // ignore persistence failures
    }
  }
}
