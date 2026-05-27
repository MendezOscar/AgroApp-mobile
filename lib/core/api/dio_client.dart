import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class DioClient {
  static Dio createDio(FlutterSecureStorage storage) {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Si es 401 intentar refresh automático
        if (error.response?.statusCode == 401) {
          debugPrint('🔄 Token expirado — intentando refresh...');
          final refreshed = await _tryRefreshToken(storage);
          if (refreshed) {
            // Reintentar la petición original con el nuevo token
            try {
              final token = await storage.read(key: AppConstants.tokenKey);
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $token';
              final response = await dio.fetch(opts);
              debugPrint('✅ Petición reintentada exitosamente');
              return handler.resolve(response);
            } catch (e) {
              debugPrint('❌ Error al reintentar petición: $e');
              return handler.next(error);
            }
          } else {
            // Refresh falló — el usuario debe hacer login de nuevo
            debugPrint('❌ Refresh falló — sesión expirada');
            await _clearSession(storage);
            return handler.next(error);
          }
        }
        handler.next(error);
      },
    ));

    return dio;
  }

  static Future<bool> _tryRefreshToken(FlutterSecureStorage storage) async {
    try {
      final refreshToken = await storage.read(key: 'auth_refresh_token');
      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('❌ No hay refresh token guardado');
        return false;
      }

      debugPrint('🔄 Llamando a /auth/refresh...');

      // Usar Dio sin interceptors para evitar loop infinito
      final refreshDio = Dio(BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newToken = data['accessToken'] ?? data['token'] ?? '';
        final newRefreshToken = data['refreshToken'] ?? '';

        if (newToken.isEmpty) return false;

        // Guardar nuevos tokens
        await storage.write(key: AppConstants.tokenKey, value: newToken);
        await storage.write(key: 'auth_token', value: newToken);
        await storage.write(key: 'auth_refresh_token', value: newRefreshToken);

        // Actualizar datos del usuario guardados
        final userJson = await storage.read(key: 'auth_user');
        if (userJson != null) {
          final userMap = jsonDecode(userJson) as Map<String, dynamic>;
          userMap['token'] = newToken;
          userMap['refreshToken'] = newRefreshToken;
          await storage.write(key: 'auth_user', value: jsonEncode(userMap));
        }

        debugPrint('✅ Token renovado correctamente');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error en refresh: $e');
      return false;
    }
  }

  static Future<void> _clearSession(FlutterSecureStorage storage) async {
    await storage.delete(key: AppConstants.tokenKey);
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'auth_refresh_token');
    await storage.delete(key: 'auth_user');
  }
}
