import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

/// Service for fetching nearby places using Google Places API
/// This provides an optional online data source for finding services
class GooglePlacesService {
  final String? apiKey;
  final http.Client _httpClient;

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
    final uri = Uri.parse(_nearbySearchUrl).replace(queryParameters: {
      'location': '$latitude,$longitude',
      'radius': radiusMeters.toStringAsFixed(0),
      'type': placeType,
      'key': apiKey!,
    });

    try {
      final response = await _httpClient.get(uri).timeout(
        Duration(seconds: AppConstants.connectionTimeoutSeconds),
      );

      if (response.statusCode != 200) {
        AppLogger.warning('Google Places API returned ${response.statusCode}');
        return [];
      }

      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>? ?? [];

      return results.map((place) {
        return _placeToService(place as Map<String, dynamic>, serviceType ?? placeType);
      }).toList();
    } catch (e) {
      AppLogger.warning('Places API search failed for type $placeType: $e');
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

    // Extract county from vicinity or formatted address
    String county = 'Mombasa'; // Default
    final vicinity = place['vicinity'] as String? ?? '';
    if (vicinity.toLowerCase().contains('kilifi')) {
      county = 'Kilifi';
    } else if (vicinity.toLowerCase().contains('kwale')) {
      county = 'Kwale';
    }

    return Service(
      id: 'google_${place['place_id'] ?? DateTime.now().millisecondsSinceEpoch}',
      name: place['name'] as String? ?? 'Unknown Service',
      type: type,
      county: county,
      address: vicinity,
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

  /// Get detailed information for a specific place
  Future<Service?> getPlaceDetails(String placeId) async {
    if (!isAvailable) return null;

    final uri = Uri.parse(_placeDetailsUrl).replace(queryParameters: {
      'place_id': placeId.replaceFirst('google_', ''),
      'fields': 'name,formatted_address,formatted_phone_number,geometry,opening_hours,types,website',
      'key': apiKey!,
    });

    try {
      final response = await _httpClient.get(uri).timeout(
        Duration(seconds: AppConstants.connectionTimeoutSeconds),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body);
      final result = data['result'] as Map<String, dynamic>?;
      
      if (result == null) return null;

      final location = result['geometry']?['location'] ?? {};
      final types = result['types'] as List<dynamic>? ?? [];
      final type = _determineServiceType(types, 'GBVRC');

      String operatingHours = '24/7';
      if (result['opening_hours']?['weekday_text'] != null) {
        final hours = result['opening_hours']['weekday_text'] as List<dynamic>;
        operatingHours = hours.isNotEmpty ? hours.first.toString() : '24/7';
      }

      // Extract county from address
      String county = 'Mombasa';
      final address = result['formatted_address'] as String? ?? '';
      if (address.toLowerCase().contains('kilifi')) {
        county = 'Kilifi';
      } else if (address.toLowerCase().contains('kwale')) {
        county = 'Kwale';
      }

      return Service(
        id: 'google_$placeId',
        name: result['name'] as String? ?? 'Unknown',
        type: type,
        county: county,
        address: address,
        phoneNumber: result['formatted_phone_number'] as String? ?? '',
        latitude: (location['lat'] as num?)?.toDouble() ?? 0.0,
        longitude: (location['lng'] as num?)?.toDouble() ?? 0.0,
        operatingHours: operatingHours,
        servicesOffered: _getDefaultServicesForType(type),
        youthFriendly: false,
        website: result['website'] as String?,
      );
    } catch (e) {
      AppLogger.error('Failed to get place details', error: e);
      return null;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
