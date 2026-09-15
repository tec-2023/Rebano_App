import '../../domain/entities/prayer_request.dart';
import '../../domain/entities/intercessor.dart';

abstract class PrayerRepository {
  Future<List<PrayerRequest>> getPrayerRequests(String churchId);
  Future<IntercessorOfTheDay> getIntercessorOfTheDay(String churchId);
  Future<PrayerRequest> createPrayerRequest(PrayerRequest request);
  Future<PrayerRequest> togglePraying(String requestId, bool isCurrentlyPraying);
  Future<PrayerRequest> markAsAnswered(String requestId, String testimony);
}

class MockPrayerRepository implements PrayerRepository {
  final List<PrayerRequest> _requests = [
    PrayerRequest(
      id: 'prayer-1',
      churchId: 'tenant-1',
      authorName: 'Hna. Rosa Gutiérrez',
      title: 'Cirugía de mi madre Doña Carmen',
      description: 'Pedimos cobertura en oración por la intervención quirúrgica de corazón que tendrá mi mamá este jueves. Que Dios guíe las manos de los médicos.',
      category: PrayerCategory.health,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      prayingCount: 14,
      isUserPraying: true,
    ),
    PrayerRequest(
      id: 'prayer-2',
      churchId: 'tenant-1',
      authorName: 'Hno. Marcos Alvarado',
      title: '¡Dios proveyó empleo en la empresa!',
      description: 'Estuve 4 meses sin empleo y toda la célula estuvo orando. ¡Hoy firmé contrato indefinido! Doy toda la gloria y honra al Señor.',
      category: PrayerCategory.finances,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isAnswered: true,
      answeredAt: DateTime.now().subtract(const Duration(hours: 12)),
      testimony: 'El Señor abrió puertas donde no había camino. El salario superó las expectativas y podré seguir sirviendo en el ministerio de jóvenes.',
      prayingCount: 28,
      isUserPraying: true,
    ),
    PrayerRequest(
      id: 'prayer-3',
      churchId: 'tenant-1',
      authorName: 'Familia Mendoza',
      title: 'Reconciliación y salvación de nuestro hijo Daniel',
      description: 'Oramos para que el Espíritu Santo toque el corazón de Daniel y regrese a los caminos del Señor.',
      category: PrayerCategory.family,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      prayingCount: 9,
      isUserPraying: false,
    ),
    PrayerRequest(
      id: 'prayer-4',
      churchId: 'tenant-1',
      authorName: 'Líder María Fernanda',
      title: 'Ruta de Evangelismo de este sábado 5:00 PM',
      description: 'Que los corazones en las calles de la colonia San Pedro estén dispuestos para recibir el mensaje de salvación y los tratados.',
      category: PrayerCategory.ministry,
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      prayingCount: 21,
      isUserPraying: true,
    ),
  ];

  @override
  Future<List<PrayerRequest>> getPrayerRequests(String churchId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_requests);
  }

  @override
  Future<IntercessorOfTheDay> getIntercessorOfTheDay(String churchId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return IntercessorOfTheDay(
      id: 'intercessor-today',
      churchId: churchId,
      memberName: 'Hermana Raquel Salinas',
      role: 'Diaconisa e Intercesora',
      phone: '+52 81 1234 9988',
      bibleVerse: 'Confesaos vuestras ofensas unos a otros, y orad unos por otros, para que seáis sanados. La oración eficaz del justo puede mucho.',
      scriptureReference: 'Santiago 5:16',
      prayerFocus: 'Sanidad física de los enfermos y restauración familiar.',
      date: DateTime.now(),
    );
  }

  @override
  Future<PrayerRequest> createPrayerRequest(PrayerRequest request) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _requests.insert(0, request);
    return request;
  }

  @override
  Future<PrayerRequest> togglePraying(String requestId, bool isCurrentlyPraying) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final current = _requests[index];
      final newIsPraying = !isCurrentlyPraying;
      final newCount = newIsPraying ? current.prayingCount + 1 : (current.prayingCount > 0 ? current.prayingCount - 1 : 0);
      final updated = current.copyWith(
        isUserPraying: newIsPraying,
        prayingCount: newCount,
      );
      _requests[index] = updated;
      return updated;
    }
    throw Exception('Petición no encontrada');
  }

  @override
  Future<PrayerRequest> markAsAnswered(String requestId, String testimony) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final updated = _requests[index].copyWith(
        isAnswered: true,
        answeredAt: DateTime.now(),
        testimony: testimony,
      );
      _requests[index] = updated;
      return updated;
    }
    throw Exception('Petición no encontrada');
  }
}
