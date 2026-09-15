import 'package:latlong2/latlong.dart';

class CellMember {
  final String id;
  final String name;
  final String phone;
  final String role; // 'Anfitrión', 'Asistente', 'Nuevo Creyente', 'Miembro'
  final bool isAttending;
  final String? prayerNeed;

  const CellMember({
    required this.id,
    required this.name,
    required this.phone,
    this.role = 'Miembro',
    this.isAttending = false,
    this.prayerNeed,
  });

  CellMember copyWith({
    String? id,
    String? name,
    String? phone,
    String? role,
    bool? isAttending,
    String? prayerNeed,
  }) {
    return CellMember(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isAttending: isAttending ?? this.isAttending,
      prayerNeed: prayerNeed ?? this.prayerNeed,
    );
  }
}

class CellGroup {
  final String id;
  final String churchId;
  final String name;
  final String leaderName;
  final String hostName;
  final String meetingDayTime; // Ej: 'Miércoles 7:30 PM'
  final String address;
  final double latitude;
  final double longitude;
  final List<CellMember> members;

  const CellGroup({
    required this.id,
    required this.churchId,
    required this.name,
    required this.leaderName,
    required this.hostName,
    required this.meetingDayTime,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.members,
  });

  CellGroup copyWith({
    String? id,
    String? churchId,
    String? name,
    String? leaderName,
    String? hostName,
    String? meetingDayTime,
    String? address,
    double? latitude,
    double? longitude,
    List<CellMember>? members,
  }) {
    return CellGroup(
      id: id ?? this.id,
      churchId: churchId ?? this.churchId,
      name: name ?? this.name,
      leaderName: leaderName ?? this.leaderName,
      hostName: hostName ?? this.hostName,
      meetingDayTime: meetingDayTime ?? this.meetingDayTime,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      members: members ?? this.members,
    );
  }
}

class EvangelismRoute {
  final String id;
  final String cellGroupId;
  final String meetingPointName; // Casa de esa semana
  final String meetingPointAddress;
  final String scheduleTime; // '5:00 PM'
  final LatLng meetingPointCoordinates;
  final List<LatLng> routePoints;
  final List<String> targetStreets;
  final String specialInstructions;

  const EvangelismRoute({
    required this.id,
    required this.cellGroupId,
    required this.meetingPointName,
    required this.meetingPointAddress,
    this.scheduleTime = '5:00 PM',
    required this.meetingPointCoordinates,
    required this.routePoints,
    required this.targetStreets,
    required this.specialInstructions,
  });

  EvangelismRoute copyWith({
    String? id,
    String? cellGroupId,
    String? meetingPointName,
    String? meetingPointAddress,
    String? scheduleTime,
    LatLng? meetingPointCoordinates,
    List<LatLng>? routePoints,
    List<String>? targetStreets,
    String? specialInstructions,
  }) {
    return EvangelismRoute(
      id: id ?? this.id,
      cellGroupId: cellGroupId ?? this.cellGroupId,
      meetingPointName: meetingPointName ?? this.meetingPointName,
      meetingPointAddress: meetingPointAddress ?? this.meetingPointAddress,
      scheduleTime: scheduleTime ?? this.scheduleTime,
      meetingPointCoordinates: meetingPointCoordinates ?? this.meetingPointCoordinates,
      routePoints: routePoints ?? this.routePoints,
      targetStreets: targetStreets ?? this.targetStreets,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}

class CellReport {
  final String id;
  final String cellGroupId;
  final DateTime date;
  final int attendanceCount;
  final int newVisitorsCount;
  final int tractsDeliveredCount;
  final double offeringAmount;
  final String notes;

  const CellReport({
    required this.id,
    required this.cellGroupId,
    required this.date,
    required this.attendanceCount,
    required this.newVisitorsCount,
    required this.tractsDeliveredCount,
    this.offeringAmount = 0.0,
    required this.notes,
  });
}
