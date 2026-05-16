class TaskTemplateEntity {
  final String id;
  final String createdBy;
  final String creatorName;
  final String? plotId;
  final String? plotName;
  final String? cropId;
  final String? cropName;
  final String title;
  final String? description;
  final String taskType;
  final String priority;
  final String shift;
  final String recurrenceType;
  final String? weekDays;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final int occurrenceCount;
  final DateTime createdAt;

  const TaskTemplateEntity({
    required this.id,
    required this.createdBy,
    required this.creatorName,
    this.plotId,
    this.plotName,
    this.cropId,
    this.cropName,
    required this.title,
    this.description,
    required this.taskType,
    required this.priority,
    required this.shift,
    required this.recurrenceType,
    this.weekDays,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.occurrenceCount,
    required this.createdAt,
  });

  String get shiftIcon => shift == 'Day' ? '☀️' : '🌙';
  String get shiftLabel => shift == 'Day' ? 'Diurno' : 'Nocturno';

  String get recurrenceLabel => switch (recurrenceType) {
        'Once' => 'Una vez',
        'Daily' => 'Diario',
        'Weekly' => 'Semanal',
        'DateRange' => 'Rango de fechas',
        _ => recurrenceType,
      };
}
