class LaborEntity {
  final String id;
  final String cropId;
  final String? taskId;
  final String activityType;
  final double? hoursWorked;
  final int workersCount;
  final double? cost;
  final DateTime performedAt;
  final String? notes;
  final DateTime createdAt;

  const LaborEntity({
    required this.id,
    required this.cropId,
    this.taskId,
    required this.activityType,
    this.hoursWorked,
    required this.workersCount,
    this.cost,
    required this.performedAt,
    this.notes,
    required this.createdAt,
  });
}
