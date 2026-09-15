import '../../domain/entities/app_user.dart';
import '../../domain/entities/user_role.dart';

abstract class AuthRepository {
  Future<AppUser?> login(String email, String password);
  Future<AppUser> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String churchId,
  });
  Future<AppUser> registerMember({
    required String name,
    required String email,
    required String password,
    required String churchId,
  });
  Future<List<AppUser>> getChurchMembers(String churchId);
  Future<AppUser> updateUserRoles(String userId, List<UserRole> newRoles);
}

class MockAuthRepository implements AuthRepository {
  final List<AppUser> _users = [
    AppUser(
      id: 'user-1',
      churchId: 'tenant-1',
      name: 'Pastor David Morales',
      email: 'pastor@graciaypaz.org',
      roles: const [UserRole.admin, UserRole.member],
      phone: '+52 81 8000 1111',
      joinedAt: DateTime(2024, 1, 10),
    ),
    AppUser(
      id: 'user-2',
      churchId: 'tenant-1',
      name: 'Carlos Mendoza',
      email: 'carlos.tesorero@graciaypaz.org',
      roles: const [UserRole.treasurer, UserRole.cellLeader, UserRole.member],
      cellGroupId: 'cell-1',
      phone: '+52 81 8000 2222',
      joinedAt: DateTime(2024, 2, 15),
    ),
    AppUser(
      id: 'user-3',
      churchId: 'tenant-1',
      name: 'María Fernanda Ríos',
      email: 'maria.lider@graciaypaz.org',
      roles: const [UserRole.cellLeader, UserRole.member],
      cellGroupId: 'cell-1',
      phone: '+52 81 8000 3333',
      joinedAt: DateTime(2024, 3, 20),
    ),
    AppUser(
      id: 'user-4',
      churchId: 'tenant-1',
      name: 'Juan Silva',
      email: 'juan.miembro@graciaypaz.org',
      roles: const [UserRole.member],
      cellGroupId: 'cell-1',
      phone: '+52 81 8000 4444',
      joinedAt: DateTime(2024, 5, 5),
    ),
    AppUser(
      id: 'user-5',
      churchId: 'tenant-1',
      name: 'Lucía Benítez',
      email: 'lucia.b@graciaypaz.org',
      roles: const [UserRole.member],
      cellGroupId: 'cell-1',
      phone: '+52 81 8000 5555',
      joinedAt: DateTime(2024, 6, 12),
    ),
    AppUser(
      id: 'user-6',
      churchId: 'tenant-1',
      name: 'Roberto Gómez',
      email: 'roberto.g@graciaypaz.org',
      roles: const [UserRole.member],
      cellGroupId: 'cell-1',
      phone: '+52 81 8000 6666',
      joinedAt: DateTime(2024, 7, 01),
    ),
  ];

  @override
  Future<AppUser?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final normalized = email.trim().toLowerCase();
    try {
      return _users.firstWhere((u) => u.email.toLowerCase() == normalized);
    } catch (_) {
      // Si no existe, creamos un usuario de demostración
      final mockUser = AppUser(
        id: 'user-${DateTime.now().millisecondsSinceEpoch}',
        churchId: 'tenant-1',
        name: email.split('@').first.toUpperCase(),
        email: email,
        roles: const [UserRole.member],
        joinedAt: DateTime.now(),
      );
      _users.add(mockUser);
      return mockUser;
    }
  }

  @override
  Future<AppUser> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String churchId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final admin = AppUser(
      id: 'user-admin-${DateTime.now().millisecondsSinceEpoch}',
      churchId: churchId,
      name: name,
      email: email,
      roles: const [UserRole.admin, UserRole.member],
      joinedAt: DateTime.now(),
    );
    _users.add(admin);
    return admin;
  }

  @override
  Future<AppUser> registerMember({
    required String name,
    required String email,
    required String password,
    required String churchId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final member = AppUser(
      id: 'user-mem-${DateTime.now().millisecondsSinceEpoch}',
      churchId: churchId,
      name: name,
      email: email,
      roles: const [UserRole.member],
      joinedAt: DateTime.now(),
    );
    _users.add(member);
    return member;
  }

  @override
  Future<List<AppUser>> getChurchMembers(String churchId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _users.where((u) => u.churchId == churchId).toList();
  }

  @override
  Future<AppUser> updateUserRoles(String userId, List<UserRole> newRoles) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      // Garantizar que siempre tenga al menos el rol de miembro
      final finalRoles = List<UserRole>.from(newRoles);
      if (!finalRoles.contains(UserRole.member)) {
        finalRoles.add(UserRole.member);
      }
      final updated = _users[index].copyWith(roles: finalRoles);
      _users[index] = updated;
      return updated;
    }
    throw Exception('Usuario no encontrado');
  }
}
