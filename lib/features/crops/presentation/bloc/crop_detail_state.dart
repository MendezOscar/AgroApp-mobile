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
      ];
}
