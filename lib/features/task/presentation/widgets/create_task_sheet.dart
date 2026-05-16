import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../farms/data/datasources/farms_remote_datasource.dart';
import '../../../plots/data/datasources/plots_remote_datasource.dart';
import '../../../users/data/datasources/users_remote_datasource.dart';
import '../bloc/tasks_cubit.dart';
import '../bloc/tasks_state.dart';

class CreateTaskSheet extends StatefulWidget {
  const CreateTaskSheet({super.key});

  @override
  State<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<CreateTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _fmt = DateFormat('dd/MM/yyyy');

  String _priority = 'Medium';
  String _taskType = 'Other';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  String? _assignedTo;
  String? _plotId;

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _plots = [];
  bool _loadingData = true;

  final _priorities = [
    {'value': 'Low', 'label': '⚪ Baja'},
    {'value': 'Medium', 'label': '🔵 Media'},
    {'value': 'High', 'label': '🟠 Alta'},
    {'value': 'Urgent', 'label': '🔴 Urgente'},
  ];

  final _taskTypes = [
    {'value': 'Irrigation', 'label': '💧 Riego'},
    {'value': 'Fertilization', 'label': '🧪 Fertilización'},
    {'value': 'Labor', 'label': '👷 Labor'},
    {'value': 'Inspection', 'label': '📷 Inspección'},
    {'value': 'Sensor', 'label': '📡 Sensor'},
    {'value': 'Other', 'label': '📋 Otro'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final users = await sl<UsersRemoteDatasource>().getUsers();
      final farms = await sl<FarmsRemoteDatasource>().getFarms();

      final List<Map<String, dynamic>> plots = [];
      for (final farm in farms) {
        final farmPlots =
            await sl<PlotsRemoteDatasource>().getPlots(farm['id'] as String);
        for (final p in farmPlots) {
          plots.add({
            'id': p['id'],
            'name': '${farm['name']} — ${p['name']}',
          });
        }
      }

      if (mounted) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(
            users.where((u) => u['isActive'] == true).map((u) => {
                  'id': u['id'],
                  'name': u['name'],
                  'role': u['role'],
                }),
          );
          _plots = plots;
          _loadingData = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingData = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TasksCubit, TasksState>(
      listener: (context, state) {
        if (state.success != null) Navigator.pop(context);
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.error!), backgroundColor: AppTheme.error),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                const Text(
                  'Nueva Tarea',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Título
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Título *',
                    prefixIcon: Icon(Icons.task_outlined),
                  ),
                  validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),

                // Descripción
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.notes),
                    hintText: 'Instrucciones detalladas...',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),

                // Tipo de tarea
                DropdownButtonFormField<String>(
                  value: _taskType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de tarea *',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _taskTypes
                      .map((t) => DropdownMenuItem(
                            value: t['value'],
                            child: Text(t['label']!),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _taskType = v!),
                ),
                const SizedBox(height: 12),

                // Asignar a
                _loadingData
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                              color: AppTheme.primary),
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        value: _assignedTo,
                        decoration: const InputDecoration(
                          labelText: 'Asignar a *',
                          prefixIcon: Icon(Icons.person_outlined),
                        ),
                        items: _users
                            .map((u) => DropdownMenuItem(
                                  value: u['id'] as String,
                                  child: Text(
                                    '${u['name']} (${u['role']})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _assignedTo = v),
                        validator: (v) =>
                            v == null ? 'Selecciona un usuario' : null,
                      ),
                const SizedBox(height: 12),

                // Parcela (opcional)
                if (_plots.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: _plotId,
                    decoration: const InputDecoration(
                      labelText: 'Parcela (opcional)',
                      prefixIcon: Icon(Icons.grid_view),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Sin parcela específica'),
                      ),
                      ..._plots.map((p) => DropdownMenuItem(
                            value: p['id'] as String,
                            child: Text(
                              p['name'] as String,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                    ],
                    onChanged: (v) => setState(() => _plotId = v),
                  ),
                const SizedBox(height: 12),

                // Prioridad y fecha en fila
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _priority,
                        decoration: const InputDecoration(
                          labelText: 'Prioridad',
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                        items: _priorities
                            .map((p) => DropdownMenuItem(
                                  value: p['value'],
                                  child: Text(p['label']!),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _priority = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dueDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _dueDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha límite',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(_fmt.format(_dueDate)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Botón crear
                BlocBuilder<TasksCubit, TasksState>(
                  builder: (context, state) => ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<TasksCubit>().createTask({
                                'assignedTo': _assignedTo,
                                'plotId': _plotId,
                                'cropId': null,
                                'title': _titleCtrl.text.trim(),
                                'description': _descCtrl.text.isEmpty
                                    ? null
                                    : _descCtrl.text.trim(),
                                'priority': _priority,
                                'taskType': _taskType,
                                'dueDate':
                                    _dueDate.toIso8601String().split('T')[0],
                              });
                            }
                          },
                    child: state.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Crear tarea'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
