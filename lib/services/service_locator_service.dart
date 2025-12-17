import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/service.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';
import 'database_service.dart';
import 'google_places_service.dart';

/// Data source types for tracking where services came from
enum ServiceDataSource {
  database,
  jsonFallback,
  hardcodedFallback,
  googlePlaces,
}

class ServiceLocatorService {
  final DatabaseService databaseService;
  final GooglePlacesService? googlePlacesService;
  
  /// Track the current data source for debugging/logging
  ServiceDataSource? lastDataSource;

  ServiceLocatorService({
    required this.databaseService,
    this.googlePlacesService,
  });

  /// Find nearest services to user location
  /// Uses multiple data sources with fallback logic:
  /// 1. Google Places API (primary - online)
  /// 2. Database (fallback)
  /// 3. JSON asset fallback (offline)
  /// 4. Hardcoded fallback (emergency offline use)
  Future<List<ServiceWithDistance>> findNearestServices(
    Position userLocation, {
    String? serviceType,
    String? county,
    int maxResults = 10,
    bool includeGooglePlaces = false,
  }) async {
    List<Service> services = [];
    
    // Step 1: Try Google Places API FIRST (primary data source)
    if (includeGooglePlaces && 
        googlePlacesService != null &&
        googlePlacesService!.isAvailable &&
        AppConstants.enableGooglePlacesApi) {
      try {
        AppLogger.info('Attempting to fetch from Google Places API...');
        services = await googlePlacesService!.fetchNearbyServices(
          latitude: userLocation.latitude,
          longitude: userLocation.longitude,
          serviceType: serviceType,
          radiusMeters: AppConstants.placesSearchRadiusMeters,
        );
        lastDataSource = ServiceDataSource.googlePlaces;
        AppLogger.info('✓ Loaded ${services.length} services from Google Places API');
      } catch (e) {
        AppLogger.warning('Google Places API failed: $e');
      }
    } else {
      AppLogger.info('Google Places not enabled or not available');
    }

    // Step 2: FALLBACK - Try database/JSON if Google Places returned nothing
    if (services.isEmpty) {
      AppLogger.info('Falling back to local database...');
      try {
        services = await databaseService.getServices(
          type: serviceType,
          county: county,
        );
        lastDataSource = ServiceDataSource.database;
        AppLogger.info('Loaded ${services.length} services from database/JSON fallback');
      } catch (e) {
        AppLogger.warning('Database service failed: $e');
      }
    }

    // Step 3: FALLBACK - If still no services, use hardcoded fallback
    if (services.isEmpty && AppConstants.enableOfflineFallback) {
      AppLogger.info('Falling back to hardcoded data...');
      services = databaseService.getHardcodedFallbackServices();
      if (serviceType != null) {
        services = services.where((s) => s.type == serviceType).toList();
      }
      if (county != null) {
        services = services.where((s) => s.county == county).toList();
      }
      lastDataSource = ServiceDataSource.hardcodedFallback;
      AppLogger.info('Using ${services.length} hardcoded fallback services');
    }

    // Calculate distances and create ServiceWithDistance objects
    final servicesWithDistance = services.map((service) {
      final distance = _calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        service.latitude,
        service.longitude,
      );
      return ServiceWithDistance(service: service, distance: distance);
    }).toList();

    // Filter by max distance
    final filtered = servicesWithDistance
        .where((s) => s.distance <= AppConstants.maxServiceDisplayDistance)
        .toList();

    // Sort by distance
    filtered.sort((a, b) => a.distance.compareTo(b.distance));

    return filtered.take(maxResults).toList();
  }

  /// Get all services by type
  Future<List<Service>> getServicesByType(String type) async {
    return await databaseService.getServices(type: type);
  }

  /// Get all services by county
  Future<List<Service>> getServicesByCounty(String county) async {
    return await databaseService.getServices(county: county);
  }

  /// Get service details by ID
  Future<Service?> getServiceDetails(String serviceId) async {
    return await databaseService.getServiceById(serviceId);
  }

  /// Search services by query string
  Future<List<ServiceWithDistance>> searchServices(
    String query,
    Position? userLocation,
  ) async {
    final services = await databaseService.searchServices(query);

    if (userLocation == null) {
      return services
          .map((s) => ServiceWithDistance(service: s, distance: 0))
          .toList();
    }

    // Calculate distances
    final servicesWithDistance = services.map((service) {
      final distance = _calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        service.latitude,
        service.longitude,
      );
      return ServiceWithDistance(service: service, distance: distance);
    }).toList();

    // Sort by distance
    servicesWithDistance.sort((a, b) => a.distance.compareTo(b.distance));

    return servicesWithDistance;
  }

  /// Get all services with distances from user location
  Future<List<ServiceWithDistance>> getAllServicesWithDistance(
    Position userLocation,
  ) async {
    final services = await databaseService.getServices();

    final servicesWithDistance = services.map((service) {
      final distance = _calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        service.latitude,
        service.longitude,
      );
      return ServiceWithDistance(service: service, distance: distance);
    }).toList();

    servicesWithDistance.sort((a, b) => a.distance.compareTo(b.distance));

    return servicesWithDistance;
  }

  /// Fallback: return all services without location (distance set to 0)
  /// Uses multiple fallback sources if primary fails
  Future<List<ServiceWithDistance>> getAllServicesFallback() async {
    List<Service> services = [];
    
    // Try database/JSON first
    try {
      services = await databaseService.getServices();
      lastDataSource = ServiceDataSource.database;
    } catch (e) {
      AppLogger.warning('Failed to get services from database: $e');
    }
    
    // If empty, use hardcoded fallback
    if (services.isEmpty && AppConstants.enableOfflineFallback) {
      services = databaseService.getHardcodedFallbackServices();
      lastDataSource = ServiceDataSource.hardcodedFallback;
      AppLogger.info('Using hardcoded fallback services');
    }
    
    return services
        .map((service) => ServiceWithDistance(service: service, distance: 0))
        .toList();
  }

  /// Fetch nearby services from Google Places API
  /// This supplements local data with online search results
  Future<List<ServiceWithDistance>> fetchNearbyFromGooglePlaces(
    Position userLocation, {
    String? serviceType,
    double? radiusMeters,
  }) async {
    if (googlePlacesService == null || !googlePlacesService!.isAvailable) {
      AppLogger.info('Google Places service not available');
      return [];
    }

    try {
      final services = await googlePlacesService!.fetchNearbyServices(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
        serviceType: serviceType,
        radiusMeters: radiusMeters ?? AppConstants.placesSearchRadiusMeters,
      );

      return services.map((service) {
        final distance = _calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          service.latitude,
          service.longitude,
        );
        return ServiceWithDistance(service: service, distance: distance);
      }).toList()
        ..sort((a, b) => a.distance.compareTo(b.distance));
    } catch (e) {
      AppLogger.error('Failed to fetch from Google Places', error: e);
      return [];
    }
  }

  /// Get services with combined data from all sources
  /// Merges local data with Google Places results (optional)
  Future<List<ServiceWithDistance>> getCombinedServices(
    Position userLocation, {
    String? serviceType,
    String? county,
    bool includeGooglePlaces = false,
    int maxResults = 50,
  }) async {
    final Map<String, ServiceWithDistance> uniqueServices = {};

    // Get local services first
    final localServices = await findNearestServices(
      userLocation,
      serviceType: serviceType,
      county: county,
      maxResults: maxResults,
    );
    
    for (final service in localServices) {
      uniqueServices[service.service.id] = service;
    }

    // Optionally add Google Places services
    if (includeGooglePlaces && 
        googlePlacesService != null && 
        googlePlacesService!.isAvailable) {
      final placesServices = await fetchNearbyFromGooglePlaces(
        userLocation,
        serviceType: serviceType,
      );
      
      for (final service in placesServices) {
        // Only add if not already present (avoid duplicates)
        if (!uniqueServices.containsKey(service.service.id)) {
          uniqueServices[service.service.id] = service;
        }
      }
    }

    // Sort by distance and return
    final result = uniqueServices.values.toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));
    
    return result.take(maxResults).toList();
  }

  /// Check which data source was used for the last query
  String get dataSourceDescription {
    switch (lastDataSource) {
      case ServiceDataSource.database:
        return 'Local database';
      case ServiceDataSource.jsonFallback:
        return 'JSON asset (offline)';
      case ServiceDataSource.hardcodedFallback:
        return 'Emergency fallback data';
      case ServiceDataSource.googlePlaces:
        return 'Google Places API';
      case null:
        return 'Unknown';
    }
  }

  /// Check if Google Places API is available
  bool get isGooglePlacesAvailable => 
      googlePlacesService?.isAvailable ?? false;

  /// Filter services by multiple criteria
  Future<List<ServiceWithDistance>> filterServices({
    required Position userLocation,
    String? type,
    String? county,
    bool? youthFriendly,
    double? maxDistance,
  }) async {
    var services = await databaseService.getServices(
      type: type,
      county: county,
    );

    if (youthFriendly != null) {
      services =
          services.where((s) => s.youthFriendly == youthFriendly).toList();
    }

    final servicesWithDistance = services.map((service) {
      final distance = _calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        service.latitude,
        service.longitude,
      );
      return ServiceWithDistance(service: service, distance: distance);
    }).toList();

    // Filter by max distance if specified
    var filtered = servicesWithDistance;
    if (maxDistance != null) {
      filtered = filtered.where((s) => s.distance <= maxDistance).toList();
    }

    filtered.sort((a, b) => a.distance.compareTo(b.distance));

    return filtered;
  }

  /// Get current user location
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );
  }

  /// Calculate distance between two points using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371.0;

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) => degrees * (pi / 180);

  /// Get services count by type
  Future<Map<String, int>> getServicesCountByType() async {
    final services = await databaseService.getServices();
    final Map<String, int> counts = {};

    for (var service in services) {
      counts[service.type] = (counts[service.type] ?? 0) + 1;
    }

    return counts;
  }

  /// Get services count by county
  Future<Map<String, int>> getServicesCountByCounty() async {
    final services = await databaseService.getServices();
    final Map<String, int> counts = {};

    for (var service in services) {
      counts[service.county] = (counts[service.county] ?? 0) + 1;
    }

    return counts;
  }

  /// Check if a service is nearby (within threshold distance)
  bool isNearby(ServiceWithDistance serviceWithDistance) {
    return serviceWithDistance.distance <= AppConstants.nearbyServiceThreshold;
  }
}
