import 'package:flutter/foundation.dart';
import '../models/card.dart';
import '../services/mock_data_service.dart';

class CardProvider extends ChangeNotifier {
  final MockDataService _mockDataService = MockDataService();

  List<Card> _cards = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Card> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get cardCount => _cards.length;
  bool get hasCards => _cards.isNotEmpty;

  // Get default card
  Card? get defaultCard {
    try {
      return _cards.firstWhere((card) => card.isDefault);
    } catch (e) {
      return _cards.isNotEmpty ? _cards.first : null;
    }
  }

  // Get active cards
  List<Card> get activeCards {
    return _cards.where((card) => card.isActive).toList();
  }

  // Get expired cards
  List<Card> get expiredCards {
    return _cards.where((card) => card.isExpired).toList();
  }

  // Load user cards
  Future<void> loadCards(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      final cards = await _mockDataService.getUserCards(userId);
      _cards = cards;
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load cards');
      _setLoading(false);
    }
  }

  // Add new card
  Future<Card?> addCard({
    required String userId,
    required CardType type,
    required String cardNumber,
    required String cardholderName,
    required String expiryMonth,
    required String expiryYear,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final card = await _mockDataService.addCard(
        userId: userId,
        type: type,
        cardNumber: cardNumber,
        cardholderName: cardholderName,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
      );

      if (card != null) {
        _cards.add(card);
        _setLoading(false);
        return card;
      } else {
        _setError('Failed to add card');
        _setLoading(false);
        return null;
      }
    } catch (e) {
      _setError('Failed to add card: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }

  // Delete card
  Future<bool> deleteCard(String cardId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _mockDataService.deleteCard(cardId);

      if (success) {
        _cards.removeWhere((card) => card.id == cardId);
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to delete card');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete card: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Set default card
  Future<bool> setDefaultCard(String userId, String cardId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _mockDataService.setDefaultCard(userId, cardId);

      if (success) {
        // Update local card list to reflect the change
        for (int i = 0; i < _cards.length; i++) {
          _cards[i] = _cards[i].copyWith(isDefault: _cards[i].id == cardId);
        }
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to set default card');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to set default card: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Get card by ID
  Card? getCardById(String cardId) {
    try {
      return _cards.firstWhere((card) => card.id == cardId);
    } catch (e) {
      return null;
    }
  }

  // Update card status
  Future<bool> updateCardStatus(String cardId, CardStatus status) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      final index = _cards.indexWhere((card) => card.id == cardId);
      if (index != -1) {
        _cards[index] = _cards[index].copyWith(status: status);
        _setLoading(false);
        return true;
      } else {
        _setError('Card not found');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to update card status');
      _setLoading(false);
      return false;
    }
  }

  // Block card
  Future<bool> blockCard(String cardId) async {
    return await updateCardStatus(cardId, CardStatus.blocked);
  }

  // Unblock card
  Future<bool> unblockCard(String cardId) async {
    return await updateCardStatus(cardId, CardStatus.active);
  }

  // Validate card number
  bool isValidCardNumber(String cardNumber) {
    final cleanCard = cardNumber.replaceAll(RegExp(r'[\s\-]'), '');

    if (cleanCard.length < 13 || cleanCard.length > 19) {
      return false;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(cleanCard)) {
      return false;
    }

    return _isValidLuhn(cleanCard);
  }

  // Format card number for display
  String formatCardNumber(String cardNumber) {
    final cleanCard = cardNumber.replaceAll(RegExp(r'[\s\-]'), '');

    if (cleanCard.length <= 4) return cleanCard;
    if (cleanCard.length <= 8) return '${cleanCard.substring(0, 4)} ${cleanCard.substring(4)}';
    if (cleanCard.length <= 12) return '${cleanCard.substring(0, 4)} ${cleanCard.substring(4, 8)} ${cleanCard.substring(8)}';

    return '${cleanCard.substring(0, 4)} ${cleanCard.substring(4, 8)} ${cleanCard.substring(8, 12)} ${cleanCard.substring(12, 16)}';
  }

  // Mask card number
  String maskCardNumber(String cardNumber) {
    final cleanCard = cardNumber.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleanCard.length < 4) return cleanCard;

    final lastFour = cleanCard.substring(cleanCard.length - 4);
    final maskedPart = '*' * (cleanCard.length - 4);
    return '${maskedPart.substring(0, 4)} ${maskedPart.substring(4, 8)} ${maskedPart.substring(8, 12)} $lastFour';
  }

  // Detect card brand
  String detectCardBrand(String cardNumber) {
    final cleanCard = cardNumber.replaceAll(RegExp(r'[\s\-]'), '');

    if (cleanCard.startsWith('4')) return 'Visa';
    if (cleanCard.startsWith('5')) return 'Mastercard';
    if (cleanCard.startsWith('3') && cleanCard.length == 15) return 'American Express';
    if (cleanCard.startsWith('6')) return 'Discover';
    if (cleanCard.startsWith('34') || cleanCard.startsWith('37')) return 'American Express';
    if (cleanCard.startsWith('65')) return 'Discover';
    if (cleanCard.startsWith('6011')) return 'Discover';

    return 'Unknown';
  }

  // Get card brand icon
  String getCardBrandIcon(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'assets/icons/visa.svg';
      case 'mastercard':
        return 'assets/icons/mastercard.svg';
      case 'american express':
      case 'amex':
        return 'assets/icons/amex.svg';
      case 'discover':
        return 'assets/icons/discover.svg';
      default:
        return 'assets/icons/credit_card.svg';
    }
  }

  // Get card color based on brand
  String getCardColor(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return '#1A1F71';
      case 'mastercard':
        return '#EB001B';
      case 'american express':
      case 'amex':
        return '#006FCF';
      case 'discover':
        return '#FF6000';
      default:
        return '#6C757D';
    }
  }

  // Validate expiry date
  bool isValidExpiryDate(String month, String year) {
    if (month.isEmpty || year.isEmpty) return false;

    try {
      final expiryMonth = int.parse(month);
      final expiryYear = int.parse(year.length == 2 ? '20$year' : year);

      if (expiryMonth < 1 || expiryMonth > 12) return false;

      final now = DateTime.now();
      final expiryPlusOneMonth = DateTime(expiryYear, expiryMonth + 1);

      return expiryPlusOneMonth.isAfter(now);
    } catch (e) {
      return false;
    }
  }

  // Validate CVV
  bool isValidCVV(String cvv, String cardNumber) {
    if (cvv.isEmpty) return false;

    final cleanCard = cardNumber.replaceAll(RegExp(r'[\s\-]'), '');
    final expectedLength = cleanCard.startsWith('3') ? 4 : 3; // Amex has 4 digits

    return cvv.length == expectedLength && RegExp(r'^[0-9]+$').hasMatch(cvv);
  }

  // Check if card is expiring soon (within 3 months)
  bool isCardExpiringSoon(String expiryMonth, String expiryYear) {
    try {
      final month = int.parse(expiryMonth);
      final year = int.parse(expiryYear.length == 2 ? '20$expiryYear' : expiryYear);
      final expiryDate = DateTime(year, month);
      final threeMonthsFromNow = DateTime.now().add(const Duration(days: 90));

      return expiryDate.isBefore(threeMonthsFromNow) && expiryDate.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  // Get card summary statistics
  Map<String, dynamic> getCardSummary() {
    final activeCount = activeCards.length;
    final expiredCount = expiredCards.length;
    final defaultCardId = defaultCard?.id;

    return {
      'totalCards': _cards.length,
      'activeCards': activeCount,
      'expiredCards': expiredCount,
      'blockedCards': _cards.where((c) => c.status == CardStatus.blocked).length,
      'defaultCardId': defaultCardId,
      'hasDefaultCard': defaultCardId != null,
    };
  }

  // Sort cards by default status first, then by expiry date
  List<Card> get sortedCards {
    final sorted = List<Card>.from(_cards);
    sorted.sort((a, b) {
      // Default cards first
      if (a.isDefault && !b.isDefault) return -1;
      if (!a.isDefault && b.isDefault) return 1;

      // Then by expiry date (expiring cards last)
      final aExpiry = a.expiresAt ?? DateTime(2099);
      final bExpiry = b.expiresAt ?? DateTime(2099);

      return aExpiry.compareTo(bExpiry);
    });

    return sorted;
  }

  // Refresh cards
  Future<void> refreshCards(String userId) async {
    await loadCards(userId);
  }

  // Clear all cards (for testing)
  void clearCards() {
    _cards.clear();
    notifyListeners();
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

  // Luhn algorithm for card validation
  bool _isValidLuhn(String cardNumber) {
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

  }