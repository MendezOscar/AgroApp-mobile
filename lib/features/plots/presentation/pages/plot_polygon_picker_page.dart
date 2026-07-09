import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/geo_point.dart';
import '../../../../core/widgets/map_zoom_buttons.dart';

const _defaultCenter = LatLng(14.6, -86.8); // Honduras

class PlotPolygonPickerPage extends StatefulWidget {
  final List<LatLng>? initialPoints;
  final LatLng? initialCenter;

  const PlotPolygonPickerPage({
    super.key,
    this.initialPoints,
    this.initialCenter,
  });

  @override
  State<PlotPolygonPickerPage> createState() => _PlotPolygonPickerPageState();
}

class _PlotPolygonPickerPageState extends State<PlotPolygonPickerPage> {
  late List<LatLng> _points;
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _points = List.of(widget.initialPoints ?? const []);
  }

  LatLng get _mapCenter =>
      widget.initialCenter ??
      (_points.isNotEmpty ? _points.first : _defaultCenter);

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _undoLast() {
    if (_points.isEmpty) return;
    setState(() => _points.removeLast());
  }

  void _reset() {
    setState(() => _points.clear());
  }

  @override
  Widget build(BuildContext context) {
    final area = polygonAreaHectares(_points);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dibujar parcela'),
        actions: [
          IconButton(
            onPressed: _points.isEmpty ? null : _undoLast,
            icon: const Icon(Icons.undo),
            tooltip: 'Deshacer último punto',
          ),
          IconButton(
            onPressed: _points.isEmpty ? null : _reset,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Reiniciar',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppTheme.primary.withValues(alpha: 0.08),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              _points.length < 3
                  ? 'Toca el mapa para marcar los vértices de la parcela '
                      '(mínimo 3 puntos).'
                  : 'Área: ${area.toStringAsFixed(2)} ha · ${_points.length} '
                      'puntos',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppTheme.primary),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _mapCenter,
                    initialZoom: widget.initialCenter != null ||
                            widget.initialPoints != null
                        ? 16
                        : 7,
                    onTap: (_, point) => setState(() => _points.add(point)),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.osdadev.agroapp',
                    ),
                    if (_points.length >= 3)
                      PolygonLayer(polygons: [
                        Polygon(
                          points: _points,
                          color: AppTheme.primary.withValues(alpha: 0.25),
                          borderColor: AppTheme.primary,
                          borderStrokeWidth: 2,
                        ),
                      ]),
                    if (_points.length >= 2)
                      PolylineLayer(polylines: [
                        Polyline(
                          points: _points,
                          color: AppTheme.primary,
                          strokeWidth: 2,
                        ),
                      ]),
                    MarkerLayer(
                      markers: _points
                          .map((p) => Marker(
                                point: p,
                                width: 14,
                                height: 14,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
                MapZoomButtons(mapController: _mapController),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text('Confirmar parcela',
            style: TextStyle(color: Colors.white)),
        onPressed: _points.length < 3
            ? null
            : () => Navigator.pop(context, _points),
      ),
    );
  }
}
