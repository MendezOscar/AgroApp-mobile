import 'package:dio/dio.dart';

class CropImagesRemoteDatasource {
  final Dio _dio;
  CropImagesRemoteDatasource(this._dio);

  Future<List<dynamic>> getImages(String cropId) async {
    final response = await _dio.get('/crops/$cropId/images');
    return response.data;
  }

  Future<Map<String, dynamic>> uploadImage(
      String cropId, String filePath, String category) async {
    print(
        'SUBIENDO IMAGEN: cropId=$cropId filePath=$filePath category=$category');
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'category': category,
        'takenAt': DateTime.now().toUtc().toIso8601String(),
      });
      print('FORM DATA CREADO OK');
      final response = await _dio.post('/crops/$cropId/images', data: formData);
      return response.data;
    } catch (e) {
      print('ERROR EN DATASOURCE: $e');
      rethrow;
    }
  }

  Future<void> deleteImage(String cropId, String id) async {
    await _dio.delete('/crops/$cropId/images/$id');
  }
}
