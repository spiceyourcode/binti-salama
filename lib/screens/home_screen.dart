import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/authentication_service.dart';
import '../services/panic_button_service.dart';
import '../services/database_service.dart';
import '../services/settings_service.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';
import '../utils/logger.dart';
import '../widgets/panic_button_widget.dart';
import '../widgets/volume_button_detector.dart';
import '../widgets/bottom_navigation.dart';
import '../services/language_provider.dart';
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
  String? _currentTriggerType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPanicTriggerAndInitialize();
  }

  Future<void> _loadPanicTriggerAndInitialize() async {
    AppLogger.info('🚀 Starting panic button initialization...');
    try {
      final authService =
          Provider.of<AuthenticationService>(context, listen: false);
      final settingsService =
          Provider.of<SettingsService>(context, listen: false);

      final userId = await authService.getCurrentUserId();
      AppLogger.info('👤 User ID: $userId');

      if (userId != null) {
        _currentTriggerType = await settingsService.getPanicTriggerType(userId);
        AppLogger.info(
            '⚙️ Loaded trigger type from settings: $_currentTriggerType');
        setState(() {});
      } else {
        AppLogger.info('⚠️ No user ID found, using default shake trigger');
        _currentTriggerType = AppConstants.panicTriggerShake;
      }
    } catch (e) {
      AppLogger.info('❌ Error loading panic trigger: $e');
      _currentTriggerType = AppConstants.panicTriggerShake;
    }
    await _initializePanicButton();
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

    final authService =
        Provider.of<AuthenticationService>(context, listen: false);
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

  Future<void> _initializePanicButton() async {
    AppLogger.info('🔧 _initializePanicButton called');
    try {
      final authService =
          Provider.of<AuthenticationService>(context, listen: false);
      final settingsService =
          Provider.of<SettingsService>(context, listen: false);
      final panicService =
          Provider.of<PanicButtonService>(context, listen: false);

      AppLogger.info('📦 Services obtained');

      final userId = await authService.getCurrentUserId();
      AppLogger.info('👤 Got user ID: $userId');

      if (userId == null) {
        AppLogger.info('⚠️ No user ID, cannot initialize panic button');
        return;
      }

      // Get the user's panic trigger preference
      final triggerType = await settingsService.getPanicTriggerType(userId);
      setState(() {
        _currentTriggerType = triggerType;
      });
      AppLogger.info('⚙️ Trigger type from settings: $triggerType');

      // Initialize the appropriate trigger
      AppLogger.info('🎯 Calling panicService.initializePanicTrigger...');
      panicService.initializePanicTrigger(triggerType, _handlePanicTrigger);

      AppLogger.info('✅ Panic button initialized with trigger: $triggerType');
      if (triggerType == AppConstants.panicTriggerShake) {
        AppLogger.info(
            '📱 Shake detection is ACTIVE - shake your phone to test!');
        AppLogger.info(
            '📊 Threshold: ${AppConstants.shakeThreshold}, Required: ${AppConstants.requiredShakes}, Window: ${AppConstants.shakeWindowSeconds}s');
      }
    } catch (e, stackTrace) {
      AppLogger.info('❌ Error initializing panic button: $e');
      AppLogger.info('📚 Stack trace: $stackTrace');
      // Fallback to shake detection
      final panicService =
          Provider.of<PanicButtonService>(context, listen: false);
      AppLogger.info('🔄 Falling back to shake detection...');
      setState(() {
        _currentTriggerType = AppConstants.panicTriggerShake;
      });
      panicService.initializePanicTrigger(
          AppConstants.panicTriggerShake, _handlePanicTrigger);
    }
  }

  void _stopPanicButton() {
    final panicService =
        Provider.of<PanicButtonService>(context, listen: false);
    panicService.stopPanicTrigger();
  }

  Future<void> _handlePanicTrigger() async {
    // Show confirmation dialog first
    final languageProvider =
        Provider.of<LanguageProvider?>(context, listen: false);
    final t = languageProvider?.t;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(t?.translate('panic_button') ?? 'Emergency Alert'),
        content: Text(t?.translate('panic_sent') ??
            'Send emergency alert to your trusted contacts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t?.translate('cancel') ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.emergencyRed,
            ),
            child: Text(t?.translate('panic_button') ?? 'Send Alert'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _sendPanicAlert();
    }
  }

  Future<void> _sendPanicAlert() async {
    final languageProvider =
        Provider.of<LanguageProvider?>(context, listen: false);
    final t = languageProvider?.t;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(t?.translate('sending_alert') ??
                    'Sending emergency alert...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final authService =
          Provider.of<AuthenticationService>(context, listen: false);
      final panicService =
          Provider.of<PanicButtonService>(context, listen: false);
      final databaseService =
          Provider.of<DatabaseService>(context, listen: false);

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
        AppLogger.info('Could not get location: $e');
      }

      // Send panic alert
      await panicService.triggerPanicAlert(userId, contacts,
          userLocation: location);

      if (!mounted) return;

      Navigator.pop(context); // Close loading dialog

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t?.translate('panic_sent') ??
              'Emergency alert sent successfully'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context); // Close loading dialog

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${t?.translate('error') ?? 'Failed to send alert'}: $e'),
          backgroundColor: AppConstants.errorColor,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider?>(context);
    final t = languageProvider?.t;

    return VolumeButtonDetector(
      triggerType: _currentTriggerType,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Sticky Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: _buildHeader(t),
              ),
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Emergency Section
                      Row(
                        children: [
                          const Icon(
                            Icons.warning,
                            color: AppConstants.emergencyRed,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t?.translate('emergency') ?? 'EMERGENCY',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.emergencyRed,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Panic Button
                      PanicButtonWidget(
                        onPressed: _handlePanicTrigger,
                        triggerType: _currentTriggerType,
                      ),
                      const SizedBox(height: 16),

                      // Emergency Hotlines
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            color: AppConstants.emergencyRed,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t?.translate('emergency_hotlines') ??
                                'Emergency Hotlines',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildEmergencyHotlines(),
                      const SizedBox(height: 24),

                      // Quick Access Menu
                      Row(
                        children: [
                          const Icon(
                            Icons.more_horiz,
                            color: AppConstants.textPrimaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t?.translate('quick_access') ?? 'QUICK ACCESS',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimaryColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _buildMenuGrid(t),
                      const SizedBox(height: 24),

                      // Reminder Card
                      _buildReminderCard(t),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavigation(currentRoute: '/home'),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations? t) {
    return Row(
      children: [
        // App Logo - use branded asset icon
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/icons/icon.png',
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        // App Name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t?.translate('app_name') ?? AppConstants.appName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              Text(
                t?.translate('you_are_safe_here') ?? 'You are safe here',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        // Settings Icon
        IconButton(
          icon: const Icon(Icons.settings,
              color: AppConstants.textSecondaryColor),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmergencyHotlines() {
    return Column(
      children: [
        _buildHotlineCard(
          'National Emergency',
          AppConstants.nationalEmergencyNumber,
          '24/7 Response',
          Colors.white,
          const Color(0xFFD32F2F),
          Icons.local_hospital,
        ),
        const SizedBox(height: 8),
        _buildHotlineCard(
          'Police Emergency',
          AppConstants.policeEmergencyNumber,
          'Immediate Help',
          const Color(0xFFE3F2FD),
          AppConstants.primaryColor,
          Icons.shield,
        ),
        const SizedBox(height: 8),
        _buildHotlineCard(
          'Gender Violence Hotline',
          AppConstants.genderViolenceHotline,
          'Confidential Support',
          AppConstants.primaryColor.withValues(alpha: 0.1),
          AppConstants.primaryColor,
          Icons.favorite,
        ),
        const SizedBox(height: 8),
        _buildHotlineCard(
          'Child Helpline',
          AppConstants.childHelplineKenya,
          'Free & Anonymous',
          AppConstants.successColor.withValues(alpha: 0.1),
          AppConstants.successColor,
          Icons.child_care,
        ),
      ],
    );
  }

  Widget _buildHotlineCard(String label, String number, String subtitle,
      Color backgroundColor, Color iconColor, IconData icon) {
    return InkWell(
      onTap: () async {
        final uri = Uri(scheme: 'tel', path: number);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(AppLocalizations? t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppConstants.successColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Remember',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You are not alone. It\'s not your fault. Help is available, and you deserve support and care.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(AppLocalizations? t) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildMenuItem(
          icon: Icons.local_hospital,
          label: t?.translate('find_services') ?? 'Find Services',
          description: 'Locate support centers near you',
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
          label: t?.translate('first_response') ?? 'First Response',
          description: 'Step-by-step guidance',
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
          label: t?.translate('my_records') ?? 'My Records',
          description: 'Secure documentation',
          color: AppConstants.primaryColor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const IncidentLogScreen()),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.info,
          label: t?.translate('resources') ?? 'Resources',
          description: 'Learn about your rights',
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
    String? description,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (description != null) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
