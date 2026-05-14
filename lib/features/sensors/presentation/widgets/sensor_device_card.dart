import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/sensor_device_entity.dart';

class SensorDeviceCard extends StatelessWidget {
  final SensorDeviceEntity device;
  final VoidCallback onTap;

  const SensorDeviceCard({
    super.key,
    required this.device,
    required this.onTap,
  });

  Color get _statusColor => device.isActive ? AppTheme.primary : Colors.grey;

  String get _lastSeen {
    if (device.lastSeenAt == null) return 'Sin datos';
    final diff = DateTime.now().difference(device.lastSeenAt!);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return DateFormat('dd/MM HH:mm').format(device.lastSeenAt!);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono con estado
              Stack(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.sensors, color: _statusColor, size: 28),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: device.isActive ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.deviceCode,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      device.deviceType.toUpperCase(),
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                          letterSpacing: 1),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          _lastSeen,
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Batería
              Column(
                children: [
                  if (device.batteryPct != null) ...[
                    Icon(
                      device.batteryPct! > 60
                          ? Icons.battery_full
                          : device.batteryPct! > 20
                              ? Icons.battery_3_bar
                              : Icons.battery_alert,
                      color: device.batteryPct! > 20
                          ? AppTheme.primary
                          : Colors.red,
                      size: 22,
                    ),
                    Text(
                      '${device.batteryPct}%',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
