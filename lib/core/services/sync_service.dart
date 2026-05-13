import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/crop_images/data/repositories/crop_images_local_repository.dart';
import '../services/local_database.dart';

class SyncService {
  final Dio _dio;
  final CropImagesLocalRepository _imagesLocal;

  SyncService(this._dio, this._imagesLocal);

  Future<void> syncAll() async {
    await syncPending();
    await syncPendingImages();
  }

  Future<void> syncPending() async {
    final db = await LocalDatabase.database;
    final pending = await db.query(
      'pending_sync',
      orderBy: 'created_at ASC',
      where: 'attempts < ?',
      whereArgs: [3],
    );

    for (final item in pending) {
      await _processItem(db, item);
    }
  }

  Future<void> syncPendingImages() async {
    final pending = await _imagesLocal.getAllPendingImages();

    for (final item in pending) {
      try {
        final file = File(item['file_path'] as String);
        if (!await file.exists()) {
          // Si el archivo ya no existe, eliminar el pendiente
          await _imagesLocal.deletePendingImage(item['id'] as String);
          continue;
        }

        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            item['file_path'] as String,
            filename: 'image_${item['id']}.jpg',
          ),
          'category': item['category'] as String,
          'takenAt': item['taken_at'] as String,
        });

        await _dio.post(
          '/crops/${item['crop_id']}/images',
          data: formData,
        );

        // Eliminar de pendientes si fue exitoso
        await _imagesLocal.deletePendingImage(item['id'] as String);
      } catch (e) {
        debugPrint('Error sincronizando imagen ${item['id']}: $e');
      }
    }
  }

  Future<void> _processItem(Database db, Map<String, dynamic> item) async {
    try {
      final payload = jsonDecode(item['payload'] as String);
      final entityType = item['entity_type'] as String;
      final action = item['action'] as String;

      String endpoint = '';
      switch (entityType) {
        case 'farm':
          endpoint = action == 'create' ? '/farms' : '/farms/${payload['id']}';
          break;
        case 'plot':
          endpoint = action == 'create'
              ? '/farms/${payload['farmId']}/plots'
              : '/farms/${payload['farmId']}/plots/${payload['id']}';
          break;
        case 'crop':
          endpoint = action == 'create'
              ? '/plots/${payload['plotId']}/crops'
              : '/plots/${payload['plotId']}/crops/${payload['id']}';
          break;
        case 'irrigation':
          endpoint = '/crops/${payload['cropId']}/irrigation';
          break;
        case 'fertilization':
          endpoint = '/crops/${payload['cropId']}/fertilization';
          break;
        case 'labor':
          endpoint = '/crops/${payload['cropId']}/labor';
          break;
      }

      if (action == 'create') {
        await _dio.post(endpoint, data: payload);
      } else if (action == 'update') {
        await _dio.put(endpoint, data: payload);
      } else if (action == 'delete') {
        await _dio.delete(endpoint);
      }

      // Eliminar si fue exitoso
      await db.delete('pending_sync', where: 'id = ?', whereArgs: [item['id']]);
    } catch (e) {
      // Incrementar intentos
      await db.update(
        'pending_sync',
        {'attempts': (item['attempts'] as int) + 1},
        where: 'id = ?',
        whereArgs: [item['id']],
      );
    }
  }

  Future<int> getPendingCount() async {
    final db = await LocalDatabase.database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM pending_sync WHERE attempts < 3');
    final syncCount = result.first['count'] as int;
    final imageCount = await _imagesLocal.getPendingCount();
    return syncCount + imageCount;
  }
}
