import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/sensors_cubit.dart';
import '../bloc/sensors_state.dart';

class AddSensorSheet extends StatefulWidget {
  final String plotId;
  const AddSensorSheet({super.key, required this.plotId});

  @override
  State<AddSensorSheet> createState() => _AddSensorSheetState();
}

class _AddSensorSheetState extends State<AddSensorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _firmwareCtrl = TextEditingController(text: '1.0.0');
  String _deviceType = 'multi';

  final _types = ['multi', 'temperature', 'humidity', 'ph', 'ec'];

  @override
  void dispose() {
    _codeCtrl.dispose();
    _firmwareCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SensorsCubit, SensorsState>(
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
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Registrar Sensor',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                'Registra el código del dispositivo ESP32',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _codeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Código del dispositivo *',
                  prefixIcon: Icon(Icons.qr_code),
                  hintText: 'Ej: ESP32-001',
                ),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _deviceType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de sensor',
                  prefixIcon: Icon(Icons.sensors),
                ),
                items: _types
                    .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t == 'multi' ? 'Multi-sensor (todos)' : t)))
                    .toList(),
                onChanged: (v) => setState(() => _deviceType = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _firmwareCtrl,
                decoration: const InputDecoration(
                  labelText: 'Versión firmware',
                  prefixIcon: Icon(Icons.memory),
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<SensorsCubit, SensorsState>(
                builder: (context, state) => ElevatedButton(
                  onPressed: state.isLoadingDevices
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            context.read<SensorsCubit>().createDevice(
                              widget.plotId,
                              {
                                'deviceCode': _codeCtrl.text.trim(),
                                'deviceType': _deviceType,
                                'firmwareVer': _firmwareCtrl.text.trim(),
                              },
                            );
                          }
                        },
                  child: state.isLoadingDevices
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Registrar sensor'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
