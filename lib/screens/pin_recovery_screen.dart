import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/authentication_service.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class PinRecoveryScreen extends StatefulWidget {
  const PinRecoveryScreen({super.key});

  @override
  State<PinRecoveryScreen> createState() => _PinRecoveryScreenState();
}

class _PinRecoveryScreenState extends State<PinRecoveryScreen> {
  final _answer1Controller = TextEditingController();
  final _answer2Controller = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  
  List<String> _questions = [];
  bool _isLoading = true;
  bool _hasSecurityQuestions = false;
  bool _isVerifying = false;
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;

  @override
  void initState() {
    super.initState();
    _loadSecurityQuestions();
  }

  @override
  void dispose() {
    _answer1Controller.dispose();
    _answer2Controller.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _loadSecurityQuestions() async {
    try {
      final authService = Provider.of<AuthenticationService>(context, listen: false);
      _hasSecurityQuestions = await authService.hasSecurityQuestions();
      
      if (_hasSecurityQuestions) {
        _questions = await authService.getSecurityQuestionsList();
      }
    } catch (e) {
      // Failed to load, will show no security questions view
      _hasSecurityQuestions = false;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyAnswersAndResetPin() async {
    // Validate answers
    if (_answer1Controller.text.trim().isEmpty || _answer2Controller.text.trim().isEmpty) {
      _showError('Please answer both security questions');
      return;
    }

    // Validate new PIN
    final newPin = _newPinController.text;
    final confirmPin = _confirmPinController.text;

    if (newPin.isEmpty || confirmPin.isEmpty) {
      _showError('Please enter and confirm your new PIN');
      return;
    }

    if (!Validators.isValidPin(newPin)) {
      _showError('PIN must be 4-6 digits');
      return;
    }

    if (newPin != confirmPin) {
      _showError('PINs do not match');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final authService = Provider.of<AuthenticationService>(context, listen: false);
      
      final success = await authService.verifySecurityAnswersAndResetPin(
        [
          {'question': _questions[0], 'answer': _answer1Controller.text.trim()},
          {'question': _questions[1], 'answer': _answer2Controller.text.trim()},
        ],
        newPin,
      );

      if (!mounted) return;

      if (success) {
        // Show success and go back to login
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppConstants.successColor),
                SizedBox(width: 12),
                Text('PIN Reset'),
              ],
            ),
            content: const Text('Your PIN has been reset successfully. Please login with your new PIN.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to login
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        _showError('Incorrect answers. Please try again.');
      }
    } catch (e) {
      _showError('Failed to reset PIN: $e');
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
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
      appBar: AppBar(
        title: const Text('Reset PIN'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_hasSecurityQuestions
              ? _buildNoSecurityQuestionsView()
              : _buildRecoveryForm(),
    );
  }

  Widget _buildNoSecurityQuestionsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 80,
              color: AppConstants.warningColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Recovery Options',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Security questions were not set up for this account. Unfortunately, the only option is to reinstall the app, which will delete all data.',
              style: TextStyle(
                fontSize: 16,
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppConstants.primaryColor),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Answer your security questions correctly to reset your PIN.',
                    style: TextStyle(color: AppConstants.textPrimaryColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Question 1
          Text(
            'Question 1:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppConstants.textSecondaryColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _questions.isNotEmpty ? _questions[0] : '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _answer1Controller,
            decoration: const InputDecoration(
              labelText: 'Your Answer',
              prefixIcon: Icon(Icons.edit),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 24),

          // Question 2
          Text(
            'Question 2:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppConstants.textSecondaryColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _questions.length > 1 ? _questions[1] : '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _answer2Controller,
            decoration: const InputDecoration(
              labelText: 'Your Answer',
              prefixIcon: Icon(Icons.edit),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 32),

          // Divider
          const Divider(),
          const SizedBox(height: 16),

          // New PIN Section
          const Text(
            'Create New PIN',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _newPinController,
            obscureText: _obscurePin,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: 'New PIN',
              hintText: '4-6 digits',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscurePin ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscurePin = !_obscurePin),
              ),
              counterText: '',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPinController,
            obscureText: _obscureConfirmPin,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: 'Confirm New PIN',
              hintText: '4-6 digits',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPin ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscureConfirmPin = !_obscureConfirmPin),
              ),
              counterText: '',
            ),
          ),
          const SizedBox(height: 32),

          // Reset Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isVerifying ? null : _verifyAnswersAndResetPin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppConstants.primaryColor,
              ),
              child: _isVerifying
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Reset PIN', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

