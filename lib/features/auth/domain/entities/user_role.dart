import 'package:flutter/material.dart';

enum UserRole {
  member('miembro', 'Miembro', Icons.person_outline, Color(0xFFD97706)),
  cellLeader('lider_celula', 'Líder de Célula', Icons.groups_outlined, Color(0xFF2563EB)),
  treasurer('tesorero', 'Tesorero', Icons.account_balance_wallet_outlined, Color(0xFF059669)),
  admin('admin', 'Pastor / Administrador', Icons.admin_panel_settings_outlined, Color(0xFF7C3AED));

  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const UserRole(this.key, this.label, this.icon, this.color);

  static UserRole fromKey(String key) {
    switch (key.toLowerCase()) {
      case 'lider_celula':
        return UserRole.cellLeader;
      case 'tesorero':
        return UserRole.treasurer;
      case 'admin':
        return UserRole.admin;
      case 'miembro':
      default:
        return UserRole.member;
    }
  }
}
