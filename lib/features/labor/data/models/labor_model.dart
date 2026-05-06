import '../../domain/entities/labor_entity.dart';

class LaborModel extends LaborEntity {
  const LaborModel({
    required super.id,
    required super.cropId,
    required super.activityType,
    super.hoursWorked,
    required super.workersCount,
    super.cost,
    required super.performedAt,
    super.notes,
    required super.createdAt,
  });

  factory LaborModel.fromJson(Map<String, dynamic> json) => LaborModel(
        id: json['id'],
        cropId: json['cropId'],
        activityType: json['activityType'],
        hoursWorked: (json['hoursWorked'] as num?)?.toDouble(),
        workersCount: json['workersCount'],
        cost: (json['cost'] as num?)?.toDouble(),
        performedAt: DateTime.parse(json['performedAt']),
        notes: json['notes'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
