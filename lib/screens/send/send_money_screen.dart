import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction.dart';
import '../../utils/validators.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  double _calculatedFee = 0.0;
  double _totalAmount = 0.0;

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Money'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Balance Card
              _buildBalanceCard(),
              const SizedBox(height: 24),

              // Send Form
              _buildSendForm(),
              const SizedBox(height: 24),

              // Summary Card
              _buildSummaryCard(),
              const SizedBox(height: 24),

              // Send Button
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final balance = authProvider.user?.balance ?? 0.0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Balance',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                  ),
                  Text(
                    '\$${balance.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSendForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Send Money',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),

        // Recipient Field
        TextFormField(
          controller: _recipientController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Recipient Email',
            hintText: 'Enter recipient email address',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: Validators.validateEmail,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),

        // Amount Field
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
            hintText: 'Enter amount to send',
            prefixIcon: Icon(Icons.attach_money),
            prefixText: '\$ ',
          ),
          validator: Validators.validateAmount,
          onChanged: _calculateFees,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),

        // Description Field
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description (Optional)',
            hintText: 'Add a note for the recipient',
            prefixIcon: Icon(Icons.description_outlined),
          ),
          validator: Validators.validateDescription,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleSendMoney(),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Amount', '\$${_amountController.text.isEmpty ? "0.00" : _amountController.text}'),
          _buildSummaryRow('Transaction Fee', '\$${_calculatedFee.toStringAsFixed(2)}'),
          const Divider(height: 24),
          _buildSummaryRow(
            'Total Amount',
            '\$${_totalAmount.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                  color: isTotal ? Theme.of(context).colorScheme.primary : null,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Consumer<TransactionProvider>(
          builder: (context, transactionProvider, child) {
            return ElevatedButton(
              onPressed: (authProvider.isLoading || transactionProvider.isLoading)
                ? null
                : _handleSendMoney,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: (authProvider.isLoading || transactionProvider.isLoading)
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Send Money',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            );
          },
        );
      },
    );
  }

  void _calculateFees(String value) {
    if (value.isEmpty) {
      setState(() {
        _calculatedFee = 0.0;
        _totalAmount = 0.0;
      });
      return;
    }

    try {
      final amount = double.parse(value);
      final transactionProvider = context.read<TransactionProvider>();
      final fee = transactionProvider.calculateTransactionFee(amount);

      setState(() {
        _calculatedFee = fee;
        _totalAmount = amount + fee;
      });
    } catch (e) {
      setState(() {
        _calculatedFee = 0.0;
        _totalAmount = 0.0;
      });
    }
  }

  void _handleSendMoney() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final transactionProvider = context.read<TransactionProvider>();

      final amount = double.parse(_amountController.text);

      // Check if user has sufficient balance
      if (!transactionProvider.canMakeTransaction(amount, authProvider.user!.balance)) {
        _showErrorSnackBar('Insufficient balance for this transaction');
        return;
      }

      // Create transaction
      final transaction = await transactionProvider.createTransaction(
        userId: authProvider.user!.id,
        type: TransactionType.send,
        amount: amount,
        recipientName: _recipientController.text.split('@')[0],
        recipientEmail: _recipientController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      );

      if (transaction != null) {
        // Clear form
        _recipientController.clear();
        _amountController.clear();
        _descriptionController.clear();

        setState(() {
          _calculatedFee = 0.0;
          _totalAmount = 0.0;
        });

        _showSuccessSnackBar('Money sent successfully!');
      } else {
        _showErrorSnackBar(transactionProvider.errorMessage ?? 'Transaction failed');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
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
}