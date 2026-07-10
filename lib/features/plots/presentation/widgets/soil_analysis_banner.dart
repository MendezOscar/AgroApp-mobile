import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../data/datasources/soil_analysis_remote_datasource.dart';

/// Muestra el último análisis de suelo de la parcela (pH y % materia
/// orgánica), si existe, en el punto donde se decide la dosis de
/// fertilización.
class SoilAnalysisBanner extends StatefulWidget {
  final String plotId;

  const SoilAnalysisBanner({super.key, required this.plotId});

  @override
  State<SoilAnalysisBanner> createState() => _SoilAnalysisBannerState();
}

class _SoilAnalysisBannerState extends State<SoilAnalysisBanner> {
  Map<String, dynamic>? _latest;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final analyses =
          await sl<SoilAnalysisRemoteDatasource>().getAnalyses(widget.plotId);
      if (mounted && analyses.isNotEmpty) {
        setState(() => _latest = analyses.first as Map<String, dynamic>);
      }
    } catch (_) {
      // Silencioso: esto es solo una ayuda informativa, no bloquea el registro.
    }
  }

  @override
  Widget build(BuildContext context) {
    final latest = _latest;
    if (latest == null) return const SizedBox();

    final ph = latest['ph'];
    final organicMatter = latest['organicMatterPct'];
    if (ph == null && organicMatter == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.brown.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.brown.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.eco_outlined, color: Colors.brown, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              [
                'Último análisis de suelo:',
                if (ph != null) 'pH $ph',
                if (organicMatter != null) 'M.O. $organicMatter%',
              ].join(' '),
              style: const TextStyle(fontSize: 12.5, color: Colors.brown),
            ),
          ),
        ],
      ),
    );
  }
}
