import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../core/services/local_database.dart';
import '../../domain/entities/crop_entity.dart';
import '../models/crop_model.dart';

class CropsLocalRepository {
  Future<Database> get _db => LocalDatabase.database;

  Future<List<CropEntity>> getCrops(String plotId) async {
    final db = await _db;
    final maps = await db.query('crops',
        where: 'plot_id = ? AND status != ?', whereArgs: [plotId, 'Cancelled']);
    return maps.map((m) => _fromMap(m)).toList();
  }

  Future<void> saveCrops(String plotId, List<CropEntity> crops) async {
    final db = await _db;
    final batch = db.batch();
    for (final crop in crops) {
      batch.insert('crops', _toMap(crop),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> savePendingCreate(
      String plotId, Map<String, dynamic> data) async {
    final db = await _db;
    await db.insert('pending_sync', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'entity_type': 'crop',
      'action': 'create',
      'payload': jsonEncode({...data, 'plotId': plotId}),
      'created_at': DateTime.now().toIso8601String(),
      'attempts': 0,
    });
  }

  CropEntity _fromMap(Map<String, dynamic> m) => CropModel(
        id: m['id'],
        plotId: m['plot_id'],
        cropType: m['crop_type'],
        variety: m['variety'],
        plantedAt: DateTime.parse(m['planted_at']),
        estimatedHarvest: m['estimated_harvest'] != null
            ? DateTime.parse(m['estimated_harvest'])
            : null,
        harvestedAt: m['harvested_at'] != null
            ? DateTime.parse(m['harvested_at'])
            : null,
        status: m['status'],
        yieldKg: m['yield_kg'],
        notes: m['notes'],
        createdAt: DateTime.parse(m['created_at']),
      );

  Map<String, dynamic> _toMap(CropEntity c) => {
        'id': c.id,
        'plot_id': c.plotId,
        'crop_type': c.cropType,
        'variety': c.variety,
        'planted_at': c.plantedAt.toIso8601String(),
        'estimated_harvest': c.estimatedHarvest?.toIso8601String(),
        'harvested_at': c.harvestedAt?.toIso8601String(),
        'status': c.status,
        'yield_kg': c.yieldKg,
        'notes': c.notes,
        'created_at': c.createdAt.toIso8601String(),
        'synced_at': DateTime.now().toIso8601String(),
      };
}
