import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/phenology_stage_entity.dart';

class PhenologyTimeline extends StatelessWidget {
  final List<PhenologyStageEntity> stages;
  final Function(PhenologyStageEntity) onStageTap;

  const PhenologyTimeline({
    super.key,
    required this.stages,
    required this.onStageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (stages.isEmpty) return const SizedBox();

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stages.length,
        itemBuilder: (_, i) {
          final stage = stages[i];
          final isFirst = i == 0;
          final isLast = i == stages.length - 1;

          return GestureDetector(
            onTap: () => onStageTap(stage),
            child: Row(
              children: [
                // Línea izquierda
                if (!isFirst)
                  Container(
                    width: 30,
                    height: 3,
                    color: stage.isActive || !stage.isActive
                        ? AppTheme.primary.withValues(alpha: 0.4)
                        : Colors.grey[300],
                  ),

                // Nodo de etapa
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Círculo con ícono
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: stage.isActive
                            ? AppTheme.primary
                            : stage.endedAt != null
                                ? AppTheme.primary.withValues(alpha: 0.3)
                                : Colors.grey[200],
                        border: stage.isActive
                            ? Border.all(color: AppTheme.primary, width: 3)
                            : null,
                        boxShadow: stage.isActive
                            ? [
                                BoxShadow(
                                  color:
                                      AppTheme.primary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          stage.icon ?? '🌱',
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Nombre de etapa
                    SizedBox(
                      width: 70,
                      child: Text(
                        stage.stageName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: stage.isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: stage.isActive
                              ? AppTheme.primary
                              : Colors.grey[600],
                        ),
                      ),
                    ),

                    // Días en la etapa
                    if (stage.isActive)
                      Text(
                        'Día ${stage.daysInStage}',
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),

                // Línea derecha
                if (!isLast)
                  Container(
                    width: 30,
                    height: 3,
                    color: AppTheme.primary.withValues(alpha: 0.4),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
