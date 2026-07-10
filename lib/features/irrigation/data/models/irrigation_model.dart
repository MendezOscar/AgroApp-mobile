import '../../domain/entities/irrigation_entity.dart';

class IrrigationModel extends IrrigationEntity {
  const IrrigationModel({
    required super.id,
    required super.cropId,
    super.taskId,
    required super.method,
    super.volumeLiters,
    super.durationMin,
    super.cost,
    required super.appliedAt,
    super.notes,
    required super.createdAt,
  });

  factory IrrigationModel.fromJson(Map<String, dynamic> json) =>
      IrrigationModel(
        id: json['id'],
        cropId: json['cropId'],
        taskId: json['taskId'],
        method: json['method'],
        volumeLiters: (json['volumeLiters'] as num?)?.toDouble(),
        durationMin: json['durationMin'],
        cost: (json['cost'] as num?)?.toDouble(),
        appliedAt: DateTime.parse(json['appliedAt']),
        notes: json['notes'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
