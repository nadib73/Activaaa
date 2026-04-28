/// ── Model User ───────────────────────────────────────────────────────────────
class UserModel {
  final String id;
  final String name;
  final String email;
  final String gender;
  final int age;
  final String region;
  final String educationLevel;
  final String dailyRole; // <- TAMBAHAN
  final DateTime createdAt;
  final DateTime? lastLogin;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.age,
    required this.region,
    required this.educationLevel,
    required this.dailyRole, // <- TAMBAHAN
    required this.createdAt,
    this.lastLogin,
  });

  // ── From JSON ──────────────────────────────────────────────────────────────
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'User',
      email: json['email']?.toString() ?? '',
      gender: json['gender']?.toString().toLowerCase() ?? 'male',
      age: _parseInt(json['age']),
      region: json['region']?.toString() ?? 'Asia',
      educationLevel: json['education_level']?.toString() ?? 'Bachelor',
      dailyRole: json['daily_role']?.toString() ?? '', // <- TAMBAHAN
      createdAt: _parseDate(json['created_at']),
      lastLogin: json['last_login'] != null
          ? DateTime.tryParse(json['last_login'].toString())
          : null,
    );
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }

  static DateTime _parseDate(dynamic val) {
    if (val == null) return DateTime.now();
    return DateTime.tryParse(val.toString()) ?? DateTime.now();
  }

  // ── To JSON ────────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
    'gender': gender,
    'age': age,
    'region': region,
    'education_level': educationLevel,
    'daily_role': dailyRole, // <- TAMBAHAN
    'created_at': createdAt.toIso8601String(),
  };

  // ── Copy With ──────────────────────────────────────────────────────────────
  UserModel copyWith({
    String? name,
    String? gender,
    int? age,
    String? region,
    String? educationLevel,
    String? dailyRole, // <- TAMBAHAN
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      region: region ?? this.region,
      educationLevel: educationLevel ?? this.educationLevel,
      dailyRole: dailyRole ?? this.dailyRole, // <- TAMBAHAN
      createdAt: createdAt,
      lastLogin: lastLogin,
    );
  }

  /// Inisial nama untuk avatar
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  String toString() =>
      'UserModel(id: $id, name: $name, email: $email, dailyRole: $dailyRole)';
}

/// ── Auth Response (Login) ────────────────────────────────────────────────────
class AuthResponse {
  final bool success;
  final String message;
  final String token;
  final String tokenType;
  final int? expiresIn;
  final UserModel user;

  const AuthResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.tokenType,
    required this.user,
    this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    final token = data['token']?.toString() ?? '';

    final userJson =
        data['user'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return AuthResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      token: token,
      tokenType: data['token_type']?.toString() ?? 'bearer',
      expiresIn: data['expires_in'] as int?,
      user: UserModel.fromJson(userJson), // <- otomatis bawa daily_role
    );
  }
}

/// ── Register Response ────────────────────────────────────────────────────────
class RegisterResponse {
  final bool success;
  final String message;
  final String token;
  final UserModel user;

  const RegisterResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    final userJson =
        data['user'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return RegisterResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      token: data['token']?.toString() ?? '',
      user: UserModel.fromJson(userJson), // <- otomatis bawa daily_role
    );
  }
}
