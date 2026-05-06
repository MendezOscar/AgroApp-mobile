import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/farm_entity.dart';

class FarmCard extends StatelessWidget {
  final FarmEntity farm;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const FarmCard({
    super.key,
    required this.farm,
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
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.landscape, color: AppTheme.primary),
        ),
        title: Text(farm.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (farm.region != null || farm.country != null)
              Text('${farm.region ?? ''} ${farm.country ?? ''}'.trim(),
                  style: TextStyle(color: Colors.grey[600])),
            if (farm.areaHa != null)
              Text('${farm.areaHa!.toStringAsFixed(1)} ha',
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
