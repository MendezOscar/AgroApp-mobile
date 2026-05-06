import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../bloc/crop_detail_cubit.dart';
import '../../bloc/crop_detail_state.dart';

class FertilizationTab extends StatelessWidget {
  final String cropId;
  const FertilizationTab({super.key, required this.cropId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CropDetailCubit, CropDetailState>(
      builder: (context, state) {
        if (state.isLoadingFertilization) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        }

        return state.fertilizations.isEmpty
            ? const Center(child: Text('No hay registros de fertilización'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.fertilizations.length,
                itemBuilder: (_, i) {
                  final item = state.fertilizations[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child:
                            Icon(Icons.science, color: Colors.white, size: 20),
                      ),
                      title: Text(item.productName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.productType != null) Text(item.productType!),
                          Text(DateFormat('dd/MM/yyyy').format(item.appliedAt)),
                          if (item.totalKg != null)
                            Text('${item.totalKg!.toStringAsFixed(1)} kg'),
                          if (item.cost != null)
                            Text('L. ${item.cost!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600)),
                          if (item.nextApplication != null)
                            Text(
                              'Próxima: ${DateFormat('dd/MM/yyyy').format(item.nextApplication!)}',
                              style: const TextStyle(color: AppTheme.accent),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => context
                            .read<CropDetailCubit>()
                            .deleteFertilization(cropId, item.id),
                      ),
                    ),
                  );
                },
              );
      },
    );
  }
}
