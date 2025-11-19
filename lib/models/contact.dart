class Contact {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final bool isFavorite;
  final DateTime lastContactDate;
  final int transactionCount;
  final double totalTransacted;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.isFavorite = false,
    required this.lastContactDate,
    this.transactionCount = 0,
    this.totalTransacted = 0.0,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      avatarUrl: json['avatarUrl'],
      isFavorite: json['isFavorite'] ?? false,
      lastContactDate: DateTime.parse(json['lastContactDate']),
      transactionCount: json['transactionCount'] ?? 0,
      totalTransacted: json['totalTransacted']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'isFavorite': isFavorite,
      'lastContactDate': lastContactDate.toIso8601String(),
      'transactionCount': transactionCount,
      'totalTransacted': totalTransacted,
    };
  }

  Contact copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    bool? isFavorite,
    DateTime? lastContactDate,
    int? transactionCount,
    double? totalTransacted,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      lastContactDate: lastContactDate ?? this.lastContactDate,
      transactionCount: transactionCount ?? this.transactionCount,
      totalTransacted: totalTransacted ?? this.totalTransacted,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    } else {
      return '?';
    }
  }

  String get formattedTotalTransacted {
    return '\$${totalTransacted.toStringAsFixed(2)}';
  }

  String get phoneNumberDisplay {
    if (phoneNumber == null || phoneNumber!.isEmpty) {
      return 'No phone';
    }

    final phone = phoneNumber!;
    if (phone.length == 10) {
      return '(${phone.substring(0, 3)}) ${phone.substring(3, 6)}-${phone.substring(6)}';
    } else if (phone.length > 10 && phone.startsWith('+1')) {
      final usPhone = phone.substring(2);
      return '+1 (${usPhone.substring(0, 3)}) ${usPhone.substring(3, 6)}-${usPhone.substring(6)}';
    }

    return phone;
  }

  @override
  String toString() {
    return 'Contact(name: $name, email: $email, transactionCount: $transactionCount)';
  }
}