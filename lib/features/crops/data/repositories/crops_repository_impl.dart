import '../../domain/entities/crop_entity.dart';
import '../../domain/repositories/crops_repository.dart';
import '../datasources/crops_remote_datasource.dart';
import '../models/crop_model.dart';

class CropsRepositoryImpl implements CropsRepository {
  final CropsRemoteDatasource _datasource;

  CropsRepositoryImpl(this._datasource);

  @override
  Future<List<CropEntity>> getCrops(String plotId) async {
    final data = await _datasource.getCrops(plotId);
    return data.map((e) => CropModel.fromJson(e)).toList();
  }

  @override
  Future<CropEntity> createCrop(
      String plotId, Map<String, dynamic> data) async {
    final result = await _datasource.createCrop(plotId, data);
    return CropModel.fromJson(result);
  }

  @override
  Future<void> deleteCrop(String plotId, String cropId) async {
    await _datasource.deleteCrop(plotId, cropId);
  }
}
