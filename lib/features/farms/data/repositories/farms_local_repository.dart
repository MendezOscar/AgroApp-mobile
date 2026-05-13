import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../core/services/local_database.dart';
import '../../domain/entities/farm_entity.dart';
import '../models/farm_model.dart';

class FarmsLocalRepository {
  Future<Database> get _db => LocalDatabase.database;

  Future<List<FarmEntity>> getFarms() async {
    final db = await _db;
    final maps =
        await db.query('farms', where: 'is_active = ?', whereArgs: [1]);
    return maps.map((m) => _fromMap(m)).toList();
  }

  Future<void> saveFarms(List<FarmEntity> farms) async {
    final db = await _db;
    final batch = db.batch();
    for (final farm in farms) {
      batch.insert(
        'farms',
        _toMap(farm),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> savePendingCreate(Map<String, dynamic> data) async {
    final db = await _db;
    await db.insert('pending_sync', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'entity_type': 'farm',
      'action': 'create',
      'payload': jsonEncode(data),
      'created_at': DateTime.now().toIso8601String(),
      'attempts': 0,
    });
  }

  FarmEntity _fromMap(Map<String, dynamic> m) => FarmModel(
        id: m['id'],
        name: m['name'],
        description: m['description'],
        lat: m['lat'],
        lng: m['lng'],
        areaHa: m['area_ha'],
        country: m['country'],
        region: m['region'],
        isActive: m['is_active'] == 1,
        createdAt: DateTime.parse(m['created_at']),
      );

  Map<String, dynamic> _toMap(FarmEntity f) => {
        'id': f.id,
        'name': f.name,
        'description': f.description,
        'lat': f.lat,
        'lng': f.lng,
        'area_ha': f.areaHa,
        'country': f.country,
        'region': f.region,
        'is_active': f.isActive ? 1 : 0,
        'created_at': f.createdAt.toIso8601String(),
        'synced_at': DateTime.now().toIso8601String(),
      };
}
