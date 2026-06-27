import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/models/paged_result.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../data/datasources/alerts_remote_datasource.dart';
import '../../data/models/alert_model.dart';
import '../../data/repositories/alerts_local_repository.dart';
import 'alerts_state.dart';

class AlertsCubit extends SafeCubit<AlertsState> {
  final AlertsRemoteDatasource _datasource;
  final AlertsLocalRepository _localRepository;
  bool _onlyUnread = false;

  AlertsCubit(this._datasource, this._localRepository)
      : super(const AlertsState());

  Future<void> loadAlerts({bool onlyUnread = false}) async {
    _onlyUnread = onlyUnread;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        final raw = await _datasource.getAlerts(onlyUnread: onlyUnread, page: 1);
        final paged = PagedResult.fromJson(raw, AlertModel.fromJson);
        final count = await _datasource.getUnreadCount();
        await _localRepository.saveAlerts(paged.items);
        emit(state.copyWith(
          alerts: paged.items,
          unreadCount: count,
          isLoading: false,
          isOffline: false,
          page: paged.page,
          hasNextPage: paged.hasNextPage,
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
          page: 1,
          hasNextPage: false,
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
          page: 1,
          hasNextPage: false,
        ));
      } catch (_) {
        emit(state.copyWith(
            isLoading: false, error: 'No se pudieron cargar las alertas'));
      }
    }
  }

  Future<void> loadMoreAlerts() async {
    if (!state.hasNextPage || state.isLoadingMore || state.isOffline) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final nextPage = state.page + 1;
      final raw = await _datasource.getAlerts(
          onlyUnread: _onlyUnread, page: nextPage);
      final paged = PagedResult.fromJson(raw, AlertModel.fromJson);
      emit(state.copyWith(
        alerts: [...state.alerts, ...paged.items],
        isLoadingMore: false,
        page: paged.page,
        hasNextPage: paged.hasNextPage,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false));
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
