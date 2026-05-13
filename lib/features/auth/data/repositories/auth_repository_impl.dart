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

  AuthRepositoryImpl(this._datasource, this._storage);

  @override
  Future<AuthEntity> login(String email, String password) async {
    final data = await _datasource.login(email, password);
    final model = AuthModel.fromJson(data);
    await _storage.write(key: AppConstants.tokenKey, value: model.token);

    // Registrar token FCM
    _registerFcmToken();

    // Sync inicial en background — no bloquea el login
    Future.delayed(const Duration(seconds: 1), () {
      sl<InitialSyncService>().syncAll();
    });

    return model;
  }

  void _registerFcmToken() async {
    try {
      final token = await NotificationService.getToken();
      if (token != null) {
        // Necesitamos Dio con el token ya guardado
        final dio = DioClient.createDio(_storage);
        await dio.post('/notifications/fcm-token', data: {
          'token': token,
          'platform': 'mobile',
        });
      }
    } catch (e) {
      // No bloqueamos el login si falla el registro del token
      debugPrint('FCM token registration failed: $e');
    }
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
