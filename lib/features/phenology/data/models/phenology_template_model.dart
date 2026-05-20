import '../../domain/entities/phenology_template_entity.dart';

class PhenologyTemplateModel extends PhenologyTemplateEntity {
  const PhenologyTemplateModel({
    required super.id,
    required super.cropType,
    required super.stageName,
    required super.stageOrder,
    super.description,
    required super.minDays,
    required super.maxDays,
    super.icon,
    super.recommendations,
  });

  factory PhenologyTemplateModel.fromJson(Map<String, dynamic> json) =>
      PhenologyTemplateModel(
        id: json['id'],
        cropType: json['cropType'],
        stageName: json['stageName'],
        stageOrder: json['stageOrder'],
        description: json['description'],
        minDays: json['minDays'],
        maxDays: json['maxDays'],
        icon: json['icon'],
        recommendations: json['recommendations'],
      );
}
