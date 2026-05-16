import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../users/data/datasources/users_remote_datasource.dart';
import '../bloc/shifts_cubit.dart';
import '../bloc/shifts_state.dart';

class AssignOccurrenceSheet extends StatefulWidget {
  final String occurrenceId;
  final String currentShift;

  const AssignOccurrenceSheet({
    super.key,
    required this.occurrenceId,
    required this.currentShift,
  });

  @override
  State<AssignOccurrenceSheet> createState() => _AssignOccurrenceSheetState();
}

class _AssignOccurrenceSheetState extends State<AssignOccurrenceSheet> {
  String? _assignedTo;
  late String _shift;
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _shift = widget.currentShift;
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await sl<UsersRemoteDatasource>().getUsers();
      if (mounted) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(
            users
                .where((u) =>
                    u['isActive'] == true &&
                    (u['role'] == 'Farmer' || u['role'] == 'Manager'))
                .map((u) => {
                      'id': u['id'],
                      'name': u['name'],
                      'role': u['role'],
                    }),
          );
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
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
            const Text('Asignar turno',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Seleccionar turno
            const Text('Turno',
                style:
                    TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _shiftOption('☀️', 'Diurno', 'Day'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _shiftOption('🌙', 'Nocturno', 'Night'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Seleccionar usuario
            const Text('Asignar a',
                style:
                    TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 8),
            _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary))
                : DropdownButtonFormField<String>(
                    value: _assignedTo,
                    decoration: const InputDecoration(
                      labelText: 'Seleccionar persona',
                      prefixIcon: Icon(Icons.person_outlined),
                    ),
                    items: _users
                        .map((u) => DropdownMenuItem(
                              value: u['id'] as String,
                              child: Text('${u['name']} (${u['role']})'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _assignedTo = v),
                  ),
            const SizedBox(height: 24),

            BlocBuilder<ShiftsCubit, ShiftsState>(
              builder: (context, state) => ElevatedButton(
                onPressed: _assignedTo == null || state.isLoading
                    ? null
                    : () => context.read<ShiftsCubit>().assignOccurrence(
                          widget.occurrenceId,
                          _assignedTo!,
                          _shift,
                        ),
                child: state.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Asignar turno'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shiftOption(String icon, String label, String value) {
    final isSelected = _shift == value;
    return GestureDetector(
      onTap: () => setState(() => _shift = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.primary : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
