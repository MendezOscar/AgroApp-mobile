import 'package:equatable/equatable.dart';
import '../../domain/entities/farm_entity.dart';

abstract class FarmsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FarmsInitial extends FarmsState {}

class FarmsLoading extends FarmsState {}

class FarmsLoaded extends FarmsState {
  final List<FarmEntity> farms;
  final bool isOffline;

  FarmsLoaded(this.farms, {this.isOffline = false});

  @override
  List<Object?> get props => [farms, isOffline];
}

class FarmsError extends FarmsState {
  final String message;
  FarmsError(this.message);

  @override
  List<Object?> get props => [message];
}

class FarmOperationSuccess extends FarmsState {
  final String message;
  FarmOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
