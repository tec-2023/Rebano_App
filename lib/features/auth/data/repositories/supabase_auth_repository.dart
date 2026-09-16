import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/user_role.dart';
import 'mock_auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  @override
  Future<AppUser?> login(String email, String password) async {
    try {
      final AuthResponse res = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = res.user;
      if (user == null) {
        throw const AuthException('No se pudo autenticar el usuario.');
      }

      return await getUserProfile(user.id, fallbackEmail: user.email ?? email);
    } on AuthException catch (e) {
      debugPrint('[SupabaseAuthRepository] Error de autenticación: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[SupabaseAuthRepository] Error inesperado en login: $e');
      rethrow;
    }
  }

  @override
  Future<AppUser> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String churchId,
  }) async {
    return _registerUser(
      name: name,
      email: email,
      password: password,
      churchId: churchId,
      isAdmin: true,
    );
  }

  @override
  Future<AppUser> registerMember({
    required String name,
    required String email,
    required String password,
    required String churchId,
  }) async {
    return _registerUser(
      name: name,
      email: email,
      password: password,
      churchId: churchId,
      isAdmin: false,
    );
  }

  Future<AppUser> _registerUser({
    required String name,
    required String email,
    required String password,
    required String churchId,
    required bool isAdmin,
  }) async {
    try {
      // Pasamos los metadatos requeridos para que el SQL Trigger de Supabase
      // inserte automáticamente el registro en la tabla 'perfiles'.
      final AuthResponse res = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'nombre_completo': name.trim(),
          'id_iglesia': churchId.trim(),
          'is_admin': isAdmin,
        },
      );

      final user = res.user;
      if (user == null) {
        throw const AuthException('No se pudo completar el registro.');
      }

      // Intentar obtener el perfil generado por el trigger
      try {
        final profile = await getUserProfile(user.id, fallbackEmail: email);
        if (profile != null) return profile;
      } catch (e) {
        debugPrint('[SupabaseAuthRepository] Perfil aún no listo en trigger: $e');
      }

      // Fallback inmediato con los datos registrados
      return AppUser(
        id: user.id,
        churchId: churchId,
        name: name,
        email: email,
        roles: isAdmin ? [UserRole.admin, UserRole.member] : [UserRole.member],
        joinedAt: DateTime.now(),
      );
    } on AuthException catch (e) {
      debugPrint('[SupabaseAuthRepository] Error en registro: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[SupabaseAuthRepository] Error inesperado en registro: $e');
      rethrow;
    }
  }

  /// Obtiene los datos del perfil desde la tabla 'perfiles'
  Future<AppUser?> getUserProfile(String userId, {String? fallbackEmail}) async {
    try {
      final data = await _client
          .from('perfiles')
          .select('id, nombre_completo, roles, id_iglesia')
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        debugPrint('[SupabaseAuthRepository] No se encontró perfil para el usuario $userId');
        return null;
      }

      final rolesList = _parseRoles(data['roles']);

      return AppUser(
        id: data['id']?.toString() ?? userId,
        churchId: data['id_iglesia']?.toString() ?? '',
        name: data['nombre_completo']?.toString() ?? (fallbackEmail ?? 'Usuario'),
        email: fallbackEmail ?? _client.auth.currentUser?.email ?? '',
        roles: rolesList,
        phone: data['telefono']?.toString(),
        avatarUrl: data['avatar_url']?.toString(),
        joinedAt: data['created_at'] != null
            ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
    } catch (e) {
      debugPrint('[SupabaseAuthRepository] Error al obtener perfil: $e');
      return null;
    }
  }

  /// Obtiene el usuario actualmente autenticado en la sesión activa
  Future<AppUser?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return await getUserProfile(user.id, fallbackEmail: user.email);
  }

  @override
  Future<List<AppUser>> getChurchMembers(String churchId) async {
    try {
      final List<dynamic> response = await _client
          .from('perfiles')
          .select('id, nombre_completo, roles, id_iglesia')
          .eq('id_iglesia', churchId)
          .order('nombre_completo', ascending: true);

      return response.map((data) {
        final rolesList = _parseRoles(data['roles']);
        return AppUser(
          id: data['id']?.toString() ?? '',
          churchId: data['id_iglesia']?.toString() ?? churchId,
          name: data['nombre_completo']?.toString() ?? 'Miembro',
          email: '', // Protegido por RLS en perfiles
          roles: rolesList,
          phone: data['telefono']?.toString(),
          avatarUrl: data['avatar_url']?.toString(),
          joinedAt: data['created_at'] != null
              ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseAuthRepository] Error al obtener miembros: $e');
      return [];
    }
  }

  @override
  Future<AppUser> updateUserRoles(String userId, List<UserRole> newRoles) async {
    try {
      // Asegurarse de incluir el rol base 'miembro'
      final finalRoles = List<UserRole>.from(newRoles);
      if (!finalRoles.contains(UserRole.member)) {
        finalRoles.add(UserRole.member);
      }

      final rolesKeys = finalRoles.map((r) => r.key).toList();

      final updated = await _client
          .from('perfiles')
          .update({'roles': rolesKeys})
          .eq('id', userId)
          .select('id, nombre_completo, roles, id_iglesia')
          .single();

      return AppUser(
        id: updated['id']?.toString() ?? userId,
        churchId: updated['id_iglesia']?.toString() ?? '',
        name: updated['nombre_completo']?.toString() ?? 'Usuario',
        email: '',
        roles: _parseRoles(updated['roles']),
        phone: updated['telefono']?.toString(),
        avatarUrl: updated['avatar_url']?.toString(),
        joinedAt: updated['created_at'] != null
            ? DateTime.tryParse(updated['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
    } catch (e) {
      debugPrint('[SupabaseAuthRepository] Error al actualizar roles: $e');
      rethrow;
    }
  }

  @override
  Future<AppUser> updateUserProfile({
    required String userId,
    required String name,
    String? phone,
    String? newPassword,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'nombre_completo': name.trim(),
      };
      if (phone != null) {
        updateData['telefono'] = phone.trim();
      }

      await _client
          .from('perfiles')
          .update(updateData)
          .eq('id', userId);

      if (newPassword != null && newPassword.trim().isNotEmpty) {
        await _client.auth.updateUser(
          UserAttributes(password: newPassword.trim()),
        );
      }

      final profile = await getUserProfile(userId);
      if (profile != null) return profile;

      return AppUser(
        id: userId,
        churchId: '',
        name: name,
        email: _client.auth.currentUser?.email ?? '',
        roles: const [UserRole.member],
        phone: phone,
        joinedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('[SupabaseAuthRepository] Error al actualizar perfil: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('[SupabaseAuthRepository] Error al cerrar sesión: $e');
    }
  }

  List<UserRole> _parseRoles(dynamic rawRoles) {
    final List<UserRole> roles = [];
    if (rawRoles == null) {
      return [UserRole.member];
    }

    if (rawRoles is List) {
      for (final item in rawRoles) {
        final key = item.toString().trim();
        roles.add(UserRole.fromKey(key));
      }
    } else if (rawRoles is String) {
      final parts = rawRoles.replaceAll('{', '').replaceAll('}', '').replaceAll('"', '').split(',');
      for (final part in parts) {
        if (part.trim().isNotEmpty) {
          roles.add(UserRole.fromKey(part.trim()));
        }
      }
    }

    if (!roles.contains(UserRole.member)) {
      roles.add(UserRole.member);
    }

    return roles.toSet().toList(); // remover duplicados
  }
}
