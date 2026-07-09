class IrrigationEntity {
  final String id;
  final String cropId;
  final String? taskId;
  final String method;
  final double? volumeLiters;
  final int? durationMin;
  final DateTime appliedAt;
  final String? notes;
  final DateTime createdAt;

  const IrrigationEntity({
    required this.id,
    required this.cropId,
    this.taskId,
    required this.method,
    this.volumeLiters,
    this.durationMin,
    required this.appliedAt,
    this.notes,
    required this.createdAt,
  });
}
