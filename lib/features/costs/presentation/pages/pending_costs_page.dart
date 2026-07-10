import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../farms/data/datasources/farms_remote_datasource.dart';
import '../../data/datasources/costs_remote_datasource.dart';

const _activityIcons = {
  'Irrigation': Icons.water_drop,
  'Fertilization': Icons.science,
  'Labor': Icons.agriculture,
};

const _activityLabels = {
  'Irrigation': 'Riego',
  'Fertilization': 'Fertilización',
  'Labor': 'Labor',
};

class PendingCostsPage extends StatefulWidget {
  const PendingCostsPage({super.key});

  @override
  State<PendingCostsPage> createState() => _PendingCostsPageState();
}

class _PendingCostsPageState extends State<PendingCostsPage> {
  final _fmt = DateFormat('dd/MM/yyyy');

  List<Map<String, dynamic>> _farms = [];
  String? _selectedFarmId;
  List<Map<String, dynamic>> _activities = [];
  bool _loadingFarms = true;
  bool _loadingActivities = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFarms();
  }

  Future<void> _loadFarms() async {
    setState(() => _loadingFarms = true);
    try {
      final farms = await sl<FarmsRemoteDatasource>().getFarms();
      if (!mounted) return;
      setState(() {
        _farms = List<Map<String, dynamic>>.from(farms);
        _selectedFarmId = _farms.isNotEmpty ? _farms.first['id'] as String : null;
        _loadingFarms = false;
      });
      if (_selectedFarmId != null) _loadActivities(_selectedFarmId!);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingFarms = false;
          _error = 'Error al cargar fincas';
        });
      }
    }
  }

  Future<void> _loadActivities(String farmId) async {
    setState(() {
      _loadingActivities = true;
      _error = null;
    });
    try {
      final data = await sl<CostsRemoteDatasource>().getPendingCosts(farmId);
      if (!mounted) return;
      setState(() {
        _activities = List<Map<String, dynamic>>.from(data);
        _loadingActivities = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingActivities = false;
          _error = 'Error al cargar costos pendientes';
        });
      }
    }
  }

  void _showSetCostSheet(Map<String, dynamic> activity) {
    final costCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_activityLabels[activity['activityType']] ?? activity['activityType']} — ${activity['cropType']}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(activity['description'] as String? ?? '',
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 16),
                TextFormField(
                  controller: costCtrl,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Costo (L.) *'),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Campo requerido'
                      : (double.tryParse(v) == null ? 'Número inválido' : null),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setSheetState(() => submitting = true);
                          try {
                            await sl<CostsRemoteDatasource>().setCost(
                              activity['activityType'] as String,
                              activity['cropId'] as String,
                              activity['id'] as String,
                              double.parse(costCtrl.text),
                            );
                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                            if (_selectedFarmId != null) {
                              _loadActivities(_selectedFarmId!);
                            }
                          } catch (e) {
                            setSheetState(() => submitting = false);
                            if (sheetContext.mounted) {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Error al guardar el costo'),
                                  backgroundColor: AppTheme.error,
                                ),
                              );
                            }
                          }
                        },
                  child: submitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar costo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Costos pendientes')),
      body: _loadingFarms
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : Column(
              children: [
                if (_farms.length > 1)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<String>(
                      value: _selectedFarmId,
                      decoration: const InputDecoration(labelText: 'Finca'),
                      items: _farms
                          .map((f) => DropdownMenuItem(
                                value: f['id'] as String,
                                child: Text(f['name'] as String),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _selectedFarmId = v);
                        _loadActivities(v);
                      },
                    ),
                  ),
                Expanded(
                  child: _loadingActivities
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primary))
                      : _error != null
                          ? Center(child: Text(_error!))
                          : _activities.isEmpty
                              ? const Center(
                                  child: Text(
                                      'No hay actividades pendientes de costo 🎉'),
                                )
                              : RefreshIndicator(
                                  color: AppTheme.primary,
                                  onRefresh: () async {
                                    if (_selectedFarmId != null) {
                                      await _loadActivities(_selectedFarmId!);
                                    }
                                  },
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _activities.length,
                                    itemBuilder: (_, i) {
                                      final activity = _activities[i];
                                      final date = DateTime.tryParse(
                                          activity['date'] as String);
                                      return Card(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: AppTheme.primary
                                                .withValues(alpha: 0.15),
                                            child: Icon(
                                              _activityIcons[
                                                      activity['activityType']] ??
                                                  Icons.receipt_long,
                                              color: AppTheme.primary,
                                            ),
                                          ),
                                          title: Text(
                                              '${activity['cropType']} — ${activity['description']}'),
                                          subtitle: Text(
                                            '${_activityLabels[activity['activityType']] ?? activity['activityType']} · '
                                            '${activity['plotName'] ?? ''} · '
                                            '${date != null ? _fmt.format(date) : ''}',
                                          ),
                                          trailing: TextButton(
                                            onPressed: () =>
                                                _showSetCostSheet(activity),
                                            child: const Text('Llenar costo'),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                ),
              ],
            ),
    );
  }
}
