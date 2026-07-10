class PhenologyStageEntity {
  final String id;
  final String cropId;
  final String? templateId;
  final String stageName;
  final int stageOrder;
  final String? icon;
  final String? recommendations;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? observations;
  final bool isCustom;
  final bool isActive;
  final int daysInStage;
  final DateTime createdAt;

  const PhenologyStageEntity({
    required this.id,
    required this.cropId,
    this.templateId,
    required this.stageName,
    required this.stageOrder,
    this.icon,
    this.recommendations,
    required this.startedAt,
    this.endedAt,
    this.observations,
    required this.isCustom,
    required this.isActive,
    required this.daysInStage,
    required this.createdAt,
  });
}
