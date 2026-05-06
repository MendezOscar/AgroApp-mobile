import '../entities/crop_entity.dart';

abstract class CropsRepository {
  Future<List<CropEntity>> getCrops(String plotId);
  Future<CropEntity> createCrop(String plotId, Map<String, dynamic> data);
  Future<void> deleteCrop(String plotId, String cropId);
}
