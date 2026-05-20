import 'package:equatable/equatable.dart';
import '../../domain/entities/phenology_stage_entity.dart';
import '../../domain/entities/phenology_template_entity.dart';

class PhenologyState extends Equatable {
  final List<PhenologyStageEntity> stages;
  final List<PhenologyTemplateEntity> templates;
  final bool isLoading;
  final String? error;
  final String? success;

  const PhenologyState({
    this.stages = const [],
    this.templates = const [],
    this.isLoading = false,
    this.error,
    this.success,
  });

  PhenologyState copyWith({
    List<PhenologyStageEntity>? stages,
    List<PhenologyTemplateEntity>? templates,
    bool? isLoading,
    String? error,
    String? success,
  }) =>
      PhenologyState(
        stages: stages ?? this.stages,
        templates: templates ?? this.templates,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        success: success,
      );

  PhenologyStageEntity? get activeStage =>
      stages.where((s) => s.isActive).firstOrNull;

  double get progressPercent {
    if (stages.isEmpty) return 0;
    final completed = stages.where((s) => !s.isActive).length;
    return completed / stages.length;
  }

  @override
  List<Object?> get props => [stages, templates, isLoading, error, success];
}
