import 'package:sqflite/sqflite.dart';
import '../../../../core/services/local_database.dart';
import '../../domain/entities/alert_entity.dart';
import '../models/alert_model.dart';

class AlertsLocalRepository {
  Future<Database> get _db => LocalDatabase.database;

  Future<List<AlertEntity>> getAlerts() async {
    final db = await _db;
    final maps =
        await db.query('alerts', orderBy: 'triggered_at DESC', limit: 50);
    return maps.map((m) => _fromMap(m)).toList();
  }

  Future<void> saveAlerts(List<AlertEntity> alerts) async {
    final db = await _db;
    final batch = db.batch();
    for (final alert in alerts) {
      batch.insert('alerts', _toMap(alert),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  AlertEntity _fromMap(Map<String, dynamic> m) => AlertModel(
        id: m['id'],
        alertType: m['alert_type'],
        severity: m['severity'],
        message: m['message'],
        isRead: m['is_read'] == 1,
        triggeredAt: DateTime.parse(m['triggered_at']),
      );

  Map<String, dynamic> _toMap(AlertEntity a) => {
        'id': a.id,
        'alert_type': a.alertType,
        'severity': a.severity,
        'message': a.message,
        'is_read': a.isRead ? 1 : 0,
        'triggered_at': a.triggeredAt.toIso8601String(),
      };
}
