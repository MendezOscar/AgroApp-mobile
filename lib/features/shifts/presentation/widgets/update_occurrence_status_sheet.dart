import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task_occurrence_entity.dart';
import '../bloc/shifts_cubit.dart';
import '../bloc/shifts_state.dart';

class UpdateOccurrenceStatusSheet extends StatefulWidget {
  final TaskOccurrenceEntity occurrence;

  const UpdateOccurrenceStatusSheet({super.key, required this.occurrence});

  @override
  State<UpdateOccurrenceStatusSheet> createState() =>
      _UpdateOccurrenceStatusSheetState();
}

class _UpdateOccurrenceStatusSheetState
    extends State<UpdateOccurrenceStatusSheet> {
  late String _status;
  final _notesCtrl = TextEditingController();

  final _statuses = [
    {'value': 'Pending', 'label': 'Pendiente', 'icon': '⏳'},
    {'value': 'InProgress', 'label': 'En progreso', 'icon': '🔄'},
    {'value': 'Completed', 'label': 'Completado', 'icon': '✅'},
    {'value': 'Cancelled', 'label': 'Cancelado', 'icon': '❌'},
  ];

  @override
  void initState() {
    super.initState();
    _status = widget.occurrence.status;
    _notesCtrl.text = widget.occurrence.notes ?? '';
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShiftsCubit, ShiftsState>(
      listener: (context, state) {
        if (state.success != null) Navigator.pop(context);
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
            Row(
              children: [
                Text(widget.occurrence.taskTypeIcon,
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.occurrence.templateTitle,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.occurrence.shiftIcon} ${widget.occurrence.shiftLabel}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            ..._statuses.map((s) {
              final isSelected = _status == s['value'];
              return GestureDetector(
                onTap: () => setState(() => _status = s['value']!),
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
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            BlocBuilder<ShiftsCubit, ShiftsState>(
              builder: (context, state) => ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () => context.read<ShiftsCubit>().updateStatus(
                          widget.occurrence.id,
                          _status,
                          _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
                        ),
                child: state.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Actualizar turno'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
