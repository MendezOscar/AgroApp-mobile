import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/plot_entity.dart';

class PlotCard extends StatelessWidget {
  final PlotEntity plot;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PlotCard({
    super.key,
    required this.plot,
    required this.onTap,
    required this.onDelete,
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
        title: Text(plot.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (plot.soilType != null)
              Text('Suelo: ${plot.soilType}',
                  style: TextStyle(color: Colors.grey[600])),
            if (plot.areaHa != null)
              Text('${plot.areaHa!.toStringAsFixed(1)} ha',
                  style: const TextStyle(
                      color: AppTheme.primary, fontWeight: FontWeight.w500)),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
          onSelected: (value) {
            if (value == 'delete') onDelete();
          },
        ),
        onTap: onTap,
      ),
    );
  }
}
