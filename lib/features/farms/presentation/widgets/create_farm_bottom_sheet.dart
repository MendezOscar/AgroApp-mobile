import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/farms_bloc.dart';
import '../bloc/farms_event.dart';
import '../bloc/farms_state.dart';

class CreateFarmBottomSheet extends StatefulWidget {
  const CreateFarmBottomSheet({super.key});

  @override
  State<CreateFarmBottomSheet> createState() => _CreateFarmBottomSheetState();
}

class _CreateFarmBottomSheetState extends State<CreateFarmBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _areaCtrl.dispose();
    _countryCtrl.dispose();
    _regionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FarmsBloc, FarmsState>(
      listener: (context, state) {
        if (state is FarmsLoaded) Navigator.pop(context);
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
              // Handle
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
              Text('Nueva Finca',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nombre de la finca *',
                    prefixIcon: Icon(Icons.landscape)),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(
                    labelText: 'Descripción', prefixIcon: Icon(Icons.notes)),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _countryCtrl,
                    decoration: const InputDecoration(
                        labelText: 'País',
                        prefixIcon: Icon(Icons.flag_outlined)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _regionCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Región/Depto'),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              TextFormField(
                controller: _areaCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Área (hectáreas)',
                    prefixIcon: Icon(Icons.straighten)),
              ),
              const SizedBox(height: 24),
              BlocBuilder<FarmsBloc, FarmsState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is FarmsLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<FarmsBloc>().add(CreateFarm(
                                    name: _nameCtrl.text.trim(),
                                    description:
                                        _descriptionCtrl.text.trim().isEmpty
                                            ? null
                                            : _descriptionCtrl.text.trim(),
                                    country: _countryCtrl.text.trim().isEmpty
                                        ? null
                                        : _countryCtrl.text.trim(),
                                    region: _regionCtrl.text.trim().isEmpty
                                        ? null
                                        : _regionCtrl.text.trim(),
                                    areaHa: _areaCtrl.text.trim().isEmpty
                                        ? null
                                        : double.tryParse(
                                            _areaCtrl.text.trim()),
                                  ));
                            }
                          },
                    child: state is FarmsLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Crear finca'),
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
