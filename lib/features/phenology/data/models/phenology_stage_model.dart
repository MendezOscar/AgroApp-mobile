import '../../domain/entities/phenology_stage_entity.dart';

class PhenologyStageModel extends PhenologyStageEntity {
  const PhenologyStageModel({
    required super.id,
    required super.cropId,
    super.templateId,
    required super.stageName,
    required super.stageOrder,
    super.icon,
    required super.startedAt,
    super.endedAt,
    super.observations,
    required super.isCustom,
    required super.isActive,
    required super.daysInStage,
    required super.createdAt,
  });

  factory PhenologyStageModel.fromJson(Map<String, dynamic> json) =>
      PhenologyStageModel(
        id: json['id'],
        cropId: json['cropId'],
        templateId: json['templateId'],
        stageName: json['stageName'],
        stageOrder: json['stageOrder'],
        icon: json['icon'],
        startedAt: DateTime.parse(json['startedAt']),
        endedAt:
            json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
        observations: json['observations'],
        isCustom: json['isCustom'],
        isActive: json['isActive'],
        daysInStage: json['daysInStage'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
