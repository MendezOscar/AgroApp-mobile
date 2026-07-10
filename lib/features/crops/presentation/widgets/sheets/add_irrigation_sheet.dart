import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../phenology/presentation/widgets/phenology_recommendation_banner.dart';
import '../../bloc/crop_detail_cubit.dart';

class AddIrrigationSheet extends StatefulWidget {
  final String cropId;
  final String? taskId;
  final String? occurrenceId;
  final VoidCallback? onRegistered;
  const AddIrrigationSheet({
    super.key,
    required this.cropId,
    this.taskId,
    this.occurrenceId,
    this.onRegistered,
  });

  @override
  State<AddIrrigationSheet> createState() => _AddIrrigationSheetState();
}

class _AddIrrigationSheetState extends State<AddIrrigationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _volumeCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _method = 'goteo';
  DateTime _appliedAt = DateTime.now();
  final _fmt = DateFormat('dd/MM/yyyy HH:mm');
  bool _loading = false;

  final _methods = ['goteo', 'aspersion', 'gravedad', 'manual'];

  @override
  void dispose() {
    _volumeCtrl.dispose();
    _durationCtrl.dispose();
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
            Text('Registrar Riego',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            PhenologyRecommendationBanner(cropId: widget.cropId),
            DropdownButtonFormField<String>(
              value: _method,
              decoration: const InputDecoration(labelText: 'Método de riego'),
              items: _methods
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => _method = v!),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _volumeCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Volumen (litros)'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _durationCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Duración (min)'),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextFormField(
              controller: _costCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Costo (L.)'),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _appliedAt,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _appliedAt = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Fecha de riego'),
                child: Text(_fmt.format(_appliedAt)),
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
                      setState(() => _loading = true);
                      await context.read<CropDetailCubit>().createIrrigation(
                        widget.cropId,
                        {
                          'method': _method,
                          'volumeLiters': _volumeCtrl.text.isEmpty
                              ? null
                              : double.tryParse(_volumeCtrl.text),
                          'durationMin': _durationCtrl.text.isEmpty
                              ? null
                              : int.tryParse(_durationCtrl.text),
                          'cost': _costCtrl.text.isEmpty
                              ? null
                              : double.tryParse(_costCtrl.text),
                          'appliedAt': _appliedAt.toUtc().toIso8601String(),
                          'notes':
                              _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
                          'taskId': widget.taskId,
                          'occurrenceId': widget.occurrenceId,
                        },
                      );
                      if (context.mounted) Navigator.pop(context);
                      widget.onRegistered?.call();
                    },
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Registrar riego'),
            ),
          ],
        ),
      ),
    );
  }
}
