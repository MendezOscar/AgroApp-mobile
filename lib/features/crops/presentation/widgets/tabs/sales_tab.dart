import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../bloc/crop_detail_cubit.dart';
import '../../bloc/crop_detail_state.dart';

class SalesTab extends StatelessWidget {
  final String cropId;
  const SalesTab({super.key, required this.cropId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CropDetailCubit, CropDetailState>(
      builder: (context, state) {
        if (state.isLoadingSales) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        }

        if (state.sales.isEmpty) {
          return const Center(child: Text('No hay ventas registradas'));
        }

        final totalRevenue =
            state.sales.fold<double>(0, (sum, s) => sum + s.totalAmount);

        return RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () => context.read<CropDetailCubit>().loadSales(cropId),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: AppTheme.primary.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ingresos totales',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('L. ${totalRevenue.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...state.sales.map((item) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.sell_outlined,
                            color: Colors.white, size: 20),
                      ),
                      title: Text(
                          '${item.quantityKg.toStringAsFixed(1)} kg × L. ${item.pricePerKg.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DateFormat('dd/MM/yyyy').format(item.soldAt)),
                          if (item.buyer != null) Text(item.buyer!),
                        ],
                      ),
                      trailing: Text(
                        'L. ${item.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
