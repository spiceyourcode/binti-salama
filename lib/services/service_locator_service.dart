import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/service.dart';
import '../utils/constants.dart';
import 'database_service.dart';

class ServiceLocatorService {
  final DatabaseService databaseService;

  ServiceLocatorService({required this.databaseService});

  /// Find nearest services to user location
  Future<List<ServiceWithDistance>> findNearestServices(
    Position userLocation, {
    String? serviceType,
    String? county,
    int maxResults = 10,
  }) async {
    final services = await databaseService.getServices(
      type: serviceType,
      county: county,
    );

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
  Future<List<ServiceWithDistance>> getAllServicesFallback() async {
    final services = await databaseService.getServices();
    return services
        .map((service) => ServiceWithDistance(service: service, distance: 0))
        .toList();
  }

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
