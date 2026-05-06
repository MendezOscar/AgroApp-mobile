import '../entities/farm_entity.dart';

abstract class FarmsRepository {
  Future<List<FarmEntity>> getFarms();
  Future<FarmEntity> createFarm(Map<String, dynamic> data);
  Future<void> deleteFarm(String id);
}
