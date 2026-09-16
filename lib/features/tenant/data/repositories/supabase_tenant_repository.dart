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
      final cleanCode = code.trim().toUpperCase();
      final data = await _client
          .from('iglesias')
          .select('id, nombre_completo, logo_url, color_principal, lema_o_vision, codigo, direccion, telefono, pastor_nombre, email_contacto, created_at')
          .eq('codigo', cleanCode)
          .maybeSingle();

      if (data == null) return null;
      return _mapToChurchTenant(data);
    } catch (e) {
      debugPrint('[SupabaseTenantRepository] Error al obtener iglesia por código: $e');
      return null;
    }
  }

  /// Obtiene los datos de la iglesia por su ID (Multi-tenant Branding)
  Future<ChurchTenant?> getTenantById(String churchId) async {
    try {
      final data = await _client
          .from('iglesias')
          .select('id, nombre_completo, logo_url, color_principal, lema_o_vision, codigo, direccion, telefono, pastor_nombre, email_contacto, created_at')
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
      // Generar código único para la congregación (ej. REB-8492)
      final randomSuffix = (1000 + (DateTime.now().microsecondsSinceEpoch % 9000)).toString();
      final generatedCode = 'REB-$randomSuffix';

      final hexColor = AppColors.toHex(primaryColor);

      final data = await _client.from('iglesias').insert({
        'nombre_completo': name.trim(),
        'codigo': generatedCode,
        'pastor_nombre': pastorName.trim(),
        'email_contacto': email.trim(),
        'color_principal': hexColor,
      }).select().single();

      return _mapToChurchTenant(data);
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

    return ChurchTenant(
      id: data['id']?.toString() ?? '',
      name: data['nombre_completo']?.toString() ?? 'Iglesia',
      code: data['codigo']?.toString() ?? 'REB-1000',
      pastorName: data['pastor_nombre']?.toString() ?? 'Pastor',
      email: data['email_contacto']?.toString() ?? '',
      primaryColor: primaryColor,
      logoUrl: data['logo_url']?.toString(),
      motto: data['lema_o_vision']?.toString(),
      address: data['direccion']?.toString() ?? 'Dirección no especificada',
      phone: data['telefono']?.toString() ?? '',
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
