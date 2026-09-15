import 'user_role.dart';

class AppUser {
  final String id;
  final String churchId;
  final String name;
  final String email;
  final List<UserRole> roles;
  final String? cellGroupId;
  final String? avatarUrl;
  final String? phone;
  final DateTime joinedAt;

  const AppUser({
    required this.id,
    required this.churchId,
    required this.name,
    required this.email,
    required this.roles,
    this.cellGroupId,
    this.avatarUrl,
    this.phone,
    required this.joinedAt,
  });

  /// Verifica si el usuario posee un rol específico
  bool hasRole(UserRole role) {
    return roles.contains(role);
  }

  /// Verifica si el usuario posee al menos uno de los roles requeridos
  bool hasAnyRole(List<UserRole> requiredRoles) {
    if (requiredRoles.isEmpty) return true;
    return requiredRoles.any((r) => roles.contains(r));
  }

  bool get isAdmin => hasRole(UserRole.admin);
  bool get isLeader => hasRole(UserRole.cellLeader);
  bool get isTreasurer => hasRole(UserRole.treasurer);
  bool get isMember => hasRole(UserRole.member);

  AppUser copyWith({
    String? id,
    String? churchId,
    String? name,
    String? email,
    List<UserRole>? roles,
    String? cellGroupId,
    String? avatarUrl,
    String? phone,
    DateTime? joinedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      churchId: churchId ?? this.churchId,
      name: name ?? this.name,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      cellGroupId: cellGroupId ?? this.cellGroupId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
