import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task_occurrence_entity.dart';

class OccurrenceCard extends StatelessWidget {
  final TaskOccurrenceEntity occurrence;
  final bool isManager;
  final VoidCallback? onAssign;
  final VoidCallback onUpdateStatus;

  const OccurrenceCard({
    super.key,
    required this.occurrence,
    required this.isManager,
    this.onAssign,
    required this.onUpdateStatus,
  });

  Color get _statusColor => switch (occurrence.status) {
        'Pending' => Colors.orange,
        'InProgress' => Colors.blue,
        'Completed' => Colors.green,
        _ => Colors.grey,
      };

  String get _statusLabel => switch (occurrence.status) {
        'Pending' => 'Pendiente',
        'InProgress' => 'En progreso',
        'Completed' => 'Completada',
        _ => 'Cancelada',
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: occurrence.isUnassigned
            ? const BorderSide(color: Colors.orange, width: 1.5)
            : occurrence.isOverdue
                ? const BorderSide(color: Colors.red, width: 1.5)
                : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(occurrence.taskTypeIcon,
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        occurrence.templateTitle,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Row(
                        children: [
                          Text(occurrence.shiftIcon),
                          const SizedBox(width: 4),
                          Text(
                            occurrence.shiftLabel,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                        color: _statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Info parcela/cultivo
            if (occurrence.plotName != null || occurrence.cropName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    if (occurrence.plotName != null)
                      _chip(Icons.grid_view, occurrence.plotName!,
                          AppTheme.primary),
                    if (occurrence.cropName != null) ...[
                      const SizedBox(width: 8),
                      _chip(Icons.grass, occurrence.cropName!, Colors.teal),
                    ],
                  ],
                ),
              ),

            // Asignado a
            Row(
              children: [
                occurrence.isUnassigned
                    ? Icon(Icons.person_add_outlined,
                        color: Colors.orange, size: 18)
                    : Icon(Icons.person, color: Colors.grey[500], size: 18),
                const SizedBox(width: 6),
                Text(
                  occurrence.isUnassigned
                      ? 'Sin asignar'
                      : occurrence.assigneeName ?? 'Sin asignar',
                  style: TextStyle(
                    color: occurrence.isUnassigned
                        ? Colors.orange
                        : Colors.grey[700],
                    fontWeight: occurrence.isUnassigned
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                // Botones de acción
                if (isManager && onAssign != null)
                  TextButton.icon(
                    onPressed: onAssign,
                    icon: const Icon(Icons.person_add, size: 16),
                    label:
                        Text(occurrence.isUnassigned ? 'Asignar' : 'Reasignar'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 8)),
                  ),
                if (!occurrence.isCompleted && occurrence.assignedTo != null)
                  TextButton.icon(
                    onPressed: onUpdateStatus,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Estado'),
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 8)),
                  ),
              ],
            ),

            if (occurrence.notes != null) ...[
              const Divider(height: 16),
              Text(
                occurrence.notes!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
