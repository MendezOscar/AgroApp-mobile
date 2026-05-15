import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

class UsersState extends Equatable {
  final List<UserEntity> users;
  final bool isLoading;
  final String? error;
  final String? success;

  const UsersState({
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.success,
  });

  UsersState copyWith({
    List<UserEntity>? users,
    bool? isLoading,
    String? error,
    String? success,
  }) =>
      UsersState(
        users: users ?? this.users,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        success: success,
      );

  @override
  List<Object?> get props => [users, isLoading, error, success];
}
