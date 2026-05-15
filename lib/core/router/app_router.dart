import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/alerts/presentation/pages/alerts_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/crops/domain/entities/crop_entity.dart';
import '../../features/crops/presentation/pages/crop_detail_page.dart';
import '../../features/crops/presentation/pages/crops_page.dart';
import '../../features/farms/presentation/pages/farms_page.dart';
import '../../features/plots/presentation/pages/plots_page.dart';
import '../../features/sensors/presentation/pages/dashboard_page.dart';
import '../../features/users/presentation/pages/profile_page.dart';
import '../widgets/main_shell.dart';

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
      if (isAuthenticated && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

      // Shell con BottomNavigationBar
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardPage(),
          ),
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
          GoRoute(
            path: '/alerts',
            builder: (_, __) => const AlertsPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfilePage(),
          ),
        ],
      ),

      // Fuera del shell — pantallas de detalle
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
