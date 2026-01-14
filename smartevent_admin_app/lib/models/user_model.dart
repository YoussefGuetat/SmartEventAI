class User {
  final int id;
  final String email;
  final String? name;
  final String role;
  final bool active;

  User({
    required this.id,
    required this.email,
    this.name,
    required this.role,
    required this.active,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['idAuthentification'] as int,
      email: json['email'] as String,
      name: json['nomUtilisateur'],
      role: json['role'] as String,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idAuthentification': id,
      'email': email,
      'nomUtilisateur': name,
      'role': role,
      'active': active,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'motDePasse': password,
    };
  }
}

class LoginResponse {
  final User user;

  LoginResponse({
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: User.fromJson(json),
    );
  }
}