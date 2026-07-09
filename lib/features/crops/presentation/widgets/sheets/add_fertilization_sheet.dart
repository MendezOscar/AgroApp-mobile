import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../bloc/crop_detail_cubit.dart';

class AddFertilizationSheet extends StatefulWidget {
  final String cropId;
  final String? taskId;
  final VoidCallback? onRegistered;
  const AddFertilizationSheet({
    super.key,
    required this.cropId,
    this.taskId,
    this.onRegistered,
  });

  @override
  State<AddFertilizationSheet> createState() => _AddFertilizationSheetState();
}

class _AddFertilizationSheetState extends State<AddFertilizationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _productNameCtrl = TextEditingController();
  final _totalKgCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _productType;
  String _method = 'manual';
  DateTime _appliedAt = DateTime.now();
  DateTime? _nextApplication;
  bool _loading = false;
  final _fmt = DateFormat('dd/MM/yyyy');

  final _types = ['NPK', 'foliar', 'organico', 'micronutriente'];
  final _methods = ['manual', 'aspersion', 'fertirrigacion', 'drench'];

  @override
  void dispose() {
    _productNameCtrl.dispose();
    _totalKgCtrl.dispose();
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
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Registrar Fertilización',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _productNameCtrl,
                decoration: const InputDecoration(labelText: 'Producto *'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _productType,
                    decoration: const InputDecoration(labelText: 'Tipo'),
                    items: _types
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _productType = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _method,
                    decoration: const InputDecoration(labelText: 'Método'),
                    items: _methods
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() => _method = v!),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _totalKgCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Total (kg)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _costCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Costo (L.)'),
                  ),
                ),
              ]),
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
                  decoration:
                      const InputDecoration(labelText: 'Fecha de aplicación'),
                  child: Text(_fmt.format(_appliedAt)),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 14)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _nextApplication = picked);
                },
                child: InputDecorator(
                  decoration:
                      const InputDecoration(labelText: 'Próxima aplicación'),
                  child: Text(_nextApplication != null
                      ? _fmt.format(_nextApplication!)
                      : 'Seleccionar (opcional)'),
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
                          await context
                              .read<CropDetailCubit>()
                              .createFertilization(
                            widget.cropId,
                            {
                              'productName': _productNameCtrl.text.trim(),
                              'productType': _productType,
                              'method': _method,
                              'totalKg': _totalKgCtrl.text.isEmpty
                                  ? null
                                  : double.tryParse(_totalKgCtrl.text),
                              'cost': _costCtrl.text.isEmpty
                                  ? null
                                  : double.tryParse(_costCtrl.text),
                              'appliedAt': _appliedAt.toUtc().toIso8601String(),
                              'nextApplication': _nextApplication
                                  ?.toUtc()
                                  .toIso8601String()
                                  .split('T')[0],
                              'notes': _notesCtrl.text.isEmpty
                                  ? null
                                  : _notesCtrl.text,
                              'taskId': widget.taskId,
                            },
                          );
                          if (context.mounted) Navigator.pop(context);
                          widget.onRegistered?.call();
                        }
                      },
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Registrar fertilización'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
