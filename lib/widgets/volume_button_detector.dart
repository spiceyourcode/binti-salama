import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/panic_button_service.dart';
import '../utils/constants.dart';

/// Widget that detects volume button presses for panic button trigger
class VolumeButtonDetector extends StatefulWidget {
  final Widget child;
  final String? triggerType;

  const VolumeButtonDetector({
    super.key,
    required this.child,
    this.triggerType,
  });

  @override
  State<VolumeButtonDetector> createState() => _VolumeButtonDetectorState();
}

class _VolumeButtonDetectorState extends State<VolumeButtonDetector> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureFocusIfNeeded());
  }

  @override
  void dispose() {
    _focusNode.unfocus();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VolumeButtonDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.triggerType != widget.triggerType) {
      _ensureFocusIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final triggerType = widget.triggerType;
    final isVolumeTrigger = triggerType == AppConstants.panicTriggerVolume;

    if (!isVolumeTrigger) {
      return widget.child;
    }

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) => _handleKeyEvent(event),
      child: widget.child,
    );
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final logicalKey = event.logicalKey;
      if (logicalKey == LogicalKeyboardKey.audioVolumeUp ||
          logicalKey == LogicalKeyboardKey.audioVolumeDown) {
        final panicService =
            Provider.of<PanicButtonService>(context, listen: false);
        panicService.handleVolumeButtonPress();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _ensureFocusIfNeeded() {
    if (!mounted) return;

    if (widget.triggerType == AppConstants.panicTriggerVolume) {
      // Request focus so volume key events are captured
      if (!_focusNode.hasFocus && _focusNode.canRequestFocus) {
        _focusNode.requestFocus();
      }
    } else if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }
}

