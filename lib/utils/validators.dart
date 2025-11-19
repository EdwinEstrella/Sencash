import 'constants.dart';

class Validators {
  // Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Basic email regex pattern
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password Validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    // Check for at least one letter
    if (!value.contains(RegExp(r'[a-zA-Z]'))) {
      return 'Password must contain at least one letter';
    }

    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  // Confirm Password Validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Name Validation
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters long';
    }

    if (value.trim().length > AppConstants.maxNameLength) {
      return '$fieldName cannot be more than ${AppConstants.maxNameLength} characters';
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r'^[a-zA-Z\s\-\_\.]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  // Phone Number Validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters
    final cleanPhone = value.replaceAll(RegExp(r'[^0-9+]'), '');

    // Check if it starts with + (international format) or is exactly 10 digits (US format)
    if (!cleanPhone.startsWith('+') && cleanPhone.length != 10) {
      return 'Please enter a valid 10-digit phone number';
    }

    if (cleanPhone.startsWith('+') && cleanPhone.length < 8) {
      return 'Please enter a valid international phone number';
    }

    return null;
  }

  // Card Number Validation
  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }

    // Remove spaces and dashes
    final cleanCard = value.replaceAll(RegExp(r'[\s\-]'), '');

    if (cleanCard.length < 13 || cleanCard.length > 19) {
      return 'Please enter a valid card number';
    }

    // Check if all characters are digits
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanCard)) {
      return 'Card number can only contain digits';
    }

    // Luhn algorithm validation
    if (!isValidLuhn(cleanCard)) {
      return 'Please enter a valid card number';
    }

    return null;
  }

  // CVV Validation
  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }

    if (value.length != 3 && value.length != 4) {
      return 'CVV must be 3 or 4 digits';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'CVV can only contain digits';
    }

    return null;
  }

  // Expiry Date Validation (MM/YY format)
  static String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    }

    // Check format MM/YY or MM/YYYY
    final expiryRegex = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2}|[0-9]{4})$');
    if (!expiryRegex.hasMatch(value)) {
      return 'Please enter a valid expiry date (MM/YY)';
    }

    final parts = value.split('/');
    final month = int.parse(parts[0]);
    String yearStr = parts[1];

    // Convert YY to YYYY if needed
    if (yearStr.length == 2) {
      final currentYear = DateTime.now().year;
      final currentYearLastTwo = currentYear % 100;
      int yearBase = currentYear - currentYearLastTwo;
      int yearParsed = int.parse(yearStr);

      // If the year is in the past, assume it's in the future
      if (yearParsed < currentYearLastTwo) {
        yearBase += 100;
      }

      yearStr = (yearBase + yearParsed).toString();
    }

    final year = int.parse(yearStr);
    final now = DateTime.now();

    // Add one month to expiry date to check if card is expired
    final expiryPlusOneMonth = DateTime(year, month + 1);

    if (expiryPlusOneMonth.isBefore(now)) {
      return 'Card has expired';
    }

    return null;
  }

  // Amount Validation
  static String? validateAmount(String? value, {double? maxAmount}) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }

    // Remove $ and commas
    final cleanAmount = value.replaceAll(RegExp(r'[\$,]'), '');

    try {
      final amount = double.parse(cleanAmount);

      if (amount <= 0) {
        return 'Amount must be greater than 0';
      }

      if (amount < AppConstants.minTransactionAmount) {
        return 'Minimum amount is \$${AppConstants.minTransactionAmount.toStringAsFixed(2)}';
      }

      if (maxAmount != null && amount > maxAmount) {
        return 'Maximum amount is \$${maxAmount.toStringAsFixed(2)}';
      }

      if (amount > AppConstants.maxTransactionAmount) {
        return 'Maximum amount is \$${AppConstants.maxTransactionAmount.toStringAsFixed(2)}';
      }

    } catch (e) {
      return 'Please enter a valid amount';
    }

    return null;
  }

  // Description Validation
  static String? validateDescription(String? value) {
    if (value != null && value.trim().length > AppConstants.maxDescriptionLength) {
      return 'Description cannot be more than ${AppConstants.maxDescriptionLength} characters';
    }

    return null;
  }

  // Generic Required Field Validation
  static String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  // Luhn Algorithm for card validation
  static bool isValidLuhn(String cardNumber) {
    if (cardNumber.isEmpty) return false;

    int sum = 0;
    bool alternate = false;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  // Format card number with spaces
  static String formatCardNumber(String cardNumber) {
    final cleanCard = cardNumber.replaceAll(RegExp(r'[\s\-]'), '');

    if (cleanCard.length <= 4) return cleanCard;
    if (cleanCard.length <= 8) return '${cleanCard.substring(0, 4)} ${cleanCard.substring(4)}';
    if (cleanCard.length <= 12) return '${cleanCard.substring(0, 4)} ${cleanCard.substring(4, 8)} ${cleanCard.substring(8)}';

    return '${cleanCard.substring(0, 4)} ${cleanCard.substring(4, 8)} ${cleanCard.substring(8, 12)} ${cleanCard.substring(12, 16)}';
  }

  // Format expiry date
  static String formatExpiryDate(String value) {
    if (value.isEmpty) return value;

    // Remove any non-digit characters
    String cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanValue.length >= 3) {
      return '${cleanValue.substring(0, 2)}/${cleanValue.substring(2, 4)}';
    }

    return cleanValue;
  }

  // Format amount
  static String formatAmount(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  // Format phone number
  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return phoneNumber;

    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    if (cleanPhone.length == 10) {
      return '(${cleanPhone.substring(0, 3)}) ${cleanPhone.substring(3, 6)}-${cleanPhone.substring(6)}';
    }

    return cleanPhone;
  }

  // Expiry Date Validation for separate month and year fields
  static bool isValidExpiryDate(String month, String year) {
    try {
      final currentMonth = DateTime.now().month;
      final currentYear = DateTime.now().year % 100; // Get last 2 digits

      final expMonth = int.parse(month);
      final expYear = int.parse(year);

      if (expMonth < 1 || expMonth > 12) {
        return false;
      }

      if (expYear < currentYear || (expYear == currentYear && expMonth < currentMonth)) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}