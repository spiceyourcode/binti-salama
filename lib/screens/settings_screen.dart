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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Custom Header
                _buildHeader(t),
                // Scrollable Content
                Expanded(
                  child: ListView(
                    children: [
                      _buildSection('SECURITY & PRIVACY'),
                      _buildListTile(
                        icon: Icons.pin,
                        title: t?.translate('change_pin') ?? 'Change PIN',
                        subtitle: 'Update your security PIN',
                        onTap: _showChangePinDialog,
                      ),
                      _buildSwitchTile(
                        icon: Icons.visibility_off,
                        title: 'Disguise Mode',
                        subtitle: 'Hide app name & icon',
                        value: _disguiseMode,
                        onChanged: _updateDisguiseMode,
                      ),
                      _buildListTile(
                        icon: Icons.lock_clock,
                        title: 'Auto-Lock',
                        subtitle: 'Currently: $_autoLockMinutes minutes',
                        onTap: _showAutoLockDialog,
                      ),
                      _buildSection('TRUSTED CONTACTS',
                          count: _contacts.length),
                      _buildContactsList(),
                      _buildAddContactButton(),
                      _buildSection('EMERGENCY'),
                      _buildDropdownTile(
                        icon: Icons.touch_app,
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
                      _buildSection('GENERAL'),
                      _buildDropdownTile(
                        icon: Icons.language,
                        title: t != null ? t.translate('language') : 'Language',
                        subtitle: 'Choose your preferred language',
                        value: _language,
                        items: {
                          AppConstants.languageEnglish:
                              t != null ? t.translate('english') : 'English',
                          AppConstants.languageSwahili:
                              t != null ? t.translate('swahili') : 'Kiswahili',
                        },
                        onChanged: (value) async {
                          await _updateLanguage(value);
                          // notify LanguageProvider about the change so UI updates immediately
                          final lp = Provider.of<LanguageProvider?>(context,
                              listen: false);
                          if (lp != null) {
                            await lp.setLanguage(
                                value ?? AppConstants.languageEnglish);
                          }
                        },
                      ),
                      _buildSwitchTile(
                        icon: Icons.notifications,
                        title: 'Notifications',
                        subtitle: 'App alerts & reminders',
                        value: _notificationsEnabled,
                        onChanged: _updateNotifications,
                      ),
                      _buildSection('ABOUT & LEGAL'),
                      _buildListTile(
                        icon: Icons.info,
                        title: 'About Binti Salama',
                        subtitle: 'Mission & version info',
                        onTap: _showAboutDialog,
                      ),
                      _buildListTile(
                        icon: Icons.privacy_tip,
                        title: 'Privacy Policy',
                        subtitle: 'How we protect your data',
                        onTap: _showPrivacyPolicy,
                      ),
                      _buildSection('DANGER ZONE', isDanger: true),
                      _buildListTile(
                        icon: Icons.delete_forever,
                        title: 'Delete All Data',
                        subtitle: 'Permanently erase everything',
                        titleColor: AppConstants.errorColor,
                        onTap: _confirmDeleteAccount,
                      ),
                      const SizedBox(height: 32),
                      _buildLogoutButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(AppLocalizations? t) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
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
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, {int? count, bool isDanger = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDanger
                  ? AppConstants.errorColor
                  : AppConstants.textSecondaryColor,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppConstants.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count contacts',
                style: TextStyle(
                  fontSize: 10,
                  color: AppConstants.accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (titleColor ?? AppConstants.primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            color: titleColor ?? AppConstants.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 12),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppConstants.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppConstants.accentColor,
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppConstants.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 12),
            )
          : null,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          isDense: true,
          items: items.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    if (_contacts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No trusted contacts added yet',
          style: TextStyle(color: AppConstants.textSecondaryColor),
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

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: avatarColor.withOpacity(0.2),
            child: Text(
              initials,
              style: TextStyle(
                color: avatarColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(contact.name),
          subtitle: Text(contact.phoneNumber),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: contact.isEmergency
                      ? AppConstants.successColor.withOpacity(0.1)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  contact.isEmergency ? 'Emergency Contact' : 'Friend',
                  style: TextStyle(
                    fontSize: 10,
                    color: contact.isEmergency
                        ? AppConstants.successColor
                        : AppConstants.textSecondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppConstants.errorColor, size: 20),
                onPressed: () => _confirmDeleteContact(contact),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddContactButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _showAddContactDialog,
        icon: const Icon(Icons.person_add, size: 18),
        label: const Text('Add Trusted Contact'),
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
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
