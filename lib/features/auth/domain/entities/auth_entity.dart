class AuthEntity {
  final String token;
  final String name;
  final String email;
  final String role;
  final String tenantId;

  const AuthEntity({
    required this.token,
    required this.name,
    required this.email,
    required this.role,
    required this.tenantId,
  });
}
