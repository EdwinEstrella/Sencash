import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/mock_data_service.dart';

class TransactionProvider extends ChangeNotifier {
  final MockDataService _mockDataService = MockDataService();

  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  TransactionStatus? _statusFilter;
  DateTime? _startDate;
  DateTime? _endDate;

  // Getters
  List<Transaction> get transactions => _filteredTransactions.isEmpty
      ? _transactions
      : _filteredTransactions;
  List<Transaction> get allTransactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  TransactionStatus? get statusFilter => _statusFilter;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  // Statistics getters
  double get totalSent => _transactions
      .where((t) => t.isCompleted && t.isSent)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalReceived => _transactions
      .where((t) => t.isCompleted && t.isReceived)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalFees => _transactions
      .where((t) => t.isCompleted && t.isSent)
      .fold(0.0, (sum, t) => sum + t.fee);

  int get totalTransactions => _transactions.where((t) => t.isCompleted).length;
  int get pendingTransactions => _transactions.where((t) => t.isPending).length;
  int get failedTransactions => _transactions.where((t) => t.isFailed).length;

  // Load user transactions
  Future<void> loadTransactions(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      final transactions = await _mockDataService.getUserTransactions(userId);
      _transactions = transactions;
      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load transactions');
      _setLoading(false);
    }
  }

  // Create new transaction
  Future<Transaction?> createTransaction({
    required String userId,
    required TransactionType type,
    required double amount,
    required String recipientName,
    required String recipientEmail,
    String? recipientPhone,
    String? description,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final transaction = await _mockDataService.createTransaction(
        userId: userId,
        type: type,
        amount: amount,
        recipientName: recipientName,
        recipientEmail: recipientEmail,
        recipientPhone: recipientPhone,
        description: description,
      );

      if (transaction != null) {
        _transactions.insert(0, transaction);
        _applyFilters();
        _setLoading(false);
        return transaction;
      } else {
        _setError('Failed to create transaction');
        _setLoading(false);
        return null;
      }
    } catch (e) {
      _setError('Transaction failed: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }

  // Create mass transactions
  Future<List<Transaction>> createMassTransactions({
    required String userId,
    required List<Map<String, dynamic>> recipients,
    double? totalAmount,
  }) async {
    _setLoading(true);
    _clearError();

    final List<Transaction> createdTransactions = [];

    try {
      for (final recipient in recipients) {
        final amount = recipient['amount'] as double;

        final transaction = await _mockDataService.createTransaction(
          userId: userId,
          type: TransactionType.send,
          amount: amount,
          recipientName: recipient['name'] as String,
          recipientEmail: recipient['email'] as String,
          recipientPhone: recipient['phone'] as String?,
          description: recipient['description'] as String?,
        );

        if (transaction != null) {
          createdTransactions.add(transaction);
          _transactions.insert(0, transaction);
        }
      }

      _applyFilters();
      _setLoading(false);
      return createdTransactions;
    } catch (e) {
      _setError('Mass transaction failed: ${e.toString()}');
      _setLoading(false);
      return [];
    }
  }

  // Search transactions
  Future<void> searchTransactions(String query) async {
    _searchQuery = query;
    await _applyFilters();
  }

  // Filter by status
  Future<void> filterByStatus(TransactionStatus? status) async {
    _statusFilter = status;
    await _applyFilters();
  }

  // Filter by date range
  Future<void> filterByDateRange(DateTime? startDate, DateTime? endDate) async {
    _startDate = startDate;
    _endDate = endDate;
    await _applyFilters();
  }

  // Clear all filters
  Future<void> clearFilters() async {
    _searchQuery = '';
    _statusFilter = null;
    _startDate = null;
    _endDate = null;
    await _applyFilters();
  }

  // Apply all active filters
  Future<void> _applyFilters() async {
    List<Transaction> filtered = List.from(_transactions);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final searchResults = await _mockDataService.searchTransactions(
        _transactions.first.userId,
        _searchQuery,
      );
      filtered = searchResults;
    }

    // Apply status filter
    if (_statusFilter != null) {
      filtered = filtered.where((t) => t.status == _statusFilter).toList();
    }

    // Apply date range filter
    if (_startDate != null || _endDate != null) {
      filtered = filtered.where((t) {
        if (_startDate != null && t.createdAt.isBefore(_startDate!)) return false;
        if (_endDate != null && t.createdAt.isAfter(_endDate!)) return false;
        return true;
      }).toList();
    }

    _filteredTransactions = filtered;
    notifyListeners();
  }

  // Get transaction by ID
  Transaction? getTransactionById(String transactionId) {
    try {
      return _transactions.firstWhere((t) => t.id == transactionId);
    } catch (e) {
      return null;
    }
  }

  // Get recent transactions (last 5)
  List<Transaction> get recentTransactions {
    return _transactions.take(5).toList();
  }

  // Get transactions by type
  List<Transaction> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  // Get transactions by status
  List<Transaction> getTransactionsByStatus(TransactionStatus status) {
    return _transactions.where((t) => t.status == status).toList();
  }

  // Get transactions for specific date range
  List<Transaction> getTransactionsForDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) {
      return t.createdAt.isAfter(start.subtract(const Duration(days: 1))) &&
             t.createdAt.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get transactions from last N days
  List<Transaction> getTransactionsFromLastDays(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _transactions.where((t) => t.createdAt.isAfter(cutoffDate)).toList();
  }

  // Calculate transaction statistics
  Map<String, dynamic> calculateStatistics({DateTime? startDate, DateTime? endDate}) {
    List<Transaction> relevantTransactions = _transactions;

    if (startDate != null || endDate != null) {
      relevantTransactions = getTransactionsForDateRange(
        startDate ?? DateTime(2000),
        endDate ?? DateTime.now(),
      );
    }

    final completedTransactions = relevantTransactions.where((t) => t.isCompleted);

    return {
      'totalAmount': completedTransactions.fold(0.0, (sum, t) => sum + t.amount),
      'totalSent': completedTransactions
          .where((t) => t.isSent)
          .fold(0.0, (sum, t) => sum + t.amount),
      'totalReceived': completedTransactions
          .where((t) => t.isReceived)
          .fold(0.0, (sum, t) => sum + t.amount),
      'totalFees': completedTransactions
          .where((t) => t.isSent)
          .fold(0.0, (sum, t) => sum + t.fee),
      'transactionCount': completedTransactions.length,
      'sentCount': completedTransactions.where((t) => t.isSent).length,
      'receivedCount': completedTransactions.where((t) => t.isReceived).length,
      'pendingCount': relevantTransactions.where((t) => t.isPending).length,
      'failedCount': relevantTransactions.where((t) => t.isFailed).length,
    };
  }

  // Get monthly statistics
  Map<String, dynamic> getMonthlyStatistics() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return calculateStatistics(startDate: startOfMonth, endDate: endOfMonth);
  }

  // Get unique recipients
  List<String> get uniqueRecipients {
    final recipients = _transactions
        .where((t) => t.isCompleted)
        .map((t) => t.recipientEmail)
        .toSet()
        .toList();

    recipients.sort();
    return recipients;
  }

  // Get most frequent recipients
  List<Map<String, dynamic>> getMostFrequentRecipients() {
    final Map<String, Map<String, dynamic>> recipientData = {};

    for (final transaction in _transactions.where((t) => t.isCompleted && t.isSent)) {
      final email = transaction.recipientEmail;

      if (!recipientData.containsKey(email)) {
        recipientData[email] = {
          'name': transaction.recipientName,
          'email': email,
          'count': 0,
          'totalAmount': 0.0,
        };
      }

      recipientData[email]!['count']++;
      recipientData[email]!['totalAmount'] += transaction.amount;
    }

    final sortedRecipients = recipientData.values.toList()
      ..sort((a, b) => b['count'].compareTo(a['count']));

    return sortedRecipients.take(5).toList();
  }

  // Refresh transactions
  Future<void> refreshTransactions(String userId) async {
    await loadTransactions(userId);
  }

  // Get estimated fee for transaction
  double calculateTransactionFee(double amount) {
    const feeRate = 0.015; // 1.5%
    const minFee = 0.50;

    final calculatedFee = amount * feeRate;
    return calculatedFee < minFee ? minFee : calculatedFee;
  }

  // Check if user can make transaction
  bool canMakeTransaction(double amount, double userBalance) {
    final fee = calculateTransactionFee(amount);
    final total = amount + fee;
    return userBalance >= total;
  }

  // Get transaction summary for mass send
  Map<String, dynamic> calculateMassSendSummary(List<Map<String, dynamic>> recipients) {
    double totalAmount = 0.0;
    double totalFees = 0.0;
    int recipientCount = recipients.length;

    for (final recipient in recipients) {
      final amount = recipient['amount'] as double;
      totalAmount += amount;
      totalFees += calculateTransactionFee(amount);
    }

    return {
      'recipientCount': recipientCount,
      'totalAmount': totalAmount,
      'totalFees': totalFees,
      'grandTotal': totalAmount + totalFees,
      'averageAmount': recipientCount > 0 ? totalAmount / recipientCount : 0.0,
    };
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

  }