import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  const AuthModel({
    required super.token,
    required super.name,
    required super.email,
    required super.role,
    required super.tenantId,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
        token: json['token'],
        name: json['name'],
        email: json['email'],
        role: json['role'],
        tenantId: json['tenantId'],
      );
}
