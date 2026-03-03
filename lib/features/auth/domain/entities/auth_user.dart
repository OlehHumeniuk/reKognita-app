class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.companyId,
  });

  final String id;
  final String email;
  final String name;
  final String role;
  final int companyId;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'].toString(),
      email: json['email'] as String,
      name: json['full_name'] as String,
      role: json['role'] as String,
      companyId: json['company_id'] as int,
    );
  }
}
