import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/users_cubit.dart';
import '../bloc/users_state.dart';

class UsersManagementPage extends StatelessWidget {
  const UsersManagementPage({super.key});

  Color _roleColor(String role) => switch (role) {
        'Admin' => Colors.purple,
        'Manager' => Colors.blue,
        'Farmer' => AppTheme.primary,
        _ => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<UsersCubit>().loadUsers(),
          ),
        ],
      ),
      body: BlocConsumer<UsersCubit, UsersState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.error!), backgroundColor: AppTheme.error),
            );
          }
          if (state.success != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.success!),
                  backgroundColor: AppTheme.primary),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) return const LoadingWidget();

          return Column(
            children: [
              // Resumen
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _roleSummary(state.users, 'Admin', Colors.purple),
                    _roleSummary(state.users, 'Manager', Colors.blue),
                    _roleSummary(state.users, 'Farmer', AppTheme.primary),
                    _roleSummary(state.users, 'Viewer', Colors.grey),
                  ],
                ),
              ),

              // Lista
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.users.length,
                  itemBuilder: (_, i) {
                    final user = state.users[i];
                    return _UserCard(
                      user: user,
                      roleColor: _roleColor(user.role),
                      onToggle: (isActive) => context
                          .read<UsersCubit>()
                          .toggleUser(user.id, isActive),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Invitar usuario',
            style: TextStyle(color: Colors.white)),
        onPressed: () => _showInviteUser(context),
      ),
    );
  }

  Widget _roleSummary(List<UserEntity> users, String role, Color color) {
    final count = users.where((u) => u.role == role && u.isActive).length;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text('$count',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(role,
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _showInviteUser(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedRole = 'Farmer';
    final formKey = GlobalKey<FormState>();
    final roles = ['Admin', 'Manager', 'Farmer', 'Viewer'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<UsersCubit>(),
        child: StatefulBuilder(
          builder: (context, setState) => BlocListener<UsersCubit, UsersState>(
            listener: (context, state) {
              if (state.success != null) Navigator.pop(context);
            },
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Invitar Usuario',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo *',
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                      validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña temporal *',
                        prefixIcon: Icon(Icons.lock_outlined),
                      ),
                      validator: (v) =>
                          v!.length < 8 ? 'Mínimo 8 caracteres' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        prefixIcon: Icon(Icons.shield_outlined),
                      ),
                      items: roles
                          .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedRole = v!),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<UsersCubit, UsersState>(
                      builder: (context, state) => ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  context.read<UsersCubit>().inviteUser(
                                        name: nameCtrl.text.trim(),
                                        email: emailCtrl.text.trim(),
                                        password: passwordCtrl.text,
                                        role: selectedRole,
                                      );
                                }
                              },
                        child: state.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Invitar usuario'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserEntity user;
  final Color roleColor;
  final Function(bool) onToggle;

  const _UserCard({
    required this.user,
    required this.roleColor,
    required this.onToggle,
  });

  String get _initials => user.name
      .split(' ')
      .take(2)
      .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
      .join();

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: user.isActive ? roleColor : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              _initials,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: user.isActive ? Colors.black87 : Colors.grey,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: user.isActive
                    ? roleColor.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user.role,
                style: TextStyle(
                  color: user.isActive ? roleColor : Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email,
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            if (user.lastLoginAt != null)
              Text(
                'Último acceso: ${fmt.format(user.lastLoginAt!)}',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
          ],
        ),
        trailing: Switch(
          value: user.isActive,
          activeColor: AppTheme.primary,
          onChanged: onToggle,
        ),
      ),
    );
  }
}
