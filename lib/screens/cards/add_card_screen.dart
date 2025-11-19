import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/card_provider.dart';
import '../../models/card.dart';
import '../../utils/validators.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardholderNameController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvvController = TextEditingController();

  String _selectedCardType = 'visa';
  bool _setAsDefault = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardholderNameController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Card'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card Type Selection
              _buildCardTypeSelection(),
              const SizedBox(height: 24),

              // Card Form
              _buildCardForm(),
              const SizedBox(height: 24),

              // Default Card Checkbox
              _buildDefaultCardCheckbox(),
              const SizedBox(height: 24),

              // Add Button
              _buildAddButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCardTypeOption(
                'Visa',
                'visa',
                'assets/icons/visa.svg',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCardTypeOption(
                'Mastercard',
                'mastercard',
                'assets/icons/mastercard.svg',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardTypeOption(String name, String value, String iconPath) {
    final isSelected = _selectedCardType == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCardType = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                  : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.credit_card,
                color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),

        // Card Number
        TextFormField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Card Number',
            hintText: '1234 5678 9012 3456',
            prefixIcon: Icon(Icons.credit_card),
          ),
          validator: Validators.validateCardNumber,
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            final formatted = Validators.formatCardNumber(value);
            _cardNumberController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          },
        ),
        const SizedBox(height: 16),

        // Cardholder Name
        TextFormField(
          controller: _cardholderNameController,
          decoration: const InputDecoration(
            labelText: 'Cardholder Name',
            hintText: 'John Doe',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) => Validators.validateName(value, fieldName: 'Cardholder name'),
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),

        // Expiry Date and CVV
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryMonthController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'MM',
                  hintText: '12',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (value.length != 2 || int.tryParse(value) == null || int.parse(value) < 1 || int.parse(value) > 12) {
                    return 'Invalid';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                maxLength: 2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _expiryYearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'YY',
                  hintText: '25',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (value.length != 2 || int.tryParse(value) == null) {
                    return 'Invalid';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                maxLength: 2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (value.length != 3 || int.tryParse(value) == null) {
                    return 'Invalid';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                maxLength: 4,
                obscureText: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDefaultCardCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _setAsDefault,
          onChanged: (value) {
            setState(() {
              _setAsDefault = value ?? false;
            });
          },
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        Text(
          'Set as default card',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, child) {
        return ElevatedButton(
          onPressed: cardProvider.isLoading ? null : _handleAddCard,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: cardProvider.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Add Card',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        );
      },
    );
  }

  void _handleAddCard() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final cardProvider = context.read<CardProvider>();

      // Validate expiry date
      final month = _expiryMonthController.text;
      final year = '20${_expiryYearController.text}'; // Convert YY to YYYY

      if (!Validators.isValidExpiryDate(month, year)) {
        _showErrorSnackBar('Invalid expiry date');
        return;
      }

      // Determine card type
      CardType cardType;
      switch (_selectedCardType.toLowerCase()) {
        case 'visa':
          cardType = CardType.visa;
          break;
        case 'mastercard':
          cardType = CardType.mastercard;
          break;
        default:
          cardType = CardType.credit;
      }

      final card = await cardProvider.addCard(
        userId: authProvider.user!.id,
        type: cardType,
        cardNumber: _cardNumberController.text.replaceAll(RegExp(r'[\s]'), ''),
        cardholderName: _cardholderNameController.text.trim(),
        expiryMonth: month,
        expiryYear: year.substring(2), // Store only YY
      );

      if (card != null) {
        // Clear form
        _cardNumberController.clear();
        _cardholderNameController.clear();
        _expiryMonthController.clear();
        _expiryYearController.clear();
        _cvvController.clear();

        _showSuccessSnackBar('Card added successfully!');
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        _showErrorSnackBar(cardProvider.errorMessage ?? 'Failed to add card');
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