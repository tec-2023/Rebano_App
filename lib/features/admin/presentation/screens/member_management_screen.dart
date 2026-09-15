import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class MemberManagementScreen extends StatelessWidget {
  const MemberManagementScreen({super.key});

  void _showEditRolesModal(BuildContext context, AppUser member) {
    List<UserRole> selectedRoles = List.from(member.roles);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                      child: Text(
                        member.name[0],
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          Text(
                            member.email,
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 10),

                const Text(
                  'Asignar Roles Acumulativos (RBAC)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Un usuario puede tener múltiples roles simultáneos. Los módulos visibles se ajustarán a sus permisos.',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey),
                ),
                const SizedBox(height: 14),

                // Lista de Checkboxes de Roles
                ...UserRole.values.map((role) {
                  final isChecked = selectedRoles.contains(role);
                  return CustomCard(
                    onTap: () {
                      setModalState(() {
                        if (isChecked) {
                          // No permitir quitar rol de miembro base
                          if (role != UserRole.member) {
                            selectedRoles.remove(role);
                          }
                        } else {
                          selectedRoles.add(role);
                        }
                      });
                    },
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: isChecked ? Border.all(color: role.color, width: 1.5) : null,
                    child: Row(
                      children: [
                        Checkbox(
                          value: isChecked,
                          activeColor: role.color,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          onChanged: role == UserRole.member
                              ? null // El rol miembro siempre está activo
                              : (val) {
                                  setModalState(() {
                                    if (val == true) {
                                      selectedRoles.add(role);
                                    } else {
                                      selectedRoles.remove(role);
                                    }
                                  });
                                },
                        ),
                        const SizedBox(width: 8),
                        Icon(role.icon, color: role.color, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role.label,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                _getRoleDescription(role),
                                style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 20),

                AppButton(
                  text: 'Guardar Roles',
                  onPressed: () async {
                    await context.read<AuthProvider>().updateMemberRoles(member.id, selectedRoles);
                    if (context.mounted) {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Roles de "${member.name}" actualizados correctamente ✅'),
                          backgroundColor: const Color(0xFF15803D),
                        ),
                      );
                    }
                  },
                  icon: Icons.check,
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Acceso total a todos los módulos y personalización de marca blanca.';
      case UserRole.cellLeader:
        return 'Acceso al módulo de Células, Asistencia y Rutas de Evangelismo.';
      case UserRole.treasurer:
        return 'Acceso al módulo financiero, ingresos, gastos y exportación a Excel.';
      case UserRole.member:
        return 'Acceso básico al Muro de Oración y peticiones congregacionales.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final members = authProvider.churchMembers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios y Roles'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Banner de Explicación
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDDD6FE)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_rounded, color: Color(0xFF7C3AED), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Control de Permisos Eclesiásticos',
                        style: TextStyle(color: Color(0xFF6D28D9), fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Toca a cualquier miembro para añadirle o retirarle roles (Líder de Célula, Tesorero o Administrador).',
                        style: TextStyle(color: Color(0xFF5B21B6), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Text('Miembros Registrados (${members.length})', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),

          ...members.map((member) => CustomCard(
                onTap: () => _showEditRolesModal(context, member),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                      child: Text(
                        member.name[0],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            member.email,
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: member.roles.map((r) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: r.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: r.color.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  r.label,
                                  style: TextStyle(color: r.color, fontSize: 10.5, fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                  ],
                ),
              )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
