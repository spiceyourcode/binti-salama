class IncidentLog {
  final String id;
  final String userId;
  final DateTime incidentDate;
  final double? latitude;
  final double? longitude;
  final String? locationAddress;
  final String description;
  final String? perpetratorDescription;
  final String? witnesses;
  final String? actionsTaken;
  final String? medicalFacilityVisited;
  final bool evidencePreserved;
  final bool policeReportFiled;
  final String? obNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  IncidentLog({
    required this.id,
    required this.userId,
    required this.incidentDate,
    this.latitude,
    this.longitude,
    this.locationAddress,
    required this.description,
    this.perpetratorDescription,
    this.witnesses,
    this.actionsTaken,
    this.medicalFacilityVisited,
    this.evidencePreserved = false,
    this.policeReportFiled = false,
    this.obNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'incident_date': incidentDate.toIso8601String(),
      'location_latitude': latitude,
      'location_longitude': longitude,
      'location_address': locationAddress,
      'description': description,
      'perpetrator_description': perpetratorDescription,
      'witnesses': witnesses,
      'actions_taken': actionsTaken,
      'medical_facility_visited': medicalFacilityVisited,
      'evidence_preserved': evidencePreserved ? 1 : 0,
      'police_report_filed': policeReportFiled ? 1 : 0,
      'ob_number': obNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory IncidentLog.fromMap(Map<String, dynamic> map) {
    return IncidentLog(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      incidentDate: DateTime.parse(map['incident_date'] as String),
      latitude: map['location_latitude'] as double?,
      longitude: map['location_longitude'] as double?,
      locationAddress: map['location_address'] as String?,
      description: map['description'] as String,
      perpetratorDescription: map['perpetrator_description'] as String?,
      witnesses: map['witnesses'] as String?,
      actionsTaken: map['actions_taken'] as String?,
      medicalFacilityVisited: map['medical_facility_visited'] as String?,
      evidencePreserved: (map['evidence_preserved'] as int) == 1,
      policeReportFiled: (map['police_report_filed'] as int) == 1,
      obNumber: map['ob_number'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  IncidentLog copyWith({
    String? id,
    String? userId,
    DateTime? incidentDate,
    double? latitude,
    double? longitude,
    String? locationAddress,
    String? description,
    String? perpetratorDescription,
    String? witnesses,
    String? actionsTaken,
    String? medicalFacilityVisited,
    bool? evidencePreserved,
    bool? policeReportFiled,
    String? obNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IncidentLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      incidentDate: incidentDate ?? this.incidentDate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAddress: locationAddress ?? this.locationAddress,
      description: description ?? this.description,
      perpetratorDescription: perpetratorDescription ?? this.perpetratorDescription,
      witnesses: witnesses ?? this.witnesses,
      actionsTaken: actionsTaken ?? this.actionsTaken,
      medicalFacilityVisited: medicalFacilityVisited ?? this.medicalFacilityVisited,
      evidencePreserved: evidencePreserved ?? this.evidencePreserved,
      policeReportFiled: policeReportFiled ?? this.policeReportFiled,
      obNumber: obNumber ?? this.obNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

