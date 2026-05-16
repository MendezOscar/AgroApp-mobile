import '../../domain/entities/task_template_entity.dart';

class TaskTemplateModel extends TaskTemplateEntity {
  const TaskTemplateModel({
    required super.id,
    required super.createdBy,
    required super.creatorName,
    super.plotId,
    super.plotName,
    super.cropId,
    super.cropName,
    required super.title,
    super.description,
    required super.taskType,
    required super.priority,
    required super.shift,
    required super.recurrenceType,
    super.weekDays,
    required super.startDate,
    super.endDate,
    required super.isActive,
    required super.occurrenceCount,
    required super.createdAt,
  });

  factory TaskTemplateModel.fromJson(Map<String, dynamic> json) =>
      TaskTemplateModel(
        id: json['id'],
        createdBy: json['createdBy'],
        creatorName: json['creatorName'],
        plotId: json['plotId'],
        plotName: json['plotName'],
        cropId: json['cropId'],
        cropName: json['cropName'],
        title: json['title'],
        description: json['description'],
        taskType: json['taskType'],
        priority: json['priority'],
        shift: json['shift'],
        recurrenceType: json['recurrenceType'],
        weekDays: json['weekDays'],
        startDate: DateTime.parse(json['startDate']),
        endDate:
            json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
        isActive: json['isActive'],
        occurrenceCount: json['occurrenceCount'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
