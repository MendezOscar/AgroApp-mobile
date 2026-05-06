import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/crop_entity.dart';

class CropCard extends StatelessWidget {
  final CropEntity crop;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CropCard({
    super.key,
    required this.crop,
    required this.onTap,
    required this.onDelete,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppTheme.primary;
      case 'harvested':
        return Colors.amber;
      case 'lost':
        return AppTheme.error;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Activo';
      case 'harvested':
        return 'Cosechado';
      case 'lost':
        return 'Perdido';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.grass, color: AppTheme.accent),
        ),
        title: Text(
          '${crop.cropType}${crop.variety != null ? ' — ${crop.variety}' : ''}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sembrado: ${fmt.format(crop.plantedAt)}',
                style: TextStyle(color: Colors.grey[600])),
            if (crop.estimatedHarvest != null)
              Text('Cosecha est.: ${fmt.format(crop.estimatedHarvest!)}',
                  style: TextStyle(color: Colors.grey[600])),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _statusColor(crop.status).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusLabel(crop.status),
                style: TextStyle(
                  color: _statusColor(crop.status),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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
