import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/card_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../config/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Logo and Title
              _buildHeader()
                  .animate()
                  .slideY(duration: 600.ms, curve: Curves.easeOut)
                  .fadeIn(duration: 800.ms),

              const SizedBox(height: 40),

              // Login Form
              _buildLoginForm()
                  .animate()
                  .slideY(duration: 800.ms, delay: 200.ms, curve: Curves.easeOut)
                  .fadeIn(duration: 1000.ms, delay: 200.ms),

              const SizedBox(height: 30),

              // Login Button
              _buildLoginButton()
                  .animate()
                  .slideY(duration: 1000.ms, delay: 400.ms, curve: Curves.easeOut)
                  .fadeIn(duration: 1200.ms, delay: 400.ms),

              const SizedBox(height: 24),

              // Demo Accounts
              _buildDemoAccounts()
                  .animate()
                  .slideY(duration: 1200.ms, delay: 600.ms, curve: Curves.easeOut)
                  .fadeIn(duration: 1400.ms, delay: 600.ms),

              const SizedBox(height: 40),

              // Register Link
              _buildRegisterLink()
                  .animate()
                  .slideY(duration: 1400.ms, delay: 800.ms, curve: Curves.easeOut)
                  .fadeIn(duration: 1600.ms, delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'International Money Transfers',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: Validators.validateEmail,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: Validators.validatePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
          ),
          const SizedBox(height: 16),

          // Remember Me & Forgot Password
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              Text(
                'Remember me',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: _handleForgotPassword,
                child: Text(
                  'Forgot Password?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return ElevatedButton(
          onPressed: authProvider.isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: authProvider.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        );
      },
    );
  }

  Widget _buildDemoAccounts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Demo Accounts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 12),
          _buildDemoAccountOption(
            email: 'usuario@test.com',
            password: '123456',
            name: 'Juan Pérez',
            balance: '\$5,250.00',
          ),
          const SizedBox(height: 8),
          _buildDemoAccountOption(
            email: 'demo@wallet.com',
            password: 'demo123',
            name: 'María García',
            balance: '\$12,430.50',
          ),
        ],
      ),
    );
  }

  Widget _buildDemoAccountOption({
    required String email,
    required String password,
    required String name,
    required String balance,
  }) {
    return InkWell(
      onTap: () {
        _emailController.text = email;
        _passwordController.text = password;
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              child: Text(
                name.substring(0, 1),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
            Text(
              balance,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        GestureDetector(
          onTap: () => context.go(AppRoutes.register),
          child: Text(
            'Sign Up',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success) {
        if (mounted) {
          // Load user data after successful login
          final user = authProvider.user!;

          // Load transactions for the user
          context.read<TransactionProvider>().loadTransactions(user.id);

          // Load cards for the user
          context.read<CardProvider>().loadCards(user.id);

          // Navigate to home
          context.go(AppRoutes.home);
        }
      } else {
        if (mounted) {
          _showErrorSnackBar(authProvider.errorMessage ?? 'Login failed');
        }
      }
    }
  }

  void _handleForgotPassword() {
    _showResetPasswordDialog();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showResetPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email address and we\'ll send you a link to reset your password.'),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: Validators.validateEmail,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return ElevatedButton(
                onPressed: authProvider.isLoading ? null : () async {
                  if (emailController.text.isNotEmpty) {
                    // Store the contexts before async operation
                    final mainContext = context;
                    final dialogContextLocal = dialogContext;

                    // Show loading indicator
                    final success = await authProvider.resetPassword(emailController.text);

                    if (success) {
                      // Close dialog first
                      if (mounted) {
                        Navigator.of(dialogContextLocal).pop();
                      }

                      // Show snackbar immediately after dialog closes
                      if (mounted) {
                        ScaffoldMessenger.of(mainContext).showSnackBar(
                          const SnackBar(
                            content: Text('Password reset email sent!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  }
                },
                child: authProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send'),
              );
            },
          ),
        ],
      ),
    );
  }
}