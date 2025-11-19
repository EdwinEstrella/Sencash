class User {
  final String id;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String fullName;
  final double balance;
  final String? avatarUrl;
  final String phoneNumber;
  final DateTime createdAt;
  final bool isEmailVerified;
  final bool isKycVerified;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.balance,
    this.avatarUrl,
    required this.phoneNumber,
    required this.createdAt,
    this.isEmailVerified = true,
    this.isKycVerified = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      fullName: json['fullName'],
      balance: json['balance'].toDouble(),
      avatarUrl: json['avatarUrl'],
      phoneNumber: json['phoneNumber'],
      createdAt: DateTime.parse(json['createdAt']),
      isEmailVerified: json['isEmailVerified'] ?? true,
      isKycVerified: json['isKycVerified'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'balance': balance,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'isKycVerified': isKycVerified,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    String? fullName,
    double? balance,
    String? avatarUrl,
    String? phoneNumber,
    DateTime? createdAt,
    bool? isEmailVerified,
    bool? isKycVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      balance: balance ?? this.balance,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isKycVerified: isKycVerified ?? this.isKycVerified,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, balance: \$${balance.toStringAsFixed(2)})';
  }
}