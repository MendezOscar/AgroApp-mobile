import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../sensors/domain/entities/sensor_reading_entity.dart';

class SensorChart extends StatelessWidget {
  final String title;
  final String unit;
  final Color color;
  final List<SensorReadingEntity> readings;
  final double? Function(SensorReadingEntity) getValue;

  const SensorChart({
    super.key,
    required this.title,
    required this.unit,
    required this.color,
    required this.readings,
    required this.getValue,
  });

  @override
  Widget build(BuildContext context) {
    final validReadings =
        readings.where((r) => getValue(r) != null).toList().reversed.toList();

    if (validReadings.isEmpty) {
      return _emptyCard();
    }

    // Si solo hay un punto, duplicarlo para poder dibujar la línea
    final chartReadings = validReadings.length == 1
        ? [validReadings.first, validReadings.first]
        : validReadings;

    final spots = chartReadings.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), getValue(e.value)!);
    }).toList();

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final range = maxY - minY;
    final padding = range == 0 ? 2.0 : range * 0.15;
    final horizontalInterval = range == 0 ? 1.0 : range / 4;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(
                  '${getValue(validReadings.last)?.toStringAsFixed(1)} $unit',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            // Mensaje si hay pocos datos
            if (validReadings.length == 1)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Solo 1 lectura — necesitas más datos para ver la tendencia',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: horizontalInterval,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, _) => Text(
                          value.toStringAsFixed(0),
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: validReadings.length > 1,
                        interval: chartReadings.length / 4,
                        getTitlesWidget: (value, _) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < chartReadings.length) {
                            return Text(
                              DateFormat('HH:mm')
                                  .format(chartReadings[idx].recordedAt),
                              style: const TextStyle(
                                  fontSize: 9, color: Colors.grey),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: minY - padding,
                  maxY: maxY + padding,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: validReadings.length > 2,
                      color: color,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: validReadings.length <= 3,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: Text('Sin datos disponibles',
                  style: TextStyle(color: Colors.grey[500])),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
