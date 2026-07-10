import 'package:sqflite/sqflite.dart';
import '../../../../core/services/local_database.dart';
import '../../domain/entities/task_occurrence_entity.dart';
import '../models/task_occurrence_model.dart';

class ShiftsLocalRepository {
  Future<Database> get _db => LocalDatabase.database;

  Future<List<TaskOccurrenceEntity>> getOccurrences({
    DateTime? date,
    String? userId,
    bool onlyMine = false,
  }) async {
    final db = await _db;
    List<Map<String, dynamic>> maps;

    if (date != null && onlyMine && userId != null) {
      maps = await db.query('occurrences_cache',
          where: 'scheduled_date = ? AND assigned_to = ?',
          whereArgs: [date.toIso8601String().split('T')[0], userId],
          orderBy: 'shift ASC');
    } else if (date != null) {
      maps = await db.query('occurrences_cache',
          where: 'scheduled_date = ?',
          whereArgs: [date.toIso8601String().split('T')[0]],
          orderBy: 'shift ASC');
    } else if (onlyMine && userId != null) {
      maps = await db.query('occurrences_cache',
          where: 'assigned_to = ?',
          whereArgs: [userId],
          orderBy: 'scheduled_date ASC');
    } else {
      maps = await db.query('occurrences_cache', orderBy: 'scheduled_date ASC');
    }

    return maps.map((m) => _fromMap(m)).toList();
  }

  Future<void> saveOccurrences(List<TaskOccurrenceEntity> occurrences) async {
    final db = await _db;
    final batch = db.batch();
    for (final o in occurrences) {
      batch.insert('occurrences_cache', _toMap(o),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> updateStatus(String id, String status, String? notes) async {
    final db = await _db;
    await db.update(
      'occurrences_cache',
      {
        'status': status,
        if (notes != null) 'notes': notes,
        if (status == 'Completed')
          'completed_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  TaskOccurrenceEntity _fromMap(Map<String, dynamic> m) => TaskOccurrenceModel(
        id: m['id'],
        templateId: m['template_id'],
        templateTitle: m['template_title'],
        taskType: m['task_type'],
        priority: m['priority'],
        assignedTo: m['assigned_to'],
        assigneeName: m['assignee_name'],
        plotName: m['plot_name'],
        cropId: m['crop_id'],
        cropName: m['crop_name'],
        scheduledDate: DateTime.parse(m['scheduled_date']),
        shift: m['shift'],
        status: m['status'],
        completedAt: m['completed_at'] != null
            ? DateTime.parse(m['completed_at'])
            : null,
        notes: m['notes'],
      );

  Map<String, dynamic> _toMap(TaskOccurrenceEntity o) => {
        'id': o.id,
        'template_id': o.templateId,
        'template_title': o.templateTitle,
        'task_type': o.taskType,
        'priority': o.priority,
        'assigned_to': o.assignedTo,
        'assignee_name': o.assigneeName,
        'plot_name': o.plotName,
        'crop_id': o.cropId,
        'crop_name': o.cropName,
        'scheduled_date': o.scheduledDate.toIso8601String().split('T')[0],
        'shift': o.shift,
        'status': o.status,
        'completed_at': o.completedAt?.toIso8601String(),
        'notes': o.notes,
        'synced_at': DateTime.now().toIso8601String(),
      };
}
