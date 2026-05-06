import 'package:equatable/equatable.dart';
import '../../domain/entities/plot_entity.dart';

abstract class PlotsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlotsInitial extends PlotsState {}

class PlotsLoading extends PlotsState {}

class PlotsLoaded extends PlotsState {
  final List<PlotEntity> plots;
  PlotsLoaded(this.plots);

  @override
  List<Object?> get props => [plots];
}

class PlotsError extends PlotsState {
  final String message;
  PlotsError(this.message);

  @override
  List<Object?> get props => [message];
}
