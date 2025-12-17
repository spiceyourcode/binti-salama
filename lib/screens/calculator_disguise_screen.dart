import 'package:flutter/material.dart';
import 'login_screen.dart';

/// A fully functional calculator that serves as the disguise for the app.
///
/// SECRET ACCESS: Enter the sequence "159=" to reveal the real app.
/// This looks like a normal calculation but unlocks Binti Salama.
class CalculatorDisguiseScreen extends StatefulWidget {
  const CalculatorDisguiseScreen({super.key});

  @override
  State<CalculatorDisguiseScreen> createState() =>
      _CalculatorDisguiseScreenState();
}

class _CalculatorDisguiseScreenState extends State<CalculatorDisguiseScreen> {
  String _display = '0';
  String _currentInput = '';
  String _operator = '';
  double _firstOperand = 0;
  bool _shouldResetDisplay = false;

  // Secret sequence tracking
  String _inputSequence = '';
  static const String _secretCode = '159='; // Secret code to unlock real app

  void _onDigitPressed(String digit) {
    setState(() {
      // Track input sequence for secret code
      _inputSequence += digit;
      if (_inputSequence.length > 10) {
        _inputSequence = _inputSequence.substring(_inputSequence.length - 10);
      }

      if (_shouldResetDisplay) {
        _display = digit;
        _currentInput = digit;
        _shouldResetDisplay = false;
      } else {
        if (_display == '0' && digit != '.') {
          _display = digit;
          _currentInput = digit;
        } else {
          _display += digit;
          _currentInput += digit;
        }
      }
    });
  }

  void _onOperatorPressed(String op) {
    setState(() {
      if (_currentInput.isNotEmpty) {
        _firstOperand = double.tryParse(_currentInput) ?? 0;
      }
      _operator = op;
      _shouldResetDisplay = true;
      _currentInput = '';
    });
  }

  void _onEqualsPressed() {
    // Track equals in sequence
    _inputSequence += '=';

    // Check for secret code
    if (_inputSequence.contains(_secretCode)) {
      _unlockRealApp();
      return;
    }

    setState(() {
      if (_operator.isEmpty || _currentInput.isEmpty) {
        _shouldResetDisplay = true;
        return;
      }

      double secondOperand = double.tryParse(_currentInput) ?? 0;
      double result = 0;

      switch (_operator) {
        case '+':
          result = _firstOperand + secondOperand;
          break;
        case '-':
          result = _firstOperand - secondOperand;
          break;
        case '×':
          result = _firstOperand * secondOperand;
          break;
        case '÷':
          if (secondOperand != 0) {
            result = _firstOperand / secondOperand;
          } else {
            _display = 'Error';
            _currentInput = '';
            _operator = '';
            _shouldResetDisplay = true;
            return;
          }
          break;
      }

      // Format result
      if (result == result.toInt()) {
        _display = result.toInt().toString();
      } else {
        _display = result
            .toStringAsFixed(8)
            .replaceAll(RegExp(r'0+$'), '')
            .replaceAll(RegExp(r'\.$'), '');
      }

      _currentInput = _display;
      _operator = '';
      _shouldResetDisplay = true;
    });
  }

  void _onClearPressed() {
    setState(() {
      _display = '0';
      _currentInput = '';
      _operator = '';
      _firstOperand = 0;
      _shouldResetDisplay = false;
      _inputSequence = '';
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
        _currentInput = _display;
      } else {
        _display = '0';
        _currentInput = '';
      }
    });
  }

  void _onPercentPressed() {
    setState(() {
      double value = double.tryParse(_currentInput) ?? 0;
      value = value / 100;
      if (value == value.toInt()) {
        _display = value.toInt().toString();
      } else {
        _display = value.toString();
      }
      _currentInput = _display;
    });
  }

  void _onPlusMinusPressed() {
    setState(() {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else if (_display != '0') {
        _display = '-$_display';
      }
      _currentInput = _display;
    });
  }

  void _unlockRealApp() {
    // Reset sequence
    _inputSequence = '';

    // Navigate to the real login screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: [
            // Display
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                alignment: Alignment.bottomRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Text(
                    _display,
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Buttons
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildButtonRow(['C', '±', '%', '÷']),
                    const SizedBox(height: 12),
                    _buildButtonRow(['7', '8', '9', '×']),
                    const SizedBox(height: 12),
                    _buildButtonRow(['4', '5', '6', '-']),
                    const SizedBox(height: 12),
                    _buildButtonRow(['1', '2', '3', '+']),
                    const SizedBox(height: 12),
                    _buildButtonRow(['0', '.', '⌫', '=']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<String> buttons) {
    return Expanded(
      child: Row(
        children: buttons.map((btn) {
          final isOperator = ['÷', '×', '-', '+', '='].contains(btn);
          final isFunction = ['C', '±', '%'].contains(btn);
          final isZero = btn == '0';

          return Expanded(
            flex: isZero ? 1 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _buildButton(
                btn,
                isOperator: isOperator,
                isFunction: isFunction,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildButton(String text,
      {bool isOperator = false, bool isFunction = false}) {
    Color bgColor;
    Color textColor;

    if (isOperator) {
      bgColor = const Color(0xFFFF9F0A);
      textColor = Colors.white;
    } else if (isFunction) {
      bgColor = const Color(0xFFA5A5A5);
      textColor = Colors.black;
    } else {
      bgColor = const Color(0xFF333333);
      textColor = Colors.white;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(40),
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () => _handleButtonPress(text),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  void _handleButtonPress(String btn) {
    switch (btn) {
      case 'C':
        _onClearPressed();
        break;
      case '±':
        _onPlusMinusPressed();
        break;
      case '%':
        _onPercentPressed();
        break;
      case '⌫':
        _onBackspacePressed();
        break;
      case '=':
        _onEqualsPressed();
        break;
      case '+':
      case '-':
      case '×':
      case '÷':
        _onOperatorPressed(btn);
        break;
      default:
        _onDigitPressed(btn);
    }
  }
}
