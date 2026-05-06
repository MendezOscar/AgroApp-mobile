import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../bloc/crop_detail_cubit.dart';
import '../../bloc/crop_detail_state.dart';

class LaborTab extends StatelessWidget {
  final String cropId;
  const LaborTab({super.key, required this.cropId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CropDetailCubit, CropDetailState>(
      builder: (context, state) {
        if (state.isLoadingLabor) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        }

        return state.labors.isEmpty
            ? const Center(child: Text('No hay registros de labores'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.labors.length,
                itemBuilder: (_, i) {
                  final item = state.labors[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppTheme.accent,
                        child: Icon(Icons.agriculture,
                            color: Colors.white, size: 20),
                      ),
                      title: Text(item.activityType,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DateFormat('dd/MM/yyyy')
                              .format(item.performedAt)),
                          Text('${item.workersCount} trabajador(es)'),
                          if (item.hoursWorked != null)
                            Text(
                                '${item.hoursWorked!.toStringAsFixed(1)} horas'),
                          if (item.cost != null)
                            Text('L. ${item.cost!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600)),
                        ],
                      ),
                      trailing: IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => context
                            .read<CropDetailCubit>()
                            .deleteLabor(cropId, item.id),
                      ),
                    ),
                  );
                },
              );
      },
    );
  }
}
