import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_entity.dart';

class AuthUserData extends AuthEntity {
  const AuthUserData({required super.token})
      : super(
          refreshToken: '',
          name: '',
          email: '',
          role: '',
          tenantId: '',
        );
}

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthEntity user;
  AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
