import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../irrigation/data/datasources/irrigation_remote_datasource.dart';
import '../../../irrigation/data/models/irrigation_model.dart';
import '../../../fertilization/data/datasources/fertilization_remote_datasource.dart';
import '../../../fertilization/data/models/fertilization_model.dart';
import '../../../labor/data/datasources/labor_remote_datasource.dart';
import '../../../labor/data/models/labor_model.dart';
import '../../../crop_images/data/datasources/crop_images_remote_datasource.dart';
import '../../../crop_images/data/models/crop_image_model.dart';
import 'crop_detail_state.dart';

class CropDetailCubit extends Cubit<CropDetailState> {
  final IrrigationRemoteDatasource _irrigationDs;
  final FertilizationRemoteDatasource _fertilizationDs;
  final LaborRemoteDatasource _laborDs;
  final CropImagesRemoteDatasource _imagesDs;

  CropDetailCubit({
    required IrrigationRemoteDatasource irrigationDs,
    required FertilizationRemoteDatasource fertilizationDs,
    required LaborRemoteDatasource laborDs,
    required CropImagesRemoteDatasource imagesDs,
  })  : _irrigationDs = irrigationDs,
        _fertilizationDs = fertilizationDs,
        _laborDs = laborDs,
        _imagesDs = imagesDs,
        super(const CropDetailState());

  // Irrigation
  Future<void> loadIrrigations(String cropId) async {
    emit(state.copyWith(isLoadingIrrigation: true));
    try {
      final data = await _irrigationDs.getIrrigations(cropId);
      emit(state.copyWith(
        irrigations: data.map((e) => IrrigationModel.fromJson(e)).toList(),
        isLoadingIrrigation: false,
      ));
    } catch (e) {
      emit(state.copyWith(
          isLoadingIrrigation: false, error: 'Error al cargar riegos'));
    }
  }

  Future<void> createIrrigation(
      String cropId, Map<String, dynamic> data) async {
    try {
      await _irrigationDs.createIrrigation(cropId, data);
      await loadIrrigations(cropId);
    } catch (e) {
      print('ERROR RIEGO: $e');
      emit(state.copyWith(error: 'Error al registrar riego'));
    }
  }

  Future<void> deleteIrrigation(String cropId, String id) async {
    try {
      await _irrigationDs.deleteIrrigation(cropId, id);
      await loadIrrigations(cropId);
    } catch (e) {
      emit(state.copyWith(error: 'Error al eliminar riego'));
    }
  }

  // Fertilization
  Future<void> loadFertilizations(String cropId) async {
    emit(state.copyWith(isLoadingFertilization: true));
    try {
      final data = await _fertilizationDs.getFertilizations(cropId);
      emit(state.copyWith(
        fertilizations:
            data.map((e) => FertilizationModel.fromJson(e)).toList(),
        isLoadingFertilization: false,
      ));
    } catch (e) {
      emit(state.copyWith(
          isLoadingFertilization: false,
          error: 'Error al cargar fertilizaciones'));
    }
  }

  Future<void> createFertilization(
      String cropId, Map<String, dynamic> data) async {
    try {
      await _fertilizationDs.createFertilization(cropId, data);
      await loadFertilizations(cropId);
    } catch (e) {
      print('ERROR FERTILIZACION: $e');
      emit(state.copyWith(error: 'Error al registrar fertilización'));
    }
  }

  Future<void> deleteFertilization(String cropId, String id) async {
    try {
      await _fertilizationDs.deleteFertilization(cropId, id);
      await loadFertilizations(cropId);
    } catch (e) {
      emit(state.copyWith(error: 'Error al eliminar fertilización'));
    }
  }

  // Labor
  Future<void> loadLabors(String cropId) async {
    emit(state.copyWith(isLoadingLabor: true));
    try {
      final data = await _laborDs.getLabors(cropId);
      emit(state.copyWith(
        labors: data.map((e) => LaborModel.fromJson(e)).toList(),
        isLoadingLabor: false,
      ));
    } catch (e) {
      emit(state.copyWith(
          isLoadingLabor: false, error: 'Error al cargar labores'));
    }
  }

  Future<void> createLabor(String cropId, Map<String, dynamic> data) async {
    try {
      await _laborDs.createLabor(cropId, data);
      await loadLabors(cropId);
    } catch (e) {
      print('ERROR LABOR: $e');
      emit(state.copyWith(error: 'Error al registrar labor'));
    }
  }

  Future<void> deleteLabor(String cropId, String id) async {
    try {
      await _laborDs.deleteLabor(cropId, id);
      await loadLabors(cropId);
    } catch (e) {
      emit(state.copyWith(error: 'Error al eliminar labor'));
    }
  }

  // Images
  Future<void> loadImages(String cropId) async {
    emit(state.copyWith(isLoadingImages: true));
    try {
      final data = await _imagesDs.getImages(cropId);
      emit(state.copyWith(
        images: data.map((e) => CropImageModel.fromJson(e)).toList(),
        isLoadingImages: false,
      ));
    } catch (e) {
      emit(state.copyWith(
          isLoadingImages: false, error: 'Error al cargar imágenes'));
    }
  }

  Future<void> uploadImage(
      String cropId, String filePath, String category) async {
    try {
      await _imagesDs.uploadImage(cropId, filePath, category);
      await loadImages(cropId);
    } catch (e) {
      if (e is DioException) {
        print('ERROR IMAGEN RESPONSE: ${e.response?.data}');
        print('ERROR IMAGEN STATUS: ${e.response?.statusCode}');
      }
      print('ERROR IMAGEN: $e');
      emit(state.copyWith(error: 'Error al subir imagen'));
    }
  }

  Future<void> deleteImage(String cropId, String id) async {
    try {
      await _imagesDs.deleteImage(cropId, id);
      await loadImages(cropId);
    } catch (e) {
      emit(state.copyWith(error: 'Error al eliminar imagen'));
    }
  }
}
