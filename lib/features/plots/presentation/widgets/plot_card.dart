import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/role_helper.dart';
import '../../../../core/widgets/role_guard.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/plot_entity.dart';

class PlotCard extends StatelessWidget {
  final PlotEntity plot;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onSensorsTap;
  final VoidCallback onSetLocation;

  const PlotCard({
    super.key,
    required this.plot,
    required this.onTap,
    required this.onDelete,
    required this.onSensorsTap,
    required this.onSetLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.secondary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.grid_view, color: AppTheme.primary),
        ),
        title: Text(
          plot.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (plot.soilType != null)
              Text(
                'Suelo: ${plot.soilType}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            if (plot.areaHa != null)
              Text(
                '${plot.areaHa!.toStringAsFixed(1)} ha',
                style: const TextStyle(
                    color: AppTheme.primary, fontWeight: FontWeight.w500),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón sensores
            RoleGuard(
              permission: RoleHelper.canManageSensors,
              child: IconButton(
                icon: const Icon(Icons.sensors, color: AppTheme.primary),
                onPressed: onSensorsTap,
                tooltip: 'Ver sensores',
              ),
            ),
            // Menú opciones (editar ubicación/eliminar requieren rol Admin/Manager,
            // igual que el backend)
            Builder(builder: (context) {
              final authState = context.watch<AuthBloc>().state;
              final canEdit = authState is AuthAuthenticated &&
                  RoleHelper.canCreatePlot(authState.user.role);
              if (!canEdit) return const SizedBox();

              return PopupMenuButton(
                itemBuilder: (_) => [
                  PopupMenuItem(
                      value: 'location',
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text(plot.geoJson == null
                              ? 'Dibujar parcela en mapa'
                              : 'Editar área'),
                        ],
                      )),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar'),
                        ],
                      )),
                ],
                onSelected: (value) {
                  if (value == 'delete') onDelete();
                  if (value == 'location') onSetLocation();
                },
              );
            }),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
