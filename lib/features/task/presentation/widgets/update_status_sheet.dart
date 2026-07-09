import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../crops/presentation/bloc/crop_detail_cubit.dart';
import '../../../crops/presentation/widgets/sheets/add_fertilization_sheet.dart';
import '../../../crops/presentation/widgets/sheets/add_irrigation_sheet.dart';
import '../../../crops/presentation/widgets/sheets/add_labor_sheet.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/tasks_cubit.dart';
import '../bloc/tasks_state.dart';

class UpdateStatusSheet extends StatefulWidget {
  final TaskEntity task;
  const UpdateStatusSheet({super.key, required this.task});

  @override
  State<UpdateStatusSheet> createState() => _UpdateStatusSheetState();
}

class _UpdateStatusSheetState extends State<UpdateStatusSheet> {
  late String _selectedStatus;
  final _notesCtrl = TextEditingController();

  final _statuses = [
    {'value': 'Pending', 'label': 'Pendiente', 'icon': '⏳'},
    {'value': 'InProgress', 'label': 'En progreso', 'icon': '🔄'},
    {'value': 'Completed', 'label': 'Completada', 'icon': '✅'},
    {'value': 'Cancelled', 'label': 'Cancelada', 'icon': '❌'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.task.status;
    _notesCtrl.text = widget.task.notes ?? '';
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _needsRegistration =>
      ['Irrigation', 'Fertilization', 'Labor'].contains(widget.task.taskType) &&
      widget.task.status != 'Completed';

  void _openRegisterSheet(BuildContext context) {
    if (widget.task.cropId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta tarea no tiene un cultivo asociado'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    final cropId = widget.task.cropId!;
    final cubit = sl<CropDetailCubit>();
    final tasksCubit = context.read<TasksCubit>();

    void onRegistered() {
      if (context.mounted) Navigator.of(context).pop();
      tasksCubit.loadTasks(widget.task.status);
    }

    Widget sheet;
    switch (widget.task.taskType) {
      case 'Irrigation':
        sheet = AddIrrigationSheet(
          cropId: cropId,
          taskId: widget.task.id,
          onRegistered: onRegistered,
        );
        break;
      case 'Fertilization':
        sheet = AddFertilizationSheet(
          cropId: cropId,
          taskId: widget.task.id,
          onRegistered: onRegistered,
        );
        break;
      case 'Labor':
        sheet = AddLaborSheet(
          cropId: cropId,
          taskId: widget.task.id,
          onRegistered: onRegistered,
        );
        break;
      default:
        return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: sheet,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TasksCubit, TasksState>(
      listener: (context, state) {
        if (state.success != null && state.error == null) {
          Navigator.pop(context);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),

            // Título con tipo de tarea
            Row(
              children: [
                Text(
                  widget.task.taskTypeIcon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.task.taskTypeLabel,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Actualizar estado',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  fontSize: 13),
            ),
            const SizedBox(height: 10),

            // Opciones de estado
            ..._statuses.map((s) {
              final isSelected = _selectedStatus == s['value'];
              return GestureDetector(
                onTap: () {
                  if (s['value'] == 'Completed' && _needsRegistration) {
                    _openRegisterSheet(context);
                  } else {
                    setState(() => _selectedStatus = s['value']!);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : Colors.grey.withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(s['icon']!, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Text(
                        s['label']!,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppTheme.primary : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      if (isSelected) ...[
                        const Spacer(),
                        const Icon(Icons.check_circle, color: AppTheme.primary),
                      ],
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),

            // Notas
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                prefixIcon: Icon(Icons.notes),
                hintText: 'Agrega observaciones...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Botón actualizar
            BlocBuilder<TasksCubit, TasksState>(
              builder: (context, state) => ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () {
                        context.read<TasksCubit>().updateStatus(
                              widget.task.id,
                              _selectedStatus,
                              _notesCtrl.text.isEmpty
                                  ? null
                                  : _notesCtrl.text,
                            );
                      },
                child: state.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Actualizar estado'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
