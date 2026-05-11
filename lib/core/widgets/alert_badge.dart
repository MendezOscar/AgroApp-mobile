import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/alerts/data/datasources/alerts_remote_datasource.dart';
import '../di/injection.dart';
import '../theme/app_theme.dart';

class AlertBadge extends StatefulWidget {
  const AlertBadge({super.key});

  @override
  State<AlertBadge> createState() => _AlertBadgeState();
}

class _AlertBadgeState extends State<AlertBadge> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    try {
      final count = await sl<AlertsRemoteDatasource>().getUnreadCount();
      if (mounted) setState(() => _count = count);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await context.push('/alerts');
        _loadCount(); // Recargar al volver
      },
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined),
          if (_count > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$_count',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
