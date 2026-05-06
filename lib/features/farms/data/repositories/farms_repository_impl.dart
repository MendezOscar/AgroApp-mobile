import '../../domain/entities/farm_entity.dart';
import '../../domain/repositories/farms_repository.dart';
import '../datasources/farms_remote_datasource.dart';
import '../models/farm_model.dart';

class FarmsRepositoryImpl implements FarmsRepository {
  final FarmsRemoteDatasource _datasource;

  FarmsRepositoryImpl(this._datasource);

  @override
  Future<List<FarmEntity>> getFarms() async {
    final data = await _datasource.getFarms();
    return data.map((e) => FarmModel.fromJson(e)).toList();
  }

  @override
  Future<FarmEntity> createFarm(Map<String, dynamic> data) async {
    final result = await _datasource.createFarm(data);
    return FarmModel.fromJson(result);
  }

  @override
  Future<void> deleteFarm(String id) async {
    await _datasource.deleteFarm(id);
  }
}
