import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/card_provider.dart';
import '../../models/transaction.dart';
import '../../config/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showBalance = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      await Future.wait([
        context.read<TransactionProvider>().loadTransactions(authProvider.user!.id),
        context.read<CardProvider>().loadCards(authProvider.user!.id),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Column(
            children: [
              // Main content area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header with user info and notifications
                      _buildHeader(authProvider),

                      // Balance card
                      _buildBalanceCard(authProvider),

                      // Quick actions grid
                      _buildQuickActions(),

                      // Recent activity section
                      _buildRecentActivity(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // Bottom navigation bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Header with user info and notifications
  Widget _buildHeader(AuthProvider authProvider) {
    final user = authProvider.user;
    final userName = user?.fullName ?? 'Usuario';

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User info section
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getInitials(userName),
                    style: const TextStyle(
                      color: Color(0xFF00C853),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Hola, ${_getFirstName(userName)}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Notifications button
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: () {
                // TODO: Implement notifications
              },
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.black,
                size: 24,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Balance card - black design like the web
  Widget _buildBalanceCard(AuthProvider authProvider) {
    final balance = authProvider.user?.balance ?? 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with balance label and visibility toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saldo Disponible',
                style: TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showBalance = !_showBalance;
                  });
                },
                icon: Icon(
                  _showBalance ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFFCBD5E1),
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Balance amount
          Text(
            _showBalance ? '\$${balance.toStringAsFixed(2)}' : '••••••',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  // Quick actions grid - 4 columns horizontally arranged
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionItem(
              icon: Icons.arrow_upward,
              label: 'Enviar',
              onTap: () => context.go(AppRoutes.sendMoney),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionItem(
              icon: Icons.arrow_downward,
              label: 'Recibir',
              onTap: () => context.go(AppRoutes.sendMoney),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionItem(
              icon: Icons.add,
              label: 'Añadir',
              onTap: () => context.go(AppRoutes.addCard),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionItem(
              icon: Icons.qr_code_scanner,
              label: 'Escanear',
              onTap: () {
                // TODO: Implement QR scanning
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF00C853),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Recent activity section
  Widget _buildRecentActivity() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final recentTransactions = transactionProvider.recentTransactions.take(3).toList();

        return Column(
          children: [
            // Header with "Ver todo" link
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Actividad Reciente',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.transactions),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Ver todo',
                      style: TextStyle(
                        color: Color(0xFF00C853),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Transaction items
            ...recentTransactions.map((transaction) => _buildActivityItem(transaction)),
          ],
        );
      },
    );
  }

  Widget _buildActivityItem(Transaction transaction) {
    final isSent = transaction.type == TransactionType.send;
    final categoryIcon = _getTransactionIcon(transaction);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Transaction icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: categoryIcon is IconData
                ? Icon(
                    categoryIcon,
                    color: const Color(0xFF00C853),
                    size: 30,
                  )
                : Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: categoryIcon['color'],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      categoryIcon['icon'],
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
          ),
          const SizedBox(width: 16),

          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.recipientName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatActivityDate(transaction.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '${isSent ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isSent ? const Color(0xFFEF4444) : const Color(0xFF00C853),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: 'Inicio',
            isSelected: true,
            onTap: () {}, // Already on home
          ),
          _buildNavItem(
            icon: Icons.credit_card,
            label: 'Tarjetas',
            isSelected: false,
            onTap: () => context.go(AppRoutes.cards),
          ),
          _buildNavItem(
            icon: Icons.receipt_long,
            label: 'Actividad',
            isSelected: false,
            onTap: () => context.go(AppRoutes.transactions),
          ),
          _buildNavItem(
            icon: Icons.person,
            label: 'Perfil',
            isSelected: false,
            onTap: () => context.go(AppRoutes.profile),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? const Color(0xFF00C853) : const Color(0xFF64748B),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF00C853) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    } else {
      return '?';
    }
  }

  String _getFirstName(String fullName) {
    final parts = fullName.trim().split(' ');
    return parts.isNotEmpty ? parts[0] : fullName;
  }

  String _formatActivityDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return months[month - 1];
  }

  dynamic _getTransactionIcon(Transaction transaction) {
    final recipient = transaction.recipientEmail.toLowerCase();

    if (transaction.type == TransactionType.receive) {
      return Icons.account_balance_wallet;
    }

    if (recipient.contains('spotify') || recipient.contains('music')) {
      return {'icon': Icons.music_note, 'color': const Color(0xFF1DB954)};
    } else if (recipient.contains('uber') || recipient.contains('taxi')) {
      return {'icon': Icons.local_taxi, 'color': const Color(0xFFFF0000)};
    } else if (recipient.contains('amazon') || recipient.contains('shop')) {
      return {'icon': Icons.shopping_bag, 'color': const Color(0xFFFF9900)};
    } else if (recipient.contains('restaurant') || recipient.contains('food')) {
      return {'icon': Icons.restaurant, 'color': const Color(0xFFE91E63)};
    } else {
      return Icons.arrow_upward;
    }
  }
}