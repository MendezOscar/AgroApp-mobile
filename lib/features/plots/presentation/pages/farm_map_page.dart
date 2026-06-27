import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/geo_point.dart';
import '../../domain/entities/plot_entity.dart';
import '../bloc/plots_bloc.dart';
import '../bloc/plots_event.dart';
import '../bloc/plots_state.dart';

class FarmMapPage extends StatefulWidget {
  final String farmId;
  final String farmName;

  const FarmMapPage({super.key, required this.farmId, required this.farmName});

  @override
  State<FarmMapPage> createState() => _FarmMapPageState();
}

class _FarmMapPageState extends State<FarmMapPage> {
  late final PlotsBloc _plotsBloc;

  @override
  void initState() {
    super.initState();
    _plotsBloc = sl<PlotsBloc>()..add(LoadPlots(widget.farmId));
  }

  @override
  void dispose() {
    _plotsBloc.close();
    super.dispose();
  }

  void _showPlotInfo(PlotEntity plot) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plot.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (plot.soilType != null) Text('Suelo: ${plot.soilType}'),
            if (plot.areaHa != null)
              Text('${plot.areaHa!.toStringAsFixed(1)} ha'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _plotsBloc,
      child: Scaffold(
        appBar: AppBar(title: Text('Mapa — ${widget.farmName}')),
        body: BlocBuilder<PlotsBloc, PlotsState>(
          builder: (context, state) {
            if (state is! PlotsLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final located = <PlotEntity, LatLng>{};
            for (final plot in state.plots) {
              final point = decodeGeoPoint(plot.geoJson);
              if (point != null) located[plot] = point;
            }

            if (located.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Ninguna parcela tiene ubicación asignada todavía.\n'
                    'Puedes asignarla desde el menú de cada parcela en "Parcelas".',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            final center = LatLng(
              located.values.map((p) => p.latitude).reduce((a, b) => a + b) /
                  located.length,
              located.values.map((p) => p.longitude).reduce((a, b) => a + b) /
                  located.length,
            );

            return FlutterMap(
              options: MapOptions(initialCenter: center, initialZoom: 14),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.osdadev.agroapp',
                ),
                MarkerLayer(
                  markers: located.entries
                      .map((e) => Marker(
                            point: e.value,
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () => _showPlotInfo(e.key),
                              child: const Icon(Icons.location_pin,
                                  color: AppTheme.primary, size: 40),
                            ),
                          ))
                      .toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
