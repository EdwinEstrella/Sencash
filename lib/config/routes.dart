import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/send/send_money_screen.dart';
import '../screens/send/mass_send_screen.dart';
import '../screens/transactions/transactions_screen.dart';
import '../screens/transactions/transaction_detail_screen.dart';
import '../screens/cards/cards_screen.dart';
import '../screens/cards/add_card_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../utils/constants.dart';

class AppRoutes {
  static const String splash = RouteConstants.splash;
  static const String login = RouteConstants.login;
  static const String register = RouteConstants.register;
  static const String home = RouteConstants.home;
  static const String sendMoney = RouteConstants.sendMoney;
  static const String massSend = RouteConstants.massSend;
  static const String transactions = RouteConstants.transactions;
  static const String transactionDetail = RouteConstants.transactionDetail;
  static const String cards = RouteConstants.cards;
  static const String addCard = RouteConstants.addCard;
  static const String profile = RouteConstants.profile;
  static const String settings = RouteConstants.settings;
  static const String notifications = RouteConstants.notifications;
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    routes: [
      // Authentication Routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main App Routes (without ShellRoute - each screen has its own navigation)
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.sendMoney,
        name: 'send-money',
        builder: (context, state) => const SendMoneyScreen(),
      ),
      GoRoute(
        path: AppRoutes.massSend,
        name: 'mass-send',
        builder: (context, state) => const MassSendScreen(),
      ),
      GoRoute(
        path: AppRoutes.transactions,
        name: 'transactions',
        builder: (context, state) => const TransactionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.transactionDetail,
        name: 'transaction-detail',
        builder: (context, state) {
          final transactionId = state.pathParameters['transactionId']!;
          return TransactionDetailScreen(transactionId: transactionId);
        },
      ),
      GoRoute(
        path: AppRoutes.cards,
        name: 'cards',
        builder: (context, state) => const CardsScreen(),
      ),
      GoRoute(
        path: AppRoutes.addCard,
        name: 'add-card',
        builder: (context, state) => const AddCardScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
    redirect: (context, state) {
      // Add authentication redirect logic here
      // For now, we'll allow all routes
      return null;
    },
  );
}

// Error Screen
class ErrorScreen extends StatelessWidget {
  final Exception? error;
  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Oops! Something went wrong.',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'An unexpected error occurred.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Route Extensions for easier navigation
extension RouteExtensions on BuildContext {
  void goToHome() => go(AppRoutes.home);
  void goToLogin() => go(AppRoutes.login);
  void goToRegister() => go(AppRoutes.register);
  void goToSendMoney() => go(AppRoutes.sendMoney);
  void goToMassSend() => go(AppRoutes.massSend);
  void goToTransactions() => go(AppRoutes.transactions);
  void goToTransactionDetail(String transactionId) => go('${AppRoutes.transactionDetail}/$transactionId');
  void goToCards() => go(AppRoutes.cards);
  void goToAddCard() => go(AppRoutes.addCard);
  void goToProfile() => go(AppRoutes.profile);

  void pushToHome() => push(AppRoutes.home);
  void pushToSendMoney() => push(AppRoutes.sendMoney);
  void pushToTransactions() => push(AppRoutes.transactions);
  void pushToCards() => push(AppRoutes.cards);
  void pushToProfile() => push(AppRoutes.profile);
  void pushToAddCard() => push(AppRoutes.addCard);
}