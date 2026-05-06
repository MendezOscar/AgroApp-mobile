import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/crops_bloc.dart';
import '../bloc/crops_event.dart';
import '../bloc/crops_state.dart';

class CreateCropBottomSheet extends StatefulWidget {
  final String plotId;

  const CreateCropBottomSheet({super.key, required this.plotId});

  @override
  State<CreateCropBottomSheet> createState() => _CreateCropBottomSheetState();
}

class _CreateCropBottomSheetState extends State<CreateCropBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _cropTypeCtrl = TextEditingController();
  final _varietyCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _plantedAt = DateTime.now();
  DateTime? _estimatedHarvest;
  final _fmt = DateFormat('dd/MM/yyyy');

  @override
  void dispose() {
    _cropTypeCtrl.dispose();
    _varietyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isPlanted) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          isPlanted ? _plantedAt : (_estimatedHarvest ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isPlanted) {
          _plantedAt = picked;
        } else {
          _estimatedHarvest = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CropsBloc, CropsState>(
      listener: (context, state) {
        if (state is CropsLoaded) Navigator.pop(context);
        if (state is CropsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: AppTheme.error),
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Nuevo Cultivo',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _cropTypeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tipo de cultivo *',
                  prefixIcon: Icon(Icons.grass),
                  hintText: 'Ej: maíz, frijol, tomate',
                ),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _varietyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Variedad',
                  prefixIcon: Icon(Icons.spa_outlined),
                  hintText: 'Ej: DK-7088',
                ),
              ),
              const SizedBox(height: 12),
              // Fecha siembra
              InkWell(
                onTap: () => _pickDate(true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de siembra *',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_fmt.format(_plantedAt)),
                ),
              ),
              const SizedBox(height: 12),
              // Fecha cosecha estimada
              InkWell(
                onTap: () => _pickDate(false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Cosecha estimada',
                    prefixIcon: Icon(Icons.event_available),
                  ),
                  child: Text(_estimatedHarvest != null
                      ? _fmt.format(_estimatedHarvest!)
                      : 'Seleccionar fecha'),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              BlocBuilder<CropsBloc, CropsState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is CropsLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<CropsBloc>().add(CreateCrop(
                                    plotId: widget.plotId,
                                    cropType: _cropTypeCtrl.text.trim(),
                                    variety: _varietyCtrl.text.isEmpty
                                        ? null
                                        : _varietyCtrl.text.trim(),
                                    plantedAt: _plantedAt,
                                    estimatedHarvest: _estimatedHarvest,
                                    notes: _notesCtrl.text.isEmpty
                                        ? null
                                        : _notesCtrl.text,
                                  ));
                            }
                          },
                    child: state is CropsLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Crear cultivo'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
