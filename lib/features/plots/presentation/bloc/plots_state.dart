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
  final bool isOffline;

  PlotsLoaded(this.plots, {this.isOffline = false});

  @override
  List<Object?> get props => [plots, isOffline];
}

class PlotsError extends PlotsState {
  final String message;
  PlotsError(this.message);

  @override
  List<Object?> get props => [message];
}
