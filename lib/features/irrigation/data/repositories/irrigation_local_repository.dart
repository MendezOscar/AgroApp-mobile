import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../core/services/local_database.dart';
import '../../domain/entities/irrigation_entity.dart';
import '../models/irrigation_model.dart';

class IrrigationLocalRepository {
  Future<Database> get _db => LocalDatabase.database;

  Future<List<IrrigationEntity>> getIrrigations(String cropId) async {
    final db = await _db;
    final maps = await db.query('irrigation_logs',
        where: 'crop_id = ?', whereArgs: [cropId], orderBy: 'applied_at DESC');
    return maps.map((m) => _fromMap(m)).toList();
  }

  Future<void> saveIrrigations(
      String cropId, List<IrrigationEntity> items) async {
    final db = await _db;
    final batch = db.batch();
    for (final item in items) {
      batch.insert('irrigation_logs', _toMap(item),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> savePending(String cropId, Map<String, dynamic> data) async {
    final db = await _db;
    await db.insert('pending_sync', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'entity_type': 'irrigation',
      'action': 'create',
      'payload': jsonEncode({...data, 'cropId': cropId}),
      'created_at': DateTime.now().toIso8601String(),
      'attempts': 0,
    });
  }

  IrrigationEntity _fromMap(Map<String, dynamic> m) => IrrigationModel(
        id: m['id'],
        cropId: m['crop_id'],
        method: m['method'],
        volumeLiters: m['volume_liters'],
        durationMin: m['duration_min'],
        appliedAt: DateTime.parse(m['applied_at']),
        notes: m['notes'],
        createdAt: DateTime.parse(m['created_at']),
      );

  Map<String, dynamic> _toMap(IrrigationEntity i) => {
        'id': i.id,
        'crop_id': i.cropId,
        'method': i.method,
        'volume_liters': i.volumeLiters,
        'duration_min': i.durationMin,
        'applied_at': i.appliedAt.toIso8601String(),
        'notes': i.notes,
        'created_at': i.createdAt.toIso8601String(),
        'synced_at': DateTime.now().toIso8601String(),
      };
}
