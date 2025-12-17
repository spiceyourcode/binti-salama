import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/authentication_service.dart';
import '../services/language_provider.dart';
import '../services/disguise_mode_provider.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'calculator_disguise_screen.dart';

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
    final disguiseProvider =
        Provider.of<DisguiseModeProvider>(context, listen: false);

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
        // Account exists - check if disguise mode is enabled
        // Load disguise mode setting
        await disguiseProvider.loadDisguiseMode();
        
        if (!mounted) return;
        
        // If disguise mode is ON, ALWAYS show the calculator first
        // This ensures the real app is never visible to someone watching
        if (disguiseProvider.isDisguised) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const CalculatorDisguiseScreen()),
          );
          return;
        }
        
        // Normal mode - check if authenticated
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
    final disguiseProvider = Provider.of<DisguiseModeProvider?>(context);
    final t = languageProvider?.t;

    // Get appearance based on disguise mode
    final isDisguised = disguiseProvider?.isDisguised ?? false;
    final appName = isDisguised 
        ? DisguiseConstants.disguisedAppName 
        : (t?.translate('app_name') ?? AppConstants.appName);
    final appTagline = isDisguised 
        ? DisguiseConstants.disguisedTagline 
        : (t?.translate('app_tagline') ?? AppConstants.appDescription);
    final appIcon = isDisguised 
        ? DisguiseConstants.disguisedIcon 
        : Icons.security;
    final primaryColor = isDisguised 
        ? DisguiseConstants.disguisedPrimaryColor 
        : AppConstants.primaryColor;
    final privacyNotice = isDisguised 
        ? '' // Hide privacy notice in disguise mode
        : (t?.translate('privacy_notice') ?? 
            'Your privacy and safety are our priority.\nAll data is encrypted and stored securely on your device.');

    return Scaffold(
      backgroundColor: primaryColor,
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
                child: Icon(
                  appIcon,
                  size: 60,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 32),

              // App Name
              Text(
                appName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // App Tagline
              Text(
                appTagline,
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

              // Privacy Notice (hidden in disguise mode)
              if (privacyNotice.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    privacyNotice,
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

