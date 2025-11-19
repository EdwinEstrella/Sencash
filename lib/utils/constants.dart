class AppConstants {
  // App Info
  static const String appName = 'SenCash';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Fintech wallet for international money transfers';

  // API Configuration (Mock)
  static const String apiBaseUrl = 'https://api.sencash.test';
  static const int networkDelay = 800; // Simulated network delay in ms

  // Transaction Limits
  static const double minTransactionAmount = 10.0;
  static const double maxTransactionAmount = 10000.0;
  static const double transactionFeeRate = 0.015; // 1.5%
  static const double minTransactionFee = 0.50;
  static const int maxMassRecipients = 20;

  // Currency
  static const String defaultCurrency = 'USD';
  static const String currencySymbol = '\$';

  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'MMM dd, yyyy • hh:mm a';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxCardNumberLength = 16;
  static const int cardCVVLength = 3;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 200;

  // Mock Users for Testing
  static const Map<String, String> mockUsers = {
    'usuario@test.com': '123456',
    'demo@wallet.com': 'demo123',
    'test@example.com': 'test123',
  };

  // Animation Durations
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;

  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Please check your internet connection.';
  static const String authErrorMessage = 'Invalid email or password.';
  static const String insufficientFundsMessage = 'Insufficient balance for this transaction.';
  static const String invalidAmountMessage = 'Please enter a valid amount.';

  // Success Messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String registrationSuccessMessage = 'Account created successfully!';
  static const String transferSuccessMessage = 'Money sent successfully!';
  static const String cardAddedMessage = 'Card added successfully!';
}

class RouteConstants {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String sendMoney = '/send-money';
  static const String massSend = '/mass-send';
  static const String transactions = '/transactions';
  static const String transactionDetail = '/transaction-detail';
  static const String cards = '/cards';
  static const String addCard = '/add-card';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
}

class CacheConstants {
  static const String userKey = 'user';
  static const String authTokenKey = 'auth_token';
  static const String isDarkModeKey = 'is_dark_mode';
  static const String isBiometricEnabledKey = 'is_biometric_enabled';
  static const String languageKey = 'language';
  static const String rememberMeKey = 'remember_me';
  static const String recentTransfersKey = 'recent_transfers';
}