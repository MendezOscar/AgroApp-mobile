import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/datasources/phenology_remote_datasource.dart';

/// Muestra la recomendación de la etapa fenológica activa del cultivo,
/// si existe, en el punto donde se toma la decisión (registrar una
/// actividad) en vez de dejarla enterrada solo en la pestaña Fenología.
class PhenologyRecommendationBanner extends StatefulWidget {
  final String cropId;

  const PhenologyRecommendationBanner({super.key, required this.cropId});

  @override
  State<PhenologyRecommendationBanner> createState() =>
      _PhenologyRecommendationBannerState();
}

class _PhenologyRecommendationBannerState
    extends State<PhenologyRecommendationBanner> {
  String? _stageName;
  String? _recommendation;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final stages =
          await sl<PhenologyRemoteDatasource>().getStages(widget.cropId);
      final active = stages.cast<Map<String, dynamic>>().firstWhere(
            (s) => s['endedAt'] == null,
            orElse: () => const {},
          );
      final recommendation = active['recommendations'] as String?;
      if (mounted && recommendation != null && recommendation.isNotEmpty) {
        setState(() {
          _stageName = active['stageName'] as String?;
          _recommendation = recommendation;
        });
      }
    } catch (_) {
      // Silencioso: esto es solo una ayuda informativa, no bloquea el registro.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_recommendation == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: AppTheme.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_stageName != null)
                  Text(
                    'Etapa: $_stageName',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppTheme.primary),
                  ),
                const SizedBox(height: 2),
                Text(
                  _recommendation!,
                  style: const TextStyle(fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
