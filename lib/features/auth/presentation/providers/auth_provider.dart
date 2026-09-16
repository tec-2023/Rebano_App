import 'package:flutter/material.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/utils/error_translator.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/user_role.dart';
import '../../data/repositories/mock_auth_repository.dart';
import '../../data/repositories/supabase_auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AppUser? _currentUser;
  List<AppUser> _churchMembers = [];
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ??
            (SupabaseConfig.isInitialized
                ? SupabaseAuthRepository()
                : MockAuthRepository()) {
    _initSession();
  }

  Future<void> _initSession() async {
    final repo = _repository;
    if (repo is SupabaseAuthRepository) {
      final existingUser = await repo.getCurrentUser();
      if (existingUser != null) {
        _currentUser = existingUser;
        await _loadChurchMembers(existingUser.churchId);
        notifyListeners();
        return;
      }
    }

    // Default mock demo user if no active session
    _currentUser = AppUser(
      id: 'user-1',
      churchId: 'tenant-1',
      name: 'Pastor David Morales',
      email: 'pastor@elalfarero.org',
      roles: const [UserRole.admin, UserRole.member],
      phone: '+505 8888 1111',
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
      _errorMessage = ErrorTranslator.translate(e);
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
      _errorMessage = ErrorTranslator.translate(e);
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
      _errorMessage = ErrorTranslator.translate(e);
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

  Future<bool> updateUserProfile({
    required String name,
    String? phone,
    String? newPassword,
  }) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateUserProfile(
        userId: _currentUser!.id,
        name: name,
        phone: phone,
        newPassword: newPassword,
      );
      _currentUser = updated;
      final index = _churchMembers.indexWhere((m) => m.id == updated.id);
      if (index != -1) {
        _churchMembers[index] = updated;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar perfil: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final repo = _repository;
    if (repo is SupabaseAuthRepository) {
      await repo.signOut();
    }
    _currentUser = null;
    notifyListeners();
  }
}
