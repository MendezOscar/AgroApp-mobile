class TaskEntity {
  final String id;
  final String createdBy;
  final String assignedTo;
  final String assigneeName;
  final String creatorName;
  final String? plotId;
  final String? plotName;
  final String? cropId;
  final String? cropName;
  final String title;
  final String? description;
  final String priority;
  final String status;
  final DateTime dueDate;
  final DateTime? completedAt;
  final String? notes;
  final DateTime createdAt;
  final String taskType;

  const TaskEntity({
    required this.id,
    required this.createdBy,
    required this.assignedTo,
    required this.assigneeName,
    required this.creatorName,
    required this.taskType,
    this.plotId,
    this.plotName,
    this.cropId,
    this.cropName,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    required this.dueDate,
    this.completedAt,
    this.notes,
    required this.createdAt,
  });

  bool get isOverdue => status == 'Pending' || status == 'InProgress'
      ? dueDate.isBefore(DateTime.now())
      : false;

  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  String get taskTypeIcon => switch (taskType) {
        'Irrigation' => '💧',
        'Fertilization' => '🧪',
        'Labor' => '👷',
        'Inspection' => '📷',
        'Sensor' => '📡',
        _ => '📋',
      };

  String get taskTypeLabel => switch (taskType) {
        'Irrigation' => 'Riego',
        'Fertilization' => 'Fertilización',
        'Labor' => 'Labor',
        'Inspection' => 'Inspección',
        'Sensor' => 'Sensor',
        _ => 'Otro',
      };
}
