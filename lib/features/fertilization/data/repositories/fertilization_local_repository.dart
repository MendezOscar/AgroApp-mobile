import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../core/services/local_database.dart';
import '../../domain/entities/fertilization_entity.dart';
import '../models/fertilization_model.dart';

class FertilizationLocalRepository {
  Future<Database> get _db => LocalDatabase.database;

  Future<List<FertilizationEntity>> getFertilizations(String cropId) async {
    final db = await _db;
    final maps = await db.query('fertilization_logs',
        where: 'crop_id = ?', whereArgs: [cropId], orderBy: 'applied_at DESC');
    return maps.map((m) => _fromMap(m)).toList();
  }

  Future<void> saveFertilizations(
      String cropId, List<FertilizationEntity> items) async {
    final db = await _db;
    final batch = db.batch();
    for (final item in items) {
      batch.insert('fertilization_logs', _toMap(item),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> savePending(String cropId, Map<String, dynamic> data) async {
    final db = await _db;
    await db.insert('pending_sync', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'entity_type': 'fertilization',
      'action': 'create',
      'payload': jsonEncode({...data, 'cropId': cropId}),
      'created_at': DateTime.now().toIso8601String(),
      'attempts': 0,
    });
  }

  FertilizationEntity _fromMap(Map<String, dynamic> m) => FertilizationModel(
        id: m['id'],
        cropId: m['crop_id'],
        productName: m['product_name'],
        productType: m['product_type'],
        doseKgHa: m['dose_kg_ha'],
        totalKg: m['total_kg'],
        method: m['method'],
        cost: m['cost'],
        appliedAt: DateTime.parse(m['applied_at']),
        nextApplication: m['next_application'] != null
            ? DateTime.parse(m['next_application'])
            : null,
        notes: m['notes'],
        createdAt: DateTime.parse(m['created_at']),
      );

  Map<String, dynamic> _toMap(FertilizationEntity f) => {
        'id': f.id,
        'crop_id': f.cropId,
        'product_name': f.productName,
        'product_type': f.productType,
        'dose_kg_ha': f.doseKgHa,
        'total_kg': f.totalKg,
        'method': f.method,
        'cost': f.cost,
        'applied_at': f.appliedAt.toIso8601String(),
        'next_application': f.nextApplication?.toIso8601String(),
        'notes': f.notes,
        'created_at': f.createdAt.toIso8601String(),
        'synced_at': DateTime.now().toIso8601String(),
      };
}
