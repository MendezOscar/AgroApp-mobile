import 'package:equatable/equatable.dart';

abstract class CropsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCrops extends CropsEvent {
  final String plotId;
  LoadCrops(this.plotId);

  @override
  List<Object?> get props => [plotId];
}

class CreateCrop extends CropsEvent {
  final String plotId;
  final String cropType;
  final String? variety;
  final DateTime plantedAt;
  final DateTime? estimatedHarvest;
  final String? notes;

  CreateCrop({
    required this.plotId,
    required this.cropType,
    this.variety,
    required this.plantedAt,
    this.estimatedHarvest,
    this.notes,
  });

  @override
  List<Object?> get props => [plotId, cropType, variety, plantedAt];
}

class DeleteCrop extends CropsEvent {
  final String plotId;
  final String cropId;

  DeleteCrop({required this.plotId, required this.cropId});

  @override
  List<Object?> get props => [plotId, cropId];
}
