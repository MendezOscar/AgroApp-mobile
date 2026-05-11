import 'package:equatable/equatable.dart';
import '../../domain/entities/alert_entity.dart';

class AlertsState extends Equatable {
  final List<AlertEntity> alerts;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  const AlertsState({
    this.alerts = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  AlertsState copyWith({
    List<AlertEntity>? alerts,
    int? unreadCount,
    bool? isLoading,
    String? error,
  }) =>
      AlertsState(
        alerts: alerts ?? this.alerts,
        unreadCount: unreadCount ?? this.unreadCount,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [alerts, unreadCount, isLoading, error];
}
