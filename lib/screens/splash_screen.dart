import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/authentication_service.dart';
import '../services/language_provider.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Show splash for minimum duration
    await Future.delayed(
      const Duration(seconds: AppConstants.splashScreenDurationSeconds),
    );

    if (!mounted) return;

    final authService =
        Provider.of<AuthenticationService>(context, listen: false);

    try {
      // Check if account exists
      final hasAccount = await authService.hasAccount();

      if (!mounted) return;

      if (!hasAccount) {
        // No account exists, show onboarding
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      } else {
        // Account exists, check if authenticated
        final isAuthenticated = await authService.isAuthenticated();

        if (!mounted) return;

        if (isAuthenticated) {
          // Already authenticated, go to home
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          // Need to login
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      AppLogger.info('Initialization error: $e');
      // On error, go to onboarding
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider?>(context);
    final t = languageProvider?.t;

    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon/Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.security,
                  size: 60,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 32),

              // App Name
              Text(
                t?.translate('app_name') ?? AppConstants.appName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // App Tagline
              Text(
                t?.translate('app_tagline') ?? AppConstants.appDescription,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 16),

              // Privacy Notice
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  t?.translate('privacy_notice') ??
                      'Your privacy and safety are our priority.\nAll data is encrypted and stored securely on your device.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

