import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/alerts_remote_datasource.dart';
import '../../data/models/alert_model.dart';
import 'alerts_state.dart';

class AlertsCubit extends Cubit<AlertsState> {
  final AlertsRemoteDatasource _datasource;

  AlertsCubit(this._datasource) : super(const AlertsState());

  Future<void> loadAlerts({bool onlyUnread = false}) async {
    emit(state.copyWith(isLoading: true));
    try {
      final data = await _datasource.getAlerts(onlyUnread: onlyUnread);
      final count = await _datasource.getUnreadCount();
      emit(state.copyWith(
        alerts: data.map((e) => AlertModel.fromJson(e)).toList(),
        unreadCount: count,
        isLoading: false,
      ));
    } catch (e) {
      if (e is DioException) {
        print('ERROR ALERTAS STATUS: ${e.response?.statusCode}');
        print('ERROR ALERTAS RESPONSE: ${e.response?.data}');
      }
      print('ERROR ALERTAS: $e');
      emit(state.copyWith(isLoading: false, error: 'Error al cargar alertas'));
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _datasource.markAsRead(id);
      await loadAlerts();
    } catch (e) {
      emit(state.copyWith(error: 'Error al marcar alerta'));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final unread = state.alerts.where((a) => !a.isRead).toList();
      for (final alert in unread) {
        await _datasource.markAsRead(alert.id);
      }
      await loadAlerts();
    } catch (e) {
      emit(state.copyWith(error: 'Error al marcar alertas'));
    }
  }
}
