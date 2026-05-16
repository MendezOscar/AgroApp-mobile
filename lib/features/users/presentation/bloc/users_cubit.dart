import '../../../../core/bloc/safe_cubit.dart';
import '../../data/datasources/users_remote_datasource.dart';
import '../../data/models/user_model.dart';
import 'users_state.dart';

class UsersCubit extends SafeCubit<UsersState> {
  final UsersRemoteDatasource _datasource;

  UsersCubit(this._datasource) : super(const UsersState());

  Future<void> loadUsers() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final data = await _datasource.getUsers();
      emit(state.copyWith(
        users: data.map((e) => UserModel.fromJson(e)).toList(),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Error al cargar usuarios'));
    }
  }

  Future<void> inviteUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      await _datasource.inviteUser({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
      await loadUsers();
      emit(state.copyWith(success: 'Usuario invitado correctamente'));
    } catch (e) {
      emit(state.copyWith(error: 'Error al invitar usuario'));
    }
  }

  Future<void> toggleUser(String id, bool isActive) async {
    try {
      await _datasource.toggleUser(id, isActive);
      await loadUsers();
      emit(state.copyWith(
          success: isActive ? 'Usuario activado' : 'Usuario desactivado'));
    } catch (e) {
      emit(state.copyWith(error: 'Error al actualizar usuario'));
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      await _datasource.changePassword(currentPassword, newPassword);
      emit(state.copyWith(success: 'Contraseña actualizada correctamente'));
    } catch (e) {
      emit(state.copyWith(error: 'Contraseña actual incorrecta'));
    }
  }
}
