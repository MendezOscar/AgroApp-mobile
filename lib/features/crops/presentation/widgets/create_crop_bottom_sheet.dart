import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/crop_entity.dart';
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
  CropEntity? _lastCrop;

  @override
  void initState() {
    super.initState();
    final state = context.read<CropsBloc>().state;
    if (state is CropsLoaded && state.crops.isNotEmpty) {
      final sorted = [...state.crops]
        ..sort((a, b) => b.plantedAt.compareTo(a.plantedAt));
      _lastCrop = sorted.first;
    }
    _cropTypeCtrl.addListener(() => setState(() {}));
  }

  bool get _sameCropTypeAsLast =>
      _lastCrop != null &&
      _cropTypeCtrl.text.trim().toLowerCase() ==
          _lastCrop!.cropType.trim().toLowerCase() &&
      _cropTypeCtrl.text.trim().isNotEmpty;

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
              if (_lastCrop != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Último cultivo en esta parcela: ${_lastCrop!.cropType} '
                    '(sembrado el ${_fmt.format(_lastCrop!.plantedAt)})',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12.5),
                  ),
                ),
              TextFormField(
                controller: _cropTypeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tipo de cultivo *',
                  prefixIcon: Icon(Icons.grass),
                  hintText: 'Ej: maíz, frijol, tomate',
                ),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              if (_sameCropTypeAsLast)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.orange, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ya sembraste ${_lastCrop!.cropType} aquí la última '
                          'vez — considera rotar de cultivo para cuidar el suelo.',
                          style: const TextStyle(
                              color: Colors.orange, fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
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
