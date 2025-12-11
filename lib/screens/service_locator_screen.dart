import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/service_locator_service.dart';
import '../services/language_provider.dart';
import '../models/service.dart';
import '../utils/constants.dart';

class ServiceLocatorScreen extends StatefulWidget {
  const ServiceLocatorScreen({super.key});

  @override
  State<ServiceLocatorScreen> createState() => _ServiceLocatorScreenState();
}

class _ServiceLocatorScreenState extends State<ServiceLocatorScreen> {
  Position? _currentPosition;
  List<ServiceWithDistance> _services = [];
  List<ServiceWithDistance> _filteredServices = [];
  bool _isLoading = true;
  String? _selectedType;
  String? _selectedCounty;
  final _searchController = TextEditingController();
  GoogleMapController? _mapController;
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);

    try {
      final serviceLocator =
          Provider.of<ServiceLocatorService>(context, listen: false);

      // Get current location
      try {
        _currentPosition = await serviceLocator.getCurrentLocation();
      } catch (e) {
        print('Location error: $e');
      }

      // Load services
      if (_currentPosition != null) {
        _services = await serviceLocator.findNearestServices(
          _currentPosition!,
          maxResults: 50,
        );
      } else {
        // If location unavailable, load all services
        final allServices = await serviceLocator.getServicesByCounty('Mombasa');
        _services = allServices
            .map((s) => ServiceWithDistance(service: s, distance: 0))
            .toList();
      }

      _filteredServices = _services;
    } catch (e) {
      _showError('Failed to load services: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterServices() {
    setState(() {
      _filteredServices = _services.where((serviceWithDistance) {
        final service = serviceWithDistance.service;

        // Type filter
        if (_selectedType != null && service.type != _selectedType) {
          return false;
        }

        // County filter
        if (_selectedCounty != null && service.county != _selectedCounty) {
          return false;
        }

        // Search filter
        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          return service.name.toLowerCase().contains(query) ||
              service.address.toLowerCase().contains(query);
        }

        return true;
      }).toList();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showError('Could not make phone call');
    }
  }

  Future<void> _openMaps(double lat, double lon) async {
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showError('Could not open maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Services'),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map),
            onPressed: () {
              setState(() => _showMap = !_showMap);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search services...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterServices();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => _filterServices(),
                ),
                const SizedBox(height: 12),

                // Filters
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        label: 'Type',
                        value: _selectedType,
                        items: ['All', ...AppConstants.serviceTypes],
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value == 'All' ? null : value;
                            _filterServices();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown(
                        label: 'County',
                        value: _selectedCounty,
                        items: ['All', ...AppConstants.counties],
                        onChanged: (value) {
                          setState(() {
                            _selectedCounty = value == 'All' ? null : value;
                            _filterServices();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _showMap
                    ? _buildMapView()
                    : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value ?? 'All',
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildListView() {
    if (_filteredServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No services found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _selectedType = null;
                  _selectedCounty = null;
                });
                _filterServices();
              },
              child: const Text('Clear filters'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredServices.length,
      itemBuilder: (context, index) {
        return _buildServiceCard(_filteredServices[index]);
      },
    );
  }

  Widget _buildServiceCard(ServiceWithDistance serviceWithDistance) {
    final service = serviceWithDistance.service;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showServiceDetails(serviceWithDistance),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildServiceIcon(service.type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getServiceTypeLabel(service.type),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_currentPosition != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        serviceWithDistance.distanceFormatted,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${service.address}, ${service.county}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    service.operatingHours,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              if (service.youthFriendly) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified,
                          size: 14, color: AppConstants.successColor),
                      SizedBox(width: 4),
                      Text(
                        'Youth Friendly',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.successColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case AppConstants.serviceTypeGBVRC:
        icon = Icons.local_hospital;
        color = AppConstants.primaryColor;
        break;
      case AppConstants.serviceTypeClinic:
        icon = Icons.medical_services;
        color = AppConstants.accentColor;
        break;
      case AppConstants.serviceTypePolice:
        icon = Icons.local_police;
        color = AppConstants.secondaryColor;
        break;
      case AppConstants.serviceTypeRescueCenter:
        icon = Icons.home;
        color = AppConstants.warningColor;
        break;
      default:
        icon = Icons.place;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _getServiceTypeLabel(String type) {
    switch (type) {
      case AppConstants.serviceTypeGBVRC:
        return 'GBV Recovery Center';
      case AppConstants.serviceTypeClinic:
        return 'Health Clinic';
      case AppConstants.serviceTypePolice:
        return 'Police GBV Desk';
      case AppConstants.serviceTypeRescueCenter:
        return 'Rescue Center';
      default:
        return type;
    }
  }

  Widget _buildMapView() {
    if (_currentPosition == null) {
      return const Center(
        child: Text('Location not available'),
      );
    }

    final Set<Marker> markers = _filteredServices.map((serviceWithDistance) {
      final service = serviceWithDistance.service;
      return Marker(
        markerId: MarkerId(service.id),
        position: LatLng(service.latitude, service.longitude),
        infoWindow: InfoWindow(
          title: service.name,
          snippet: service.address,
        ),
        onTap: () => _showServiceDetails(serviceWithDistance),
      );
    }).toSet();

    // Add user location marker
    markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position:
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: AppConstants.defaultMapZoom,
      ),
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onMapCreated: (controller) {
        _mapController = controller;
      },
    );
  }

  void _showServiceDetails(ServiceWithDistance serviceWithDistance) {
    final service = serviceWithDistance.service;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  _buildServiceIcon(service.type),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getServiceTypeLabel(service.type),
                          style: const TextStyle(
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),

              _buildDetailRow(Icons.location_on, 'Address',
                  '${service.address}, ${service.county}'),
              _buildDetailRow(Icons.phone, 'Phone', service.phoneNumber),
              _buildDetailRow(
                  Icons.access_time, 'Hours', service.operatingHours),

              if (_currentPosition != null)
                _buildDetailRow(Icons.directions, 'Distance',
                    serviceWithDistance.distanceFormatted),

              if (service.servicesOffered.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Services Offered:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...service.servicesOffered.map((s) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check,
                              size: 16, color: AppConstants.successColor),
                          const SizedBox(width: 8),
                          Expanded(child: Text(s)),
                        ],
                      ),
                    )),
              ],

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _makePhoneCall(service.phoneNumber),
                      icon: const Icon(Icons.phone),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.successColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _openMaps(service.latitude, service.longitude),
                      icon: const Icon(Icons.directions),
                      label: const Text('Directions'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppConstants.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
