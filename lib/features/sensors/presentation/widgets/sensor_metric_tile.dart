import 'package:flutter/material.dart';

class SensorMetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final String unit;
  final Color color;

  const SensorMetricTile({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: value != null
            ? color.withValues(alpha: 0.08)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value != null
              ? color.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: value != null ? color : Colors.grey, size: 18),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          value != null
              ? RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value!,
                        style: TextStyle(
                            color: color,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' $unit',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                )
              : Text('—',
                  style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
