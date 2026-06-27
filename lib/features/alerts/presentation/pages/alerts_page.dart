import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../core/widgets/paginated_list.dart';
import '../../domain/entities/alert_entity.dart';
import '../bloc/alerts_cubit.dart';
import '../bloc/alerts_state.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  late final AlertsCubit _cubit;
  bool _onlyUnread = false;

  @override
  void initState() {
    super.initState();
    _cubit = sl<AlertsCubit>()..loadAlerts();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.error;
      case 'warning':
        return Icons.warning_amber;
      default:
        return Icons.info_outline;
    }
  }

  String _severityLabel(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return 'Crítica';
      case 'warning':
        return 'Advertencia';
      default:
        return 'Info';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: BlocBuilder<AlertsCubit, AlertsState>(
            builder: (context, state) => Row(
              children: [
                const Text('Alertas'),
                if (state.unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${state.unreadCount}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            BlocBuilder<AlertsCubit, AlertsState>(
              builder: (context, state) {
                if (state.unreadCount == 0 || state.isOffline) {
                  return const SizedBox();
                }
                return TextButton.icon(
                  icon: const Icon(Icons.done_all, color: Colors.white),
                  label: const Text('Leer todas',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () => _cubit.markAllAsRead(),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<AlertsCubit, AlertsState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.orange.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) return const LoadingWidget();

            return Column(
              children: [
                // Banner offline
                if (state.isOffline) const OfflineBanner(),

                // Filtro
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Solo no leídas'),
                        selected: _onlyUnread,
                        onSelected: (v) {
                          setState(() => _onlyUnread = v);
                          _cubit.loadAlerts(onlyUnread: v);
                        },
                        selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${state.alerts.length} alertas',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      if (state.isOffline) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'desde caché',
                            style: TextStyle(
                                color: Colors.orange,
                                fontSize: 11,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Lista
                Expanded(
                  child: PaginatedList<AlertEntity>(
                    items: state.alerts,
                    hasNextPage: state.hasNextPage,
                    isLoadingMore: state.isLoadingMore,
                    onLoadMore: () => _cubit.loadMoreAlerts(),
                    onRefresh: () => _cubit.loadAlerts(onlyUnread: _onlyUnread),
                    emptyWidget: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none,
                              size: 72, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            _onlyUnread
                                ? 'No hay alertas sin leer'
                                : state.isOffline
                                    ? 'No hay alertas guardadas localmente'
                                    : 'No hay alertas',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    itemBuilder: (_, alert, __) => _AlertCard(
                      alert: alert,
                      isOffline: state.isOffline,
                      onMarkRead: () => _cubit.markAsRead(alert.id),
                      severityColor: _severityColor(alert.severity),
                      severityIcon: _severityIcon(alert.severity),
                      severityLabel: _severityLabel(alert.severity),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AlertEntity alert;
  final bool isOffline;
  final VoidCallback onMarkRead;
  final Color severityColor;
  final IconData severityIcon;
  final String severityLabel;

  const _AlertCard({
    required this.alert,
    required this.isOffline,
    required this.onMarkRead,
    required this.severityColor,
    required this.severityIcon,
    required this.severityLabel,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: alert.isRead ? null : severityColor.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: alert.isRead
            ? BorderSide.none
            : BorderSide(color: severityColor.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: severityColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(severityIcon, color: severityColor),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                alert.alertType.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: alert.isRead ? Colors.grey[700] : Colors.black87,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                severityLabel,
                style: TextStyle(
                    color: severityColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              alert.message,
              style: TextStyle(
                  color: alert.isRead ? Colors.grey[500] : Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              fmt.format(alert.triggeredAt),
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          ],
        ),
        trailing: alert.isRead
            ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
            : isOffline
                ? Icon(Icons.wifi_off, color: Colors.grey[400], size: 20)
                : IconButton(
                    icon: const Icon(Icons.mark_email_read_outlined),
                    color: severityColor,
                    onPressed: onMarkRead,
                    tooltip: 'Marcar como leída',
                  ),
      ),
    );
  }
}
