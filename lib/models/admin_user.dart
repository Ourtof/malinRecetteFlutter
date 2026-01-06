class AdminUser {
  final int id;
  final String email;
  final String pseudo;
  final List<String> roles;
  final bool enabled;

  const AdminUser({
    required this.id,
    required this.email,
    required this.pseudo,
    required this.roles,
    required this.enabled,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      pseudo: json['pseudo'] as String? ?? '',
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      enabled: json['enabled'] as bool? ?? false,
    );
  }

  AdminUser copyWith({
    int? id,
    String? email,
    String? pseudo,
    List<String>? roles,
    bool? enabled,
  }) {
    return AdminUser(
      id: id ?? this.id,
      email: email ?? this.email,
      pseudo: pseudo ?? this.pseudo,
      roles: roles ?? this.roles,
      enabled: enabled ?? this.enabled,
    );
  }
}

