import 'package:equatable/equatable.dart';
import '../../../irrigation/domain/entities/irrigation_entity.dart';
import '../../../fertilization/domain/entities/fertilization_entity.dart';
import '../../../labor/domain/entities/labor_entity.dart';
import '../../../crop_images/domain/entities/crop_image_entity.dart';
import '../../data/models/ai_diagnosis_model.dart';

class CropDetailState extends Equatable {
  final List<IrrigationEntity> irrigations;
  final List<FertilizationEntity> fertilizations;
  final AiDiagnosisModel? aiDiagnosis;
  final List<LaborEntity> labors;
  final List<CropImageEntity> images;
  final bool isLoadingIrrigation;
  final bool isLoadingFertilization;
  final bool isLoadingLabor;
  final bool isLoadingImages;
  final bool isOffline;
  final String? error;
  final bool isAnalyzing; // ← nuevo

  // ─── Paginación ───────────────────────────────────────────
  final int irrigationPage;
  final bool irrigationHasNextPage;
  final bool isLoadingMoreIrrigation;

  final int fertilizationPage;
  final bool fertilizationHasNextPage;
  final bool isLoadingMoreFertilization;

  final int laborPage;
  final bool laborHasNextPage;
  final bool isLoadingMoreLabor;

  const CropDetailState({
    this.irrigations = const [],
    this.fertilizations = const [],
    this.labors = const [],
    this.images = const [],
    this.aiDiagnosis,
    this.isLoadingIrrigation = false,
    this.isLoadingFertilization = false,
    this.isLoadingLabor = false,
    this.isLoadingImages = false,
    this.isOffline = false,
    this.error,
    this.isAnalyzing = false,
    this.irrigationPage = 1,
    this.irrigationHasNextPage = false,
    this.isLoadingMoreIrrigation = false,
    this.fertilizationPage = 1,
    this.fertilizationHasNextPage = false,
    this.isLoadingMoreFertilization = false,
    this.laborPage = 1,
    this.laborHasNextPage = false,
    this.isLoadingMoreLabor = false,
  });

  CropDetailState copyWith({
    List<IrrigationEntity>? irrigations,
    List<FertilizationEntity>? fertilizations,
    List<LaborEntity>? labors,
    AiDiagnosisModel? aiDiagnosis,
    List<CropImageEntity>? images,
    bool? isLoadingIrrigation,
    bool? isLoadingFertilization,
    bool? isLoadingLabor,
    bool? isLoadingImages,
    bool? isOffline,
    String? error,
    bool? isAnalyzing,
    int? irrigationPage,
    bool? irrigationHasNextPage,
    bool? isLoadingMoreIrrigation,
    int? fertilizationPage,
    bool? fertilizationHasNextPage,
    bool? isLoadingMoreFertilization,
    int? laborPage,
    bool? laborHasNextPage,
    bool? isLoadingMoreLabor,
  }) =>
      CropDetailState(
        irrigations: irrigations ?? this.irrigations,
        fertilizations: fertilizations ?? this.fertilizations,
        labors: labors ?? this.labors,
        images: images ?? this.images,
        aiDiagnosis: aiDiagnosis ?? this.aiDiagnosis,
        isLoadingIrrigation: isLoadingIrrigation ?? this.isLoadingIrrigation,
        isLoadingFertilization:
            isLoadingFertilization ?? this.isLoadingFertilization,
        isLoadingLabor: isLoadingLabor ?? this.isLoadingLabor,
        isLoadingImages: isLoadingImages ?? this.isLoadingImages,
        isOffline: isOffline ?? this.isOffline,
        error: error,
        isAnalyzing: isAnalyzing ?? this.isAnalyzing,
        irrigationPage: irrigationPage ?? this.irrigationPage,
        irrigationHasNextPage:
            irrigationHasNextPage ?? this.irrigationHasNextPage,
        isLoadingMoreIrrigation:
            isLoadingMoreIrrigation ?? this.isLoadingMoreIrrigation,
        fertilizationPage: fertilizationPage ?? this.fertilizationPage,
        fertilizationHasNextPage:
            fertilizationHasNextPage ?? this.fertilizationHasNextPage,
        isLoadingMoreFertilization:
            isLoadingMoreFertilization ?? this.isLoadingMoreFertilization,
        laborPage: laborPage ?? this.laborPage,
        laborHasNextPage: laborHasNextPage ?? this.laborHasNextPage,
        isLoadingMoreLabor: isLoadingMoreLabor ?? this.isLoadingMoreLabor,
      );

  @override
  List<Object?> get props => [
        irrigations,
        fertilizations,
        labors,
        images,
        aiDiagnosis,
        isLoadingIrrigation,
        isLoadingFertilization,
        isLoadingLabor,
        isLoadingImages,
        isOffline,
        error,
        irrigationPage,
        irrigationHasNextPage,
        isLoadingMoreIrrigation,
        fertilizationPage,
        fertilizationHasNextPage,
        isLoadingMoreFertilization,
        laborPage,
        laborHasNextPage,
        isLoadingMoreLabor,
      ];
}
