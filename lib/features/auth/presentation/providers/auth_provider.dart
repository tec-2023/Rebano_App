import 'package:flutter/material.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/user_role.dart';
import '../../data/repositories/mock_auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AppUser? _currentUser;
  List<AppUser> _churchMembers = [];
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? MockAuthRepository() {
    // Inicializar con Pastor David Morales por defecto para facilitar pruebas completas
    _currentUser = AppUser(
      id: 'user-1',
      churchId: 'tenant-1',
      name: 'Pastor David Morales',
      email: 'pastor@graciaypaz.org',
      roles: const [UserRole.admin, UserRole.member],
      phone: '+52 81 8000 1111',
      joinedAt: DateTime(2024, 1, 10),
    );
    _loadChurchMembers('tenant-1');
  }

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  List<AppUser> get churchMembers => _churchMembers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<UserRole> get currentRoles => _currentUser?.roles ?? [];

  bool hasRole(UserRole role) => _currentUser?.hasRole(role) ?? false;
  bool hasAnyRole(List<UserRole> roles) => _currentUser?.hasAnyRole(roles) ?? false;

  Future<void> _loadChurchMembers(String churchId) async {
    try {
      _churchMembers = await _repository.getChurchMembers(churchId);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.login(email, password);
      _currentUser = user;
      if (user != null) {
        await _loadChurchMembers(user.churchId);
      }
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _errorMessage = 'Credenciales inválidas: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String churchId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final admin = await _repository.registerAdmin(
        name: name,
        email: email,
        password: password,
        churchId: churchId,
      );
      _currentUser = admin;
      await _loadChurchMembers(churchId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error en el registro del Pastor: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerMember({
    required String name,
    required String email,
    required String password,
    required String churchId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final member = await _repository.registerMember(
        name: name,
        email: email,
        password: password,
        churchId: churchId,
      );
      _currentUser = member;
      await _loadChurchMembers(churchId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error en el registro de miembro: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Permite cambiar de perfil de prueba de manera instantánea
  void switchDemoRole(UserRole role) {
    if (_currentUser == null) return;

    List<UserRole> newRoles;
    String demoName = _currentUser!.name;

    switch (role) {
      case UserRole.admin:
        newRoles = [UserRole.admin, UserRole.member];
        demoName = 'Pastor David Morales (Admin)';
        break;
      case UserRole.cellLeader:
        newRoles = [UserRole.cellLeader, UserRole.member];
        demoName = 'María Fernanda (Líder Célula)';
        break;
      case UserRole.treasurer:
        newRoles = [UserRole.treasurer, UserRole.member];
        demoName = 'Carlos Mendoza (Tesorero)';
        break;
      case UserRole.member:
        newRoles = [UserRole.member];
        demoName = 'Juan Silva (Miembro)';
        break;
    }

    _currentUser = _currentUser!.copyWith(
      roles: newRoles,
      name: demoName,
    );
    notifyListeners();
  }

  Future<void> updateMemberRoles(String userId, List<UserRole> roles) async {
    try {
      final updated = await _repository.updateUserRoles(userId, roles);
      final index = _churchMembers.indexWhere((m) => m.id == userId);
      if (index != -1) {
        _churchMembers[index] = updated;
      }
      if (_currentUser?.id == userId) {
        _currentUser = updated;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'No se pudieron actualizar los roles: $e';
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
