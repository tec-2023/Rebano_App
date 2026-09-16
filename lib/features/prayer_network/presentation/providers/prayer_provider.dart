import 'package:flutter/material.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/prayer_request.dart';
import '../../domain/entities/intercessor.dart';
import '../../data/repositories/mock_prayer_repository.dart';
import '../../data/repositories/supabase_prayer_repository.dart';

enum PrayerFilter { all, pending, answered, praise }

class PrayerProvider extends ChangeNotifier {
  final PrayerRepository _repository;

  List<PrayerRequest> _requests = [];
  IntercessorOfTheDay? _intercessorToday;
  PrayerFilter _currentFilter = PrayerFilter.all;
  bool _isLoading = false;
  String? _errorMessage;

  PrayerProvider({PrayerRepository? repository})
      : _repository = repository ??
            (SupabaseConfig.isInitialized
                ? SupabasePrayerRepository()
                : MockPrayerRepository()) {
    loadPrayers('tenant-1');
  }

  List<PrayerRequest> get requests => _requests;
  IntercessorOfTheDay? get intercessorToday => _intercessorToday;
  PrayerFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<PrayerRequest> get filteredRequests {
    switch (_currentFilter) {
      case PrayerFilter.pending:
        return _requests.where((r) => !r.isAnswered).toList();
      case PrayerFilter.answered:
        return _requests.where((r) => r.isAnswered).toList();
      case PrayerFilter.praise:
        return _requests.where((r) => r.category == PrayerCategory.praise).toList();
      case PrayerFilter.all:
        return _requests;
    }
  }

  void setFilter(PrayerFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> loadPrayers(String churchId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getPrayerRequests(churchId),
        _repository.getIntercessorOfTheDay(churchId),
      ]);
      _requests = results[0] as List<PrayerRequest>;
      _intercessorToday = results[1] as IntercessorOfTheDay;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar peticiones: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePraying(String requestId) async {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    final current = _requests[index];
    // Optimistic UI update
    final updated = await _repository.togglePraying(requestId, current.isUserPraying);
    _requests[index] = updated;
    notifyListeners();
  }

  Future<void> markAsAnswered(String requestId, String testimony) async {
    try {
      final updated = await _repository.markAsAnswered(requestId, testimony);
      final index = _requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _requests[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error al marcar contestada: $e';
      notifyListeners();
    }
  }

  Future<void> addPrayerRequest({
    required String churchId,
    required String authorName,
    required String title,
    required String description,
    required PrayerCategory category,
    bool isAnonymous = false,
  }) async {
    final newRequest = PrayerRequest(
      id: 'prayer-${DateTime.now().millisecondsSinceEpoch}',
      churchId: churchId,
      authorName: isAnonymous ? 'Hermano en Cristo (Anónimo)' : authorName,
      title: title,
      description: description,
      category: category,
      createdAt: DateTime.now(),
      isAnonymous: isAnonymous,
    );

    try {
      final created = await _repository.createPrayerRequest(newRequest);
      _requests.insert(0, created);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al publicar petición: $e';
      notifyListeners();
    }
  }
}
