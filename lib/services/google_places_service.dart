import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';
import 'maps_cache_service.dart';
import 'connectivity_service.dart';

/// Service for fetching nearby places using Google Places API
/// This provides an optional online data source for finding services
/// Includes caching for offline support and performance optimization
class GooglePlacesService {
  final String? apiKey;
  final http.Client _httpClient;
  final MapsCacheService? cacheService;
  final ConnectivityService? connectivityService;

  // Google Places API endpoints
  static const String _nearbySearchUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
  static const String _placeDetailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';

  // Place types relevant to GBV support services
  static const Map<String, List<String>> serviceTypeToPlaceTypes = {
    'GBVRC': ['hospital', 'health'],
    'clinic': ['hospital', 'doctor', 'health', 'physiotherapist'],
    'police': ['police'],
    'rescue_center': ['local_government_office', 'social_services'],
  };

  // Keywords to search for GBV-related services
  static const List<String> gbvKeywords = [
    'GBV',
    'gender violence',
    'women support',
    'crisis center',
    'safe house',
    'women shelter',
  ];

  GooglePlacesService({
    this.apiKey,
    http.Client? httpClient,
    this.cacheService,
    this.connectivityService,
  }) : _httpClient = httpClient ?? http.Client();

  /// Check if the service is available (has valid API key)
  bool get isAvailable => apiKey != null && apiKey!.isNotEmpty;

  /// Fetch nearby services from Google Places API
  /// Returns empty list if API key is not configured or request fails
  Future<List<Service>> fetchNearbyServices({
    required double latitude,
    required double longitude,
    String? serviceType,
    double radiusMeters = 10000, // 10km default
  }) async {
    if (!isAvailable) {
      AppLogger.info('Google Places API key not configured, skipping online fetch');
      return [];
    }

    try {
      final List<Service> allServices = [];
      
      // Determine which place types to search for
      List<String> placeTypes;
      if (serviceType != null && serviceTypeToPlaceTypes.containsKey(serviceType)) {
        placeTypes = serviceTypeToPlaceTypes[serviceType]!;
      } else {
        // Search all relevant types
        placeTypes = serviceTypeToPlaceTypes.values.expand((e) => e).toSet().toList();
      }

      // Search for each place type
      for (final placeType in placeTypes) {
        final services = await _searchNearbyPlaces(
          latitude: latitude,
          longitude: longitude,
          placeType: placeType,
          radiusMeters: radiusMeters,
          serviceType: serviceType,
        );
        allServices.addAll(services);
      }

      // Remove duplicates based on place ID
      final uniqueServices = <String, Service>{};
      for (final service in allServices) {
        uniqueServices[service.id] = service;
      }

      AppLogger.info('Fetched ${uniqueServices.length} services from Google Places API');
      return uniqueServices.values.toList();
    } catch (e) {
      AppLogger.error('Failed to fetch from Google Places API', error: e);
      return [];
    }
  }

  Future<List<Service>> _searchNearbyPlaces({
    required double latitude,
    required double longitude,
    required String placeType,
    required double radiusMeters,
    String? serviceType,
  }) async {
    // Generate cache key
    final cacheKey = cacheService?.generatePlacesCacheKey(
      latitude: latitude,
      longitude: longitude,
      serviceType: serviceType,
      placeType: placeType,
      radiusMeters: radiusMeters,
    );

    // Try to get from cache first
    if (cacheService != null && cacheKey != null) {
      final cachedData = await cacheService!.getCachedData(cacheKey);
      if (cachedData != null) {
        AppLogger.info('Using cached Places API data for $placeType');
        final results = cachedData['results'] as List<dynamic>? ?? [];
        return results.map((place) {
          return _placeToService(place as Map<String, dynamic>, serviceType ?? placeType);
        }).toList();
      }
    }

    // Check connectivity before making API call
    final isConnected = await connectivityService?.isConnected() ?? true;
    if (!isConnected) {
      AppLogger.info('No internet connection, attempting to use cache');
      // Try to get expired cache as fallback
      if (cacheService != null && cacheKey != null) {
        final cachedData = await cacheService!.getCachedData(cacheKey);
        if (cachedData != null) {
          AppLogger.info('Using expired cache as offline fallback');
          final results = cachedData['results'] as List<dynamic>? ?? [];
          return results.map((place) {
            return _placeToService(place as Map<String, dynamic>, serviceType ?? placeType);
          }).toList();
        }
      }
      AppLogger.warning('No cache available and device is offline');
      return [];
    }

    // Make API call
    final uri = Uri.parse(_nearbySearchUrl).replace(queryParameters: {
      'location': '$latitude,$longitude',
      'radius': radiusMeters.toStringAsFixed(0),
      'type': placeType,
      'key': apiKey!,
    });

    try {
      AppLogger.info('Places API Request: $uri');
      final response = await _httpClient.get(uri).timeout(
        Duration(seconds: AppConstants.connectionTimeoutSeconds),
      );

      AppLogger.info('Places API Response Status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        AppLogger.warning('Google Places API returned ${response.statusCode}');
        AppLogger.warning('Response body: ${response.body}');
        // Try cache as fallback on API error
        if (cacheService != null && cacheKey != null) {
          final cachedData = await cacheService!.getCachedData(cacheKey);
          if (cachedData != null) {
            AppLogger.info('Using cache as fallback after API error');
            final results = cachedData['results'] as List<dynamic>? ?? [];
            return results.map((place) {
              return _placeToService(place as Map<String, dynamic>, serviceType ?? placeType);
            }).toList();
          }
        }
        return [];
      }

      final data = json.decode(response.body);
      
      // Check for API-level errors (status field in response)
      final status = data['status'] as String?;
      if (status != null && status != 'OK' && status != 'ZERO_RESULTS') {
        AppLogger.warning('Places API status: $status');
        AppLogger.warning('Error message: ${data['error_message'] ?? 'No error message'}');
        // Try cache as fallback
        if (cacheService != null && cacheKey != null) {
          final cachedData = await cacheService!.getCachedData(cacheKey);
          if (cachedData != null) {
            AppLogger.info('Using cache as fallback after API status error');
            final results = cachedData['results'] as List<dynamic>? ?? [];
            return results.map((place) {
              return _placeToService(place as Map<String, dynamic>, serviceType ?? placeType);
            }).toList();
          }
        }
        return [];
      }
      
      final results = data['results'] as List<dynamic>? ?? [];
      AppLogger.info('Places API returned ${results.length} results');

      // Cache the successful response
      if (cacheService != null && cacheKey != null && results.isNotEmpty) {
        await cacheService!.setCachedData(
          cacheKey: cacheKey,
          cacheType: CacheType.places,
          data: data,
          metadata: {
            'latitude': latitude,
            'longitude': longitude,
            'placeType': placeType,
            'serviceType': serviceType,
            'radiusMeters': radiusMeters,
          },
        );
      }

      return results.map((place) {
        return _placeToService(place as Map<String, dynamic>, serviceType ?? placeType);
      }).toList();
    } catch (e) {
      AppLogger.warning('Places API search failed for type $placeType: $e');
      // Try cache as fallback on exception
      if (cacheService != null && cacheKey != null) {
        final cachedData = await cacheService!.getCachedData(cacheKey);
        if (cachedData != null) {
          AppLogger.info('Using cache as fallback after exception');
          final results = cachedData['results'] as List<dynamic>? ?? [];
          return results.map((place) {
            return _placeToService(place as Map<String, dynamic>, serviceType ?? placeType);
          }).toList();
        }
      }
      return [];
    }
  }

  /// Convert Google Places API result to Service model
  Service _placeToService(Map<String, dynamic> place, String serviceType) {
    final location = place['geometry']?['location'] ?? {};
    final lat = (location['lat'] as num?)?.toDouble() ?? 0.0;
    final lng = (location['lng'] as num?)?.toDouble() ?? 0.0;

    // Determine the service type based on place types
    String type = _determineServiceType(
      place['types'] as List<dynamic>? ?? [],
      serviceType,
    );

    // Extract operating hours if available
    String operatingHours = '24/7';
    if (place['opening_hours'] != null) {
      final openNow = place['opening_hours']['open_now'] as bool?;
      operatingHours = openNow == true ? 'Open Now' : 'Hours Vary';
    }

    // Extract county from address or use coordinates
    String county = _determineCountyFromPlace(place, lat, lng);

    return Service(
      id: 'google_${place['place_id'] ?? DateTime.now().millisecondsSinceEpoch}',
      name: place['name'] as String? ?? 'Unknown Service',
      type: type,
      county: county,
      address: place['vicinity'] as String? ?? place['formatted_address'] as String? ?? '',
      phoneNumber: '', // Would need Place Details API call for phone
      latitude: lat,
      longitude: lng,
      operatingHours: operatingHours,
      servicesOffered: _getDefaultServicesForType(type),
      youthFriendly: false, // Unknown from Places API
      website: null,
    );
  }

  String _determineServiceType(List<dynamic> placeTypes, String fallbackType) {
    for (final placeType in placeTypes) {
      final typeStr = placeType.toString().toLowerCase();
      if (typeStr.contains('hospital') || typeStr.contains('health')) {
        return 'GBVRC';
      } else if (typeStr.contains('police')) {
        return 'police';
      } else if (typeStr.contains('doctor') || typeStr.contains('clinic')) {
        return 'clinic';
      }
    }
    
    // Map fallback type
    if (fallbackType == 'hospital' || fallbackType == 'health') {
      return 'GBVRC';
    } else if (fallbackType == 'doctor') {
      return 'clinic';
    }
    
    return fallbackType;
  }

  List<String> _getDefaultServicesForType(String type) {
    switch (type) {
      case 'GBVRC':
        return [
          'Medical Examination',
          'Counseling Services',
          'Referral Services',
        ];
      case 'clinic':
        return [
          'Medical Treatment',
          'Health Consultation',
        ];
      case 'police':
        return [
          'Report Filing',
          'Investigation Support',
        ];
      case 'rescue_center':
        return [
          'Safe Shelter',
          'Support Services',
        ];
      default:
        return ['General Services'];
    }
  }

  /// Determine county from place data or coordinates
  /// Checks formatted_address first, then vicinity, then uses coordinates as fallback
  String _determineCountyFromPlace(Map<String, dynamic> place, double lat, double lng) {
    // First, try to extract from formatted_address (more complete)
    final formattedAddress = place['formatted_address'] as String? ?? '';
    final vicinity = place['vicinity'] as String? ?? '';
    final addressText = formattedAddress.isNotEmpty ? formattedAddress : vicinity;
    
    final addressLower = addressText.toLowerCase();
    
    // Check for county names in address
    if (addressLower.contains('kilifi')) {
      return 'Kilifi';
    } else if (addressLower.contains('kwale')) {
      return 'Kwale';
    } else if (addressLower.contains('mombasa')) {
      return 'Mombasa';
    }
    
    // If address doesn't contain county name, use coordinate-based detection
    return _determineCountyFromCoordinates(lat, lng);
  }

  /// Determine county from coordinates using approximate boundaries
  /// Uses approximate geographic boundaries for coastal Kenya counties
  String _determineCountyFromCoordinates(double lat, double lng) {
    // Validate coordinates are in reasonable range for coastal Kenya
    if (lat == 0.0 && lng == 0.0) {
      return 'Mombasa'; // Default fallback for invalid coordinates
    }

    // Approximate county boundaries for coastal Kenya
    // These are rough boundaries and may need refinement based on actual county borders
    
    // Mombasa County: roughly -4.1 to -3.9 lat, 39.6 to 39.8 lng
    if (lat >= -4.1 && lat <= -3.9 && lng >= 39.6 && lng <= 39.8) {
      return 'Mombasa';
    }
    // Kilifi County: roughly -3.8 to -2.9 lat, 39.5 to 40.2 lng (larger area)
    else if (lat >= -3.8 && lat <= -2.9 && lng >= 39.5 && lng <= 40.2) {
      return 'Kilifi';
    }
    // Kwale County: roughly -4.6 to -3.8 lat, 39.0 to 39.6 lng
    else if (lat >= -4.6 && lat <= -3.8 && lng >= 39.0 && lng <= 39.6) {
      return 'Kwale';
    }
    
    // Default fallback - use Mombasa as it's the central county
    return 'Mombasa';
  }

  /// Get detailed information for a specific place
  Future<Service?> getPlaceDetails(String placeId) async {
    if (!isAvailable) return null;

    final cleanPlaceId = placeId.replaceFirst('google_', '');
    final cacheKey = cacheService?.generateCacheKey(
      type: CacheType.places,
      parameters: {'place_id': cleanPlaceId},
    );

    // Try cache first
    if (cacheService != null && cacheKey != null) {
      final cachedData = await cacheService!.getCachedData(cacheKey);
      if (cachedData != null) {
        AppLogger.info('Using cached place details for $cleanPlaceId');
        final result = cachedData['result'] as Map<String, dynamic>?;
        if (result != null) {
          return _placeDetailsToService(result);
        }
      }
    }

    // Check connectivity
    final isConnected = await connectivityService?.isConnected() ?? true;
    if (!isConnected) {
      AppLogger.info('No internet connection for place details');
      return null;
    }

    final uri = Uri.parse(_placeDetailsUrl).replace(queryParameters: {
      'place_id': cleanPlaceId,
      'fields': 'name,formatted_address,formatted_phone_number,geometry,opening_hours,types,website',
      'key': apiKey!,
    });

    try {
      final response = await _httpClient.get(uri).timeout(
        Duration(seconds: AppConstants.connectionTimeoutSeconds),
      );

      if (response.statusCode != 200) {
        // Try cache as fallback
        if (cacheService != null && cacheKey != null) {
          final cachedData = await cacheService!.getCachedData(cacheKey);
          if (cachedData != null) {
            final result = cachedData['result'] as Map<String, dynamic>?;
            if (result != null) {
              return _placeDetailsToService(result);
            }
          }
        }
        return null;
      }

      final data = json.decode(response.body);
      final result = data['result'] as Map<String, dynamic>?;
      
      if (result == null) return null;

      // Cache the successful response
      if (cacheService != null && cacheKey != null) {
        await cacheService!.setCachedData(
          cacheKey: cacheKey,
          cacheType: CacheType.places,
          data: data,
          metadata: {'place_id': cleanPlaceId},
        );
      }

      return _placeDetailsToService(result);
    } catch (e) {
      AppLogger.error('Failed to get place details', error: e);
      // Try cache as fallback
      if (cacheService != null && cacheKey != null) {
        final cachedData = await cacheService!.getCachedData(cacheKey);
        if (cachedData != null) {
          final result = cachedData['result'] as Map<String, dynamic>?;
          if (result != null) {
            return _placeDetailsToService(result);
          }
        }
      }
      return null;
    }
  }

  /// Convert place details result to Service model
  Service _placeDetailsToService(Map<String, dynamic> result) {
    final location = result['geometry']?['location'] ?? {};
    final types = result['types'] as List<dynamic>? ?? [];
    final type = _determineServiceType(types, 'GBVRC');

    String operatingHours = '24/7';
    if (result['opening_hours']?['weekday_text'] != null) {
      final hours = result['opening_hours']['weekday_text'] as List<dynamic>;
      operatingHours = hours.isNotEmpty ? hours.first.toString() : '24/7';
    }

    // Extract county from address or coordinates
    final lat = (location['lat'] as num?)?.toDouble() ?? 0.0;
    final lng = (location['lng'] as num?)?.toDouble() ?? 0.0;
    final address = result['formatted_address'] as String? ?? '';
    String county = _determineCountyFromPlace({'formatted_address': address}, lat, lng);

    return Service(
      id: 'google_${result['place_id'] ?? DateTime.now().millisecondsSinceEpoch}',
      name: result['name'] as String? ?? 'Unknown',
      type: type,
      county: county,
      address: address,
      phoneNumber: result['formatted_phone_number'] as String? ?? '',
      latitude: lat,
      longitude: lng,
      operatingHours: operatingHours,
      servicesOffered: _getDefaultServicesForType(type),
      youthFriendly: false,
      website: result['website'] as String?,
    );
  }

  void dispose() {
    _httpClient.close();
  }
}
