class UserEntity {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.lastLoginAt,
    required this.createdAt,
  });
}
