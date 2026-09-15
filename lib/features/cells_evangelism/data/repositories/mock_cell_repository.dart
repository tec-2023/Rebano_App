import 'package:latlong2/latlong.dart';
import '../../domain/entities/cell_group.dart';

abstract class CellRepository {
  Future<CellGroup> getCellGroupByLeader(String churchId, String leaderId);
  Future<void> updateAttendance(String cellGroupId, List<CellMember> members);
  Future<EvangelismRoute> getEvangelismRoute(String cellGroupId);
  Future<void> updateEvangelismMeetingPoint(String cellGroupId, String name, String address, LatLng coords);
  Future<CellReport> submitCellReport(CellReport report);
}

class MockCellRepository implements CellRepository {
  CellGroup _cellGroup = CellGroup(
    id: 'cell-1',
    churchId: 'tenant-1',
    name: 'Célula Los Olivos #4',
    leaderName: 'María Fernanda Ríos',
    hostName: 'Familia González (Casa Hna. Claudia)',
    meetingDayTime: 'Miércoles 7:30 PM',
    address: 'Calle Los Olivos #324, Col. Vista Hermosa',
    latitude: 25.6866,
    longitude: -100.3161,
    members: const [
      CellMember(id: 'm-1', name: 'Carlos Mendoza', phone: '8180002222', role: 'Asistente Líder', isAttending: true),
      CellMember(id: 'm-2', name: 'Claudia González', phone: '8180007777', role: 'Anfitriona', isAttending: true),
      CellMember(id: 'm-3', name: 'Juan Silva', phone: '8180004444', role: 'Miembro', isAttending: true),
      CellMember(id: 'm-4', name: 'Lucía Benítez', phone: '8180005555', role: 'Miembro', isAttending: false),
      CellMember(id: 'm-5', name: 'Roberto Gómez', phone: '8180006666', role: 'Nuevo Creyente', isAttending: true),
      CellMember(id: 'm-6', name: 'Esperanza Treviño', phone: '8180008888', role: 'Miembro', isAttending: false),
      CellMember(id: 'm-7', name: 'Mateo Morales', phone: '8180009999', role: 'Nuevo Creyente', isAttending: true),
    ],
  );

  EvangelismRoute _route = const EvangelismRoute(
    id: 'route-1',
    cellGroupId: 'cell-1',
    meetingPointName: 'Casa de la Familia González (Punto de Reunión)',
    meetingPointAddress: 'Calle Los Olivos #324, Col. Vista Hermosa',
    scheduleTime: '5:00 PM (Sábados)',
    meetingPointCoordinates: LatLng(25.6866, -100.3161),
    routePoints: [
      LatLng(25.6866, -100.3161), // Punto de encuentro
      LatLng(25.6880, -100.3175), // Calle Naranjos
      LatLng(25.6895, -100.3160), // Parque Central
      LatLng(25.6885, -100.3140), // Av. Vista Hermosa
      LatLng(25.6866, -100.3161), // Retorno a casa de oración
    ],
    targetStreets: [
      '1. Calle Los Olivos (Casas #300 al #380)',
      '2. Calle Naranjos y Callejón del Rosal',
      '3. Plaza y Parque Central Vista Hermosa',
      '4. Av. Vista Hermosa (Comercios y transeúntes)',
    ],
    specialInstructions: 'Llevar 50 tratados evangelísticos, agua embotellada y calzado cómodo. Oración de intercesión previa de 15 minutos en el punto de encuentro.',
  );

  final List<CellReport> _reports = [];

  @override
  Future<CellGroup> getCellGroupByLeader(String churchId, String leaderId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _cellGroup;
  }

  @override
  Future<void> updateAttendance(String cellGroupId, List<CellMember> members) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _cellGroup = _cellGroup.copyWith(members: members);
  }

  @override
  Future<EvangelismRoute> getEvangelismRoute(String cellGroupId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _route;
  }

  @override
  Future<void> updateEvangelismMeetingPoint(String cellGroupId, String name, String address, LatLng coords) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _route = _route.copyWith(
      meetingPointName: name,
      meetingPointAddress: address,
      meetingPointCoordinates: coords,
    );
  }

  @override
  Future<CellReport> submitCellReport(CellReport report) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _reports.insert(0, report);
    return report;
  }
}
