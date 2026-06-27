import '../../../../core/bloc/safe_cubit.dart';
import '../../data/datasources/crops_remote_datasource.dart';
import '../../data/models/crop_comparison_model.dart';
import '../../domain/entities/crop_comparison_entity.dart';

class CropComparisonState {
  final bool isLoading;
  final List<CropComparisonEntity> crops;
  final String? error;

  const CropComparisonState({
    this.isLoading = false,
    this.crops = const [],
    this.error,
  });

  CropComparisonState copyWith({
    bool? isLoading,
    List<CropComparisonEntity>? crops,
    String? error,
  }) =>
      CropComparisonState(
        isLoading: isLoading ?? this.isLoading,
        crops: crops ?? this.crops,
        error: error,
      );
}

class CropComparisonCubit extends SafeCubit<CropComparisonState> {
  final CropsRemoteDatasource _cropsDs;

  CropComparisonCubit(this._cropsDs) : super(const CropComparisonState());

  Future<void> loadComparison(String farmId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final data = await _cropsDs.getCropComparison(farmId);
      final crops = data.map((c) => CropComparisonModel.fromJson(c)).toList();
      emit(state.copyWith(isLoading: false, crops: crops));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error al cargar la comparativa de cultivos.',
      ));
    }
  }
}
