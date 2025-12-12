import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/authentication_service.dart';
import '../services/settings_service.dart';
import '../services/database_service.dart';
import '../models/trusted_contact.dart';
import '../utils/constants.dart';
import '../services/language_provider.dart';
import '../utils/localization.dart';
import '../utils/validators.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = AppConstants.languageEnglish;
  String _panicTrigger = AppConstants.panicTriggerShake;
  bool _notificationsEnabled = false;
  bool _disguiseMode = false;
  int _autoLockMinutes = AppConstants.autoLockDefaultMinutes;
  List<TrustedContact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final authService =
          Provider.of<AuthenticationService>(context, listen: false);
      final settingsService =
          Provider.of<SettingsService>(context, listen: false);
      final databaseService =
          Provider.of<DatabaseService>(context, listen: false);

      final userId = await authService.getCurrentUserId();
      if (userId != null) {
        final settings = await settingsService.getSettings(userId);
        _contacts = await databaseService.getTrustedContacts(userId);

        setState(() {
          _language = settings.language;
          _panicTrigger = settings.panicTriggerType;
          _notificationsEnabled = settings.notificationsEnabled;
          _disguiseMode = settings.disguiseMode;
          _autoLockMinutes = settings.autoLockMinutes;
        });
      }
    } catch (e) {
      _showError('Failed to load settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider?>(context, listen: true);
    final t = languageProvider?.t;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF6F3FF),
              Color(0xFFF9FAFF),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildHeader(t),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 24),
                        children: [
                          _buildSectionHeader('SECURITY & PRIVACY'),
                          _buildSettingsCard(
                            icon: Icons.vpn_key,
                            gradient: const [
                              Color(0xFF6B4CE6),
                              Color(0xFF8C6BFF)
                            ],
                            title: t?.translate('change_pin') ?? 'Change PIN',
                            subtitle: 'Update your security PIN',
                            onTap: _showChangePinDialog,
                          ),
                          _buildSwitchCard(
                            icon: Icons.visibility_off,
                            gradient: const [
                              Color(0xFF6B4CE6),
                              Color(0xFF8C6BFF)
                            ],
                            title: 'Disguise Mode',
                            subtitle: 'Hide app name & icon',
                            value: _disguiseMode,
                            onChanged: _updateDisguiseMode,
                          ),
                          _buildSettingsCard(
                            icon: Icons.lock_clock,
                            gradient: const [
                              Color(0xFF00C9B7),
                              Color(0xFF0083FF)
                            ],
                            title: 'Auto-Lock',
                            subtitle: 'Currently: $_autoLockMinutes minutes',
                            onTap: _showAutoLockDialog,
                          ),
                          _buildSectionHeader('TRUSTED CONTACTS',
                              countLabel: '${_contacts.length} contacts'),
                          _buildContactsList(),
                          _buildAddContactCard(),
                          _buildSectionHeader('EMERGENCY'),
                          _buildDropdownCard(
                            icon: Icons.touch_app,
                            gradient: const [
                              Color(0xFFFF7A45),
                              Color(0xFFFFA15A)
                            ],
                            title: 'Panic Button Trigger',
                            subtitle: 'How to activate emergency alert',
                            value: _panicTrigger,
                            items: {
                              AppConstants.panicTriggerShake: 'Shake Phone',
                              AppConstants.panicTriggerDoubleTap: 'Double Tap',
                              AppConstants.panicTriggerVolume: 'Volume Buttons',
                            },
                            onChanged: _updatePanicTrigger,
                          ),
                          _buildSectionHeader('GENERAL'),
                          _buildDropdownCard(
                            icon: Icons.language,
                            gradient: const [
                              Color(0xFFFFA15A),
                              Color(0xFFFF7A45)
                            ],
                            title: t != null
                                ? t.translate('language')
                                : 'Language',
                            subtitle: 'Choose your preferred language',
                            value: _language,
                            items: {
                              AppConstants.languageEnglish: t != null
                                  ? t.translate('english')
                                  : 'English',
                              AppConstants.languageSwahili: t != null
                                  ? t.translate('swahili')
                                  : 'Kiswahili',
                            },
                            onChanged: (value) async {
                              await _updateLanguage(value);
                              final lp = Provider.of<LanguageProvider?>(context,
                                  listen: false);
                              if (lp != null) {
                                await lp.setLanguage(
                                    value ?? AppConstants.languageEnglish);
                              }
                            },
                          ),
                          _buildSwitchCard(
                            icon: Icons.notifications,
                            gradient: const [
                              Color(0xFF00C9B7),
                              Color(0xFF16D0C8)
                            ],
                            title: 'Notifications',
                            subtitle: 'App alerts & reminders',
                            value: _notificationsEnabled,
                            onChanged: _updateNotifications,
                          ),
                          _buildSectionHeader('ABOUT & LEGAL'),
                          _buildSettingsCard(
                            icon: Icons.info,
                            gradient: const [
                              Color(0xFF00C9B7),
                              Color(0xFF6B4CE6)
                            ],
                            title: 'About Binti Salama',
                            subtitle: 'Mission & version info',
                            onTap: _showAboutDialog,
                          ),
                          _buildSettingsCard(
                            icon: Icons.privacy_tip,
                            gradient: const [
                              Color(0xFF6B4CE6),
                              Color(0xFF8C6BFF)
                            ],
                            title: 'Privacy Policy',
                            subtitle: 'How we protect your data',
                            onTap: _showPrivacyPolicy,
                          ),
                          _buildSectionHeader('DANGER ZONE', danger: true),
                          _buildDangerCard(),
                          const SizedBox(height: 16),
                          _buildLogoutCard(),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations? t) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t != null ? t.settings : 'Settings',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage your preferences',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF6B4CE6), Color(0xFF8C6BFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    if (_contacts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildSettingsCard(
          icon: Icons.person_outline,
          gradient: const [Color(0xFF00C9B7), Color(0xFF6B4CE6)],
          title: 'No trusted contacts added yet',
          subtitle: 'Add contacts to send emergency alerts',
          onTap: _showAddContactDialog,
        ),
      );
    }

    return Column(
      children: _contacts.map((contact) {
        final initials = contact.name
            .split(' ')
            .map((n) => n.isNotEmpty ? n[0].toUpperCase() : '')
            .take(2)
            .join();
        final avatarColor = contact.isEmergency
            ? AppConstants.successColor
            : AppConstants.warningColor;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: avatarColor.withValues(alpha: 0.15),
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: avatarColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact.phoneNumber,
                        style: const TextStyle(
                          color: AppConstants.textSecondaryColor,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: contact.isEmergency
                              ? AppConstants.successColor
                                  .withValues(alpha: 0.12)
                              : AppConstants.warningColor
                                  .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          contact.isEmergency
                              ? 'Emergency Contact'
                              : (contact.contactType.isNotEmpty
                                  ? contact.contactType
                                  : 'Friend'),
                          style: TextStyle(
                            fontSize: 11,
                            color: contact.isEmergency
                                ? AppConstants.successColor
                                : AppConstants.warningColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppConstants.errorColor, size: 20),
                  onPressed: () => _confirmDeleteContact(contact),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddContactCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _showAddContactDialog,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF6B4CE6), Color(0xFF8C6BFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child:
                    const Icon(Icons.person_add, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Add Trusted Contact',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton(
        onPressed: _logout,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
              color: AppConstants.textSecondaryColor.withOpacity(0.2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: Colors.white,
        ),
        child: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDangerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _confirmDeleteAccount,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppConstants.errorColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppConstants.errorColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_forever,
                    color: AppConstants.errorColor, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delete All Data',
                      style: TextStyle(
                        color: AppConstants.errorColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Permanently erase everything',
                      style: TextStyle(
                        color: AppConstants.errorColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title,
      {String? countLabel, bool danger = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: danger
                  ? AppConstants.errorColor
                  : AppConstants.textSecondaryColor,
            ),
          ),
          if (countLabel != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppConstants.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                countLabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppConstants.accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required List<Color> gradient,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _gradientIcon(icon, gradient),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required List<Color> gradient,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _buildSettingsCard(
      icon: icon,
      gradient: gradient,
      title: title,
      subtitle: subtitle,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: AppConstants.accentColor,
      ),
    );
  }

  Widget _buildDropdownCard({
    required IconData icon,
    required List<Color> gradient,
    required String title,
    String? subtitle,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return _buildSettingsCard(
      icon: icon,
      gradient: gradient,
      title: title,
      subtitle: subtitle,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          items: items.entries
              .map(
                (entry) => DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _gradientIcon(IconData icon, List<Color> gradient) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }

  Future<void> _updateLanguage(String? value) async {
    if (value == null) return;

    try {
      final authService =
          Provider.of<AuthenticationService>(context, listen: false);
      final settingsService =
          Provider.of<SettingsService>(context, listen: false);

      final userId = await authService.getCurrentUserId();
      if (userId != null) {
        await settingsService.updateLanguage(userId, value);
        setState(() => _language = value);
        _showSuccess('Language updated');
      }
    } catch (e) {
      _showError('Failed to update language: $e');
    }
  }

  Future<void> _updatePanicTrigger(String? value) async {
    if (value == null) return;

    try {
      final authService =
          Provider.of<AuthenticationService>(context, listen: false);
      final settingsService =
          Provider.of<SettingsService>(context, listen: false);

      final userId = await authService.getCurrentUserId();
      if (userId != null) {
        await settingsService.updatePanicTrigger(userId, value);
        setState(() => _panicTrigger = value);
        _showSuccess('Panic trigger updated');
      }
    } catch (e) {
      _showError('Failed to update panic trigger: $e');
    }
  }

  Future<void> _updateNotifications(bool value) async {
    try {
      final authService =
          Provider.of<AuthenticationService>(context, listen: false);
      final settingsService =
          Provider.of<SettingsService>(context, listen: false);

      final userId = await authService.getCurrentUserId();
      if (userId != null) {
        await settingsService.updateNotifications(userId, value);
        setState(() => _notificationsEnabled = value);
      }
    } catch (e) {
      _showError('Failed to update notifications: $e');
    }
  }

  Future<void> _updateDisguiseMode(bool value) async {
    try {
      final authService =
          Provider.of<AuthenticationService>(context, listen: false);
      final settingsService =
          Provider.of<SettingsService>(context, listen: false);

      final userId = await authService.getCurrentUserId();
      if (userId != null) {
        await settingsService.updateDisguiseMode(userId, value);
        setState(() => _disguiseMode = value);
      }
    } catch (e) {
      _showError('Failed to update disguise mode: $e');
    }
  }

  void _showChangePinDialog() {
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Current PIN',
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'New PIN',
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Confirm New PIN',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final oldPin = oldPinController.text;
              final newPin = newPinController.text;
              final confirmPin = confirmPinController.text;

              if (newPin != confirmPin) {
                _showError(AppConstants.errorPinMismatch);
                return;
              }

              if (!Validators.isValidPin(newPin)) {
                _showError(AppConstants.errorInvalidPin);
                return;
              }

              try {
                final authService =
                    Provider.of<AuthenticationService>(context, listen: false);
                await authService.changePin(oldPin, newPin);
                if (mounted) {
                  Navigator.pop(context);
                  _showSuccess('PIN changed successfully');
                }
              } catch (e) {
                _showError('Failed to change PIN: $e');
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showAutoLockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-Lock Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1, 5, 10, 15, 30].map((minutes) {
            return RadioListTile<int>(
              title: Text('$minutes minutes'),
              value: minutes,
              groupValue: _autoLockMinutes,
              onChanged: (value) async {
                if (value != null) {
                  try {
                    final authService = Provider.of<AuthenticationService>(
                        context,
                        listen: false);
                    final settingsService =
                        Provider.of<SettingsService>(context, listen: false);

                    final userId = await authService.getCurrentUserId();
                    if (userId != null) {
                      await settingsService.updateAutoLockMinutes(
                          userId, value);
                      setState(() => _autoLockMinutes = value);
                      if (mounted) {
                        Navigator.pop(context);
                        _showSuccess('Auto-lock timer updated');
                      }
                    }
                  } catch (e) {
                    _showError('Failed to update auto-lock: $e');
                  }
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String contactType = AppConstants.contactTypeFamily;
    bool isEmergency = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Trusted Contact'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: contactType,
                  decoration: const InputDecoration(labelText: 'Contact Type'),
                  items: AppConstants.contactTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => contactType = value);
                    }
                  },
                ),
                CheckboxListTile(
                  title: const Text('Emergency Contact'),
                  subtitle: const Text('Receives panic alerts'),
                  value: isEmergency,
                  onChanged: (value) {
                    setState(() => isEmergency = value ?? true);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    phoneController.text.isEmpty) {
                  _showError('Please fill in all fields');
                  return;
                }

                if (!Validators.isValidPhoneNumber(phoneController.text)) {
                  _showError(AppConstants.errorInvalidPhoneNumber);
                  return;
                }

                try {
                  final authService = Provider.of<AuthenticationService>(
                      context,
                      listen: false);
                  final databaseService =
                      Provider.of<DatabaseService>(context, listen: false);

                  final userId = await authService.getCurrentUserId();
                  if (userId != null) {
                    final contact = TrustedContact(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: userId,
                      name: nameController.text,
                      phoneNumber:
                          Validators.formatPhoneNumber(phoneController.text),
                      contactType: contactType,
                      isEmergency: isEmergency,
                    );

                    await databaseService.insertTrustedContact(contact);
                    await _loadSettings();

                    if (mounted) {
                      Navigator.pop(context);
                      _showSuccess('Contact added successfully');
                    }
                  }
                } catch (e) {
                  _showError('Failed to add contact: $e');
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteContact(TrustedContact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final databaseService =
                    Provider.of<DatabaseService>(context, listen: false);
                await databaseService.deleteTrustedContact(contact.id);
                await _loadSettings();

                if (mounted) {
                  Navigator.pop(context);
                  _showSuccess('Contact deleted');
                }
              } catch (e) {
                _showError('Failed to delete contact: $e');
              }
            },
            style:
                TextButton.styleFrom(foregroundColor: AppConstants.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppConstants.appName),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version ${AppConstants.appVersion}'),
            SizedBox(height: 16),
            Text(AppConstants.appDescription),
            SizedBox(height: 16),
            Text(
              'This app provides confidential crisis response and support for adolescent girls experiencing sexual violence in Kenya\'s coastal region.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Your privacy is our priority. All data is encrypted and stored securely on your device. '
            'We do not collect, share, or transmit any personal information to external servers. '
            'You have full control over your data and can delete it at any time.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This will permanently delete all your data including incident logs, contacts, and settings. '
              'This action cannot be undone.',
              style: TextStyle(color: AppConstants.errorColor),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter PIN to confirm',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final authService =
                    Provider.of<AuthenticationService>(context, listen: false);
                await authService.deleteAccount(pinController.text);

                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                _showError('Failed to delete account: $e');
              }
            },
            style:
                TextButton.styleFrom(foregroundColor: AppConstants.errorColor),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      final authService =
          Provider.of<AuthenticationService>(context, listen: false);
      await authService.logout();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showError('Failed to logout: $e');
    }
  }
}
