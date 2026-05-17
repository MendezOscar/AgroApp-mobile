import 'dart:ui';

class AiDiagnosisModel {
  final String status;
  final String condition;
  final double confidence;
  final String description;
  final List<String> recommendations;

  const AiDiagnosisModel({
    required this.status,
    required this.condition,
    required this.confidence,
    required this.description,
    required this.recommendations,
  });

  factory AiDiagnosisModel.fromJson(Map<String, dynamic> json) =>
      AiDiagnosisModel(
        status: json['status'] ?? 'uncertain',
        condition: json['condition'] ?? 'No determinado',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        description: json['description'] ?? '',
        recommendations: List<String>.from(json['recommendations'] ?? []),
      );

  Color get statusColor => switch (status) {
        'healthy' => const Color(0xFF2E7D32),
        'critical' => const Color(0xFFD32F2F),
        'warning' => const Color(0xFFF57F17),
        _ => const Color(0xFF757575),
      };

  String get statusIcon => switch (status) {
        'healthy' => '✅',
        'critical' => '🚨',
        'warning' => '⚠️',
        _ => '🔍',
      };

  String get statusLabel => switch (status) {
        'healthy' => 'Cultivo Saludable',
        'critical' => 'Problema Crítico',
        'warning' => 'Requiere Atención',
        _ => 'Análisis Incierto',
      };
}
