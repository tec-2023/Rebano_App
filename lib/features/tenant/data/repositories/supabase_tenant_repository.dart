import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/church_tenant.dart';
import 'mock_tenant_repository.dart';

class SupabaseTenantRepository implements TenantRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  @override
  Future<ChurchTenant?> getTenantByCode(String code) async {
    try {
      final clean = code.trim();
      if (clean.isEmpty) return null;

      // 1. Buscar por ID exacto de la congregación
      var data = await _client
          .from('iglesias')
          .select('id, nombre_completo, logo_url, color_principal, lema_o_vision')
          .eq('id', clean)
          .maybeSingle();

      // 2. Si no se encuentra por ID exacto, buscar por coincidencia en el nombre
      if (data == null) {
        final List<dynamic> list = await _client
            .from('iglesias')
            .select('id, nombre_completo, logo_url, color_principal, lema_o_vision')
            .ilike('nombre_completo', '%$clean%')
            .limit(1);
        if (list.isNotEmpty) {
          data = list.first as Map<String, dynamic>;
        }
      }

      if (data == null) return null;
      return _mapToChurchTenant(data);
    } catch (e) {
      debugPrint('[SupabaseTenantRepository] Error al obtener iglesia por código/ID: $e');
      return null;
    }
  }

  /// Obtiene los datos de la iglesia por su ID (Multi-tenant Branding)
  Future<ChurchTenant?> getTenantById(String churchId) async {
    try {
      final data = await _client
          .from('iglesias')
          .select('id, nombre_completo, logo_url, color_principal, lema_o_vision')
          .eq('id', churchId)
          .maybeSingle();

      if (data == null) return null;
      return _mapToChurchTenant(data);
    } catch (e) {
      debugPrint('[SupabaseTenantRepository] Error al obtener iglesia por ID: $e');
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
    try {
      final hexColor = AppColors.toHex(primaryColor);

      // Insertamos únicamente las columnas existentes en la tabla 'iglesias'
      final insertPayload = <String, dynamic>{
        'nombre_completo': name.trim(),
        'color_principal': hexColor,
      };

      final data = await _client
          .from('iglesias')
          .insert(insertPayload)
          .select('id, nombre_completo, logo_url, color_principal, lema_o_vision')
          .single();

      final tenant = _mapToChurchTenant(data);
      return tenant.copyWith(
        pastorName: pastorName.trim(),
        email: email.trim(),
      );
    } catch (e) {
      debugPrint('[SupabaseTenantRepository] Error al registrar iglesia: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateChurchCustomization({
    required String tenantId,
    required String name,
    required Color primaryColor,
    String? logoUrl,
  }) async {
    try {
      final hexColor = AppColors.toHex(primaryColor);
      final updateData = <String, dynamic>{
        'nombre_completo': name.trim(),
        'color_principal': hexColor,
      };
      if (logoUrl != null) {
        updateData['logo_url'] = logoUrl;
      }

      await _client
          .from('iglesias')
          .update(updateData)
          .eq('id', tenantId);
    } catch (e) {
      debugPrint('[SupabaseTenantRepository] Error al actualizar personalización de iglesia: $e');
      rethrow;
    }
  }

  ChurchTenant _mapToChurchTenant(Map<String, dynamic> data) {
    final hexColor = data['color_principal']?.toString();
    final primaryColor = AppColors.fromHex(hexColor, fallback: const Color(0xFF1E5BB8));
    final id = data['id']?.toString() ?? '';

    return ChurchTenant(
      id: id,
      name: data['nombre_completo']?.toString() ?? 'Iglesia',
      code: id,
      pastorName: 'Pastor',
      email: '',
      primaryColor: primaryColor,
      logoUrl: data['logo_url']?.toString(),
      motto: data['lema_o_vision']?.toString(),
      address: 'Sede Principal',
      phone: '',
      createdAt: DateTime.now(),
    );
  }
}
