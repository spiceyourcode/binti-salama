import 'dart:math';

class Service {
  final String id;
  final String name;
  final String type;
  final String county;
  final String address;
  final String phoneNumber;
  final double latitude;
  final double longitude;
  final String operatingHours;
  final List<String> servicesOffered;
  final bool youthFriendly;
  final String? website;

  Service({
    required this.id,
    required this.name,
    required this.type,
    required this.county,
    required this.address,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
    required this.operatingHours,
    required this.servicesOffered,
    required this.youthFriendly,
    this.website,
  });

  /// Calculate distance in kilometers using Haversine formula
  double distanceFrom(double userLat, double userLon) {
    const double earthRadiusKm = 6371.0;
    final dLat = _toRadians(latitude - userLat);
    final dLon = _toRadians(longitude - userLon);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
              cos(_toRadians(userLat)) * cos(_toRadians(latitude)) *
              sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRadians(double degrees) => degrees * (pi / 180);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'county': county,
      'address': address,
      'phone_number': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'operating_hours': operatingHours,
      'services_offered': servicesOffered.join('|'),
      'youth_friendly': youthFriendly ? 1 : 0,
      'website': website,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      county: map['county'] as String,
      address: map['address'] as String,
      phoneNumber: map['phone_number'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      operatingHours: map['operating_hours'] as String,
      servicesOffered: (map['services_offered'] as String).split('|'),
      youthFriendly: (map['youth_friendly'] as int) == 1,
      website: map['website'] as String?,
    );
  }

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      county: json['county'] as String,
      address: json['address'] as String,
      phoneNumber: json['phoneNumber'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      operatingHours: json['operatingHours'] as String,
      servicesOffered: List<String>.from(json['servicesOffered'] as List),
      youthFriendly: json['youthFriendly'] as bool,
      website: json['website'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'county': county,
      'address': address,
      'phoneNumber': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'operatingHours': operatingHours,
      'servicesOffered': servicesOffered,
      'youthFriendly': youthFriendly,
      'website': website,
    };
  }
}

class ServiceWithDistance {
  final Service service;
  final double distance;

  ServiceWithDistance({
    required this.service,
    required this.distance,
  });

  String get distanceFormatted {
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} m';
    }
    return '${distance.toStringAsFixed(1)} km';
  }
}

