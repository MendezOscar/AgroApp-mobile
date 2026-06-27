import '../../../../core/bloc/safe_cubit.dart';
import '../../data/datasources/crops_remote_datasource.dart';
import '../../data/models/crop_prediction_model.dart';
import '../../domain/entities/crop_prediction_entity.dart';

class CropPredictionState {
  final bool isLoading;
  final CropPredictionEntity? prediction;
  final String? error;

  const CropPredictionState({
    this.isLoading = false,
    this.prediction,
    this.error,
  });

  CropPredictionState copyWith({
    bool? isLoading,
    CropPredictionEntity? prediction,
    String? error,
  }) =>
      CropPredictionState(
        isLoading: isLoading ?? this.isLoading,
        prediction: prediction ?? this.prediction,
        error: error,
      );
}

class CropPredictionCubit extends SafeCubit<CropPredictionState> {
  final CropsRemoteDatasource _cropsDs;

  CropPredictionCubit(this._cropsDs) : super(const CropPredictionState());

  Future<void> loadPrediction(String plotId, String cropId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final data = await _cropsDs.getCropPrediction(plotId, cropId);
      emit(state.copyWith(
        isLoading: false,
        prediction: CropPredictionModel.fromJson(data),
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error al cargar la predicción de cosecha.',
      ));
    }
  }
}
