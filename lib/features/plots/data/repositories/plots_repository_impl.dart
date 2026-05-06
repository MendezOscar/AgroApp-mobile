import '../../domain/entities/plot_entity.dart';
import '../../domain/repositories/plots_repository.dart';
import '../datasources/plots_remote_datasource.dart';
import '../models/plot_model.dart';

class PlotsRepositoryImpl implements PlotsRepository {
  final PlotsRemoteDatasource _datasource;

  PlotsRepositoryImpl(this._datasource);

  @override
  Future<List<PlotEntity>> getPlots(String farmId) async {
    final data = await _datasource.getPlots(farmId);
    return data.map((e) => PlotModel.fromJson(e)).toList();
  }

  @override
  Future<PlotEntity> createPlot(
      String farmId, Map<String, dynamic> data) async {
    final result = await _datasource.createPlot(farmId, data);
    return PlotModel.fromJson(result);
  }

  @override
  Future<void> deletePlot(String farmId, String plotId) async {
    await _datasource.deletePlot(farmId, plotId);
  }
}
