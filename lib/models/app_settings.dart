class AppSettings {
  final String id;
  final String userId;
  final String language;
  final String panicTriggerType;
  final bool notificationsEnabled;
  final bool disguiseMode;
  final int autoLockMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppSettings({
    required this.id,
    required this.userId,
    this.language = 'en',
    this.panicTriggerType = 'shake',
    this.notificationsEnabled = false,
    this.disguiseMode = false,
    this.autoLockMinutes = 5,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'language': language,
      'panic_trigger_type': panicTriggerType,
      'notifications_enabled': notificationsEnabled ? 1 : 0,
      'disguise_mode': disguiseMode ? 1 : 0,
      'auto_lock_minutes': autoLockMinutes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      language: map['language'] as String,
      panicTriggerType: map['panic_trigger_type'] as String,
      notificationsEnabled: (map['notifications_enabled'] as int) == 1,
      disguiseMode: (map['disguise_mode'] as int) == 1,
      autoLockMinutes: map['auto_lock_minutes'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  AppSettings copyWith({
    String? id,
    String? userId,
    String? language,
    String? panicTriggerType,
    bool? notificationsEnabled,
    bool? disguiseMode,
    int? autoLockMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      language: language ?? this.language,
      panicTriggerType: panicTriggerType ?? this.panicTriggerType,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      disguiseMode: disguiseMode ?? this.disguiseMode,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

