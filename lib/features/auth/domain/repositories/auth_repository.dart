import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<AuthEntity> login(String email, String password);
  Future<AuthEntity> register({
    required String tenantName,
    required String name,
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<String?> getToken();
  Future<AuthEntity?> getSavedUser();
}
