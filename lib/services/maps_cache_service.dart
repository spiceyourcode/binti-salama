import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/api_cache_entry.dart';
import '../utils/logger.dart';
import 'database_service.dart';

/// Cache types for different API responses
enum CacheType {
  places,
  geocoding,
  reverseGeocoding,
  route,
}

/// Service for caching Google Maps API responses
class MapsCacheService {
  final DatabaseService databaseService;
  
  // Cache expiration times (in hours)
  static const int placesCacheHours = 24; // Places data valid for 24 hours
  static const int geocodingCacheHours = 168; // Geocoding valid for 7 days (addresses don't change often)
  static const int reverseGeocodingCacheHours = 168; // Reverse geocoding valid for 7 days
  static const int routeCacheHours = 1; // Routes valid for 1 hour (traffic changes)

  MapsCacheService({required this.databaseService});

  /// Generate a cache key from parameters
  String generateCacheKey({
    required CacheType type,
    required Map<String, dynamic> parameters,
  }) {
    // Sort parameters for consistent key generation
    final sortedParams = Map.fromEntries(
      parameters.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    
    final paramString = sortedParams.entries
        .map((e) => '${e.key}:${e.value}')
        .join('|');
    
    return '${type.name}_$paramString';
  }

  /// Generate cache key for places search
  String generatePlacesCacheKey({
    required double latitude,
    required double longitude,
    String? serviceType,
    String? placeType,
    double? radiusMeters,
  }) {
    return generateCacheKey(
      type: CacheType.places,
      parameters: {
        'lat': latitude.toStringAsFixed(4),
        'lng': longitude.toStringAsFixed(4),
        'serviceType': serviceType ?? '',
        'placeType': placeType ?? '',
        'radius': radiusMeters?.toStringAsFixed(0) ?? '10000',
      },
    );
  }

  /// Generate cache key for geocoding (address to coordinates)
  String generateGeocodingCacheKey(String address) {
    return generateCacheKey(
      type: CacheType.geocoding,
      parameters: {'address': address.toLowerCase().trim()},
    );
  }

  /// Generate cache key for reverse geocoding (coordinates to address)
  String generateReverseGeocodingCacheKey(double latitude, double longitude) {
    return generateCacheKey(
      type: CacheType.reverseGeocoding,
      parameters: {
        'lat': latitude.toStringAsFixed(6),
        'lng': longitude.toStringAsFixed(6),
      },
    );
  }

  /// Get cached data if valid
  Future<Map<String, dynamic>?> getCachedData(String cacheKey) async {
    try {
      final db = await databaseService.database;
      final maps = await db.query(
        'api_cache',
        where: 'cache_key = ?',
        whereArgs: [cacheKey],
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      final entry = ApiCacheEntry.fromMap(maps.first);

      // Check if cache is expired
      if (entry.isExpired) {
        AppLogger.info('Cache entry expired for key: $cacheKey');
        await _deleteCacheEntry(cacheKey);
        return null;
      }

      AppLogger.info('Cache hit for key: $cacheKey');
      return jsonDecode(entry.data) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.warning('Error reading cache: $e');
      return null;
    }
  }

  /// Store data in cache
  Future<void> setCachedData({
    required String cacheKey,
    required CacheType cacheType,
    required Map<String, dynamic> data,
    Map<String, dynamic>? metadata,
    int? customExpirationHours,
  }) async {
    try {
      final expirationHours = customExpirationHours ?? _getDefaultExpirationHours(cacheType);
      final now = DateTime.now();
      final expiresAt = now.add(Duration(hours: expirationHours));

      final entry = ApiCacheEntry(
        id: cacheKey, // Use cache key as ID for easy lookup
        cacheKey: cacheKey,
        cacheType: cacheType.name,
        data: jsonEncode(data),
        createdAt: now,
        expiresAt: expiresAt,
        metadata: metadata,
      );

      final db = await databaseService.database;
      await db.insert(
        'api_cache',
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      AppLogger.info('Cached data for key: $cacheKey (expires in $expirationHours hours)');
    } catch (e) {
      AppLogger.warning('Error caching data: $e');
    }
  }

  /// Delete a specific cache entry
  Future<void> _deleteCacheEntry(String cacheKey) async {
    try {
      final db = await databaseService.database;
      await db.delete(
        'api_cache',
        where: 'cache_key = ?',
        whereArgs: [cacheKey],
      );
    } catch (e) {
      AppLogger.warning('Error deleting cache entry: $e');
    }
  }

  /// Clear all expired cache entries
  Future<void> clearExpiredCache() async {
    try {
      final db = await databaseService.database;
      final now = DateTime.now().toIso8601String();
      final deleted = await db.delete(
        'api_cache',
        where: 'expires_at < ?',
        whereArgs: [now],
      );
      if (deleted > 0) {
        AppLogger.info('Cleared $deleted expired cache entries');
      }
    } catch (e) {
      AppLogger.warning('Error clearing expired cache: $e');
    }
  }

  /// Clear all cache entries of a specific type
  Future<void> clearCacheByType(CacheType type) async {
    try {
      final db = await databaseService.database;
      final deleted = await db.delete(
        'api_cache',
        where: 'cache_type = ?',
        whereArgs: [type.name],
      );
      if (deleted > 0) {
        AppLogger.info('Cleared $deleted cache entries of type: ${type.name}');
      }
    } catch (e) {
      AppLogger.warning('Error clearing cache by type: $e');
    }
  }

  /// Clear all cache entries
  Future<void> clearAllCache() async {
    try {
      final db = await databaseService.database;
      await db.delete('api_cache');
      AppLogger.info('Cleared all cache entries');
    } catch (e) {
      AppLogger.warning('Error clearing all cache: $e');
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final db = await databaseService.database;
      final total = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM api_cache'),
      ) ?? 0;

      final expired = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM api_cache WHERE expires_at < ?',
          [DateTime.now().toIso8601String()],
        ),
      ) ?? 0;

      return {
        'total': total,
        'expired': expired,
        'valid': total - expired,
      };
    } catch (e) {
      AppLogger.warning('Error getting cache stats: $e');
      return {'total': 0, 'expired': 0, 'valid': 0};
    }
  }

  /// Get default expiration hours for cache type
  int _getDefaultExpirationHours(CacheType type) {
    switch (type) {
      case CacheType.places:
        return placesCacheHours;
      case CacheType.geocoding:
        return geocodingCacheHours;
      case CacheType.reverseGeocoding:
        return reverseGeocodingCacheHours;
      case CacheType.route:
        return routeCacheHours;
    }
  }
}

