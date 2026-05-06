import 'package:equatable/equatable.dart';
import '../../domain/entities/crop_entity.dart';

abstract class CropsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CropsInitial extends CropsState {}

class CropsLoading extends CropsState {}

class CropsLoaded extends CropsState {
  final List<CropEntity> crops;
  CropsLoaded(this.crops);

  @override
  List<Object?> get props => [crops];
}

class CropsError extends CropsState {
  final String message;
  CropsError(this.message);

  @override
  List<Object?> get props => [message];
}
