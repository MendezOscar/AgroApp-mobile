import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/bloc/safe_cubit.dart';
import '../../data/datasources/phenology_remote_datasource.dart';
import '../../data/models/phenology_stage_model.dart';
import '../../data/models/phenology_template_model.dart';
import 'phenology_state.dart';

class PhenologyCubit extends SafeCubit<PhenologyState> {
  final PhenologyRemoteDatasource _datasource;

  PhenologyCubit(this._datasource) : super(const PhenologyState());

  Future<void> loadStages(String cropId) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final data = await _datasource.getStages(cropId);
      emit(state.copyWith(
        stages: data.map((e) => PhenologyStageModel.fromJson(e)).toList(),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, error: 'Error al cargar etapas fenológicas'));
    }
  }

  Future<void> loadTemplates(String cropType) async {
    try {
      final data = await _datasource.getTemplates(cropType);
      emit(state.copyWith(
        templates: data.map((e) => PhenologyTemplateModel.fromJson(e)).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Error al cargar plantillas'));
    }
  }

  Future<void> createStage(String cropId, Map<String, dynamic> data) async {
    try {
      await _datasource.createStage(cropId, data);
      await loadStages(cropId);
      emit(state.copyWith(success: 'Etapa registrada correctamente'));
    } catch (e) {
      emit(state.copyWith(error: 'Error al registrar etapa'));
    }
  }

  Future<void> updateStage(
      String cropId, String stageId, Map<String, dynamic> data) async {
    try {
      await _datasource.updateStage(cropId, stageId, data);
      await loadStages(cropId);
      emit(state.copyWith(success: 'Etapa actualizada'));
    } catch (e) {
      emit(state.copyWith(error: 'Error al actualizar etapa'));
    }
  }
}
