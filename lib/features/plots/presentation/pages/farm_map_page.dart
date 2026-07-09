import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/geo_point.dart';
import '../../../../core/widgets/map_zoom_buttons.dart';
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
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _plotsBloc = sl<PlotsBloc>()..add(LoadPlots(widget.farmId));
  }

  @override
  void dispose() {
    _plotsBloc.close();
    _mapController.dispose();
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

            final polygons = <PlotEntity, List<LatLng>>{};
            final legacyPoints = <PlotEntity, LatLng>{};
            for (final plot in state.plots) {
              final ring = decodeGeoPolygon(plot.geoJson);
              if (ring != null && ring.length >= 3) {
                polygons[plot] = ring;
                continue;
              }
              final point = decodeGeoPoint(plot.geoJson);
              if (point != null) legacyPoints[plot] = point;
            }

            if (polygons.isEmpty && legacyPoints.isEmpty) {
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

            LatLng centroidOf(List<LatLng> points) => LatLng(
                  points.map((p) => p.latitude).reduce((a, b) => a + b) /
                      points.length,
                  points.map((p) => p.longitude).reduce((a, b) => a + b) /
                      points.length,
                );

            final centroids = {
              for (final e in polygons.entries) e.key: centroidOf(e.value),
              ...legacyPoints,
            };

            final center = centroidOf(centroids.values.toList());

            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(initialCenter: center, initialZoom: 14),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.osdadev.agroapp',
                    ),
                    PolygonLayer(
                      polygons: polygons.values
                          .map((points) => Polygon(
                                points: points,
                                color:
                                    AppTheme.primary.withValues(alpha: 0.25),
                                borderColor: AppTheme.primary,
                                borderStrokeWidth: 2,
                              ))
                          .toList(),
                    ),
                    MarkerLayer(
                      markers: [
                        ...polygons.keys.map((plot) => Marker(
                              point: centroids[plot]!,
                              width: 32,
                              height: 32,
                              child: GestureDetector(
                                onTap: () => _showPlotInfo(plot),
                                child: const Icon(Icons.crop_square,
                                    color: AppTheme.primary, size: 28),
                              ),
                            )),
                        ...legacyPoints.entries.map((e) => Marker(
                              point: e.value,
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                onTap: () => _showPlotInfo(e.key),
                                child: const Icon(Icons.location_pin,
                                    color: AppTheme.primary, size: 40),
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
                MapZoomButtons(mapController: _mapController),
              ],
            );
          },
        ),
      ),
    );
  }
}
