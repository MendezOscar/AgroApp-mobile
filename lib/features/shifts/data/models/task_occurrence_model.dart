import '../../domain/entities/task_occurrence_entity.dart';

class TaskOccurrenceModel extends TaskOccurrenceEntity {
  const TaskOccurrenceModel({
    required super.id,
    required super.templateId,
    required super.templateTitle,
    required super.taskType,
    required super.priority,
    super.assignedTo,
    super.assigneeName,
    super.plotName,
    super.cropName,
    required super.scheduledDate,
    required super.shift,
    required super.status,
    super.completedAt,
    super.notes,
  });

  factory TaskOccurrenceModel.fromJson(Map<String, dynamic> json) =>
      TaskOccurrenceModel(
        id: json['id'],
        templateId: json['templateId'],
        templateTitle: json['templateTitle'],
        taskType: json['taskType'],
        priority: json['priority'],
        assignedTo: json['assignedTo'],
        assigneeName: json['assigneeName'],
        plotName: json['plotName'],
        cropName: json['cropName'],
        scheduledDate: DateTime.parse(json['scheduledDate']),
        shift: json['shift'],
        status: json['status'],
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        notes: json['notes'],
      );
}
