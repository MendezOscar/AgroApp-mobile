import 'package:equatable/equatable.dart';

import '../../domain/entities/alert_entity.dart';

class AlertsState extends Equatable {
  final List<AlertEntity> alerts;
  final int unreadCount;
  final bool isLoading;
  final bool isOffline;
  final String? error;
  final int page;
  final bool hasNextPage;
  final bool isLoadingMore;

  const AlertsState({
    this.alerts = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.isOffline = false,
    this.error,
    this.page = 1,
    this.hasNextPage = false,
    this.isLoadingMore = false,
  });

  AlertsState copyWith({
    List<AlertEntity>? alerts,
    int? unreadCount,
    bool? isLoading,
    bool? isOffline,
    String? error,
    int? page,
    bool? hasNextPage,
    bool? isLoadingMore,
  }) =>
      AlertsState(
        alerts: alerts ?? this.alerts,
        unreadCount: unreadCount ?? this.unreadCount,
        isLoading: isLoading ?? this.isLoading,
        isOffline: isOffline ?? this.isOffline,
        error: error,
        page: page ?? this.page,
        hasNextPage: hasNextPage ?? this.hasNextPage,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  @override
  List<Object?> get props => [
        alerts,
        unreadCount,
        isLoading,
        isOffline,
        error,
        page,
        hasNextPage,
        isLoadingMore,
      ];
}
