import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/church_tenant.dart';
import 'mock_tenant_repository.dart';

class SupabaseTenantRepository implements TenantRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  static String generateChurchCode(String churchName, [DateTime? date]) {
    final words = churchName
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    String acronym = '';
    for (final word in words) {
      final cleanWord = word.replaceAll(RegExp(r'[^a-zA-Z0-9áéíóúÁÉÍÓÚñÑ]'), '');
      if (cleanWord.isNotEmpty) {
        String firstChar = cleanWord[0].toUpperCase();
        firstChar = _removeAccents(firstChar);
        acronym += firstChar;
      }
    }

    if (acronym.isEmpty) {
      acronym = 'REB';
    }

    final now = date ?? DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = (now.year % 100).toString().padLeft(2, '0');

    return '$acronym-$day$month$year';
  }

  static String _removeAccents(String str) {
    return str
        .replaceAll('Á', 'A')
        .replaceAll('É', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ú', 'U')
        .replaceAll('Ñ', 'N');
  }

  @override
  Future<ChurchTenant?> getTenantByCode(String code) async {
    try {
      final clean = code.trim();
      if (clean.isEmpty) return null;

      // 1. Buscar por código de acceso exacto
      var data = await _client
          .from('iglesias')
          .select('id, nombre_completo, nombre_corto, codigo_acceso, logo_url, color_principal, lema_o_vision')
          .ilike('codigo_acceso', clean)
          .maybeSingle();

      // 2. Si no se encuentra, buscar por ID exacto de la congregación
      data ??= await _client
          .from('iglesias')
          .select('id, nombre_completo, nombre_corto, codigo_acceso, logo_url, color_principal, lema_o_vision')
          .eq('id', clean)
          .maybeSingle();

      // 3. Si no se encuentra, buscar por coincidencia en el nombre
      if (data == null) {
        final List<dynamic> list = await _client
            .from('iglesias')
            .select('id, nombre_completo, nombre_corto, codigo_acceso, logo_url, color_principal, lema_o_vision')
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
          .select('id, nombre_completo, nombre_corto, codigo_acceso, logo_url, color_principal, lema_o_vision')
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
    String? shortName,
    required String pastorName,
    required String email,
    required Color primaryColor,
  }) async {
    final hexColor = AppColors.toHex(primaryColor);
    final baseChurchCode = generateChurchCode(name);

    // Intentamos registrar con el código base o sufijos automáticos en caso de colisión
    for (int attempt = 0; attempt < 5; attempt++) {
      final codeToTry = attempt == 0
          ? baseChurchCode
          : '$baseChurchCode-${attempt + 1}';

      try {
        final insertPayload = <String, dynamic>{
          'nombre_completo': name.trim(),
          'codigo_acceso': codeToTry,
          'color_principal': hexColor,
        };
        if (shortName != null && shortName.trim().isNotEmpty) {
          insertPayload['nombre_corto'] = shortName.trim();
        }

        final data = await _client
            .from('iglesias')
            .insert(insertPayload)
            .select('id, nombre_completo, nombre_corto, codigo_acceso, logo_url, color_principal, lema_o_vision')
            .single();

        final tenant = _mapToChurchTenant(data);
        return tenant.copyWith(
          shortName: shortName?.trim(),
          pastorName: pastorName.trim(),
          email: email.trim(),
          code: data['codigo_acceso']?.toString() ?? codeToTry,
        );
      } catch (e) {
        final errString = e.toString().toLowerCase();
        // Si el error es por clave duplicada de código de acceso, reintentamos con el siguiente sufijo
        if ((errString.contains('23505') || errString.contains('duplicate key')) &&
            errString.contains('codigo_acceso') &&
            attempt < 4) {
          debugPrint('[SupabaseTenantRepository] Código $codeToTry en uso, reintentando con sufijo...');
          continue;
        }
        debugPrint('[SupabaseTenantRepository] Error al registrar iglesia: $e');
        rethrow;
      }
    }

    throw Exception('No se pudo generar un código único para la congregación.');
  }

  @override
  Future<void> updateChurchCustomization({
    required String tenantId,
    required String name,
    String? shortName,
    required Color primaryColor,
    String? logoUrl,
  }) async {
    try {
      final hexColor = AppColors.toHex(primaryColor);
      final updateData = <String, dynamic>{
        'nombre_completo': name.trim(),
        'color_principal': hexColor,
      };
      if (shortName != null) {
        updateData['nombre_corto'] = shortName.trim();
      }
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

  @override
  Future<void> deleteChurch(String tenantId) async {
    try {
      await _client
          .from('iglesias')
          .delete()
          .eq('id', tenantId);
    } catch (e) {
      debugPrint('[SupabaseTenantRepository] Error al eliminar iglesia: $e');
      rethrow;
    }
  }

  ChurchTenant _mapToChurchTenant(Map<String, dynamic> data) {
    final hexColor = data['color_principal']?.toString();
    final primaryColor = AppColors.fromHex(hexColor, fallback: const Color(0xFF1E5BB8));
    final id = data['id']?.toString() ?? '';
    final code = data['codigo_acceso']?.toString() ?? id;
    final fullName = data['nombre_completo']?.toString() ?? 'Iglesia';
    final shortName = data['nombre_corto']?.toString() ?? '';

    return ChurchTenant(
      id: id,
      name: fullName,
      shortName: shortName,
      code: code,
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
