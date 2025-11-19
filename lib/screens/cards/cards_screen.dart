import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/card_provider.dart';
import '../../models/card.dart' as card_model;
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
    _loadCards();
  }

  void _loadCards() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      await context.read<CardProvider>().loadCards(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cards'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => context.go(AppRoutes.addCard),
          ),
        ],
      ),
      body: Consumer<CardProvider>(
        builder: (context, cardProvider, child) {
          if (cardProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final cards = cardProvider.sortedCards;

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
            onRefresh: _refreshCards,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return _buildCardItem(cards[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardItem(card_model.Card card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Card Design
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getCardColor(card.brand),
                  _getCardColor(card.brand).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _getCardColor(card.brand).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Card Pattern
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(80),
                      ),
                    ),
                  ),
                ),

                // Card Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            card.brand.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (card.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'DEFAULT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '•••• •••• •••• ${card.lastFourDigits}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Card Holder',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                card.cardholderName.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Expires',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${card.expiryMonth}/${card.expiryYear.substring(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
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
          ),

          // Card Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (!card.isDefault)
                      TextButton(
                        onPressed: () => _setDefaultCard(card),
                        child: const Text('Set Default'),
                      ),
                    if (card.isActive)
                      TextButton(
                        onPressed: () => _blockCard(card),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange,
                        ),
                        child: const Text('Block'),
                      )
                    else
                      TextButton(
                        onPressed: () => _unblockCard(card),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                        child: const Text('Unblock'),
                      ),
                  ],
                ),
                TextButton(
                  onPressed: () => _deleteCard(card),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Delete'),
                ),
              ],
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

  Future<void> _refreshCards() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      await context.read<CardProvider>().refreshCards(authProvider.user!.id);
    }
  }

  void _setDefaultCard(card_model.Card card) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      await context.read<CardProvider>().setDefaultCard(authProvider.user!.id, card.id);
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

  void _deleteCard(card_model.Card card) async {
    final confirmed = await _showConfirmationDialog(
      'Delete Card',
      'Are you sure you want to delete this card? This action cannot be undone.',
    );

    if (confirmed && mounted) {
      await context.read<CardProvider>().deleteCard(card.id);
    }
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