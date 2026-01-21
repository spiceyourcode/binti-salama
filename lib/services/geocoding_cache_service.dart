import 'package:geocoding/geocoding.dart';
import 'maps_cache_service.dart';
import 'connectivity_service.dart';
import '../utils/logger.dart';

/// Wrapper service for geocoding with caching support
class GeocodingCacheService {
  final MapsCacheService? cacheService;
  final ConnectivityService? connectivityService;

  GeocodingCacheService({
    this.cacheService,
    this.connectivityService,
  });

  /// Get coordinates from address (forward geocoding) with caching
  Future<List<Location>?> locationFromAddress(String address) async {
    if (address.isEmpty) return null;

    // Check cache first
    if (cacheService != null) {
      final cacheKey = cacheService!.generateGeocodingCacheKey(address);
      final cachedData = await cacheService!.getCachedData(cacheKey);
      
      if (cachedData != null) {
        AppLogger.info('Using cached geocoding for address: $address');
        try {
          final locations = (cachedData['locations'] as List<dynamic>?)
              ?.map((loc) => Location(
                    latitude: loc['latitude'] as double,
                    longitude: loc['longitude'] as double,
                    timestamp: DateTime.now(),
                  ))
              .toList();
          return locations;
        } catch (e) {
          AppLogger.warning('Error parsing cached geocoding data: $e');
        }
      }
    }

    // Check connectivity
    final isConnected = await connectivityService?.isConnected() ?? true;
    if (!isConnected) {
      AppLogger.info('No internet connection for geocoding');
      return null;
    }

    // Make API call
    try {
      final locations = await locationFromAddress(address);
      
      // Cache the result
      if (cacheService != null && locations != null && locations.isNotEmpty) {
        final cacheKey = cacheService!.generateGeocodingCacheKey(address);
        await cacheService!.setCachedData(
          cacheKey: cacheKey,
          cacheType: CacheType.geocoding,
          data: {
            'locations': locations.map((loc) => {
              'latitude': loc.latitude,
              'longitude': loc.longitude,
            }).toList(),
          },
          metadata: {'address': address},
        );
      }

      return locations;
    } catch (e) {
      AppLogger.warning('Geocoding error: $e');
      return null;
    }
  }

  /// Get address from coordinates (reverse geocoding) with caching
  Future<List<Placemark>?> placemarkFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    // Check cache first
    if (cacheService != null) {
      final cacheKey = cacheService!.generateReverseGeocodingCacheKey(
        latitude,
        longitude,
      );
      final cachedData = await cacheService!.getCachedData(cacheKey);
      
      if (cachedData != null) {
        AppLogger.info('Using cached reverse geocoding for coordinates');
        try {
          // Note: Placemark doesn't have a fromMap, so we'll need to reconstruct
          // For now, return null to trigger API call (can be enhanced later)
        } catch (e) {
          AppLogger.warning('Error parsing cached reverse geocoding: $e');
        }
      }
    }

    // Check connectivity
    final isConnected = await connectivityService?.isConnected() ?? true;
    if (!isConnected) {
      AppLogger.info('No internet connection for reverse geocoding');
      return null;
    }

    // Make API call
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      // Cache the result (store as JSON for now)
      if (cacheService != null && placemarks != null && placemarks.isNotEmpty) {
        final cacheKey = cacheService!.generateReverseGeocodingCacheKey(
          latitude,
          longitude,
        );
        await cacheService!.setCachedData(
          cacheKey: cacheKey,
          cacheType: CacheType.reverseGeocoding,
          data: {
            'placemarks': placemarks.map((p) => {
              'name': p.name,
              'street': p.street,
              'locality': p.locality,
              'subLocality': p.subLocality,
              'administrativeArea': p.administrativeArea,
              'subAdministrativeArea': p.subAdministrativeArea,
              'country': p.country,
              'postalCode': p.postalCode,
            }).toList(),
          },
          metadata: {
            'latitude': latitude,
            'longitude': longitude,
          },
        );
      }

      return placemarks;
    } catch (e) {
      AppLogger.warning('Reverse geocoding error: $e');
      return null;
    }
  }
}

