import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/plots_bloc.dart';
import '../bloc/plots_event.dart';
import '../bloc/plots_state.dart';

class CreatePlotBottomSheet extends StatefulWidget {
  final String farmId;

  const CreatePlotBottomSheet({super.key, required this.farmId});

  @override
  State<CreatePlotBottomSheet> createState() => _CreatePlotBottomSheetState();
}

class _CreatePlotBottomSheetState extends State<CreatePlotBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _soilTypeCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final _soilTypes = ['arcilloso', 'arenoso', 'limoso', 'franco', 'otro'];
  String? _selectedSoilType;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _soilTypeCtrl.dispose();
    _areaCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlotsBloc, PlotsState>(
      listener: (context, state) {
        if (state is PlotsLoaded) Navigator.pop(context);
        if (state is PlotsError) {
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
              Text('Nueva Parcela',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la parcela *',
                  prefixIcon: Icon(Icons.grid_view),
                ),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedSoilType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de suelo',
                  prefixIcon: Icon(Icons.layers_outlined),
                ),
                items: _soilTypes
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedSoilType = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _areaCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Área (hectáreas)',
                  prefixIcon: Icon(Icons.straighten),
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
              BlocBuilder<PlotsBloc, PlotsState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is PlotsLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<PlotsBloc>().add(CreatePlot(
                                    farmId: widget.farmId,
                                    name: _nameCtrl.text.trim(),
                                    soilType: _selectedSoilType,
                                    areaHa: _areaCtrl.text.isEmpty
                                        ? null
                                        : double.tryParse(_areaCtrl.text),
                                    notes: _notesCtrl.text.isEmpty
                                        ? null
                                        : _notesCtrl.text,
                                  ));
                            }
                          },
                    child: state is PlotsLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Crear parcela'),
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
