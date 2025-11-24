class PanicAlert {
  final String id;
  final String userId;
  final DateTime triggeredAt;
  final double? latitude;
  final double? longitude;
  final int contactsAlerted;
  final bool success;
  final String? errorMessage;

  PanicAlert({
    required this.id,
    required this.userId,
    required this.triggeredAt,
    this.latitude,
    this.longitude,
    required this.contactsAlerted,
    required this.success,
    this.errorMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'triggered_at': triggeredAt.toIso8601String(),
      'location_latitude': latitude,
      'location_longitude': longitude,
      'contacts_alerted': contactsAlerted,
      'success': success ? 1 : 0,
      'error_message': errorMessage,
    };
  }

  factory PanicAlert.fromMap(Map<String, dynamic> map) {
    return PanicAlert(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      triggeredAt: DateTime.parse(map['triggered_at'] as String),
      latitude: map['location_latitude'] as double?,
      longitude: map['location_longitude'] as double?,
      contactsAlerted: map['contacts_alerted'] as int,
      success: (map['success'] as int) == 1,
      errorMessage: map['error_message'] as String?,
    );
  }
}

