import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../data/datasources/alerts_remote_datasource.dart';
import '../../data/models/alert_model.dart';
import '../../data/repositories/alerts_local_repository.dart';
import 'alerts_state.dart';

class AlertsCubit extends SafeCubit<AlertsState> {
  final AlertsRemoteDatasource _datasource;
  final AlertsLocalRepository _localRepository;

  AlertsCubit(this._datasource, this._localRepository)
      : super(const AlertsState());

  Future<void> loadAlerts({bool onlyUnread = false}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        final data = await _datasource.getAlerts(onlyUnread: onlyUnread);
        final alerts = data.map((e) => AlertModel.fromJson(e)).toList();
        final count = await _datasource.getUnreadCount();
        await _localRepository.saveAlerts(alerts);
        emit(state.copyWith(
          alerts: alerts,
          unreadCount: count,
          isLoading: false,
          isOffline: false,
        ));
      } else {
        // Cargar desde cache local
        final alerts = await _localRepository.getAlerts();
        final unread = alerts.where((a) => !a.isRead).length;
        emit(state.copyWith(
          alerts: onlyUnread ? alerts.where((a) => !a.isRead).toList() : alerts,
          unreadCount: unread,
          isLoading: false,
          isOffline: true,
        ));
      }
    } catch (e) {
      // Intentar desde cache local
      try {
        final alerts = await _localRepository.getAlerts();
        final unread = alerts.where((a) => !a.isRead).length;
        emit(state.copyWith(
          alerts: alerts,
          unreadCount: unread,
          isLoading: false,
          isOffline: true,
        ));
      } catch (_) {
        emit(state.copyWith(
            isLoading: false, error: 'No se pudieron cargar las alertas'));
      }
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        await _datasource.markAsRead(id);
        await loadAlerts();
      } else {
        emit(state.copyWith(
            error: 'Sin conexión. Intenta cuando tengas internet.'));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error al marcar alerta'));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        final unread = state.alerts.where((a) => !a.isRead).toList();
        for (final alert in unread) {
          await _datasource.markAsRead(alert.id);
        }
        await loadAlerts();
      } else {
        emit(state.copyWith(
            error: 'Sin conexión. Intenta cuando tengas internet.'));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error al marcar alertas'));
    }
  }
}
