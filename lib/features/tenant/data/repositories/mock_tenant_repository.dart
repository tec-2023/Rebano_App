import 'package:flutter/material.dart';
import '../../domain/entities/church_tenant.dart';

abstract class TenantRepository {
  Future<ChurchTenant?> getTenantByCode(String code);
  Future<ChurchTenant> registerChurch({
    required String name,
    required String pastorName,
    required String email,
    required Color primaryColor,
  });
  Future<void> updateChurchCustomization({
    required String tenantId,
    required String name,
    required Color primaryColor,
    String? logoUrl,
  });
}

class MockTenantRepository implements TenantRepository {
  final List<ChurchTenant> _churches = [
    ChurchTenant(
      id: 'tenant-1',
      name: 'Comunidad Gracia y Paz',
      code: 'REB-1054',
      pastorName: 'Pastor David Morales',
      email: 'pastor.david@graciaypaz.org',
      primaryColor: const Color(0xFF1E5BB8), // Azul Celestial
      logoUrl: null,
      address: 'Av. Esperanza #400, Monterrey, N.L.',
      phone: '+52 81 8300 1234',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    ChurchTenant(
      id: 'tenant-2',
      name: 'Iglesia Bíblica El Redentor',
      code: 'REB-2048',
      pastorName: 'Pastor Samuel Gómez',
      email: 'samuel@elredentor.org',
      primaryColor: const Color(0xFF8B1E3F), // Vino Litúrgico
      logoUrl: null,
      address: 'Calle Reforma #55, CDMX',
      phone: '+52 55 5678 9012',
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
    ),
    ChurchTenant(
      id: 'tenant-3',
      name: 'Templo Betel Central',
      code: 'REB-3099',
      pastorName: 'Pastora Ana Lucía Pérez',
      email: 'ana.perez@betel.org',
      primaryColor: const Color(0xFF1B6B48), // Verde Esperanza
      logoUrl: null,
      address: 'Boulevard Los Olivos #12, Guadalajara, Jal.',
      phone: '+52 33 3456 7890',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
  ];

  @override
  Future<ChurchTenant?> getTenantByCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final normalizedCode = code.trim().toUpperCase();
    try {
      return _churches.firstWhere(
        (c) => c.code.toUpperCase() == normalizedCode,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ChurchTenant> registerChurch({
    required String name,
    required String pastorName,
    required String email,
    required Color primaryColor,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final randomNum = 4000 + _churches.length * 15;
    final newChurch = ChurchTenant(
      id: 'tenant-${_churches.length + 1}',
      name: name,
      code: 'REB-$randomNum',
      pastorName: pastorName,
      email: email,
      primaryColor: primaryColor,
      createdAt: DateTime.now(),
    );
    _churches.add(newChurch);
    return newChurch;
  }

  @override
  Future<void> updateChurchCustomization({
    required String tenantId,
    required String name,
    required Color primaryColor,
    String? logoUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _churches.indexWhere((c) => c.id == tenantId);
    if (index != -1) {
      _churches[index] = _churches[index].copyWith(
        name: name,
        primaryColor: primaryColor,
        logoUrl: logoUrl,
      );
    }
  }
}
