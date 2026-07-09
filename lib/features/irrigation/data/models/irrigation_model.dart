import '../../domain/entities/irrigation_entity.dart';

class IrrigationModel extends IrrigationEntity {
  const IrrigationModel({
    required super.id,
    required super.cropId,
    super.taskId,
    required super.method,
    super.volumeLiters,
    super.durationMin,
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
        appliedAt: DateTime.parse(json['appliedAt']),
        notes: json['notes'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
