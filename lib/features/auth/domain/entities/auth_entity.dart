class AuthEntity {
  final String token;
  final String refreshToken; // ← nuevo
  final String name;
  final String email;
  final String role;
  final String tenantId;

  const AuthEntity({
    required this.token,
    required this.refreshToken, // ← nuevo
    required this.name,
    required this.email,
    required this.role,
    required this.tenantId,
  });
}
