import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../services/authentication_service.dart';
import '../services/panic_button_service.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../widgets/panic_button_widget.dart';
import 'service_locator_screen.dart';
import 'first_response_screen.dart';
import 'incident_log_screen.dart';
import 'resources_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  DateTime? _lastPausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePanicButton();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPanicButton();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lastPausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      _checkAutoLock();
    }
  }

  Future<void> _checkAutoLock() async {
    if (_lastPausedTime == null) return;

    final authService = Provider.of<AuthenticationService>(context, listen: false);
    final settings = await authService.getCurrentUserSettings();
    
    if (settings == null) return;

    final elapsed = DateTime.now().difference(_lastPausedTime!);
    if (elapsed.inMinutes >= settings.autoLockMinutes) {
      await authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  void _initializePanicButton() {
    final panicService = Provider.of<PanicButtonService>(context, listen: false);
    panicService.initializeShakeDetection(_handlePanicTrigger);
  }

  void _stopPanicButton() {
    final panicService = Provider.of<PanicButtonService>(context, listen: false);
    panicService.stopShakeDetection();
  }

  Future<void> _handlePanicTrigger() async {
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Alert'),
        content: const Text('Send emergency alert to your trusted contacts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.emergencyRed,
            ),
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _sendPanicAlert();
    }
  }

  Future<void> _sendPanicAlert() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Sending emergency alert...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final authService = Provider.of<AuthenticationService>(context, listen: false);
      final panicService = Provider.of<PanicButtonService>(context, listen: false);
      final databaseService = Provider.of<DatabaseService>(context, listen: false);

      final userId = await authService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      // Get emergency contacts
      final contacts = await databaseService.getEmergencyContacts(userId);

      if (contacts.isEmpty) {
        throw Exception('No emergency contacts configured');
      }

      // Get location
      Position? location;
      try {
        location = await Geolocator.getCurrentPosition();
      } catch (e) {
        print('Could not get location: $e');
      }

      // Send panic alert
      await panicService.triggerPanicAlert(userId, contacts, userLocation: location);

      if (!mounted) return;

      Navigator.pop(context); // Close loading dialog

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency alert sent successfully'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context); // Close loading dialog

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send alert: $e'),
          backgroundColor: AppConstants.errorColor,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You are safe here',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This is a confidential space. All your information is private and secure.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Emergency Section
              const Text(
                'Emergency',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),

              // Panic Button
              PanicButtonWidget(onPressed: _handlePanicTrigger),
              const SizedBox(height: 12),

              // Emergency Hotlines
              _buildEmergencyCard(),
              const SizedBox(height: 24),

              // Quick Access Menu
              const Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),

              _buildMenuGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Hotlines',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildHotlineRow('National Emergency', AppConstants.nationalEmergencyNumber),
            _buildHotlineRow('Police Emergency', AppConstants.policeEmergencyNumber),
            _buildHotlineRow('Gender Violence Hotline', AppConstants.genderViolenceHotline),
            _buildHotlineRow('Child Helpline', AppConstants.childHelplineKenya),
          ],
        ),
      ),
    );
  }

  Widget _buildHotlineRow(String label, String number) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          TextButton.icon(
            onPressed: () {
              // Launch phone dialer
              // url_launcher will be used here
            },
            icon: const Icon(Icons.phone, size: 16),
            label: Text(number),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildMenuItem(
          icon: Icons.local_hospital,
          label: 'Find Services',
          color: AppConstants.primaryColor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ServiceLocatorScreen()),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.medical_services,
          label: 'First Response',
          color: AppConstants.accentColor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FirstResponseScreen()),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.book,
          label: 'My Records',
          color: AppConstants.secondaryColor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const IncidentLogScreen()),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.info,
          label: 'Resources',
          color: AppConstants.warningColor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ResourcesScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

