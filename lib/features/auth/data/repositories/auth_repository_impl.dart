import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/initial_sync_service.dart';
import '../../../../core/services/notification_service.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_model.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/constants/app_constants.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'auth_refresh_token'; // ← nuevo
  static const _userKey = 'auth_user';

  AuthRepositoryImpl(this._datasource, this._storage);

  @override
  Future<AuthEntity> login(String email, String password) async {
    final data = await _datasource.login(email, password);
    final model = AuthModel.fromJson(data);

    // Guardar access token
    await _storage.write(key: AppConstants.tokenKey, value: model.token);
    await _storage.write(key: _tokenKey, value: model.token);

    // Guardar refresh token ← nuevo
    await _storage.write(key: _refreshTokenKey, value: model.refreshToken);

    // Guardar datos del usuario
    await _storage.write(
        key: _userKey,
        value: jsonEncode({
          'token': model.token,
          'refreshToken': model.refreshToken, // ← nuevo
          'name': model.name,
          'email': model.email,
          'role': model.role,
          'tenantId': model.tenantId,
        }));

    _registerFcmToken();

    Future.delayed(const Duration(seconds: 3), () async {
      try {
        await sl<InitialSyncService>().syncAll();
      } catch (e) {
        debugPrint('Sync error: $e');
      }
    });

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

    // Guardar ambos tokens ← actualizado
    await _storage.write(key: AppConstants.tokenKey, value: model.token);
    await _storage.write(key: _tokenKey, value: model.token);
    await _storage.write(key: _refreshTokenKey, value: model.refreshToken);
    await _storage.write(
        key: _userKey,
        value: jsonEncode({
          'token': model.token,
          'refreshToken': model.refreshToken,
          'name': model.name,
          'email': model.email,
          'role': model.role,
          'tenantId': model.tenantId,
        }));

    return model;
  }

  @override
  Future<AuthEntity?> getSavedUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson == null) return null;
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return AuthModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    // Revocar refresh token en el backend
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken != null) {
        await _datasource.logout(refreshToken);
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    }

    // Limpiar storage
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey); // ← nuevo
    await _storage.delete(key: _userKey);
    await _storage.delete(key: AppConstants.tokenKey);
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  void _registerFcmToken() async {
    try {
      final token = await NotificationService.getToken();
      if (token != null) {
        final dio = DioClient.createDio(_storage);
        await dio.post('/notifications/fcm-token', data: {
          'token': token,
          'platform': 'mobile',
        });
      }
    } catch (e) {
      debugPrint('FCM token registration failed: $e');
    }
  }
}
