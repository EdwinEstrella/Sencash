import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction.dart';

class TransactionDetailScreen extends StatelessWidget {
  final String transactionId;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          final transaction = transactionProvider.getTransactionById(transactionId);

          if (transaction == null) {
            return const Center(
              child: Text('Transaction not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                _buildStatusCard(context, transaction),
                const SizedBox(height: 24),

                // Amount Card
                _buildAmountCard(context, transaction),
                const SizedBox(height: 24),

                // Details Card
                _buildDetailsCard(context, transaction),
                const SizedBox(height: 24),

                // Actions
                _buildActionButtons(context, transaction),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, Transaction transaction) {
    final isSent = transaction.type == TransactionType.send;
    final statusColor = _getStatusColor(transaction.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            isSent ? Icons.arrow_upward : Icons.arrow_downward,
            size: 48,
            color: statusColor,
          ),
          const SizedBox(height: 12),
          Text(
            _getStatusText(transaction.status),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
          ),
          Text(
            isSent ? 'Money Sent' : 'Money Received',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(BuildContext context, Transaction transaction) {
    final isSent = transaction.type == TransactionType.send;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Amount',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            isSent
              ? '-\$${transaction.amount.toStringAsFixed(2)}'
              : '+\$${transaction.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSent ? Colors.red : Colors.green,
                ),
          ),
          if (isSent) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              'Transaction Fee',
              '-\$${transaction.fee.toStringAsFixed(2)}',
            ),
            const Divider(height: 24),
            _buildDetailRow(
              context,
              'Total Deducted',
              '-\$${transaction.total.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, Transaction transaction) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            context,
            'Reference Number',
            transaction.referenceNumber ?? 'N/A',
          ),
          _buildDetailRow(
            context,
            'Recipient',
            transaction.recipientName,
          ),
          _buildDetailRow(
            context,
            'Email',
            transaction.recipientEmail,
          ),
          if (transaction.recipientPhone != null)
            _buildDetailRow(
              context,
              'Phone',
              transaction.recipientPhone!,
            ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            'Date',
            _formatDateTime(transaction.createdAt),
          ),
          if (transaction.completedAt != null)
            _buildDetailRow(
              context,
              'Completed',
              _formatDateTime(transaction.completedAt!),
            ),
          if (transaction.description != null && transaction.description!.isNotEmpty)
            _buildDetailRow(
              context,
              'Description',
              transaction.description!,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 4),
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

  Widget _buildActionButtons(BuildContext context, Transaction transaction) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              _shareTransaction(context, transaction);
            },
            child: const Text('Share Receipt'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              _downloadReceipt(context, transaction);
            },
            child: const Text('Download Receipt'),
          ),
        ),
      ],
    );
  }

  String _getStatusText(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final date = '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date at $time';
  }

  void _shareTransaction(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Receipt'),
        content: const Text('Share functionality coming soon! You\'ll be able to share your transaction receipt via email, messaging apps, and more.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _downloadReceipt(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Receipt'),
        content: const Text('Download receipt functionality coming soon! You\'ll be able to download your transaction receipt as a PDF file.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}