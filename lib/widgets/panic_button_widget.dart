import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../services/panic_button_service.dart';

class PanicButtonWidget extends StatefulWidget {
  final VoidCallback onPressed;
  final String? triggerType;

  const PanicButtonWidget({
    super.key,
    required this.onPressed,
    this.triggerType,
  });

  @override
  State<PanicButtonWidget> createState() => _PanicButtonWidgetState();
}

class _PanicButtonWidgetState extends State<PanicButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final triggerType = widget.triggerType ?? AppConstants.panicTriggerShake;
    final isDoubleTap = triggerType == AppConstants.panicTriggerDoubleTap;
    final isVolumeTrigger = triggerType == AppConstants.panicTriggerVolume;

    final String subtitle = isDoubleTap
        ? 'Double tap to send alert to trusted contacts'
        : 'Tap to send alert to trusted contacts';

    final String helperText = () {
      if (isDoubleTap) return 'Double tap anywhere on the button';
      if (isVolumeTrigger) return 'Or press your volume buttons';
      return 'Or shake your phone';
    }();

    final IconData helperIcon = () {
      if (isVolumeTrigger) return Icons.volume_up;
      if (isDoubleTap) return Icons.touch_app;
      return Icons.vibration;
    }();
    
    final buttonContent = Card(
      elevation: 4,
      color: const Color(0xFFFFE5E5), // Light pink background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: isDoubleTap ? null : widget.onPressed,
        onDoubleTap: isDoubleTap ? () {
          final panicService = Provider.of<PanicButtonService>(context, listen: false);
          panicService.handleDoubleTap();
        } : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.pan_tool,
                          size: 60,
                          color: AppConstants.emergencyRed,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
              const Text(
                'EMERGENCY ALERT',
                style: TextStyle(
                  color: AppConstants.emergencyRed,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppConstants.textSecondaryColor,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: AppConstants.emergencyRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(helperIcon, color: AppConstants.emergencyRed, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      helperText,
                      style: const TextStyle(
                        color: AppConstants.emergencyRed,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
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

    // Wrap with GestureDetector for double tap if needed
    if (isDoubleTap) {
      return SizedBox(
        width: double.infinity,
        child: GestureDetector(
          onDoubleTap: () {
            final panicService = Provider.of<PanicButtonService>(context, listen: false);
            panicService.handleDoubleTap();
          },
          child: buttonContent,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: buttonContent,
    );
  }
}


