import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/crops/domain/entities/crop_entity.dart';
import '../../features/crops/presentation/pages/crop_detail_page.dart';
import '../../features/crops/presentation/pages/crops_page.dart';
import '../../features/farms/presentation/pages/farms_page.dart';
import '../../features/plots/presentation/pages/plots_page.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/farms';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      GoRoute(
        path: '/farms',
        builder: (_, __) => const FarmsPage(),
        routes: [
          GoRoute(
            path: ':farmId/plots',
            builder: (context, state) {
              final farmId = state.pathParameters['farmId']!;
              final farmName = state.extra as String? ?? 'Parcelas';
              return PlotsPage(farmId: farmId, farmName: farmName);
            },
            routes: [
              GoRoute(
                path: ':plotId/crops',
                builder: (context, state) {
                  final plotId = state.pathParameters['plotId']!;
                  final plotName = state.extra as String? ?? 'Cultivos';
                  return CropsPage(plotId: plotId, plotName: plotName);
                },
              ),
            ],
          ),
        ],
      ),
      // Ruta de detalle al nivel raíz — accesible desde cualquier punto
      GoRoute(
        path: '/crop-detail',
        builder: (context, state) {
          final crop = state.extra as CropEntity;
          return CropDetailPage(crop: crop);
        },
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
