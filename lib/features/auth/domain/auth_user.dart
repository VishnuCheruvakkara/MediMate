class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.token,
  });

  final String id;
  final String email;
  final String name;
  final String? token;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String? ?? '',
        token: json['token'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        if (token != null) 'token': token,
      };
}

