import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/cell_group.dart';
import '../../data/repositories/mock_cell_repository.dart';

class CellProvider extends ChangeNotifier {
  final CellRepository _repository;

  CellGroup? _cellGroup;
  EvangelismRoute? _evangelismRoute;
  bool _isLoading = false;
  String? _errorMessage;

  CellProvider({CellRepository? repository})
      : _repository = repository ?? MockCellRepository() {
    loadCellData('tenant-1', 'user-3');
  }

  CellGroup? get cellGroup => _cellGroup;
  EvangelismRoute? get evangelismRoute => _evangelismRoute;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get attendingCount => _cellGroup?.members.where((m) => m.isAttending).length ?? 0;
  int get totalMembersCount => _cellGroup?.members.length ?? 0;

  Future<void> loadCellData(String churchId, String leaderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final group = await _repository.getCellGroupByLeader(churchId, leaderId);
      final route = await _repository.getEvangelismRoute(group.id);
      _cellGroup = group;
      _evangelismRoute = route;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar datos celulares: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleMemberAttendance(String memberId) {
    if (_cellGroup == null) return;

    final updatedMembers = _cellGroup!.members.map((m) {
      if (m.id == memberId) {
        return m.copyWith(isAttending: !m.isAttending);
      }
      return m;
    }).toList();

    _cellGroup = _cellGroup!.copyWith(members: updatedMembers);
    notifyListeners();
    _repository.updateAttendance(_cellGroup!.id, updatedMembers);
  }

  Future<bool> updateMeetingPoint(String name, String address, LatLng coords) async {
    if (_cellGroup == null) return false;
    try {
      await _repository.updateEvangelismMeetingPoint(_cellGroup!.id, name, address, coords);
      if (_evangelismRoute != null) {
        _evangelismRoute = _evangelismRoute!.copyWith(
          meetingPointName: name,
          meetingPointAddress: address,
          meetingPointCoordinates: coords,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar punto de reunión: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitReport({
    required int attendanceCount,
    required int newVisitorsCount,
    required int tractsDeliveredCount,
    required double offeringAmount,
    required String notes,
  }) async {
    if (_cellGroup == null) return false;

    final report = CellReport(
      id: 'report-${DateTime.now().millisecondsSinceEpoch}',
      cellGroupId: _cellGroup!.id,
      date: DateTime.now(),
      attendanceCount: attendanceCount,
      newVisitorsCount: newVisitorsCount,
      tractsDeliveredCount: tractsDeliveredCount,
      offeringAmount: offeringAmount,
      notes: notes,
    );

    try {
      await _repository.submitCellReport(report);
      return true;
    } catch (e) {
      _errorMessage = 'Error al enviar reporte: $e';
      notifyListeners();
      return false;
    }
  }
}
