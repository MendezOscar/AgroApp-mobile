import 'package:flutter/material.dart';
import '../../../weather/domain/entities/weather_entity.dart';

class WeatherCard extends StatelessWidget {
  final WeatherEntity weather;

  const WeatherCard({super.key, required this.weather});

  /// Mapeo reducido de WMO weather codes (Open-Meteo) a ícono.
  /// https://open-meteo.com/en/docs#weathervariables
  IconData get _icon {
    final code = weather.weatherCode;
    if (code == 0) return Icons.wb_sunny;
    if (code <= 3) return Icons.cloud;
    if (code >= 51 && code <= 67) return Icons.water_drop;
    if (code >= 71 && code <= 86) return Icons.ac_unit;
    if (code >= 95) return Icons.thunderstorm;
    return Icons.cloud_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: Colors.blue, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weather.temperature.toStringAsFixed(0)}°C',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Lluvia hoy: ${weather.rainTodayMm.toStringAsFixed(1)} mm',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
