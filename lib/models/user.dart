class User {
  final String id;
  final String pinHash;
  final DateTime createdAt;
  final DateTime lastLogin;

  User({
    required this.id,
    required this.pinHash,
    required this.createdAt,
    required this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pin_hash': pinHash,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      pinHash: map['pin_hash'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastLogin: DateTime.parse(map['last_login'] as String),
    );
  }

  User copyWith({
    String? id,
    String? pinHash,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      pinHash: pinHash ?? this.pinHash,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

