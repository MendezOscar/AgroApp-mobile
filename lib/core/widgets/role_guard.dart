import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

class RoleGuard extends StatelessWidget {
  final Widget child;
  final bool Function(String role) permission;
  final Widget? fallback;

  const RoleGuard({
    super.key,
    required this.child,
    required this.permission,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) return fallback ?? const SizedBox();
        final role = state.user.role;
        return permission(role) ? child : (fallback ?? const SizedBox());
      },
    );
  }
}
