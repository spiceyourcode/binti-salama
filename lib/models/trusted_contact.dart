class TrustedContact {
  final String id;
  final String userId;
  final String name;
  final String phoneNumber;
  final String contactType;
  final bool isEmergency;
  final String? customAlertMessage;
  final DateTime createdAt;

  TrustedContact({
    required this.id,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.contactType,
    this.isEmergency = true,
    this.customAlertMessage,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone_number': phoneNumber,
      'contact_type': contactType,
      'is_emergency': isEmergency ? 1 : 0,
      'custom_alert_message': customAlertMessage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TrustedContact.fromMap(Map<String, dynamic> map) {
    return TrustedContact(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      phoneNumber: map['phone_number'] as String,
      contactType: map['contact_type'] as String,
      isEmergency: (map['is_emergency'] as int) == 1,
      customAlertMessage: map['custom_alert_message'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  TrustedContact copyWith({
    String? id,
    String? userId,
    String? name,
    String? phoneNumber,
    String? contactType,
    bool? isEmergency,
    String? customAlertMessage,
    DateTime? createdAt,
  }) {
    return TrustedContact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      contactType: contactType ?? this.contactType,
      isEmergency: isEmergency ?? this.isEmergency,
      customAlertMessage: customAlertMessage ?? this.customAlertMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

