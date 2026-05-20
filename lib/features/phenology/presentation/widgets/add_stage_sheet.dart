import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/phenology_template_entity.dart';
import '../bloc/phenology_cubit.dart';
import '../bloc/phenology_state.dart';

class AddStageSheet extends StatefulWidget {
  final String cropId;
  final String cropType;

  const AddStageSheet({
    super.key,
    required this.cropId,
    required this.cropType,
  });

  @override
  State<AddStageSheet> createState() => _AddStageSheetState();
}

class _AddStageSheetState extends State<AddStageSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _observationsCtrl = TextEditingController();
  final _fmt = DateFormat('dd/MM/yyyy');

  DateTime _startedAt = DateTime.now();
  PhenologyTemplateEntity? _selectedTemplate;
  bool _isCustom = false;

  @override
  void initState() {
    super.initState();
    context.read<PhenologyCubit>().loadTemplates(widget.cropType);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _observationsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhenologyCubit, PhenologyState>(
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
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Registrar Etapa Fenológica',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Toggle predefinida / personalizada
                Row(
                  children: [
                    Expanded(
                      child: _typeBtn('📋 Predefinida', !_isCustom, () {
                        setState(() {
                          _isCustom = false;
                          _selectedTemplate = null;
                          _nameCtrl.clear();
                        });
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _typeBtn('✏️ Personalizada', _isCustom, () {
                        setState(() {
                          _isCustom = true;
                          _selectedTemplate = null;
                        });
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Seleccionar template o nombre custom
                if (!_isCustom)
                  BlocBuilder<PhenologyCubit, PhenologyState>(
                    builder: (context, state) {
                      if (state.templates.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primary),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Seleccionar etapa',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                  fontSize: 12)),
                          const SizedBox(height: 8),
                          ...state.templates.map((t) => _templateOption(t)),
                        ],
                      );
                    },
                  )
                else
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la etapa *',
                      prefixIcon: Icon(Icons.edit_outlined),
                    ),
                    validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  ),

                const SizedBox(height: 12),

                // Mostrar recomendaciones del template
                if (_selectedTemplate?.recommendations != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡 Recomendaciones',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppTheme.primary)),
                        const SizedBox(height: 4),
                        Text(
                          _selectedTemplate!.recommendations!,
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Fecha de inicio
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startedAt,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _startedAt = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de inicio',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(_fmt.format(_startedAt)),
                  ),
                ),
                const SizedBox(height: 12),

                // Observaciones
                TextFormField(
                  controller: _observationsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones (opcional)',
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                BlocBuilder<PhenologyCubit, PhenologyState>(
                  builder: (context, state) => ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            final name = _isCustom
                                ? _nameCtrl.text.trim()
                                : _selectedTemplate?.stageName ?? '';

                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Selecciona o escribe una etapa'),
                              ));
                              return;
                            }

                            context
                                .read<PhenologyCubit>()
                                .createStage(widget.cropId, {
                              'templateId': _selectedTemplate?.id,
                              'stageName': name,
                              'stageOrder': _selectedTemplate?.stageOrder ?? 99,
                              'startedAt':
                                  _startedAt.toIso8601String().split('T')[0],
                              'observations': _observationsCtrl.text.isEmpty
                                  ? null
                                  : _observationsCtrl.text,
                              'isCustom': _isCustom,
                            });
                          },
                    child: state.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Registrar etapa'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _templateOption(PhenologyTemplateEntity template) {
    final isSelected = _selectedTemplate?.id == template.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedTemplate = template),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(template.icon ?? '🌱', style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.stageName,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.primary : Colors.black87,
                    ),
                  ),
                  Text(
                    '${template.minDays}-${template.maxDays} días',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _typeBtn(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primary : Colors.grey,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
