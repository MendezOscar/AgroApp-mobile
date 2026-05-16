import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../farms/data/datasources/farms_remote_datasource.dart';
import '../../../plots/data/datasources/plots_remote_datasource.dart';
import '../bloc/shifts_cubit.dart';
import '../bloc/shifts_state.dart';

class CreateTemplateSheet extends StatefulWidget {
  const CreateTemplateSheet({super.key});

  @override
  State<CreateTemplateSheet> createState() => _CreateTemplateSheetState();
}

class _CreateTemplateSheetState extends State<CreateTemplateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _fmt = DateFormat('dd/MM/yyyy');

  String _taskType = 'Other';
  String _priority = 'Medium';
  String _shift = 'Day';
  String _recurrenceType = 'Once';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String? _plotId;
  final Set<int> _selectedWeekDays = {};

  List<Map<String, dynamic>> _plots = [];
  bool _loadingData = true;

  final _taskTypes = [
    {'value': 'Irrigation', 'label': '💧 Riego'},
    {'value': 'Fertilization', 'label': '🧪 Fertilización'},
    {'value': 'Labor', 'label': '👷 Labor'},
    {'value': 'Inspection', 'label': '📷 Inspección'},
    {'value': 'Sensor', 'label': '📡 Sensor'},
    {'value': 'Other', 'label': '📋 Otro'},
  ];

  final _priorities = [
    {'value': 'Low', 'label': '⚪ Baja'},
    {'value': 'Medium', 'label': '🔵 Media'},
    {'value': 'High', 'label': '🟠 Alta'},
    {'value': 'Urgent', 'label': '🔴 Urgente'},
  ];

  final _weekDayLabels = [
    {'day': 1, 'label': 'L'},
    {'day': 2, 'label': 'M'},
    {'day': 3, 'label': 'X'},
    {'day': 4, 'label': 'J'},
    {'day': 5, 'label': 'V'},
    {'day': 6, 'label': 'S'},
    {'day': 7, 'label': 'D'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
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
    return BlocListener<ShiftsCubit, ShiftsState>(
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
                const Text('Nueva Plantilla de Turno',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

                // Tipo y prioridad
                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _taskType,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      items: _taskTypes
                          .map((t) => DropdownMenuItem(
                                value: t['value'],
                                child: Text(t['label']!,
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _taskType = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _priority,
                      decoration: const InputDecoration(labelText: 'Prioridad'),
                      items: _priorities
                          .map((p) => DropdownMenuItem(
                                value: p['value'],
                                child: Text(p['label']!),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _priority = v!),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),

                // Turno
                const Text('Turno',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        fontSize: 12)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _shiftBtn('☀️', 'Diurno', 'Day')),
                  const SizedBox(width: 12),
                  Expanded(child: _shiftBtn('🌙', 'Nocturno', 'Night')),
                ]),
                const SizedBox(height: 12),

                // Parcela
                if (!_loadingData && _plots.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: _plotId,
                    decoration: const InputDecoration(
                      labelText: 'Parcela (opcional)',
                      prefixIcon: Icon(Icons.grid_view),
                    ),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Sin parcela')),
                      ..._plots.map((p) => DropdownMenuItem(
                            value: p['id'] as String,
                            child: Text(p['name'] as String,
                                overflow: TextOverflow.ellipsis),
                          )),
                    ],
                    onChanged: (v) => setState(() => _plotId = v),
                  ),
                const SizedBox(height: 12),

                // Recurrencia
                const Text('Recurrencia',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _recurrenceChip('Once', 'Una vez'),
                    _recurrenceChip('Daily', 'Diario'),
                    _recurrenceChip('Weekly', 'Semanal'),
                    _recurrenceChip('DateRange', 'Rango fechas'),
                  ],
                ),
                const SizedBox(height: 12),

                // Días de semana (solo si es Weekly)
                if (_recurrenceType == 'Weekly') ...[
                  const Text('Días de la semana',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _weekDayLabels.map((d) {
                      final day = d['day'] as int;
                      final isSelected = _selectedWeekDays.contains(day);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedWeekDays.remove(day);
                            } else {
                              _selectedWeekDays.add(day);
                            }
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary
                                : Colors.grey.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primary
                                  : Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              d['label'] as String,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Fechas
                Row(children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate:
                              DateTime.now().subtract(const Duration(days: 1)),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _startDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha inicio *',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(_fmt.format(_startDate)),
                      ),
                    ),
                  ),
                  if (_recurrenceType != 'Once') ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _endDate ??
                                _startDate.add(const Duration(days: 7)),
                            firstDate: _startDate,
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _endDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha fin *',
                            prefixIcon: Icon(Icons.event_available),
                          ),
                          child: Text(_endDate != null
                              ? _fmt.format(_endDate!)
                              : 'Seleccionar'),
                        ),
                      ),
                    ),
                  ],
                ]),
                const SizedBox(height: 24),

                BlocBuilder<ShiftsCubit, ShiftsState>(
                  builder: (context, state) => ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              if (_recurrenceType == 'Weekly' &&
                                  _selectedWeekDays.isEmpty) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('Selecciona al menos un día'),
                                ));
                                return;
                              }
                              context.read<ShiftsCubit>().createTemplate({
                                'title': _titleCtrl.text.trim(),
                                'description': _descCtrl.text.isEmpty
                                    ? null
                                    : _descCtrl.text,
                                'taskType': _taskType,
                                'priority': _priority,
                                'shift': _shift,
                                'recurrenceType': _recurrenceType,
                                'weekDays': _selectedWeekDays.isEmpty
                                    ? null
                                    : _selectedWeekDays.toList().join(','),
                                'startDate':
                                    _startDate.toIso8601String().split('T')[0],
                                'endDate':
                                    _endDate?.toIso8601String().split('T')[0],
                                'plotId': _plotId,
                                'cropId': null,
                              });
                            }
                          },
                    child: state.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Crear plantilla y generar turnos'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _shiftBtn(String icon, String label, String value) {
    final isSelected = _shift == value;
    return GestureDetector(
      onTap: () => setState(() => _shift = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
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
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primary : Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _recurrenceChip(String value, String label) {
    final isSelected = _recurrenceType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _recurrenceType = value),
      selectedColor: AppTheme.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primary : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
