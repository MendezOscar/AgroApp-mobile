import 'package:dio/dio.dart';

class UsersRemoteDatasource {
  final Dio _dio;
  UsersRemoteDatasource(this._dio);

  Future<List<dynamic>> getUsers() async {
    final response = await _dio.get('/users');
    return response.data;
  }

  Future<void> inviteUser(Map<String, dynamic> data) async {
    await _dio.post('/users/invite', data: data);
  }

  Future<void> toggleUser(String id, bool isActive) async {
    await _dio.patch('/users/$id/toggle', data: {'isActive': isActive});
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    await _dio.post('/users/change-password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}
