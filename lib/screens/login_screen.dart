import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/authentication_service.dart';
import '../services/language_provider.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePin = true;
  int _failedAttempts = 0;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final pin = _pinController.text;
    final lp = Provider.of<LanguageProvider?>(context, listen: false);
    final t = lp?.t;

    if (pin.isEmpty) {
      _showError(t?.translate('pin_hint') ?? 'Please enter your PIN');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService =
          Provider.of<AuthenticationService>(context, listen: false);
      final success = await authService.login(pin);

      if (!mounted) return;

      if (success) {
        // Navigate to home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        _failedAttempts++;
        _pinController.clear();

        if (_failedAttempts >= AppConstants.maxPinAttempts) {
          _showError(
              'Too many failed attempts. Please wait ${AppConstants.pinLockoutMinutes} minutes.');
        } else {
          _showError(
              'Incorrect PIN. ${AppConstants.maxPinAttempts - _failedAttempts} attempts remaining.');
        }
      }
    } catch (e) {
      _showError('Login failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider?>(context);
    final t = languageProvider?.t;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.security,
                    size: 50,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Welcome Text
                Text(
                  t?.translate('welcome') ?? 'Welcome Back',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  t?.translate('enter_your_pin') ??
                      'Enter your PIN to continue',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 48),

                // PIN Input
                TextField(
                  controller: _pinController,
                  obscureText: _obscurePin,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  autofocus: true,
                  onSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    labelText: t?.translate('enter_pin') ?? 'PIN',
                    hintText: t?.translate('pin_hint') ?? 'Enter your PIN',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePin
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscurePin = !_obscurePin),
                    ),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            t?.translate('login') ?? 'Login',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Forgot PIN
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title:
                            Text(t?.translate('forgot_pin') ?? 'Forgot PIN?'),
                        content: Text(
                          t?.translate('forgot_pin_message') ??
                              'For security reasons, if you forgot your PIN, '
                                  'you will need to reinstall the app. This will '
                                  'delete all locally stored data.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(t?.translate('cancel') ?? 'Cancel'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(t?.translate('forgot_pin') ?? 'Forgot PIN?'),
                ),
                const SizedBox(height: 32),

                // Privacy Notice
                Text(
                  t?.translate('privacy_notice') ??
                      'Your data is encrypted and stored securely',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondaryColor.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
