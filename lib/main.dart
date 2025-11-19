import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/card_provider.dart';
import 'utils/theme.dart';

void main() {
  runApp(const SenCashApp());
}

class SenCashApp extends StatelessWidget {
  const SenCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => CardProvider()),
      ],
      child: MaterialApp.router(
        title: 'SenCash',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme.copyWith(
          textTheme: GoogleFonts.interTextTheme(AppTheme.lightTheme.textTheme),
        ),
        darkTheme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
