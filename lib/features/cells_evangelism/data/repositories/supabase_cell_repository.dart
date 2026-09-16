import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/cell_group.dart';
import 'mock_cell_repository.dart';

class SupabaseCellRepository implements CellRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  @override
  Future<CellGroup> getCellGroupByLeader(String churchId, String leaderId) async {
    try {
      final data = await _client
          .from('celulas')
          .select()
          .eq('id_iglesia', churchId)
          .maybeSingle();

      if (data != null) {
        return _mapToCellGroup(data, churchId);
      }
    } catch (e) {
      debugPrint('[SupabaseCellRepository] Error al obtener célula: $e');
    }

    // Default template cell group if none exists yet in database
    return CellGroup(
      id: 'cell-$churchId',
      churchId: churchId,
      name: 'Célula de Crecimiento y Oración',
      leaderName: 'Líder Asignado',
      hostName: 'Familia Anfitriona',
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
      ],
    );
  }

  @override
  Future<void> updateAttendance(String cellGroupId, List<CellMember> members) async {
    try {
      final membersJson = members.map((m) => {
        'id': m.id,
        'name': m.name,
        'phone': m.phone,
        'role': m.role,
        'isAttending': m.isAttending,
        'prayerNeed': m.prayerNeed,
      }).toList();

      await _client
          .from('celulas')
          .update({'miembros': membersJson})
          .eq('id', cellGroupId);
    } catch (e) {
      debugPrint('[SupabaseCellRepository] Error al actualizar asistencia: $e');
    }
  }

  @override
  Future<EvangelismRoute> getEvangelismRoute(String cellGroupId) async {
    try {
      final data = await _client
          .from('rutas_evangelismo')
          .select()
          .eq('id_celula', cellGroupId)
          .maybeSingle();

      if (data != null) {
        final lat = (data['latitud'] as num?)?.toDouble() ?? 25.6866;
        final lng = (data['longitud'] as num?)?.toDouble() ?? -100.3161;

        return EvangelismRoute(
          id: data['id']?.toString() ?? 'route-$cellGroupId',
          cellGroupId: cellGroupId,
          meetingPointName: data['punto_reunion_nombre']?.toString() ?? 'Punto de Encuentro',
          meetingPointAddress: data['direccion']?.toString() ?? 'Dirección',
          scheduleTime: data['horario']?.toString() ?? '5:00 PM (Sábados)',
          meetingPointCoordinates: LatLng(lat, lng),
          routePoints: [
            LatLng(lat, lng),
            LatLng(lat + 0.0014, lng - 0.0014),
            LatLng(lat + 0.0029, lng + 0.0001),
            LatLng(lat + 0.0019, lng + 0.0021),
            LatLng(lat, lng),
          ],
          targetStreets: [
            '1. Calle Principal (Casas #100 al #180)',
            '2. Calles aledañas y Callejón Central',
            '3. Parque de la colonia',
            '4. Comercios y transeúntes',
          ],
          specialInstructions: data['instrucciones']?.toString() ??
              'Llevar tratados evangelísticos, agua embotellada y calzado cómodo.',
        );
      }
    } catch (e) {
      debugPrint('[SupabaseCellRepository] Error al obtener ruta: $e');
    }

    return const EvangelismRoute(
      id: 'route-1',
      cellGroupId: 'cell-1',
      meetingPointName: 'Casa de Oración y Encuentro',
      meetingPointAddress: 'Calle Los Olivos #324, Col. Vista Hermosa',
      scheduleTime: '5:00 PM (Sábados)',
      meetingPointCoordinates: LatLng(25.6866, -100.3161),
      routePoints: [
        LatLng(25.6866, -100.3161),
        LatLng(25.6880, -100.3175),
        LatLng(25.6895, -100.3160),
        LatLng(25.6885, -100.3140),
        LatLng(25.6866, -100.3161),
      ],
      targetStreets: [
        '1. Calle Los Olivos (Casas #300 al #380)',
        '2. Calle Naranjos y Callejón del Rosal',
        '3. Plaza y Parque Central Vista Hermosa',
        '4. Av. Vista Hermosa (Comercios y transeúntes)',
      ],
      specialInstructions:
          'Llevar 50 tratados evangelísticos, agua embotellada y calzado cómodo. Oración de intercesión previa de 15 minutos en el punto de encuentro.',
    );
  }

  @override
  Future<void> updateEvangelismMeetingPoint(
    String cellGroupId,
    String name,
    String address,
    LatLng coords,
  ) async {
    try {
      await _client.from('rutas_evangelismo').upsert({
        'id_celula': cellGroupId,
        'punto_reunion_nombre': name,
        'direccion': address,
        'latitud': coords.latitude,
        'longitud': coords.longitude,
      });
    } catch (e) {
      debugPrint('[SupabaseCellRepository] Error al actualizar punto de reunión: $e');
    }
  }

  @override
  Future<CellReport> submitCellReport(CellReport report) async {
    try {
      final payload = {
        'id_celula': report.cellGroupId,
        'fecha': report.date.toIso8601String(),
        'asistencia_total': report.attendanceCount,
        'nuevos_visitantes': report.newVisitorsCount,
        'tratados_entregados': report.tractsDeliveredCount,
        'ofrenda_monto': report.offeringAmount,
        'notas': report.notes,
      };

      final data = await _client
          .from('reportes_celula')
          .insert(payload)
          .select()
          .single();

      return CellReport(
        id: data['id']?.toString() ?? report.id,
        cellGroupId: report.cellGroupId,
        date: report.date,
        attendanceCount: report.attendanceCount,
        newVisitorsCount: report.newVisitorsCount,
        tractsDeliveredCount: report.tractsDeliveredCount,
        offeringAmount: report.offeringAmount,
        notes: report.notes,
      );
    } catch (e) {
      debugPrint('[SupabaseCellRepository] Error al enviar reporte de célula: $e');
      rethrow;
    }
  }

  CellGroup _mapToCellGroup(Map<String, dynamic> data, String churchId) {
    List<CellMember> members = [];
    if (data['miembros'] is List) {
      members = (data['miembros'] as List).map((m) {
        return CellMember(
          id: m['id']?.toString() ?? '',
          name: m['name']?.toString() ?? 'Miembro',
          phone: m['phone']?.toString() ?? '',
          role: m['role']?.toString() ?? 'Miembro',
          isAttending: m['isAttending'] == true,
          prayerNeed: m['prayerNeed']?.toString(),
        );
      }).toList();
    }

    return CellGroup(
      id: data['id']?.toString() ?? '',
      churchId: data['id_iglesia']?.toString() ?? churchId,
      name: data['nombre']?.toString() ?? 'Célula',
      leaderName: data['lider_nombre']?.toString() ?? 'Líder',
      hostName: data['anfitrion_nombre']?.toString() ?? 'Anfitrión',
      meetingDayTime: data['horario_dia']?.toString() ?? 'Miércoles 7:30 PM',
      address: data['direccion']?.toString() ?? 'Dirección',
      latitude: (data['latitud'] as num?)?.toDouble() ?? 25.6866,
      longitude: (data['longitud'] as num?)?.toDouble() ?? -100.3161,
      members: members,
    );
  }
}
