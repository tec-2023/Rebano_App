import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/prayer_request.dart';
import '../../domain/entities/intercessor.dart';
import 'mock_prayer_repository.dart';

class SupabasePrayerRepository implements PrayerRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  @override
  Future<List<PrayerRequest>> getPrayerRequests(String churchId) async {
    try {
      final List<dynamic> response = await _client
          .from('peticiones_oracion')
          .select()
          .eq('id_iglesia', churchId)
          .order('created_at', ascending: false);

      final currentUserId = _client.auth.currentUser?.id;

      return response.map((data) => _mapToPrayerRequest(data, currentUserId)).toList();
    } catch (e) {
      debugPrint('[SupabasePrayerRepository] Error al obtener peticiones de oración: $e');
      return [];
    }
  }

  @override
  Future<IntercessorOfTheDay> getIntercessorOfTheDay(String churchId) async {
    try {
      final data = await _client
          .from('intercesores_dia')
          .select()
          .eq('id_iglesia', churchId)
          .order('fecha', ascending: false)
          .maybeSingle();

      if (data != null) {
        return IntercessorOfTheDay(
          id: data['id']?.toString() ?? 'intercessor-today',
          churchId: data['id_iglesia']?.toString() ?? churchId,
          memberName: data['nombre_miembro']?.toString() ?? 'Intercesor Asignado',
          role: data['rol']?.toString() ?? 'Intercesor',
          phone: data['telefono']?.toString() ?? '',
          bibleVerse: data['versiculo']?.toString() ??
              'Confesaos vuestras ofensas unos a otros, y orad unos por otros...',
          scriptureReference: data['cita_biblica']?.toString() ?? 'Santiago 5:16',
          prayerFocus: data['enfoque_oracion']?.toString() ??
              'Sanidad física de los enfermos y restauración familiar.',
          date: data['fecha'] != null
              ? DateTime.tryParse(data['fecha'].toString()) ?? DateTime.now()
              : DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('[SupabasePrayerRepository] Error al obtener intercesor del día: $e');
    }

    // Retornar intercesor por defecto si aún no está configurado en BD
    return IntercessorOfTheDay(
      id: 'intercessor-today',
      churchId: churchId,
      memberName: 'Hermana Raquel Salinas',
      role: 'Diaconisa e Intercesora',
      phone: '+52 81 1234 9988',
      bibleVerse:
          'Confesaos vuestras ofensas unos a otros, y orad unos por otros, para que seáis sanados. La oración eficaz del justo puede mucho.',
      scriptureReference: 'Santiago 5:16',
      prayerFocus: 'Sanidad física de los enfermos y restauración familiar.',
      date: DateTime.now(),
    );
  }

  @override
  Future<PrayerRequest> createPrayerRequest(PrayerRequest request) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;

      // Restricción RLS: Payload DEBE incluir 'id_iglesia'
      final payload = {
        'id_iglesia': request.churchId,
        'titulo': request.title,
        'descripcion': request.description,
        'categoria': request.category.name,
        'autor_nombre': request.isAnonymous ? 'Anónimo' : request.authorName,
        'id_usuario': currentUserId,
        'es_anonimo': request.isAnonymous,
        'esta_respondida': false,
        'orando_conteo': 0,
      };

      final data = await _client
          .from('peticiones_oracion')
          .insert(payload)
          .select()
          .single();

      return _mapToPrayerRequest(data, currentUserId);
    } catch (e) {
      debugPrint('[SupabasePrayerRepository] Error al crear petición de oración: $e');
      rethrow;
    }
  }

  @override
  Future<PrayerRequest> togglePraying(String requestId, bool isCurrentlyPraying) async {
    try {
      // Obtener el conteo actual de oración
      final current = await _client
          .from('peticiones_oracion')
          .select('orando_conteo, id_iglesia')
          .eq('id', requestId)
          .single();

      final currentCount = (current['orando_conteo'] as num?)?.toInt() ?? 0;
      final newCount = isCurrentlyPraying ? (currentCount > 0 ? currentCount - 1 : 0) : currentCount + 1;

      final updated = await _client
          .from('peticiones_oracion')
          .update({'orando_conteo': newCount})
          .eq('id', requestId)
          .select()
          .single();

      final currentUserId = _client.auth.currentUser?.id;
      final req = _mapToPrayerRequest(updated, currentUserId);
      return req.copyWith(isUserPraying: !isCurrentlyPraying);
    } catch (e) {
      debugPrint('[SupabasePrayerRepository] Error al alternar oración: $e');
      rethrow;
    }
  }

  @override
  Future<PrayerRequest> markAsAnswered(String requestId, String testimony) async {
    try {
      final updated = await _client
          .from('peticiones_oracion')
          .update({
            'esta_respondida': true,
            'respondida_en': DateTime.now().toIso8601String(),
            'testimonio': testimony,
          })
          .eq('id', requestId)
          .select()
          .single();

      final currentUserId = _client.auth.currentUser?.id;
      return _mapToPrayerRequest(updated, currentUserId);
    } catch (e) {
      debugPrint('[SupabasePrayerRepository] Error al marcar petición como respondida: $e');
      rethrow;
    }
  }

  PrayerRequest _mapToPrayerRequest(Map<String, dynamic> data, String? currentUserId) {
    final catStr = (data['categoria'] ?? data['category'])?.toString() ?? 'health';
    final isAnon = (data['es_anonimo'] ?? data['is_anonymous']) == true;
    final isAnswered = (data['esta_respondida'] ?? data['is_answered']) == true;
    final author = isAnon ? 'Anónimo' : ((data['autor_nombre'] ?? data['author_name'])?.toString() ?? 'Miembro');

    return PrayerRequest(
      id: data['id']?.toString() ?? '',
      churchId: (data['id_iglesia'] ?? data['church_id'])?.toString() ?? '',
      authorName: author,
      authorAvatar: isAnon ? null : data['autor_avatar']?.toString(),
      title: (data['titulo'] ?? data['title'])?.toString() ?? 'Petición',
      description: (data['descripcion'] ?? data['description'])?.toString() ?? '',
      category: PrayerCategory.fromString(catStr),
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isAnswered: isAnswered,
      answeredAt: (data['respondida_en'] ?? data['answered_at']) != null
          ? DateTime.tryParse((data['respondida_en'] ?? data['answered_at']).toString())
          : null,
      testimony: (data['testimonio'] ?? data['testimony'])?.toString(),
      prayingCount: (data['orando_conteo'] ?? data['praying_count'] as num?)?.toInt() ?? 0,
      isUserPraying: false,
      isAnonymous: isAnon,
    );
  }
}
