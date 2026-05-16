import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task_entity.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final bool isManager;
  final VoidCallback onUpdateStatus;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.isManager,
    required this.onUpdateStatus,
    this.onDelete,
  });

  Color get _priorityColor => switch (task.priority) {
        'Urgent' => Colors.red,
        'High' => Colors.orange,
        'Medium' => Colors.blue,
        _ => Colors.grey,
      };

  String get _priorityLabel => switch (task.priority) {
        'Urgent' => '🔴 Urgente',
        'High' => '🟠 Alta',
        'Medium' => '🔵 Media',
        _ => '⚪ Baja',
      };

  Color get _statusColor => switch (task.status) {
        'Pending' => Colors.orange,
        'InProgress' => Colors.blue,
        'Completed' => Colors.green,
        _ => Colors.grey,
      };

  String get _statusLabel => switch (task.status) {
        'Pending' => 'Pendiente',
        'InProgress' => 'En progreso',
        'Completed' => 'Completada',
        _ => 'Cancelada',
      };

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: task.isOverdue
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
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      decoration: task.status == 'Completed'
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.status == 'Completed'
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                ),
                Text(
                  task.taskTypeIcon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                // Priority badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _priorityColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _priorityLabel,
                    style: TextStyle(
                        color: _priorityColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (task.description != null) ...[
              const SizedBox(height: 6),
              Text(
                task.description!,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            // Info chips
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (task.plotName != null)
                  _chip(Icons.grid_view, task.plotName!, AppTheme.primary),
                if (task.cropName != null)
                  _chip(Icons.grass, task.cropName!, Colors.teal),
                _chip(
                  Icons.person_outlined,
                  isManager ? task.assigneeName : 'De: ${task.creatorName}',
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Footer
            Row(
              children: [
                // Fecha límite
                Icon(
                  task.isOverdue
                      ? Icons.warning_amber
                      : task.isDueToday
                          ? Icons.today
                          : Icons.calendar_today,
                  size: 14,
                  color: task.isOverdue
                      ? Colors.red
                      : task.isDueToday
                          ? Colors.orange
                          : Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  task.isOverdue
                      ? 'Vencida: ${fmt.format(task.dueDate)}'
                      : task.isDueToday
                          ? 'Vence hoy'
                          : fmt.format(task.dueDate),
                  style: TextStyle(
                    color: task.isOverdue
                        ? Colors.red
                        : task.isDueToday
                            ? Colors.orange
                            : Colors.grey[500],
                    fontSize: 12,
                    fontWeight: task.isOverdue || task.isDueToday
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                // Status badge
                GestureDetector(
                  onTap:
                      task.status != 'Completed' && task.status != 'Cancelled'
                          ? onUpdateStatus
                          : null,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _statusLabel,
                          style: TextStyle(
                              color: _statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                        if (task.status != 'Completed' &&
                            task.status != 'Cancelled') ...[
                          const SizedBox(width: 4),
                          Icon(Icons.edit, size: 12, color: _statusColor),
                        ],
                      ],
                    ),
                  ),
                ),
                if (isManager && onDelete != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(Icons.delete_outline,
                        color: Colors.red[300], size: 20),
                  ),
                ],
              ],
            ),
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
