import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/crop_detail_cubit.dart';

class AddSaleSheet extends StatefulWidget {
  final String cropId;
  const AddSaleSheet({super.key, required this.cropId});

  @override
  State<AddSaleSheet> createState() => _AddSaleSheetState();
}

class _AddSaleSheetState extends State<AddSaleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantityCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _buyerCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _soldAt = DateTime.now();
  bool _loading = false;
  final _fmt = DateFormat('dd/MM/yyyy');

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    _buyerCtrl.dispose();
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
            Text('Registrar Venta',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _quantityCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Cantidad (kg) *'),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _priceCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Precio/kg (L.) *'),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextFormField(
              controller: _buyerCtrl,
              decoration: const InputDecoration(labelText: 'Comprador'),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _soldAt,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _soldAt = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Fecha'),
                child: Text(_fmt.format(_soldAt)),
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
                        await context.read<CropDetailCubit>().createSale(
                          widget.cropId,
                          {
                            'soldAt': _soldAt.toIso8601String().split('T')[0],
                            'quantityKg': double.tryParse(_quantityCtrl.text),
                            'pricePerKg': double.tryParse(_priceCtrl.text),
                            'buyer': _buyerCtrl.text.isEmpty
                                ? null
                                : _buyerCtrl.text.trim(),
                            'notes': _notesCtrl.text.isEmpty
                                ? null
                                : _notesCtrl.text,
                          },
                        );
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Registrar venta'),
            ),
          ],
        ),
      ),
    );
  }
}
