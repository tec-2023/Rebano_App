import 'package:flutter/material.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/utils/error_translator.dart';
import '../../domain/entities/church_tenant.dart';
import '../../data/repositories/mock_tenant_repository.dart';
import '../../data/repositories/supabase_tenant_repository.dart';

class TenantProvider extends ChangeNotifier {
  final TenantRepository _repository;

  ChurchTenant _currentTenant;
  bool _isLoading = false;
  String? _errorMessage;

  TenantProvider({TenantRepository? repository})
      : _repository = repository ??
            (SupabaseConfig.isInitialized
                ? SupabaseTenantRepository()
                : MockTenantRepository()),
        _currentTenant = ChurchTenant(
          id: 'tenant-1',
          name: 'Iglesia Bautista Fundamental Independiente El Alfarero',
          shortName: 'El Alfarero',
          code: 'IBFIEA-150926',
          pastorName: 'Pastor David Morales',
          email: 'pastor.david@elalfarero.org',
          primaryColor: const Color(0xFF1E5BB8),
          address: 'Costado Oeste del Parque Central, Managua, Nicaragua',
          phone: '+505 2222 3456',
          createdAt: DateTime(2025, 1, 1),
        );

  ChurchTenant get currentTenant => _currentTenant;
  Color get primaryColor => _currentTenant.primaryColor;
  String get churchName => _currentTenant.name;
  String get shortName => _currentTenant.displayName;
  String get churchCode => _currentTenant.code;
  String? get logoUrl => _currentTenant.logoUrl;
  String? get motto => _currentTenant.motto;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setTenant(ChurchTenant tenant) {
    _currentTenant = tenant;
    notifyListeners();
  }

  /// Carga la iglesia por su ID (usado en login al obtener id_iglesia del perfil)
  Future<bool> loadTenantById(String churchId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final repo = _repository;
      if (repo is SupabaseTenantRepository) {
        final tenant = await repo.getTenantById(churchId);
        if (tenant != null) {
          _currentTenant = tenant;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error al cargar congregación: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loadTenantByCode(String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tenant = await _repository.getTenantByCode(code);
      if (tenant != null) {
        _currentTenant = tenant;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Código de iglesia no encontrado. Verifica con tu pastor.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = ErrorTranslator.translate(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<ChurchTenant?> registerChurch({
    required String name,
    String? shortName,
    required String pastorName,
    required String email,
    required Color primaryColor,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newChurch = await _repository.registerChurch(
        name: name,
        shortName: shortName,
        pastorName: pastorName,
        email: email,
        primaryColor: primaryColor,
      );
      _currentTenant = newChurch;
      _isLoading = false;
      notifyListeners();
      return newChurch;
    } catch (e) {
      _errorMessage = ErrorTranslator.translate(e);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateCustomization({
    required String name,
    String? shortName,
    required Color primaryColor,
    String? logoUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.updateChurchCustomization(
        tenantId: _currentTenant.id,
        name: name,
        shortName: shortName,
        primaryColor: primaryColor,
        logoUrl: logoUrl,
      );
      _currentTenant = _currentTenant.copyWith(
        name: name,
        shortName: shortName,
        primaryColor: primaryColor,
        logoUrl: logoUrl,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar personalización: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteChurch() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteChurch(_currentTenant.id);
      _currentTenant = ChurchTenant(
        id: '',
        name: 'Sin Congregación',
        code: '',
        pastorName: '',
        email: '',
        primaryColor: const Color(0xFF1E5BB8),
        createdAt: DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar la congregación: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
