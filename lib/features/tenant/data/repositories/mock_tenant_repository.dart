import 'package:flutter/material.dart';
import '../../domain/entities/church_tenant.dart';

abstract class TenantRepository {
  Future<ChurchTenant?> getTenantByCode(String code);
  Future<ChurchTenant> registerChurch({
    required String name,
    String? shortName,
    required String pastorName,
    required String email,
    required Color primaryColor,
  });
  Future<void> updateChurchCustomization({
    required String tenantId,
    required String name,
    String? shortName,
    required Color primaryColor,
    String? logoUrl,
  });
  Future<void> deleteChurch(String tenantId);
}

class MockTenantRepository implements TenantRepository {
  final List<ChurchTenant> _churches = [
    ChurchTenant(
      id: 'tenant-1',
      name: 'Iglesia Bautista Fundamental Independiente El Alfarero',
      shortName: 'El Alfarero',
      code: 'IBFIEA-150926',
      pastorName: 'Pastor David Morales',
      email: 'pastor.david@elalfarero.org',
      primaryColor: const Color(0xFF1E5BB8), // Azul Celestial
      logoUrl: null,
      address: 'Costado Oeste del Parque Central, Managua, Nicaragua',
      phone: '+505 2222 3456',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    ChurchTenant(
      id: 'tenant-2',
      name: 'Iglesia Bíblica Bautista El Redentor',
      shortName: 'El Redentor',
      code: 'IBBER-150926',
      pastorName: 'Pastor Samuel Gómez',
      email: 'samuel@elredentor.org',
      primaryColor: const Color(0xFF8B1E3F), // Vino de la Cena
      logoUrl: null,
      address: 'De la Rotonda El Güegüense 2c al Norte, Managua, Nicaragua',
      phone: '+505 8888 1234',
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
    ),
    ChurchTenant(
      id: 'tenant-3',
      name: 'Primera Iglesia Bautista de Masaya',
      shortName: 'PIB Masaya',
      code: 'PIBM-150926',
      pastorName: 'Pastor Daniel Mendoza',
      email: 'pastor@pibmasaya.org',
      primaryColor: const Color(0xFF1B6B48), // Verde Esperanza
      logoUrl: null,
      address: 'Barrio San Jerónimo, Masaya, Nicaragua',
      phone: '+505 8765 4321',
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
    String? shortName,
    required String pastorName,
    required String email,
    required Color primaryColor,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final churchCode = _generateMockChurchCode(name);
    final newChurch = ChurchTenant(
      id: 'tenant-${_churches.length + 1}',
      name: name,
      shortName: shortName ?? '',
      code: churchCode,
      pastorName: pastorName,
      email: email,
      primaryColor: primaryColor,
      createdAt: DateTime.now(),
    );
    _churches.add(newChurch);
    return newChurch;
  }

  String _generateMockChurchCode(String churchName) {
    final words = churchName
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    String acronym = '';
    for (final word in words) {
      final cleanWord = word.replaceAll(RegExp(r'[^a-zA-Z0-9áéíóúÁÉÍÓÚñÑ]'), '');
      if (cleanWord.isNotEmpty) {
        acronym += cleanWord[0].toUpperCase();
      }
    }

    if (acronym.isEmpty) {
      acronym = 'REB';
    }

    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = (now.year % 100).toString().padLeft(2, '0');

    return '$acronym-$day$month$year';
  }

  @override
  Future<void> updateChurchCustomization({
    required String tenantId,
    required String name,
    String? shortName,
    required Color primaryColor,
    String? logoUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _churches.indexWhere((c) => c.id == tenantId);
    if (index != -1) {
      _churches[index] = _churches[index].copyWith(
        name: name,
        shortName: shortName,
        primaryColor: primaryColor,
        logoUrl: logoUrl,
      );
    }
  }

  @override
  Future<void> deleteChurch(String tenantId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _churches.removeWhere((c) => c.id == tenantId);
  }
}
