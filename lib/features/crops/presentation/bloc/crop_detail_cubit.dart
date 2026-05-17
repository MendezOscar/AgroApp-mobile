import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../crop_images/data/datasources/crop_images_remote_datasource.dart';
import '../../../crop_images/data/models/crop_image_model.dart';
import '../../../crop_images/data/repositories/crop_images_local_repository.dart';
import '../../../crop_images/domain/entities/crop_image_entity.dart';
import '../../../fertilization/data/datasources/fertilization_remote_datasource.dart';
import '../../../fertilization/data/models/fertilization_model.dart';
import '../../../fertilization/data/repositories/fertilization_local_repository.dart';
import '../../../irrigation/data/datasources/irrigation_remote_datasource.dart';
import '../../../irrigation/data/models/irrigation_model.dart';
import '../../../irrigation/data/repositories/irrigation_local_repository.dart';
import '../../../labor/data/datasources/labor_remote_datasource.dart';
import '../../../labor/data/models/labor_model.dart';
import '../../../labor/data/repositories/labor_local_repository.dart';
import '../../data/models/ai_diagnosis_model.dart';
import 'crop_detail_state.dart';

class CropDetailCubit extends SafeCubit<CropDetailState> {
  final IrrigationRemoteDatasource _irrigationDs;
  final FertilizationRemoteDatasource _fertilizationDs;
  final LaborRemoteDatasource _laborDs;
  final CropImagesRemoteDatasource _imagesDs;
  final IrrigationLocalRepository _irrigationLocal;
  final FertilizationLocalRepository _fertilizationLocal;
  final LaborLocalRepository _laborLocal;
  final CropImagesLocalRepository _imagesLocal;

  CropDetailCubit({
    required IrrigationRemoteDatasource irrigationDs,
    required FertilizationRemoteDatasource fertilizationDs,
    required LaborRemoteDatasource laborDs,
    required CropImagesRemoteDatasource imagesDs,
    required IrrigationLocalRepository irrigationLocal,
    required FertilizationLocalRepository fertilizationLocal,
    required LaborLocalRepository laborLocal,
    required CropImagesLocalRepository imagesLocal,
  })  : _irrigationDs = irrigationDs,
        _fertilizationDs = fertilizationDs,
        _laborDs = laborDs,
        _imagesDs = imagesDs,
        _irrigationLocal = irrigationLocal,
        _fertilizationLocal = fertilizationLocal,
        _laborLocal = laborLocal,
        _imagesLocal = imagesLocal,
        super(const CropDetailState());

  // ─── Irrigation ───────────────────────────────────────────

  Future<void> loadIrrigations(String cropId) async {
    emit(state.copyWith(isLoadingIrrigation: true, error: null));
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        final data = await _irrigationDs.getIrrigations(cropId);
        final items = data.map((e) => IrrigationModel.fromJson(e)).toList();
        await _irrigationLocal.saveIrrigations(cropId, items);
        emit(state.copyWith(
            irrigations: items, isLoadingIrrigation: false, isOffline: false));
      } else {
        final items = await _irrigationLocal.getIrrigations(cropId);
        emit(state.copyWith(
            irrigations: items, isLoadingIrrigation: false, isOffline: true));
      }
    } catch (e) {
      try {
        final items = await _irrigationLocal.getIrrigations(cropId);
        emit(state.copyWith(
            irrigations: items, isLoadingIrrigation: false, isOffline: true));
      } catch (_) {
        emit(state.copyWith(
            isLoadingIrrigation: false, error: 'Error al cargar riegos'));
      }
    }
  }

  Future<void> createIrrigation(
      String cropId, Map<String, dynamic> data) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        await _irrigationDs.createIrrigation(cropId, data);
      } else {
        // Guardar en pending_sync para sincronizar después
        await _irrigationLocal.savePending(cropId, data);

        // También guardar localmente para mostrar inmediatamente
        await _irrigationLocal.saveIrrigations(cropId, [
          IrrigationModel(
            id: 'local_${DateTime.now().millisecondsSinceEpoch}',
            cropId: cropId,
            method: data['method'] ?? '',
            volumeLiters: (data['volumeLiters'] as num?)?.toDouble(),
            durationMin: data['durationMin'] as int?,
            appliedAt:
                DateTime.tryParse(data['appliedAt'] ?? '') ?? DateTime.now(),
            notes: data['notes'],
            createdAt: DateTime.now(),
          ),
          ...await _irrigationLocal.getIrrigations(cropId),
        ]);
      }
      await loadIrrigations(cropId);
    } catch (e) {
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

  // ─── Fertilization ────────────────────────────────────────

  Future<void> loadFertilizations(String cropId) async {
    emit(state.copyWith(isLoadingFertilization: true, error: null));
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        final data = await _fertilizationDs.getFertilizations(cropId);
        final items = data.map((e) => FertilizationModel.fromJson(e)).toList();
        await _fertilizationLocal.saveFertilizations(cropId, items);
        emit(state.copyWith(
            fertilizations: items,
            isLoadingFertilization: false,
            isOffline: false));
      } else {
        final items = await _fertilizationLocal.getFertilizations(cropId);
        emit(state.copyWith(
            fertilizations: items,
            isLoadingFertilization: false,
            isOffline: true));
      }
    } catch (e) {
      try {
        final items = await _fertilizationLocal.getFertilizations(cropId);
        emit(state.copyWith(
            fertilizations: items,
            isLoadingFertilization: false,
            isOffline: true));
      } catch (_) {
        emit(state.copyWith(
            isLoadingFertilization: false,
            error: 'Error al cargar fertilizaciones'));
      }
    }
  }

  Future<void> createFertilization(
      String cropId, Map<String, dynamic> data) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        await _fertilizationDs.createFertilization(cropId, data);
      } else {
        await _fertilizationLocal.savePending(cropId, data);

        await _fertilizationLocal.saveFertilizations(cropId, [
          FertilizationModel(
            id: 'local_${DateTime.now().millisecondsSinceEpoch}',
            cropId: cropId,
            productName: data['productName'] ?? '',
            productType: data['productType'],
            doseKgHa: (data['doseKgHa'] as num?)?.toDouble(),
            totalKg: (data['totalKg'] as num?)?.toDouble(),
            method: data['method'],
            cost: (data['cost'] as num?)?.toDouble(),
            appliedAt:
                DateTime.tryParse(data['appliedAt'] ?? '') ?? DateTime.now(),
            nextApplication: DateTime.tryParse(data['nextApplication'] ?? ''),
            notes: data['notes'],
            createdAt: DateTime.now(),
          ),
          ...await _fertilizationLocal.getFertilizations(cropId),
        ]);
      }
      await loadFertilizations(cropId);
    } catch (e) {
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

  // ─── Labor ────────────────────────────────────────────────

  Future<void> loadLabors(String cropId) async {
    emit(state.copyWith(isLoadingLabor: true, error: null));
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        final data = await _laborDs.getLabors(cropId);
        final items = data.map((e) => LaborModel.fromJson(e)).toList();
        await _laborLocal.saveLabors(cropId, items);
        emit(state.copyWith(
            labors: items, isLoadingLabor: false, isOffline: false));
      } else {
        final items = await _laborLocal.getLabors(cropId);
        emit(state.copyWith(
            labors: items, isLoadingLabor: false, isOffline: true));
      }
    } catch (e) {
      try {
        final items = await _laborLocal.getLabors(cropId);
        emit(state.copyWith(
            labors: items, isLoadingLabor: false, isOffline: true));
      } catch (_) {
        emit(state.copyWith(
            isLoadingLabor: false, error: 'Error al cargar labores'));
      }
    }
  }

  Future<void> createLabor(String cropId, Map<String, dynamic> data) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        await _laborDs.createLabor(cropId, data);
      } else {
        await _laborLocal.savePending(cropId, data);

        await _laborLocal.saveLabors(cropId, [
          LaborModel(
            id: 'local_${DateTime.now().millisecondsSinceEpoch}',
            cropId: cropId,
            activityType: data['activityType'] ?? '',
            hoursWorked: (data['hoursWorked'] as num?)?.toDouble(),
            workersCount: data['workersCount'] as int? ?? 1,
            cost: (data['cost'] as num?)?.toDouble(),
            performedAt:
                DateTime.tryParse(data['performedAt'] ?? '') ?? DateTime.now(),
            notes: data['notes'],
            createdAt: DateTime.now(),
          ),
          ...await _laborLocal.getLabors(cropId),
        ]);
      }
      await loadLabors(cropId);
    } catch (e) {
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

  // ─── Images (solo online) ─────────────────────────────────

  Future<void> loadImages(String cropId) async {
    emit(state.copyWith(isLoadingImages: true, error: null));
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        final data = await _imagesDs.getImages(cropId);
        emit(state.copyWith(
          images: data.map((e) => CropImageModel.fromJson(e)).toList(),
          isLoadingImages: false,
          isOffline: false,
        ));
      } else {
        await _loadImagesOffline(cropId);
      }
    } catch (e) {
      await _loadImagesOffline(cropId);
    }
  }

  Future<void> uploadImage(
      String cropId, String filePath, String category) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        await _imagesDs.uploadImage(cropId, filePath, category);
        await loadImages(cropId);
      } else {
        // Guardar localmente para subir después
        await _imagesLocal.savePendingImage(
          cropId: cropId,
          filePath: filePath,
          category: category,
        );
        // Mostrar imágenes pendientes offline
        await _loadImagesOffline(cropId);
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error al guardar imagen'));
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

  Future<void> analyzeImage(String cropId, String imageId) async {
    emit(state.copyWith(isAnalyzing: true, error: null));
    try {
      final result = await _imagesDs.analyzeImage(cropId, imageId);
      await loadImages(cropId); // recargar para mostrar badge "Analizada"
      emit(state.copyWith(
        isAnalyzing: false,
        aiDiagnosis: AiDiagnosisModel.fromJson(result),
      ));
    } catch (e) {
      emit(state.copyWith(
          isAnalyzing: false, error: 'Error al analizar imagen'));
    }
  }

  Future<void> _loadImagesOffline(String cropId) async {
    // Cargar imágenes pendientes locales
    final pending = await _imagesLocal.getPendingImages(cropId);
    final localImages = pending
        .map((p) => CropImageEntity(
              id: p['id'] as String,
              cropId: cropId,
              url: p['file_path'] as String, // path local
              storageKey: p['file_path'] as String,
              category: p['category'] as String,
              takenAt: DateTime.tryParse(p['taken_at'] as String),
              createdAt: DateTime.tryParse(p['created_at'] as String) ??
                  DateTime.now(),
              isPending: true, // flag para mostrar indicador
            ))
        .toList();

    emit(state.copyWith(
      images: localImages,
      isLoadingImages: false,
      isOffline: true,
    ));
  }
}
