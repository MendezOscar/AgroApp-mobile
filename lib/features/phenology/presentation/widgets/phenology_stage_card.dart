import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/phenology_stage_entity.dart';

class PhenologyStageCard extends StatelessWidget {
  final PhenologyStageEntity stage;
  final VoidCallback onTap;

  const PhenologyStageCard({
    super.key,
    required this.stage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: stage.isActive
            ? const BorderSide(color: AppTheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Ícono
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: stage.isActive
                      ? AppTheme.primary.withValues(alpha: 0.12)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    stage.icon ?? '🌱',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          stage.stageName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: stage.isActive
                                ? Colors.black87
                                : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (stage.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Activa',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (stage.isCustom)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Personalizada',
                              style: TextStyle(
                                  color: Colors.purple,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Inicio: ${fmt.format(stage.startedAt)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    if (stage.endedAt != null)
                      Text(
                        'Fin: ${fmt.format(stage.endedAt!)}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    if (stage.observations != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          stage.observations!,
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                              fontStyle: FontStyle.italic),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),

              // Días
              Column(
                children: [
                  Text(
                    '${stage.daysInStage}',
                    style: TextStyle(
                      color:
                          stage.isActive ? AppTheme.primary : Colors.grey[500],
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'días',
                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
