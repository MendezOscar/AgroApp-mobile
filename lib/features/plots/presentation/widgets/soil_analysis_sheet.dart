import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/datasources/soil_analysis_remote_datasource.dart';

class SoilAnalysisSheet extends StatefulWidget {
  final String plotId;

  const SoilAnalysisSheet({super.key, required this.plotId});

  @override
  State<SoilAnalysisSheet> createState() => _SoilAnalysisSheetState();
}

class _SoilAnalysisSheetState extends State<SoilAnalysisSheet> {
  final _fmt = DateFormat('dd/MM/yyyy');
  final _phCtrl = TextEditingController();
  final _nCtrl = TextEditingController();
  final _pCtrl = TextEditingController();
  final _kCtrl = TextEditingController();
  final _omCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _analyzedAt = DateTime.now();
  bool _submitting = false;
  bool _loadingHistory = true;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _phCtrl.dispose();
    _nCtrl.dispose();
    _pCtrl.dispose();
    _kCtrl.dispose();
    _omCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _loadingHistory = true);
    try {
      final data =
          await sl<SoilAnalysisRemoteDatasource>().getAnalyses(widget.plotId);
      if (!mounted) return;
      setState(() {
        _history = List<Map<String, dynamic>>.from(data);
        _loadingHistory = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await sl<SoilAnalysisRemoteDatasource>().createAnalysis(widget.plotId, {
        'analyzedAt': _analyzedAt.toIso8601String().split('T')[0],
        'ph': _phCtrl.text.isEmpty ? null : double.tryParse(_phCtrl.text),
        'nitrogenPct': _nCtrl.text.isEmpty ? null : double.tryParse(_nCtrl.text),
        'phosphorusPct':
            _pCtrl.text.isEmpty ? null : double.tryParse(_pCtrl.text),
        'potassiumPct':
            _kCtrl.text.isEmpty ? null : double.tryParse(_kCtrl.text),
        'organicMatterPct':
            _omCtrl.text.isEmpty ? null : double.tryParse(_omCtrl.text),
        'notes': _notesCtrl.text.isEmpty ? null : _notesCtrl.text.trim(),
      });
      if (!mounted) return;
      _phCtrl.clear();
      _nCtrl.clear();
      _pCtrl.clear();
      _kCtrl.clear();
      _omCtrl.clear();
      _notesCtrl.clear();
      setState(() => _submitting = false);
      await _loadHistory();
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al registrar el análisis'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Análisis de suelo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _analyzedAt,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _analyzedAt = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Fecha'),
                child: Text(_fmt.format(_analyzedAt)),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _phCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'pH'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _omCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Materia orgánica %'),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _nCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'N %'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _pCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'P %'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _kCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'K %'),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notas'),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Registrar análisis'),
            ),
            const SizedBox(height: 24),
            const Text('Historial',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            if (_loadingHistory)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(color: AppTheme.primary),
              ))
            else if (_history.isEmpty)
              const Text('Sin análisis registrados todavía.',
                  style: TextStyle(color: Colors.grey))
            else
              ..._history.map((a) {
                final date = DateTime.tryParse(a['analyzedAt'] as String);
                final parts = <String>[
                  if (a['ph'] != null) 'pH ${a['ph']}',
                  if (a['organicMatterPct'] != null)
                    'M.O. ${a['organicMatterPct']}%',
                  if (a['nitrogenPct'] != null) 'N ${a['nitrogenPct']}%',
                  if (a['phosphorusPct'] != null) 'P ${a['phosphorusPct']}%',
                  if (a['potassiumPct'] != null) 'K ${a['potassiumPct']}%',
                ];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date != null ? _fmt.format(date) : '',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(parts.isEmpty ? '—' : parts.join(' · '),
                          style: const TextStyle(fontSize: 12.5)),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
