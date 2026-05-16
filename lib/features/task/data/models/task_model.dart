import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.createdBy,
    required super.assignedTo,
    required super.assigneeName,
    required super.creatorName,
    super.plotId,
    super.plotName,
    super.cropId,
    super.cropName,
    required super.title,
    super.description,
    required super.priority,
    required super.status,
    required super.dueDate,
    super.completedAt,
    super.notes,
    required super.createdAt,
    required super.taskType,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'],
        createdBy: json['createdBy'],
        assignedTo: json['assignedTo'],
        assigneeName: json['assigneeName'],
        creatorName: json['creatorName'],
        plotId: json['plotId'],
        plotName: json['plotName'],
        cropId: json['cropId'],
        cropName: json['cropName'],
        title: json['title'],
        description: json['description'],
        priority: json['priority'],
        status: json['status'],
        dueDate: DateTime.parse(json['dueDate']),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        notes: json['notes'],
        createdAt: DateTime.parse(json['createdAt']),
        taskType: json['taskType'] ?? 'Other',
      );
}
