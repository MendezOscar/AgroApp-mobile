import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_theme.dart';

const _defaultCenter = LatLng(14.6, -86.8); // Honduras

class LocationPickerPage extends StatefulWidget {
  final LatLng? initial;

  const LocationPickerPage({super.key, this.initial});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  LatLng? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubicar parcela')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: widget.initial ?? _defaultCenter,
          initialZoom: widget.initial != null ? 16 : 7,
          onTap: (_, point) => setState(() => _selected = point),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.osdadev.agroapp',
          ),
          if (_selected != null)
            MarkerLayer(markers: [
              Marker(
                point: _selected!,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_pin,
                    color: AppTheme.primary, size: 40),
              ),
            ]),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text('Confirmar ubicación',
            style: TextStyle(color: Colors.white)),
        onPressed: _selected == null
            ? null
            : () => Navigator.pop(context, _selected),
      ),
    );
  }
}
