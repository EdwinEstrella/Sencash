import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/mock_data_service.dart';

class AuthProvider extends ChangeNotifier {
  final MockDataService _mockDataService = MockDataService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Initialize auth state
  void initialize() {
    _mockDataService.initializeMockData();
  }

  // Login method
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _mockDataService.login(email, password);

      if (user != null) {
        _user = user;
        _setLoading(false);
        return true;
      } else {
        _setError('Invalid email or password');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Login failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // Register method
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _mockDataService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      if (user != null) {
        _user = user;
        _setLoading(false);
        return true;
      } else {
        _setError('Registration failed. User may already exist.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Registration failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _mockDataService.logout();
      _user = null;
      _clearError();
    } catch (e) {
      _setError('Logout failed');
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    if (_user == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      final updatedUser = _user!.copyWith(
        firstName: firstName ?? _user!.firstName,
        lastName: lastName ?? _user!.lastName,
        fullName: firstName != null || lastName != null
          ? '${firstName ?? _user!.firstName} ${lastName ?? _user!.lastName}'
          : _user!.fullName,
        phoneNumber: phoneNumber ?? _user!.phoneNumber,
      );

      _user = updatedUser;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update profile');
      _setLoading(false);
      return false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_user == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Validate current password
      if (_user!.password != currentPassword) {
        _setError('Current password is incorrect');
        _setLoading(false);
        return false;
      }

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      _user = _user!.copyWith(password: newPassword);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to change password');
      _setLoading(false);
      return false;
    }
  }

  // Toggle biometric authentication (mock)
  Future<bool> toggleBiometricAuth(bool enabled) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate biometric setup
      await Future.delayed(const Duration(milliseconds: 1200));

      _setLoading(false);
      return enabled;
    } catch (e) {
      _setError('Failed to toggle biometric authentication');
      _setLoading(false);
      return false;
    }
  }

  // Verify identity (mock KYC)
  Future<bool> verifyIdentity({
    required String documentType,
    required String documentNumber,
  }) async {
    if (_user == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Simulate KYC verification
      await Future.delayed(const Duration(milliseconds: 2000));

      _user = _user!.copyWith(isKycVerified: true);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Identity verification failed');
      _setLoading(false);
      return false;
    }
  }

  // Check if user needs to verify identity
  bool get needsKycVerification => _user != null && !_user!.isKycVerified;

  // Reset password (mock)
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      // Check if user exists
      final userExists = _mockDataService.users
          .where((u) => u.email.toLowerCase() == email.toLowerCase())
          .isNotEmpty;

      if (!userExists) {
        _setError('No account found with this email');
        _setLoading(false);
        return false;
      }

      // Simulate password reset email
      await Future.delayed(const Duration(milliseconds: 1500));

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to reset password');
      _setLoading(false);
      return false;
    }
  }

  // Validate session (mock)
  Future<bool> validateSession() async {
    if (_user == null) return false;

    try {
      // Simulate session validation
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    if (_user == null) return;

    try {
      // Simulate data refresh
      await Future.delayed(const Duration(milliseconds: 500));
      notifyListeners();
    } catch (e) {
      // Handle error silently or show error if needed
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set user manually (for testing or direct initialization)
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  // Clear user data
  void clearUser() {
    _user = null;
    _clearError();
  }

  // Get user initials
  String get userInitials {
    if (_user == null) return '?';
    return _user!.fullName.split(' ')
        .map((name) => name.isNotEmpty ? name[0] : '')
        .take(2)
        .join('')
        .toUpperCase();
  }

  // Get display name
  String get displayName => _user?.fullName ?? 'Guest';

  // Get formatted balance
  String get formattedBalance {
    if (_user == null) return '\$0.00';
    return '\$${_user!.balance.toStringAsFixed(2)}';
  }

  // Check if user can make transaction
  bool canMakeTransaction(double amount) {
    if (_user == null) return false;
    return _user!.balance >= amount;
  }

  // Get transaction limits
  Map<String, dynamic> get transactionLimits {
    return {
      'minAmount': 10.0,
      'maxAmount': 10000.0,
      'dailyLimit': 25000.0,
      'monthlyLimit': 100000.0,
    };
  }

  }