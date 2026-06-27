import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/crop_comparison_entity.dart';
import '../bloc/crop_comparison_cubit.dart';

enum _SortBy { yield_, cost }

class CropComparisonPage extends StatefulWidget {
  final String farmId;

  const CropComparisonPage({super.key, required this.farmId});

  @override
  State<CropComparisonPage> createState() => _CropComparisonPageState();
}

class _CropComparisonPageState extends State<CropComparisonPage> {
  late final CropComparisonCubit _cubit;
  _SortBy _sortBy = _SortBy.yield_;

  @override
  void initState() {
    super.initState();
    _cubit = sl<CropComparisonCubit>()..loadComparison(widget.farmId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('Comparar cultivos')),
        body: BlocBuilder<CropComparisonCubit, CropComparisonState>(
          builder: (context, state) {
            if (state.isLoading) return const LoadingWidget();

            if (state.error != null) {
              return Center(
                child: Text(state.error!,
                    style: const TextStyle(color: AppTheme.error)),
              );
            }

            if (state.crops.isEmpty) {
              return const EmptyStateWidget(
                message: 'No hay cultivos para comparar en esta finca',
                icon: Icons.bar_chart,
              );
            }

            final maxYield = state.crops.fold<double>(
                0, (max, c) => (c.yieldKg ?? 0) > max ? c.yieldKg ?? 0 : max);
            final maxCost = state.crops.fold<double>(
                0, (max, c) => c.totalCost > max ? c.totalCost : max);

            final sorted = [...state.crops]..sort((a, b) {
                if (_sortBy == _SortBy.yield_) {
                  return (b.yieldKg ?? 0).compareTo(a.yieldKg ?? 0);
                }
                return b.totalCost.compareTo(a.totalCost);
              });

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Por producción'),
                        selected: _sortBy == _SortBy.yield_,
                        onSelected: (_) =>
                            setState(() => _sortBy = _SortBy.yield_),
                        selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Por costo'),
                        selected: _sortBy == _SortBy.cost,
                        onSelected: (_) =>
                            setState(() => _sortBy = _SortBy.cost),
                        selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: sorted.length,
                    itemBuilder: (_, i) => _CropComparisonCard(
                      crop: sorted[i],
                      maxYield: maxYield,
                      maxCost: maxCost,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CropComparisonCard extends StatelessWidget {
  final CropComparisonEntity crop;
  final double maxYield;
  final double maxCost;

  const _CropComparisonCard({
    required this.crop,
    required this.maxYield,
    required this.maxCost,
  });

  @override
  Widget build(BuildContext context) {
    final yieldKg = crop.yieldKg ?? 0;
    final costPerKg =
        crop.yieldKg != null && crop.yieldKg! > 0
            ? crop.totalCost / crop.yieldKg!
            : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${crop.cropType}${crop.variety != null ? ' — ${crop.variety}' : ''}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(crop.plotName,
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 12),
            _ComparisonBar(
              label: 'Producción',
              value: crop.yieldKg != null ? '${yieldKg.toStringAsFixed(1)} kg' : 'Sin datos',
              fraction: maxYield > 0 ? yieldKg / maxYield : 0,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 8),
            _ComparisonBar(
              label: 'Costo',
              value: 'L. ${crop.totalCost.toStringAsFixed(2)}',
              fraction: maxCost > 0 ? crop.totalCost / maxCost : 0,
              color: Colors.orange,
            ),
            if (costPerKg != null) ...[
              const SizedBox(height: 8),
              Text(
                'L. ${costPerKg.toStringAsFixed(2)} por kg',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ComparisonBar extends StatelessWidget {
  final String label;
  final String value;
  final double fraction;
  final Color color;

  const _ComparisonBar({
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text(value,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction.clamp(0, 1),
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
