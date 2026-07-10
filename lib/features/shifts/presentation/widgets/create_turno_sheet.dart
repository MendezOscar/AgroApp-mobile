import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../crops/data/datasources/crops_remote_datasource.dart';
import '../../../farms/data/datasources/farms_remote_datasource.dart';
import '../../../plots/data/datasources/plots_remote_datasource.dart';
import '../bloc/shifts_cubit.dart';
import '../bloc/shifts_state.dart';

const _taskTypes = [
  {'value': 'Irrigation', 'label': '💧 Riego'},
  {'value': 'Fertilization', 'label': '🧪 Fertilización'},
  {'value': 'Labor', 'label': '👷 Labor'},
  {'value': 'Inspection', 'label': '📷 Inspección'},
  {'value': 'Sensor', 'label': '📡 Sensor'},
  {'value': 'Other', 'label': '📋 Otro'},
];

const _priorities = [
  {'value': 'Low', 'label': '⚪ Baja'},
  {'value': 'Medium', 'label': '🔵 Media'},
  {'value': 'High', 'label': '🟠 Alta'},
  {'value': 'Urgent', 'label': '🔴 Urgente'},
];

const _weekDayLabels = [
  {'day': 1, 'label': 'L'},
  {'day': 2, 'label': 'M'},
  {'day': 3, 'label': 'X'},
  {'day': 4, 'label': 'J'},
  {'day': 5, 'label': 'V'},
  {'day': 6, 'label': 'S'},
  {'day': 7, 'label': 'D'},
];

bool _needsCrop(String taskType) =>
    ['Irrigation', 'Fertilization', 'Labor'].contains(taskType);

class _TaskRowData {
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  String taskType = 'Other';
  String priority = 'Medium';
  String? plotId;
  String? cropId;
  List<Map<String, dynamic>> crops = [];
  bool loadingCrops = false;

  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
  }
}

class CreateTurnoSheet extends StatefulWidget {
  const CreateTurnoSheet({super.key});

  @override
  State<CreateTurnoSheet> createState() => _CreateTurnoSheetState();
}

class _CreateTurnoSheetState extends State<CreateTurnoSheet> {
  final _fmt = DateFormat('dd/MM/yyyy');

  String _shift = 'Day';
  String _recurrenceType = 'Once';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  final Set<int> _selectedWeekDays = {};

  final List<_TaskRowData> _rows = [_TaskRowData()];
  List<Map<String, dynamic>> _plots = [];
  bool _loadingData = true;
  String? _formError;

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

  Future<void> _loadCropsForRow(_TaskRowData row, String plotId) async {
    setState(() {
      row.loadingCrops = true;
      row.crops = [];
      row.cropId = null;
    });
    try {
      final crops = await sl<CropsRemoteDatasource>().getCrops(plotId);
      if (!mounted) return;
      setState(() {
        row.crops = List<Map<String, dynamic>>.from(
          crops.where((c) => c['status'] == 'Active').map((c) => {
                'id': c['id'],
                'name': [c['cropType'], c['variety']]
                    .where((v) => v != null && (v as String).isNotEmpty)
                    .join(' — '),
              }),
        );
        row.loadingCrops = false;
      });
    } catch (e) {
      if (mounted) setState(() => row.loadingCrops = false);
    }
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  bool _validate() {
    if (_recurrenceType == 'Weekly' && _selectedWeekDays.isEmpty) {
      setState(() => _formError = 'Selecciona al menos un día de la semana');
      return false;
    }
    if (_recurrenceType != 'Once' && _endDate == null) {
      setState(() => _formError = 'Selecciona la fecha fin');
      return false;
    }
    for (final row in _rows) {
      if (row.titleCtrl.text.trim().isEmpty) {
        setState(() => _formError = 'Cada tarea necesita un título');
        return false;
      }
      if (_needsCrop(row.taskType) && (row.plotId == null || row.cropId == null)) {
        setState(() => _formError =
            'Las tareas de riego/fertilización/labor necesitan parcela y cultivo');
        return false;
      }
    }
    setState(() => _formError = null);
    return true;
  }

  void _submit() {
    if (!_validate()) return;

    final startDateStr = _startDate.toIso8601String().split('T')[0];
    final endDateStr = _endDate?.toIso8601String().split('T')[0];
    final weekDaysStr =
        _selectedWeekDays.isEmpty ? null : _selectedWeekDays.toList().join(',');

    final tasks = _rows
        .map((row) => {
              'title': row.titleCtrl.text.trim(),
              'description':
                  row.descCtrl.text.isEmpty ? null : row.descCtrl.text.trim(),
              'taskType': row.taskType,
              'priority': row.priority,
              'shift': _shift,
              'recurrenceType': _recurrenceType,
              'weekDays': _recurrenceType == 'Weekly' ? weekDaysStr : null,
              'startDate': startDateStr,
              'endDate': endDateStr,
              'plotId': row.plotId,
              'cropId': row.cropId,
            })
        .toList();

    context.read<ShiftsCubit>().createTurno(tasks);
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
              const Text('Nuevo Turno',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

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
                              color: isSelected ? Colors.white : Colors.grey[700],
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
                      if (picked != null) setState(() => _startDate = picked);
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
                          initialDate:
                              _endDate ?? _startDate.add(const Duration(days: 7)),
                          firstDate: _startDate,
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _endDate = picked);
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
              const SizedBox(height: 20),

              const Text('Tareas de este turno',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              for (var i = 0; i < _rows.length; i++)
                _buildTaskRow(i, _rows[i]),

              TextButton.icon(
                onPressed: () => setState(() => _rows.add(_TaskRowData())),
                icon: const Icon(Icons.add),
                label: const Text('Agregar tarea'),
              ),
              const SizedBox(height: 12),

              if (_formError != null) ...[
                Text(_formError!,
                    style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                const SizedBox(height: 12),
              ],

              BlocBuilder<ShiftsCubit, ShiftsState>(
                builder: (context, state) => ElevatedButton(
                  onPressed: state.isLoading ? null : _submit,
                  child: state.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Crear turno'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskRow(int index, _TaskRowData row) {
    final needsCrop = _needsCrop(row.taskType);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tarea ${index + 1}',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.grey[600])),
              if (_rows.length > 1)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() {
                    row.dispose();
                    _rows.removeAt(index);
                  }),
                ),
            ],
          ),
          TextFormField(
            controller: row.titleCtrl,
            decoration: const InputDecoration(labelText: 'Título *'),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: row.descCtrl,
            decoration: const InputDecoration(labelText: 'Descripción'),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: row.taskType,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: _taskTypes
                    .map((t) => DropdownMenuItem(
                          value: t['value'],
                          child:
                              Text(t['label']!, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) {
                  setState(() => row.taskType = v!);
                  if (_needsCrop(v!) && row.plotId != null) {
                    _loadCropsForRow(row, row.plotId!);
                  } else {
                    setState(() {
                      row.crops = [];
                      row.cropId = null;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: row.priority,
                decoration: const InputDecoration(labelText: 'Prioridad'),
                items: _priorities
                    .map((p) => DropdownMenuItem(
                          value: p['value'],
                          child: Text(p['label']!),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => row.priority = v!),
              ),
            ),
          ]),
          if (!_loadingData && _plots.isNotEmpty) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: row.plotId,
              decoration: InputDecoration(
                labelText: needsCrop ? 'Parcela *' : 'Parcela (opcional)',
                prefixIcon: const Icon(Icons.grid_view),
              ),
              items: [
                if (!needsCrop)
                  const DropdownMenuItem(
                      value: null, child: Text('Sin parcela específica')),
                ..._plots.map((p) => DropdownMenuItem(
                      value: p['id'] as String,
                      child: Text(p['name'] as String,
                          overflow: TextOverflow.ellipsis),
                    )),
              ],
              onChanged: (v) {
                setState(() => row.plotId = v);
                if (needsCrop && v != null) {
                  _loadCropsForRow(row, v);
                } else {
                  setState(() {
                    row.crops = [];
                    row.cropId = null;
                  });
                }
              },
            ),
          ],
          if (needsCrop) ...[
            const SizedBox(height: 8),
            row.loadingCrops
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child:
                          CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  )
                : DropdownButtonFormField<String>(
                    value: row.cropId,
                    decoration: const InputDecoration(labelText: 'Cultivo *'),
                    items: row.crops
                        .map((c) => DropdownMenuItem(
                              value: c['id'] as String,
                              child: Text(c['name'] as String,
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => row.cropId = v),
                  ),
          ],
        ],
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
            color: isSelected ? AppTheme.primary : Colors.grey.withValues(alpha: 0.2),
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
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
