import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/domain/entities/user_role.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class RoleGuardWidget extends StatelessWidget {
  final List<UserRole> requiredRoles;
  final Widget child;
  final Widget? fallback;

  const RoleGuardWidget({
    super.key,
    required this.requiredRoles,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final hasAccess = authProvider.currentUser?.hasAnyRole(requiredRoles) ?? false;

    if (hasAccess) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}
