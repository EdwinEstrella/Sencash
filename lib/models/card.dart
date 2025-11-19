enum CardType {
  visa,
  mastercard,
  amex,
  discover,
  debit,
  credit,
}

enum CardStatus {
  active,
  inactive,
  expired,
  blocked,
}

class Card {
  final String id;
  final String userId;
  final CardType type;
  final CardStatus status;
  final String lastFourDigits;
  final String cardholderName;
  final String expiryMonth;
  final String expiryYear;
  final String brand; // Visa, Mastercard, etc.
  final String bankName;
  final bool isDefault;
  final double? creditLimit;
  final double? availableCredit;
  final DateTime createdAt;
  final DateTime? expiresAt;

  Card({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.lastFourDigits,
    required this.cardholderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.brand,
    required this.bankName,
    this.isDefault = false,
    this.creditLimit,
    this.availableCredit,
    required this.createdAt,
    this.expiresAt,
  });

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      id: json['id'],
      userId: json['userId'],
      type: CardType.values.firstWhere(
        (e) => e.toString() == 'CardType.${json['type']}',
      ),
      status: CardStatus.values.firstWhere(
        (e) => e.toString() == 'CardStatus.${json['status']}',
      ),
      lastFourDigits: json['lastFourDigits'],
      cardholderName: json['cardholderName'],
      expiryMonth: json['expiryMonth'],
      expiryYear: json['expiryYear'],
      brand: json['brand'],
      bankName: json['bankName'],
      isDefault: json['isDefault'] ?? false,
      creditLimit: json['creditLimit']?.toDouble(),
      availableCredit: json['availableCredit']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'lastFourDigits': lastFourDigits,
      'cardholderName': cardholderName,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'brand': brand,
      'bankName': bankName,
      'isDefault': isDefault,
      'creditLimit': creditLimit,
      'availableCredit': availableCredit,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  Card copyWith({
    String? id,
    String? userId,
    CardType? type,
    CardStatus? status,
    String? lastFourDigits,
    String? cardholderName,
    String? expiryMonth,
    String? expiryYear,
    String? brand,
    String? bankName,
    bool? isDefault,
    double? creditLimit,
    double? availableCredit,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return Card(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      cardholderName: cardholderName ?? this.cardholderName,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      brand: brand ?? this.brand,
      bankName: bankName ?? this.bankName,
      isDefault: isDefault ?? this.isDefault,
      creditLimit: creditLimit ?? this.creditLimit,
      availableCredit: availableCredit ?? this.availableCredit,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  String get maskedNumber {
    return '**** **** **** $lastFourDigits';
  }

  String get formattedExpiry {
    return '$expiryMonth/$expiryYear';
  }

  String get displayExpiry {
    final shortYear = expiryYear.substring(2);
    return '$expiryMonth/$shortYear';
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isNearExpiry {
    if (expiresAt == null) return false;
    final expiryDate = expiresAt!;
    final oneMonthFromNow = DateTime.now().add(const Duration(days: 30));
    return expiryDate.isBefore(oneMonthFromNow);
  }

  bool get isActive => status == CardStatus.active && !isExpired;

  String get cardIcon {
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'visa';
      case 'mastercard':
        return 'mastercard';
      case 'amex':
      case 'american express':
        return 'amex';
      case 'discover':
        return 'discover';
      default:
        return 'credit-card';
    }
  }

  @override
  String toString() {
    return 'Card(brand: $brand, lastFour: $lastFourDigits, status: $status, isDefault: $isDefault)';
  }
}