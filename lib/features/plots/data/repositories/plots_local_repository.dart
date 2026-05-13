import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../core/services/local_database.dart';
import '../../domain/entities/plot_entity.dart';
import '../models/plot_model.dart';

class PlotsLocalRepository {
  Future<Database> get _db => LocalDatabase.database;

  Future<List<PlotEntity>> getPlots(String farmId) async {
    final db = await _db;
    final maps = await db.query('plots',
        where: 'farm_id = ? AND is_active = ?', whereArgs: [farmId, 1]);
    return maps.map((m) => _fromMap(m)).toList();
  }

  Future<void> savePlots(String farmId, List<PlotEntity> plots) async {
    final db = await _db;
    final batch = db.batch();
    for (final plot in plots) {
      batch.insert('plots', _toMap(plot),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> savePendingCreate(
      String farmId, Map<String, dynamic> data) async {
    final db = await _db;
    await db.insert('pending_sync', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'entity_type': 'plot',
      'action': 'create',
      'payload': jsonEncode({...data, 'farmId': farmId}),
      'created_at': DateTime.now().toIso8601String(),
      'attempts': 0,
    });
  }

  PlotEntity _fromMap(Map<String, dynamic> m) => PlotModel(
        id: m['id'],
        farmId: m['farm_id'],
        name: m['name'],
        soilType: m['soil_type'],
        areaHa: m['area_ha'],
        notes: m['notes'],
        isActive: m['is_active'] == 1,
        createdAt: DateTime.parse(m['created_at']),
      );

  Map<String, dynamic> _toMap(PlotEntity p) => {
        'id': p.id,
        'farm_id': p.farmId,
        'name': p.name,
        'soil_type': p.soilType,
        'area_ha': p.areaHa,
        'notes': p.notes,
        'is_active': p.isActive ? 1 : 0,
        'created_at': p.createdAt.toIso8601String(),
        'synced_at': DateTime.now().toIso8601String(),
      };
}
