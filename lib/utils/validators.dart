import '../utils/constants.dart';

class Validators {
  /// Validate phone number (Kenyan format)
  static bool isValidPhoneNumber(String phoneNumber) {
    // Remove spaces and special characters except +
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Check various Kenyan formats
    final regex = RegExp(AppConstants.kenyaPhoneRegex);
    return regex.hasMatch(cleaned);
  }

  /// Validate PIN
  static bool isValidPin(String pin) {
    if (pin.length < AppConstants.minPinLength ||
        pin.length > AppConstants.maxPinLength) {
      return false;
    }

    // Check if PIN contains only digits
    final regex = RegExp(r'^\d+$');
    return regex.hasMatch(pin);
  }

  /// Validate PIN match
  static bool doPinsMatch(String pin1, String pin2) {
    return pin1 == pin2;
  }

  /// Validate required field
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Format phone number to Kenyan standard (+254)
  static String formatPhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.startsWith('254')) {
      return '+$cleaned';
    } else if (cleaned.startsWith('0')) {
      return '+254${cleaned.substring(1)}';
    } else if (cleaned.startsWith('7') || cleaned.startsWith('1')) {
      return '+254$cleaned';
    }
    
    return phoneNumber; // Return original if can't format
  }

  /// Get PIN validation error message
  static String? getPinError(String pin) {
    if (pin.isEmpty) {
      return AppConstants.errorEmptyField;
    }
    if (!isValidPin(pin)) {
      return AppConstants.errorInvalidPin;
    }
    return null;
  }

  /// Get phone number validation error message
  static String? getPhoneNumberError(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      return AppConstants.errorEmptyField;
    }
    if (!isValidPhoneNumber(phoneNumber)) {
      return AppConstants.errorInvalidPhoneNumber;
    }
    return null;
  }

  /// Get required field error message
  static String? getRequiredFieldError(String? value) {
    if (!isNotEmpty(value)) {
      return AppConstants.errorEmptyField;
    }
    return null;
  }
}

