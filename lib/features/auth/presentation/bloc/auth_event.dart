import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String tenantName;
  final String name;
  final String email;
  final String password;

  RegisterRequested({
    required this.tenantName,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [tenantName, name, email, password];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}
