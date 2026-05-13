import 'package:sqflite/sqflite.dart';
import '../../../../core/services/local_database.dart';

class CropImagesLocalRepository {
  Future<Database> get _db => LocalDatabase.database;

  /// Guarda una imagen pendiente de subir
  Future<void> savePendingImage({
    required String cropId,
    required String filePath,
    required String category,
  }) async {
    final db = await _db;
    await db.insert('pending_images', {
      'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
      'crop_id': cropId,
      'file_path': filePath,
      'category': category,
      'taken_at': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Obtiene imágenes pendientes de subir para un cultivo
  Future<List<Map<String, dynamic>>> getPendingImages(String cropId) async {
    final db = await _db;
    return await db.query('pending_images',
        where: 'crop_id = ?', whereArgs: [cropId], orderBy: 'created_at DESC');
  }

  /// Obtiene todas las imágenes pendientes (para sync)
  Future<List<Map<String, dynamic>>> getAllPendingImages() async {
    final db = await _db;
    return await db.query('pending_images', orderBy: 'created_at ASC');
  }

  /// Elimina una imagen pendiente después de subirla
  Future<void> deletePendingImage(String id) async {
    final db = await _db;
    await db.delete('pending_images', where: 'id = ?', whereArgs: [id]);
  }

  /// Cuenta imágenes pendientes
  Future<int> getPendingCount() async {
    final db = await _db;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM pending_images');
    return result.first['count'] as int;
  }
}
