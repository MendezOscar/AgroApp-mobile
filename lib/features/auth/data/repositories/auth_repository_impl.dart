import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_model.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/constants/app_constants.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;
  final FlutterSecureStorage _storage;

  AuthRepositoryImpl(this._datasource, this._storage);

  @override
  Future<AuthEntity> login(String email, String password) async {
    final data = await _datasource.login(email, password);
    final model = AuthModel.fromJson(data);
    await _storage.write(key: AppConstants.tokenKey, value: model.token);
    return model;
  }

  @override
  Future<AuthEntity> register({
    required String tenantName,
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await _datasource.register(
      tenantName: tenantName,
      name: name,
      email: email,
      password: password,
    );
    final model = AuthModel.fromJson(data);
    await _storage.write(key: AppConstants.tokenKey, value: model.token);
    return model;
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }
}
