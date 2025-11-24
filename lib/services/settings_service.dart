import 'package:uuid/uuid.dart';
import '../models/app_settings.dart';
import '../utils/constants.dart';
import 'database_service.dart';

class SettingsService {
  final DatabaseService databaseService;

  SettingsService({required this.databaseService});

  /// Get settings for a user
  Future<AppSettings> getSettings(String userId) async {
    var settings = await databaseService.getAppSettings(userId);
    
    // Create default settings if none exist
    if (settings == null) {
      settings = AppSettings(
        id: const Uuid().v4(),
        userId: userId,
      );
      await databaseService.insertAppSettings(settings);
    }
    
    return settings;
  }

  /// Update settings
  Future<void> updateSettings(AppSettings settings) async {
    final updatedSettings = settings.copyWith(updatedAt: DateTime.now());
    await databaseService.updateAppSettings(updatedSettings);
  }

  /// Update language
  Future<void> updateLanguage(String userId, String language) async {
    final settings = await getSettings(userId);
    final updated = settings.copyWith(language: language);
    await updateSettings(updated);
  }

  /// Update panic trigger type
  Future<void> updatePanicTrigger(String userId, String triggerType) async {
    final settings = await getSettings(userId);
    final updated = settings.copyWith(panicTriggerType: triggerType);
    await updateSettings(updated);
  }

  /// Update notifications setting
  Future<void> updateNotifications(String userId, bool enabled) async {
    final settings = await getSettings(userId);
    final updated = settings.copyWith(notificationsEnabled: enabled);
    await updateSettings(updated);
  }

  /// Update disguise mode
  Future<void> updateDisguiseMode(String userId, bool enabled) async {
    final settings = await getSettings(userId);
    final updated = settings.copyWith(disguiseMode: enabled);
    await updateSettings(updated);
  }

  /// Update auto-lock minutes
  Future<void> updateAutoLockMinutes(String userId, int minutes) async {
    final settings = await getSettings(userId);
    final updated = settings.copyWith(autoLockMinutes: minutes);
    await updateSettings(updated);
  }

  /// Get current language
  Future<String> getLanguage(String userId) async {
    final settings = await getSettings(userId);
    return settings.language;
  }

  /// Get current panic trigger type
  Future<String> getPanicTriggerType(String userId) async {
    final settings = await getSettings(userId);
    return settings.panicTriggerType;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled(String userId) async {
    final settings = await getSettings(userId);
    return settings.notificationsEnabled;
  }

  /// Check if disguise mode is enabled
  Future<bool> isDisguiseModeEnabled(String userId) async {
    final settings = await getSettings(userId);
    return settings.disguiseMode;
  }

  /// Get auto-lock minutes
  Future<int> getAutoLockMinutes(String userId) async {
    final settings = await getSettings(userId);
    return settings.autoLockMinutes;
  }

  /// Reset settings to default
  Future<void> resetToDefaults(String userId) async {
    final defaultSettings = AppSettings(
      id: const Uuid().v4(),
      userId: userId,
      language: AppConstants.languageEnglish,
      panicTriggerType: AppConstants.panicTriggerShake,
      notificationsEnabled: false,
      disguiseMode: false,
      autoLockMinutes: AppConstants.autoLockDefaultMinutes,
    );
    
    await updateSettings(defaultSettings);
  }
}

