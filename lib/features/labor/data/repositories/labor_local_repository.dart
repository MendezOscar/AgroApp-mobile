import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../core/services/local_database.dart';
import '../../domain/entities/labor_entity.dart';
import '../models/labor_model.dart';

class LaborLocalRepository {
  Future<Database> get _db => LocalDatabase.database;

  Future<List<LaborEntity>> getLabors(String cropId) async {
    final db = await _db;
    final maps = await db.query('labor_logs',
        where: 'crop_id = ?',
        whereArgs: [cropId],
        orderBy: 'performed_at DESC');
    return maps.map((m) => _fromMap(m)).toList();
  }

  Future<void> saveLabors(String cropId, List<LaborEntity> items) async {
    final db = await _db;
    final batch = db.batch();
    for (final item in items) {
      batch.insert('labor_logs', _toMap(item),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> savePending(String cropId, Map<String, dynamic> data) async {
    final db = await _db;
    await db.insert('pending_sync', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'entity_type': 'labor',
      'action': 'create',
      'payload': jsonEncode({...data, 'cropId': cropId}),
      'created_at': DateTime.now().toIso8601String(),
      'attempts': 0,
    });
  }

  LaborEntity _fromMap(Map<String, dynamic> m) => LaborModel(
        id: m['id'],
        cropId: m['crop_id'],
        taskId: m['task_id'],
        activityType: m['activity_type'],
        hoursWorked: m['hours_worked'],
        workersCount: m['workers_count'],
        cost: m['cost'],
        performedAt: DateTime.parse(m['performed_at']),
        notes: m['notes'],
        createdAt: DateTime.parse(m['created_at']),
      );

  Map<String, dynamic> _toMap(LaborEntity l) => {
        'id': l.id,
        'crop_id': l.cropId,
        'task_id': l.taskId,
        'activity_type': l.activityType,
        'hours_worked': l.hoursWorked,
        'workers_count': l.workersCount,
        'cost': l.cost,
        'performed_at': l.performedAt.toIso8601String(),
        'notes': l.notes,
        'created_at': l.createdAt.toIso8601String(),
        'synced_at': DateTime.now().toIso8601String(),
      };
}
