import 'package:sqflite/sqflite.dart';
import '../../../../core/services/local_database.dart';
import '../../domain/entities/task_entity.dart';
import '../models/task_model.dart';

class TasksLocalRepository {
  Future<Database> get _db => LocalDatabase.database;

  Future<List<TaskEntity>> getTasks(
      {bool onlyMine = false, String? userId}) async {
    final db = await _db;
    List<Map<String, dynamic>> maps;

    if (onlyMine && userId != null) {
      maps = await db.query('tasks_cache',
          where: 'assigned_to = ?',
          whereArgs: [userId],
          orderBy: 'due_date ASC');
    } else {
      maps = await db.query('tasks_cache', orderBy: 'due_date ASC');
    }
    return maps.map((m) => _fromMap(m)).toList();
  }

  Future<void> saveTasks(List<TaskEntity> tasks) async {
    final db = await _db;
    final batch = db.batch();
    for (final task in tasks) {
      batch.insert('tasks_cache', _toMap(task),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> updateTaskStatus(String id, String status, String? notes) async {
    final db = await _db;
    await db.update(
      'tasks_cache',
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

  TaskEntity _fromMap(Map<String, dynamic> m) => TaskModel(
        id: m['id'],
        createdBy: m['created_by'],
        assignedTo: m['assigned_to'],
        assigneeName: m['assignee_name'],
        creatorName: m['creator_name'],
        plotId: m['plot_id'],
        plotName: m['plot_name'],
        cropId: m['crop_id'],
        cropName: m['crop_name'],
        title: m['title'],
        description: m['description'],
        priority: m['priority'],
        status: m['status'],
        taskType: m['task_type'],
        dueDate: DateTime.parse(m['due_date']),
        completedAt: m['completed_at'] != null
            ? DateTime.parse(m['completed_at'])
            : null,
        notes: m['notes'],
        createdAt: DateTime.parse(m['created_at']),
      );

  Map<String, dynamic> _toMap(TaskEntity t) => {
        'id': t.id,
        'assigned_to': t.assignedTo,
        'assignee_name': t.assigneeName,
        'created_by': t.createdBy,
        'creator_name': t.creatorName,
        'plot_id': t.plotId,
        'plot_name': t.plotName,
        'crop_id': t.cropId,
        'crop_name': t.cropName,
        'title': t.title,
        'description': t.description,
        'priority': t.priority,
        'status': t.status,
        'task_type': t.taskType,
        'due_date': t.dueDate.toIso8601String(),
        'completed_at': t.completedAt?.toIso8601String(),
        'notes': t.notes,
        'created_at': t.createdAt.toIso8601String(),
        'synced_at': DateTime.now().toIso8601String(),
      };
}
