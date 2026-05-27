import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  const AuthModel({
    required super.token,
    required super.refreshToken, // ← nuevo
    required super.name,
    required super.email,
    required super.role,
    required super.tenantId,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
        token: json['accessToken'] ?? json['token'] ?? '',
        refreshToken: json['refreshToken'] ?? '', // ← nuevo
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? 'Viewer',
        tenantId: json['tenantId'] ?? '',
      );
}
