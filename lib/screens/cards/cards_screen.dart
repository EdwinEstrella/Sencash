import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/card_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/card.dart' as card_model;
import '../../models/transaction.dart';
import '../../config/routes.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      await Future.wait([
        context.read<CardProvider>().loadCards(authProvider.user!.id),
        context.read<TransactionProvider>().loadTransactions(authProvider.user!.id),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Consumer2<CardProvider, TransactionProvider>(
        builder: (context, cardProvider, transactionProvider, child) {
          if (cardProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final cards = cardProvider.sortedCards;
          final recentTransactions = transactionProvider.recentTransactions.take(5).toList();

          if (cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.credit_card,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No cards added',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first card to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.addCard),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Card'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Card
                  _buildMainCard(cards.first),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(cards.first),
                  const SizedBox(height: 32),

                  // Recent Activity
                  _buildRecentActivity(recentTransactions),
                  const SizedBox(height: 32),

                  // Other Cards
                  if (cards.length > 1) ...[
                    Text(
                      'Other Cards',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ...cards.skip(1).map((card) => _buildSecondaryCard(card)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Main Card Design - Black with Green Accents
  Widget _buildMainCard(card_model.Card card) {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Black background card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black87,
                  Colors.black,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          // Green accent blur effect (similar to web design)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Card content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section with bank logo and wireless icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.account_balance,
                        color: const Color(0xFF00C853),
                        size: 24,
                      ),
                    ),
                    Icon(
                      Icons.wifi_outlined,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Card number
                Text(
                  '••••  ••••  ••••  ${card.lastFourDigits}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),

                // Bottom section with cardholder and expiry
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CARD HOLDER',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          card.cardholderName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'EXPIRES',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${card.expiryMonth.toString().padLeft(2, '0')}/${card.expiryYear.substring(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Action buttons grid
  Widget _buildActionButtons(card_model.Card card) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildActionButton(
                icon: Icons.lock_outline,
                label: 'Bloquear',
                onTap: () => card.isActive ? _blockCard(card) : _unblockCard(card),
                color: card.isActive ? Colors.orange : Colors.green,
              ),
              _buildActionButton(
                icon: Icons.add_circle_outline,
                label: 'Añadir',
                onTap: () => context.go(AppRoutes.addCard),
                color: const Color(0xFF00C853),
              ),
              _buildActionButton(
                icon: Icons.visibility_outlined,
                label: 'Ver NIP',
                onTap: () => _showPinDialog(card),
                color: Colors.blue,
              ),
              _buildActionButton(
                icon: Icons.settings_outlined,
                label: 'Límites',
                onTap: () => _showLimitsDialog(card),
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: color.withValues(alpha: 0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Recent activity section
  Widget _buildRecentActivity(List<Transaction> transactions) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (transactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'No recent transactions',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ),
            )
          else
            ...transactions.map((transaction) => _buildActivityItem(transaction)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Transaction transaction) {
    final isSent = transaction.type == TransactionType.send;
    final categoryIcon = _getCategoryIcon(transaction.recipientEmail);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: categoryIcon['color'],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              categoryIcon['icon'],
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.recipientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _formatTransactionDate(transaction.createdAt),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isSent ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isSent ? Colors.red : const Color(0xFF00C853),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCategoryIcon(String email) {
    if (email.contains('restaurant') || email.contains('food')) {
      return {'icon': Icons.restaurant, 'color': Colors.orange};
    } else if (email.contains('shop') || email.contains('store')) {
      return {'icon': Icons.shopping_bag, 'color': Colors.blue};
    } else if (email.contains('uber') || email.contains('taxi')) {
      return {'icon': Icons.local_taxi, 'color': Colors.yellow};
    } else if (email.contains('amazon')) {
      return {'icon': Icons.local_shipping, 'color': Colors.orange};
    } else {
      return {'icon': Icons.account_balance_wallet, 'color': const Color(0xFF00C853)};
    }
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Secondary card for additional cards
  Widget _buildSecondaryCard(card_model.Card card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getCardColor(card.brand),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.credit_card,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•••• •••• •••• ${card.lastFourDigits}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${card.cardholderName} • ${card.brand.toUpperCase()}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (card.isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Default',
                style: TextStyle(
                  color: const Color(0xFF00C853),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getCardColor(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'american express':
      case 'amex':
        return const Color(0xFF006FCF);
      case 'discover':
        return const Color(0xFFFF6000);
      default:
        return Colors.grey.shade700;
    }
  }

  Future<void> _refreshData() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      await Future.wait([
        context.read<CardProvider>().refreshCards(authProvider.user!.id),
        context.read<TransactionProvider>().loadTransactions(authProvider.user!.id),
      ]);
    }
  }

  void _blockCard(card_model.Card card) async {
    final confirmed = await _showConfirmationDialog(
      'Block Card',
      'Are you sure you want to block this card? You won\'t be able to use it for transactions.',
    );

    if (confirmed && mounted) {
      await context.read<CardProvider>().blockCard(card.id);
    }
  }

  void _unblockCard(card_model.Card card) async {
    final confirmed = await _showConfirmationDialog(
      'Unblock Card',
      'Are you sure you want to unblock this card?',
    );

    if (confirmed && mounted) {
      await context.read<CardProvider>().unblockCard(card.id);
    }
  }

  void _showPinDialog(card_model.Card card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Card PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, size: 48, color: Color(0xFF00C853)),
            const SizedBox(height: 16),
            Text(
              'Your PIN is ****',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'For security reasons, please check your banking app for the actual PIN.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLimitsDialog(card_model.Card card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Card Limits'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLimitRow('Daily spending', '\$5,000.00'),
            _buildLimitRow('Monthly spending', '\$20,000.00'),
            _buildLimitRow('Single transaction', '\$2,500.00'),
            _buildLimitRow('ATM withdrawal', '\$1,000.00'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00C853),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}