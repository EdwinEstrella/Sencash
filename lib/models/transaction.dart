enum TransactionType {
  send,
  receive,
  transfer,
  deposit,
  withdrawal,
}

enum TransactionStatus {
  completed,
  pending,
  failed,
  cancelled,
}

class Transaction {
  final String id;
  final String userId;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final double fee;
  final double total;
  final String recipientName;
  final String recipientEmail;
  final String? recipientPhone;
  final String? description;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? referenceNumber;
  final Map<String, dynamic>? metadata;

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.amount,
    required this.fee,
    required this.total,
    required this.recipientName,
    required this.recipientEmail,
    this.recipientPhone,
    this.description,
    required this.createdAt,
    this.completedAt,
    this.referenceNumber,
    this.metadata,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['userId'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == 'TransactionStatus.${json['status']}',
      ),
      amount: json['amount'].toDouble(),
      fee: json['fee'].toDouble(),
      total: json['total'].toDouble(),
      recipientName: json['recipientName'],
      recipientEmail: json['recipientEmail'],
      recipientPhone: json['recipientPhone'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      referenceNumber: json['referenceNumber'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'amount': amount,
      'fee': fee,
      'total': total,
      'recipientName': recipientName,
      'recipientEmail': recipientEmail,
      'recipientPhone': recipientPhone,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'referenceNumber': referenceNumber,
      'metadata': metadata,
    };
  }

  Transaction copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    TransactionStatus? status,
    double? amount,
    double? fee,
    double? total,
    String? recipientName,
    String? recipientEmail,
    String? recipientPhone,
    String? description,
    DateTime? createdAt,
    DateTime? completedAt,
    String? referenceNumber,
    Map<String, dynamic>? metadata,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      total: total ?? this.total,
      recipientName: recipientName ?? this.recipientName,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isCompleted => status == TransactionStatus.completed;
  bool get isPending => status == TransactionStatus.pending;
  bool get isFailed => status == TransactionStatus.failed;
  bool get isSent => type == TransactionType.send || type == TransactionType.transfer;
  bool get isReceived => type == TransactionType.receive;

  String get formattedAmount {
    final prefix = isSent ? '-' : '+';
    return '$prefix\$${amount.toStringAsFixed(2)}';
  }

  String get formattedTotal {
    final sign = isSent ? '-' : '+';
    return '$sign\$${total.toStringAsFixed(2)}';
  }

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, amount: \$${amount.toStringAsFixed(2)}, status: $status)';
  }
}