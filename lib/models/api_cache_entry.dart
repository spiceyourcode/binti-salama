import 'dart:convert';

/// Model for API cache entries
class ApiCacheEntry {
  final String id;
  final String cacheKey;
  final String cacheType; // 'places', 'geocoding', 'reverse_geocoding', 'route'
  final String data; // JSON string of cached response
  final DateTime createdAt;
  final DateTime expiresAt;
  final Map<String, dynamic>? metadata; // Additional metadata (lat, lng, query, etc.)

  ApiCacheEntry({
    required this.id,
    required this.cacheKey,
    required this.cacheType,
    required this.data,
    required this.createdAt,
    required this.expiresAt,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cache_key': cacheKey,
      'cache_type': cacheType,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'metadata': metadata != null ? jsonEncode(metadata) : null,
    };
  }

  factory ApiCacheEntry.fromMap(Map<String, dynamic> map) {
    return ApiCacheEntry(
      id: map['id'] as String,
      cacheKey: map['cache_key'] as String,
      cacheType: map['cache_type'] as String,
      data: map['data'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      expiresAt: DateTime.parse(map['expires_at'] as String),
      metadata: map['metadata'] != null
          ? jsonDecode(map['metadata'] as String) as Map<String, dynamic>
          : null,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isValid => !isExpired;

  ApiCacheEntry copyWith({
    String? id,
    String? cacheKey,
    String? cacheType,
    String? data,
    DateTime? createdAt,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return ApiCacheEntry(
      id: id ?? this.id,
      cacheKey: cacheKey ?? this.cacheKey,
      cacheType: cacheType ?? this.cacheType,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

