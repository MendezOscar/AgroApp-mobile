class TaskOccurrenceEntity {
  final String id;
  final String templateId;
  final String templateTitle;
  final String taskType;
  final String priority;
  final String? assignedTo;
  final String? assigneeName;
  final String? plotName;
  final String? cropId;
  final String? cropName;
  final DateTime scheduledDate;
  final String shift;
  final String status;
  final DateTime? completedAt;
  final String? notes;

  const TaskOccurrenceEntity({
    required this.id,
    required this.templateId,
    required this.templateTitle,
    required this.taskType,
    required this.priority,
    this.assignedTo,
    this.assigneeName,
    this.plotName,
    this.cropId,
    this.cropName,
    required this.scheduledDate,
    required this.shift,
    required this.status,
    this.completedAt,
    this.notes,
  });

  String get shiftIcon => shift == 'Day' ? '☀️' : '🌙';
  String get shiftLabel => shift == 'Day' ? 'Diurno' : 'Nocturno';
  bool get isUnassigned => assignedTo == null;
  bool get isCompleted => status == 'Completed';
  bool get needsRegistration =>
      ['Irrigation', 'Fertilization', 'Labor'].contains(taskType);
  bool get isOverdue =>
      status == 'Pending' && scheduledDate.isBefore(DateTime.now());

  String get taskTypeIcon => switch (taskType) {
        'Irrigation' => '💧',
        'Fertilization' => '🧪',
        'Labor' => '👷',
        'Inspection' => '📷',
        'Sensor' => '📡',
        _ => '📋',
      };
}
