import 'dart:math';
import '../models/user.dart';
import '../models/transaction.dart';
import '../models/card.dart';
import '../models/contact.dart';
import '../utils/constants.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  final Random _random = Random();

  // Mock Data Storage
  List<User> _users = [];
  List<Transaction> _transactions = [];
  List<Card> _cards = [];
  List<Contact> _contacts = [];
  User? _currentUser;

  // Initialize mock data
  void initializeMockData() {
    _generateMockUsers();
    _generateMockTransactions();
    _generateMockCards();
    _generateMockContacts();
  }

  // Getters
  User? get currentUser => _currentUser;
  List<User> get users => List.unmodifiable(_users);
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<Card> get cards => List.unmodifiable(_cards);
  List<Contact> get contacts => List.unmodifiable(_contacts);

  // Set current user
  void setCurrentUser(User user) {
    _currentUser = user;
  }

  // Authentication Methods
  Future<User?> login(String email, String password) async {
    await _simulateNetworkDelay();

    try {
      final user = _users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase() && u.password == password,
      );

      setCurrentUser(user);
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<User?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    await _simulateNetworkDelay();

    final existingUser = _users.where((u) => u.email.toLowerCase() == email.toLowerCase());
    if (existingUser.isNotEmpty) {
      return null; // User already exists
    }

    final newUser = User(
      id: _generateId(),
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      fullName: '$firstName $lastName',
      balance: 1000.00 + _random.nextDouble() * 9000.00, // Random balance between $1000-$10000
      phoneNumber: phoneNumber,
      createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(365))),
    );

    _users.add(newUser);
    setCurrentUser(newUser);

    // Generate some initial transactions for the new user
    _generateInitialTransactions(newUser.id);

    return newUser;
  }

  Future<void> logout() async {
    await _simulateNetworkDelay();
    _currentUser = null;
  }

  // Transaction Methods
  Future<List<Transaction>> getUserTransactions(String userId) async {
    await _simulateNetworkDelay();
    return _transactions.where((t) => t.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<Transaction?> createTransaction({
    required String userId,
    required TransactionType type,
    required double amount,
    required String recipientName,
    required String recipientEmail,
    String? recipientPhone,
    String? description,
  }) async {
    await _simulateNetworkDelay();

    final fee = _calculateTransactionFee(amount);
    final total = type == TransactionType.send ? amount + fee : amount;

    final transaction = Transaction(
      id: _generateId(),
      userId: userId,
      type: type,
      status: TransactionStatus.pending,
      amount: amount,
      fee: fee,
      total: total,
      recipientName: recipientName,
      recipientEmail: recipientEmail,
      recipientPhone: recipientPhone,
      description: description,
      createdAt: DateTime.now(),
      referenceNumber: 'TXN${_generateTransactionReference()}',
    );

    _transactions.add(transaction);

    // Simulate transaction processing
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));

    // Update transaction status
    final updatedTransaction = transaction.copyWith(
      status: _random.nextDouble() > 0.05 ? TransactionStatus.completed : TransactionStatus.failed,
      completedAt: DateTime.now(),
    );

    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = updatedTransaction;
    }

    // Update user balance if transaction is completed
    if (updatedTransaction.isCompleted && _currentUser != null) {
      final userIndex = _users.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        final currentUser = _users[userIndex];
        double newBalance = currentUser.balance;

        if (type == TransactionType.send) {
          newBalance -= total;
        } else if (type == TransactionType.receive) {
          newBalance += amount;
        }

        _users[userIndex] = currentUser.copyWith(balance: newBalance);
        if (_currentUser?.id == userId) {
          _currentUser = _users[userIndex];
        }
      }
    }

    return updatedTransaction;
  }

  // Card Methods
  Future<List<Card>> getUserCards(String userId) async {
    await _simulateNetworkDelay();
    return _cards.where((c) => c.userId == userId).toList();
  }

  Future<Card?> addCard({
    required String userId,
    required CardType type,
    required String cardNumber,
    required String cardholderName,
    required String expiryMonth,
    required String expiryYear,
  }) async {
    await _simulateNetworkDelay();

    final brand = _detectCardBrand(cardNumber);
    final lastFourDigits = cardNumber.substring(cardNumber.length - 4);

    final newCard = Card(
      id: _generateId(),
      userId: userId,
      type: type,
      status: CardStatus.active,
      lastFourDigits: lastFourDigits,
      cardholderName: cardholderName,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      brand: brand,
      bankName: _getRandomBankName(),
      isDefault: _cards.where((c) => c.userId == userId).isEmpty,
      createdAt: DateTime.now(),
      expiresAt: DateTime(int.parse(expiryYear), int.parse(expiryMonth)),
    );

    _cards.add(newCard);
    return newCard;
  }

  Future<bool> deleteCard(String cardId) async {
    await _simulateNetworkDelay();

    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      _cards.removeAt(index);
      return true;
    }

    return false;
  }

  Future<bool> setDefaultCard(String userId, String cardId) async {
    await _simulateNetworkDelay();

    // Remove default flag from all user cards
    for (int i = 0; i < _cards.length; i++) {
      if (_cards[i].userId == userId) {
        _cards[i] = _cards[i].copyWith(isDefault: false);
      }
    }

    // Set new default card
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      _cards[index] = _cards[index].copyWith(isDefault: true);
      return true;
    }

    return false;
  }

  // Contact Methods
  Future<List<Contact>> getUserContacts(String userId) async {
    await _simulateNetworkDelay();
    return _contacts.where((c) => c.id == userId).toList();
  }

  Future<Contact?> addContact(Contact contact) async {
    await _simulateNetworkDelay();

    final existingContact = _contacts.where((c) => c.email.toLowerCase() == contact.email.toLowerCase());
    if (existingContact.isNotEmpty) {
      return existingContact.first;
    }

    _contacts.add(contact);
    return contact;
  }

  Future<bool> deleteContact(String contactId) async {
    await _simulateNetworkDelay();

    final index = _contacts.indexWhere((c) => c.id == contactId);
    if (index != -1) {
      _contacts.removeAt(index);
      return true;
    }

    return false;
  }

  // Private Helper Methods
  void _generateMockUsers() {
    _users = [
      User(
        id: '1',
        email: 'usuario@test.com',
        password: '123456',
        firstName: 'Juan',
        lastName: 'Pérez',
        fullName: 'Juan Pérez',
        balance: 5250.00,
        phoneNumber: '+1-555-0101',
        createdAt: DateTime.now().subtract(Duration(days: 365)),
      ),
      User(
        id: '2',
        email: 'demo@wallet.com',
        password: 'demo123',
        firstName: 'María',
        lastName: 'García',
        fullName: 'María García',
        balance: 12430.50,
        phoneNumber: '+1-555-0102',
        createdAt: DateTime.now().subtract(Duration(days: 180)),
      ),
      User(
        id: '3',
        email: 'test@example.com',
        password: 'test123',
        firstName: 'Carlos',
        lastName: 'Rodríguez',
        fullName: 'Carlos Rodríguez',
        balance: 8750.25,
        phoneNumber: '+1-555-0103',
        createdAt: DateTime.now().subtract(Duration(days: 90)),
      ),
      User(
        id: '4',
        email: 'ana@finanzas.com',
        password: 'ana123',
        firstName: 'Ana',
        lastName: 'Martínez',
        fullName: 'Ana Martínez',
        balance: 15675.80,
        phoneNumber: '+1-555-0104',
        createdAt: DateTime.now().subtract(Duration(days: 270)),
      ),
      User(
        id: '5',
        email: 'luis@digital.com',
        password: 'luis123',
        firstName: 'Luis',
        lastName: 'Sánchez',
        fullName: 'Luis Sánchez',
        balance: 9320.15,
        phoneNumber: '+1-555-0105',
        createdAt: DateTime.now().subtract(Duration(days: 120)),
      ),
    ];
  }

  void _generateMockTransactions() {
    final transactionTypes = [TransactionType.send, TransactionType.receive];
    final statuses = [TransactionStatus.completed, TransactionStatus.pending, TransactionStatus.failed];
    final recipients = [
      {'name': 'María García', 'email': 'demo@wallet.com'},
      {'name': 'Carlos Rodríguez', 'email': 'test@example.com'},
      {'name': 'Ana Martínez', 'email': 'ana@finanzas.com'},
      {'name': 'Luis Sánchez', 'email': 'luis@digital.com'},
      {'name': 'Pedro López', 'email': 'pedro@example.com'},
      {'name': 'Laura Díaz', 'email': 'laura@digital.com'},
      {'name': 'Roberto Silva', 'email': 'roberto@tech.com'},
      {'name': 'Sofia Ramírez', 'email': 'sofia@digital.com'},
    ];

    _transactions = [];

    for (int i = 0; i < 25; i++) {
      final userId = ['1', '2', '3', '4', '5'][_random.nextInt(5)];
      final type = transactionTypes[_random.nextInt(transactionTypes.length)];
      final status = statuses[_random.nextInt(statuses.length)];
      final recipient = recipients[_random.nextInt(recipients.length)];
      final amount = _random.nextDouble() * 2000 + 50;
      final fee = _calculateTransactionFee(amount);

      final transaction = Transaction(
        id: 'TXN${1000 + i}',
        userId: userId,
        type: type,
        status: status,
        amount: amount,
        fee: fee,
        total: type == TransactionType.send ? amount + fee : amount,
        recipientName: recipient['name']!,
        recipientEmail: recipient['email']!,
        recipientPhone: '+1-555-${_random.nextInt(9000) + 1000}',
        description: _getRandomDescription(),
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(30), hours: _random.nextInt(24))),
        completedAt: status == TransactionStatus.completed
          ? DateTime.now().subtract(Duration(days: _random.nextInt(30), hours: _random.nextInt(24)))
          : null,
        referenceNumber: 'TXN${_generateTransactionReference()}',
        metadata: {'source': 'mobile_app', 'version': '1.0.0'},
      );

      _transactions.add(transaction);
    }

    _transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _generateMockCards() {
    final cardTypes = [CardType.visa, CardType.mastercard];
    final banks = ['Bank of America', 'Chase', 'Wells Fargo', 'Citibank', 'Capital One'];

    _cards = [];

    for (final userId in ['1', '2', '3', '4', '5']) {
      final numCards = _random.nextInt(3) + 1; // 1-3 cards per user

      for (int i = 0; i < numCards; i++) {
        final cardType = cardTypes[_random.nextInt(cardTypes.length)];
        final bankName = banks[_random.nextInt(banks.length)];
        final isDefault = i == 0;

        final card = Card(
          id: 'CARD${userId}_${i + 1}',
          userId: userId,
          type: cardType,
          status: CardStatus.active,
          lastFourDigits: _generateCardNumber().substring(12),
          cardholderName: _getUserFullName(userId),
          expiryMonth: (_random.nextInt(12) + 1).toString().padLeft(2, '0'),
          expiryYear: (_random.nextInt(5) + 2025).toString(),
          brand: cardType == CardType.visa ? 'Visa' : 'Mastercard',
          bankName: bankName,
          isDefault: isDefault,
          creditLimit: cardType == CardType.credit ? _random.nextDouble() * 10000 + 1000 : null,
          availableCredit: cardType == CardType.credit ? _random.nextDouble() * 8000 + 500 : null,
          createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(365))),
          expiresAt: DateTime((_random.nextInt(5) + 2025), _random.nextInt(12) + 1),
        );

        _cards.add(card);
      }
    }
  }

  void _generateMockContacts() {
    final contactsData = [
      {'name': 'Pedro López', 'email': 'pedro@example.com', 'phone': '+1-555-0201'},
      {'name': 'Laura Díaz', 'email': 'laura@digital.com', 'phone': '+1-555-0202'},
      {'name': 'Roberto Silva', 'email': 'roberto@tech.com', 'phone': '+1-555-0203'},
      {'name': 'Sofia Ramírez', 'email': 'sofia@digital.com', 'phone': '+1-555-0204'},
      {'name': 'Miguel Ángel', 'email': 'miguel@creative.com', 'phone': '+1-555-0205'},
      {'name': 'Carmen Torres', 'email': 'carmen@business.com', 'phone': '+1-555-0206'},
      {'name': 'Diego Herrera', 'email': 'diego@startup.com', 'phone': '+1-555-0207'},
      {'name': 'Patricia Morales', 'email': 'patricia@design.com', 'phone': '+1-555-0208'},
    ];

    _contacts = contactsData.asMap().entries.map((entry) {
      final index = entry.key;
      final contact = entry.value;

      return Contact(
        id: 'CONTACT${index + 1}',
        name: contact['name']!,
        email: contact['email']!,
        phoneNumber: contact['phone'],
        isFavorite: _random.nextBool(),
        lastContactDate: DateTime.now().subtract(Duration(days: _random.nextInt(60))),
        transactionCount: _random.nextInt(50),
        totalTransacted: _random.nextDouble() * 5000 + 500,
      );
    }).toList();
  }

  void _generateInitialTransactions(String userId) {
    for (int i = 0; i < 5; i++) {
      final amount = _random.nextDouble() * 500 + 100;

      final transaction = Transaction(
        id: 'TXN_INITIAL_${userId}_$i',
        userId: userId,
        type: TransactionType.receive,
        status: TransactionStatus.completed,
        amount: amount,
        fee: 0.0,
        total: amount,
        recipientName: 'Welcome Bonus',
        recipientEmail: 'system@sencash.com',
        description: 'Initial transaction',
        createdAt: DateTime.now().subtract(Duration(days: i + 1)),
        completedAt: DateTime.now().subtract(Duration(days: i + 1)),
        referenceNumber: 'WELCOME${i + 1}',
      );

      _transactions.add(transaction);
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + _random.nextInt(10000).toString();
  }

  String _generateCardNumber() {
    String cardNumber = '';
    for (int i = 0; i < 16; i++) {
      cardNumber += _random.nextInt(10).toString();
    }
    return cardNumber;
  }

  String _generateTransactionReference() {
    return '${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(1000)}';
  }

  double _calculateTransactionFee(double amount) {
    final calculatedFee = amount * AppConstants.transactionFeeRate;
    return calculatedFee < AppConstants.minTransactionFee
      ? AppConstants.minTransactionFee
      : calculatedFee;
  }

  String _detectCardBrand(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'Visa';
    if (cardNumber.startsWith('5')) return 'Mastercard';
    if (cardNumber.startsWith('3')) return 'American Express';
    if (cardNumber.startsWith('6')) return 'Discover';
    return 'Unknown';
  }

  String _getRandomBankName() {
    final banks = ['Bank of America', 'Chase', 'Wells Fargo', 'Citibank', 'Capital One', 'US Bank', 'PNC Bank'];
    return banks[_random.nextInt(banks.length)];
  }

  String _getUserFullName(String userId) {
    final user = _users.where((u) => u.id == userId).firstOrNull;
    return user?.fullName ?? 'Unknown User';
  }

  String _getRandomDescription() {
    final descriptions = [
      'Monthly payment',
      'Gift for birthday',
      'Dinner with friends',
      'Emergency fund',
      'Vacation expenses',
      'Shopping',
      'Medical bills',
      'Education',
      'Investment',
      'Family support',
      'Business expenses',
      'Home renovation',
      'Car repair',
      'Insurance payment',
      'Utilities',
    ];
    return descriptions[_random.nextInt(descriptions.length)];
  }

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: AppConstants.networkDelay));
  }

  // Search and Filter Methods
  Future<List<Transaction>> searchTransactions(String userId, String query) async {
    await _simulateNetworkDelay();

    final userTransactions = _transactions.where((t) => t.userId == userId);
    final lowerQuery = query.toLowerCase();

    return userTransactions.where((t) {
      return t.recipientName.toLowerCase().contains(lowerQuery) ||
          t.recipientEmail.toLowerCase().contains(lowerQuery) ||
          (t.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          (t.referenceNumber?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  Future<List<Transaction>> filterTransactionsByDate(
    String userId,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    await _simulateNetworkDelay();

    final userTransactions = _transactions.where((t) => t.userId == userId);

    return userTransactions.where((t) {
      if (startDate != null && t.createdAt.isBefore(startDate)) return false;
      if (endDate != null && t.createdAt.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  Future<List<Transaction>> filterTransactionsByStatus(
    String userId,
    TransactionStatus status,
  ) async {
    await _simulateNetworkDelay();

    return _transactions
        .where((t) => t.userId == userId && t.status == status)
        .toList();
  }

  // Statistics Methods
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    await _simulateNetworkDelay();

    final userTransactions = _transactions.where((t) => t.userId == userId);
    final completedTransactions = userTransactions.where((t) => t.isCompleted);

    final totalSent = completedTransactions
        .where((t) => t.isSent)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalReceived = completedTransactions
        .where((t) => t.isReceived)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalFees = userTransactions
        .where((t) => t.isSent)
        .fold(0.0, (sum, t) => sum + t.fee);

    return {
      'totalTransactions': completedTransactions.length,
      'totalSent': totalSent,
      'totalReceived': totalReceived,
      'totalFees': totalFees,
      'netBalance': totalReceived - totalSent - totalFees,
    };
  }
}