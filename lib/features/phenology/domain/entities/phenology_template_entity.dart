class PhenologyTemplateEntity {
  final String id;
  final String cropType;
  final String stageName;
  final int stageOrder;
  final String? description;
  final int minDays;
  final int maxDays;
  final String? icon;
  final String? recommendations;

  const PhenologyTemplateEntity({
    required this.id,
    required this.cropType,
    required this.stageName,
    required this.stageOrder,
    this.description,
    required this.minDays,
    required this.maxDays,
    this.icon,
    this.recommendations,
  });
}
