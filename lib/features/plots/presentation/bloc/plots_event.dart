import 'package:equatable/equatable.dart';

abstract class PlotsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPlots extends PlotsEvent {
  final String farmId;
  LoadPlots(this.farmId);

  @override
  List<Object?> get props => [farmId];
}

class CreatePlot extends PlotsEvent {
  final String farmId;
  final String name;
  final String? soilType;
  final double? areaHa;
  final String? notes;

  CreatePlot({
    required this.farmId,
    required this.name,
    this.soilType,
    this.areaHa,
    this.notes,
  });

  @override
  List<Object?> get props => [farmId, name, soilType, areaHa, notes];
}

class UpdatePlotLocation extends PlotsEvent {
  final String farmId;
  final String plotId;
  final double lat;
  final double lng;

  UpdatePlotLocation({
    required this.farmId,
    required this.plotId,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object?> get props => [farmId, plotId, lat, lng];
}

class DeletePlot extends PlotsEvent {
  final String farmId;
  final String plotId;

  DeletePlot({required this.farmId, required this.plotId});

  @override
  List<Object?> get props => [farmId, plotId];
}
