import '../entities/plot_entity.dart';

abstract class PlotsRepository {
  Future<List<PlotEntity>> getPlots(String farmId);
  Future<PlotEntity> createPlot(String farmId, Map<String, dynamic> data);
  Future<void> deletePlot(String farmId, String plotId);
  Future<PlotEntity> updatePlot(
      String farmId, String plotId, Map<String, dynamic> data);
}
