import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/authentication_service.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  int _currentPage = 0;
  bool _isLoading = false;
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;

  @override
  void dispose() {
    _pageController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _createAccount() async {
    final pin = _pinController.text;
    final confirmPin = _confirmPinController.text;

    // Validation
    if (pin.isEmpty || confirmPin.isEmpty) {
      _showError('Please enter and confirm your PIN');
      return;
    }

    if (!Validators.isValidPin(pin)) {
      _showError(AppConstants.errorInvalidPin);
      return;
    }

    if (pin != confirmPin) {
      _showError(AppConstants.errorPinMismatch);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthenticationService>(context, listen: false);
      await authService.createAccount(pin);

      if (!mounted) return;

      // Navigate to home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      _showError('Failed to create account: $e');
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildWelcomePage(),
                  _buildPrivacyPage(),
                  _buildFeaturesPage(),
                  _buildPinSetupPage(),
                ],
              ),
            ),
            _buildPageIndicator(),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.security,
              size: 60,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Welcome to Binti Salama',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Safe Girl - Your Confidential Support',
            style: TextStyle(
              fontSize: 18,
              color: AppConstants.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            'You are not alone. This app provides confidential support, '
            'emergency assistance, and resources for adolescent girls '
            'experiencing sexual violence.',
            style: TextStyle(
              fontSize: 16,
              color: AppConstants.textSecondaryColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock,
            size: 80,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(height: 32),
          const Text(
            'Your Privacy is Protected',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildPrivacyFeature(
            Icons.phonelink_lock,
            'Encrypted Storage',
            'All your data is encrypted and stored securely on your device only',
          ),
          const SizedBox(height: 16),
          _buildPrivacyFeature(
            Icons.visibility_off,
            'PIN Protection',
            'Access your information with your private PIN',
          ),
          const SizedBox(height: 16),
          _buildPrivacyFeature(
            Icons.cloud_off,
            'No Cloud Storage',
            'Your data never leaves your device unless you choose to share it',
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyFeature(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppConstants.primaryColor),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite,
            size: 80,
            color: AppConstants.secondaryColor,
          ),
          const SizedBox(height: 32),
          const Text(
            'How We Can Help',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildFeature(Icons.emergency, 'Emergency Alert', 'Send instant alerts to trusted contacts'),
          const SizedBox(height: 16),
          _buildFeature(Icons.local_hospital, 'Find Services', 'Locate nearest GBV centers and clinics'),
          const SizedBox(height: 16),
          _buildFeature(Icons.medical_services, 'First Response', 'Step-by-step guidance on what to do'),
          const SizedBox(height: 16),
          _buildFeature(Icons.book, 'Document Incidents', 'Securely record important information'),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppConstants.primaryColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPinSetupPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.pin,
            size: 80,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(height: 32),
          const Text(
            'Create Your PIN',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Choose a 4-6 digit PIN to protect your information',
            style: TextStyle(
              fontSize: 16,
              color: AppConstants.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _pinController,
            obscureText: _obscurePin,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: 'Enter PIN',
              hintText: '4-6 digits',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscurePin ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscurePin = !_obscurePin),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPinController,
            obscureText: _obscureConfirmPin,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: 'Confirm PIN',
              hintText: '4-6 digits',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPin ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscureConfirmPin = !_obscureConfirmPin),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createAccount,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create Account'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          4,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? AppConstants.primaryColor
                  : AppConstants.primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: _previousPage,
              child: const Text('Back'),
            )
          else
            const SizedBox(width: 80),
          if (_currentPage < 3)
            ElevatedButton(
              onPressed: _nextPage,
              child: const Text('Next'),
            )
          else
            const SizedBox(width: 80),
        ],
      ),
    );
  }
}

