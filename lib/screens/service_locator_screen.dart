import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/service_locator_service.dart';
import '../services/language_provider.dart';
import '../models/service.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';
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
      final languageProvider = Provider.of<LanguageProvider?>(context, listen: false);
      final t = languageProvider?.t;
      _showError(t?.translate('failed_to_load_services') ?? 'Failed to load services: $e');
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
      final languageProvider = Provider.of<LanguageProvider?>(context, listen: false);
      final t = languageProvider?.t;
      _showError(t?.translate('could_not_make_call') ?? 'Could not make phone call');
    }
  }

  Future<void> _openMaps(double lat, double lon) async {
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      final languageProvider = Provider.of<LanguageProvider?>(context, listen: false);
      final t = languageProvider?.t;
      _showError(t?.translate('could_not_open_maps') ?? 'Could not open maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider?>(context, listen: true);
    final t = languageProvider?.t;

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
                          Text(
                            t?.translate('find_services_title') ?? 'Find Services',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t?.translate('locate_support_near_you') ?? 'Locate support near you',
                            style: const TextStyle(
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
                    hintText: t?.translate('search_by_name_or_location') ?? 'Search by name or location...',
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
                        _buildCategoryChip(t?.translate('all_services') ?? 'All Services', null, t),
                        const SizedBox(width: 8),
                        _buildCategoryChip(t?.translate('GBVRC') ?? 'GBVRC', AppConstants.serviceTypeGBVRC, t),
                        const SizedBox(width: 8),
                        _buildCategoryChip(t?.translate('clinic') ?? 'Clinics', AppConstants.serviceTypeClinic, t),
                        const SizedBox(width: 8),
                        _buildCategoryChip(t?.translate('police') ?? 'Police', AppConstants.serviceTypePolice, t),
                        const SizedBox(width: 8),
                        _buildCategoryChip(t?.translate('rescue_center') ?? 'Rescue', AppConstants.serviceTypeRescueCenter, t),
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

  Widget _buildCategoryChip(String label, String? value, AppLocalizations? t) {
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
    final languageProvider = Provider.of<LanguageProvider?>(context, listen: true);
    final t = languageProvider?.t;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Location Services Prompt
        if (_currentPosition == null)
          _buildLocationPrompt(t),
        if (_currentPosition == null) const SizedBox(height: 16),

        // Service Count Header
        if (_filteredServices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (t?.translate('showing_services') ?? 'Showing {count} services in {county}').replaceAll('{count}', '${_filteredServices.length}').replaceAll('{county}', 'Mombasa'),
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
                    t?.translate('filter_by_county') ?? 'Filter by county',
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
                    t?.translate('no_services_found') ?? 'No services found',
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
                    child: Text(t?.translate('clear_filters') ?? 'Clear filters'),
                  ),
                ],
              ),
            ),
          )
        else
          ..._filteredServices.map((service) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildServiceCard(service, t),
              )),

        // Help Card
        if (_filteredServices.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildHelpCard(t),
        ],
      ],
    );
  }

  Widget _buildLocationPrompt(AppLocalizations? t) {
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
                Text(
                  t?.translate('location_services') ?? 'Location Services',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t?.translate('enable_location_description') ?? 'Enable location to find services nearest to you',
                  style: const TextStyle(
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
              t?.translate('enable_location_button') ?? 'Enable Location →',
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

  Widget _buildHelpCard(AppLocalizations? t) {
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
                Text(
                  t?.translate('need_help_choosing') ?? 'Need Help Choosing?',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t?.translate('need_help_description') ?? 'All listed services are confidential and trained to support survivors. Youth-friendly services are specially equipped for adolescents.',
                  style: const TextStyle(
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
                    t?.translate('learn_more_about_services') ?? 'Learn more about services →',
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

  Widget _buildServiceCard(ServiceWithDistance serviceWithDistance, AppLocalizations? t) {
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
                        _getServiceTypeLabel(service.type, t),
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
                  child: Builder(
                    builder: (context) {
                      final languageProvider = Provider.of<LanguageProvider?>(context, listen: false);
                      final t = languageProvider?.t;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle,
                              size: 14, color: AppConstants.successColor),
                          const SizedBox(width: 4),
                          Text(
                            t?.translate('youth_friendly') ?? 'Youth Friendly',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppConstants.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
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
                      label: Text(t?.translate('call_now') ?? 'Call Now'),
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
                      label: Text(t?.translate('directions') ?? 'Directions'),
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

  String _getServiceTypeLabel(String type, AppLocalizations? t) {
    switch (type) {
      case AppConstants.serviceTypeGBVRC:
        return t?.translate('GBVRC') ?? 'GBV Recovery Center';
      case AppConstants.serviceTypeClinic:
        return t?.translate('clinic') ?? 'Health Clinic';
      case AppConstants.serviceTypePolice:
        return t?.translate('police') ?? 'Police GBV Desk';
      case AppConstants.serviceTypeRescueCenter:
        return t?.translate('rescue_center') ?? 'Rescue Center';
      default:
        return type;
    }
  }

  Widget _buildMapView() {
    final languageProvider = Provider.of<LanguageProvider?>(context, listen: true);
    final t = languageProvider?.t;

    if (_currentPosition == null) {
      return Center(
        child: Text(t?.translate('location_not_available') ?? 'Location not available'),
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
        infoWindow: InfoWindow(title: t?.translate('your_location') ?? 'Your Location'),
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
      builder: (context) {
        final languageProvider = Provider.of<LanguageProvider?>(context, listen: false);
        final t = languageProvider?.t;
        
        return DraggableScrollableSheet(
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
                          _getServiceTypeLabel(service.type, t),
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

              _buildDetailRow(Icons.location_on, t?.translate('address') ?? 'Address',
                  '${service.address}, ${service.county}', t),
              _buildDetailRow(Icons.phone, t?.translate('phone') ?? 'Phone', service.phoneNumber, t),
              _buildDetailRow(
                  Icons.access_time, t?.translate('opening_hours') ?? 'Hours', service.operatingHours, t),

              if (_currentPosition != null)
                _buildDetailRow(Icons.directions, t?.translate('distance') ?? 'Distance',
                    serviceWithDistance.distanceFormatted, t),

              if (service.servicesOffered.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  t?.translate('services_offered') ?? 'Services Offered:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                      label: Text(t?.translate('call') ?? 'Call'),
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
                      label: Text(t?.translate('directions') ?? 'Directions'),
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
      );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, AppLocalizations? t) {
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
