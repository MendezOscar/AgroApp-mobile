import 'package:equatable/equatable.dart';
import '../../../irrigation/domain/entities/irrigation_entity.dart';
import '../../../fertilization/domain/entities/fertilization_entity.dart';
import '../../../labor/domain/entities/labor_entity.dart';
import '../../../crop_images/domain/entities/crop_image_entity.dart';

class CropDetailState extends Equatable {
  final List<IrrigationEntity> irrigations;
  final List<FertilizationEntity> fertilizations;
  final List<LaborEntity> labors;
  final List<CropImageEntity> images;
  final bool isLoadingIrrigation;
  final bool isLoadingFertilization;
  final bool isLoadingLabor;
  final bool isLoadingImages;
  final String? error;

  const CropDetailState({
    this.irrigations = const [],
    this.fertilizations = const [],
    this.labors = const [],
    this.images = const [],
    this.isLoadingIrrigation = false,
    this.isLoadingFertilization = false,
    this.isLoadingLabor = false,
    this.isLoadingImages = false,
    this.error,
  });

  CropDetailState copyWith({
    List<IrrigationEntity>? irrigations,
    List<FertilizationEntity>? fertilizations,
    List<LaborEntity>? labors,
    List<CropImageEntity>? images,
    bool? isLoadingIrrigation,
    bool? isLoadingFertilization,
    bool? isLoadingLabor,
    bool? isLoadingImages,
    String? error,
  }) =>
      CropDetailState(
        irrigations: irrigations ?? this.irrigations,
        fertilizations: fertilizations ?? this.fertilizations,
        labors: labors ?? this.labors,
        images: images ?? this.images,
        isLoadingIrrigation: isLoadingIrrigation ?? this.isLoadingIrrigation,
        isLoadingFertilization:
            isLoadingFertilization ?? this.isLoadingFertilization,
        isLoadingLabor: isLoadingLabor ?? this.isLoadingLabor,
        isLoadingImages: isLoadingImages ?? this.isLoadingImages,
        error: error,
      );

  @override
  List<Object?> get props => [
        irrigations,
        fertilizations,
        labors,
        images,
        isLoadingIrrigation,
        isLoadingFertilization,
        isLoadingLabor,
        isLoadingImages,
        error,
      ];
}
