import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/service_locator_service.dart';
import '../models/service.dart';
import '../utils/constants.dart';
import 'resources_screen.dart';

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
      body: Column(
        children: [
          // Purple Header Section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Find Services',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Locate support near you',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _showMap ? Icons.list : Icons.map,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() => _showMap = !_showMap);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or location...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
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
                // Category Filters
                SizedBox(
                  height: 44,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip('All Services', null),
                        const SizedBox(width: 8),
                        _buildCategoryChip('GBVRC', AppConstants.serviceTypeGBVRC),
                        const SizedBox(width: 8),
                        _buildCategoryChip('Clinics', AppConstants.serviceTypeClinic),
                        const SizedBox(width: 8),
                        _buildCategoryChip('Police', AppConstants.serviceTypePolice),
                        const SizedBox(width: 8),
                        _buildCategoryChip('Rescue', AppConstants.serviceTypeRescueCenter),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
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

  Widget _buildCategoryChip(String label, String? value) {
    final isSelected = _selectedType == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = isSelected ? null : value;
          _filterServices();
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppConstants.primaryColor : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }


  Widget _buildListView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Location Services Prompt
        if (_currentPosition == null)
          _buildLocationPrompt(),
        if (_currentPosition == null) const SizedBox(height: 16),

        // Service Count Header
        if (_filteredServices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${_filteredServices.length} services in Mombasa',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Show county filter dialog
                  },
                  child: Text(
                    'Filter by county',
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Service List
        if (_filteredServices.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
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
            ),
          )
        else
          ..._filteredServices.map((service) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildServiceCard(service),
              )),

        // Help Card
        if (_filteredServices.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildHelpCard(),
        ],
      ],
    );
  }

  Widget _buildLocationPrompt() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppConstants.successColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Location Services',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Enable location to find services nearest to you',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final permission = await Permission.location.request();
              if (permission.isGranted) {
                await _loadServices();
              }
            },
            child: Text(
              'Enable Location →',
              style: TextStyle(
                color: AppConstants.successColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.help_outline,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need Help Choosing?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'All listed services are confidential and trained to support survivors. Youth-friendly services are specially equipped for adolescents.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ResourcesScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Learn more about services →',
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceWithDistance serviceWithDistance) {
    final service = serviceWithDistance.service;
    final distanceColor = service.type == AppConstants.serviceTypeGBVRC
        ? AppConstants.successColor
        : AppConstants.primaryColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showServiceDetails(serviceWithDistance),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                            color: AppConstants.textPrimaryColor,
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
                        color: distanceColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        serviceWithDistance.distanceFormatted,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: distanceColor,
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
                      Icon(Icons.check_circle,
                          size: 14, color: AppConstants.successColor),
                      SizedBox(width: 4),
                      Text(
                        'Youth Friendly',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _makePhoneCall(service.phoneNumber),
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('Call Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.successColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _openMaps(service.latitude, service.longitude),
                      icon: const Icon(Icons.directions, size: 16),
                      label: const Text('Directions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
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
