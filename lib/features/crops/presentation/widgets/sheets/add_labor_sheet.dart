import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../phenology/presentation/widgets/phenology_recommendation_banner.dart';
import '../../bloc/crop_detail_cubit.dart';

class AddLaborSheet extends StatefulWidget {
  final String cropId;
  final String? taskId;
  final String? occurrenceId;
  final VoidCallback? onRegistered;
  const AddLaborSheet({
    super.key,
    required this.cropId,
    this.taskId,
    this.occurrenceId,
    this.onRegistered,
  });

  @override
  State<AddLaborSheet> createState() => _AddLaborSheetState();
}

class _AddLaborSheetState extends State<AddLaborSheet> {
  final _formKey = GlobalKey<FormState>();
  final _hoursCtrl = TextEditingController();
  final _workersCtrl = TextEditingController(text: '1');
  final _costCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _activityType = 'deshierbe';
  DateTime _performedAt = DateTime.now();
  bool _loading = false;
  final _fmt = DateFormat('dd/MM/yyyy');

  final _activities = [
    'preparacion',
    'siembra',
    'poda',
    'deshierbe',
    'cosecha',
    'fumigacion',
    'otro'
  ];

  @override
  void dispose() {
    _hoursCtrl.dispose();
    _workersCtrl.dispose();
    _costCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
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
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Registrar Labor',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            PhenologyRecommendationBanner(cropId: widget.cropId),
            DropdownButtonFormField<String>(
              value: _activityType,
              decoration: const InputDecoration(labelText: 'Actividad *'),
              items: _activities
                  .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                  .toList(),
              onChanged: (v) => setState(() => _activityType = v!),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _workersCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Trabajadores *'),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _hoursCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Horas'),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextFormField(
              controller: _costCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Costo (L.)'),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _performedAt,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _performedAt = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Fecha'),
                child: Text(_fmt.format(_performedAt)),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notas'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _loading = true);
                        await context.read<CropDetailCubit>().createLabor(
                          widget.cropId,
                          {
                            'activityType': _activityType,
                            'workersCount':
                                int.tryParse(_workersCtrl.text) ?? 1,
                            'hoursWorked': _hoursCtrl.text.isEmpty
                                ? null
                                : double.tryParse(_hoursCtrl.text),
                            'cost': _costCtrl.text.isEmpty
                                ? null
                                : double.tryParse(_costCtrl.text),
                            'performedAt':
                                _performedAt.toUtc().toIso8601String(),
                            'notes': _notesCtrl.text.isEmpty
                                ? null
                                : _notesCtrl.text,
                            'taskId': widget.taskId,
                            'occurrenceId': widget.occurrenceId,
                          },
                        );
                        if (context.mounted) Navigator.pop(context);
                        widget.onRegistered?.call();
                      }
                    },
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Registrar labor'),
            ),
          ],
        ),
      ),
    );
  }
}
