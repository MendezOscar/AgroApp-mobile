import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../theme/app_theme.dart';

/// Botones de zoom +/- para superponer sobre un [FlutterMap]. Útil en
/// emuladores/desktop donde el gesto de pinch-zoom no siempre está
/// disponible o es poco intuitivo (Ctrl + arrastrar en el emulador Android).
class MapZoomButtons extends StatelessWidget {
  final MapController mapController;

  const MapZoomButtons({super.key, required this.mapController});

  void _zoomBy(double delta) {
    final camera = mapController.camera;
    final newZoom = (camera.zoom + delta).clamp(2.0, 19.0);
    mapController.move(camera.center, newZoom);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      right: 12,
      child: Column(
        children: [
          _ZoomButton(
            icon: Icons.add,
            onPressed: () => _zoomBy(1),
          ),
          const SizedBox(height: 8),
          _ZoomButton(
            icon: Icons.remove,
            onPressed: () => _zoomBy(-1),
          ),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ZoomButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: AppTheme.primary, size: 22),
        ),
      ),
    );
  }
}
