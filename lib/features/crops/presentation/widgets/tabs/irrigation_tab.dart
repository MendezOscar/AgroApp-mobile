import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../bloc/crop_detail_cubit.dart';
import '../../bloc/crop_detail_state.dart';

class IrrigationTab extends StatelessWidget {
  final String cropId;
  const IrrigationTab({super.key, required this.cropId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CropDetailCubit, CropDetailState>(
      builder: (context, state) {
        if (state.isLoadingIrrigation) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        }

        return Column(
          children: [
            Expanded(
              child: state.irrigations.isEmpty
                  ? const Center(child: Text('No hay registros de riego'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.irrigations.length,
                      itemBuilder: (_, i) {
                        final item = state.irrigations[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.water_drop,
                                  color: Colors.white, size: 20),
                            ),
                            title: Text(item.method,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(DateFormat('dd/MM/yyyy HH:mm')
                                    .format(item.appliedAt)),
                                if (item.volumeLiters != null)
                                  Text(
                                      '${item.volumeLiters!.toStringAsFixed(0)} litros'),
                                if (item.durationMin != null)
                                  Text('${item.durationMin} minutos'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => context
                                  .read<CropDetailCubit>()
                                  .deleteIrrigation(cropId, item.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
