import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../tenant/presentation/providers/tenant_provider.dart';
import '../providers/cell_provider.dart';

class EvangelismMapScreen extends StatefulWidget {
  const EvangelismMapScreen({super.key});

  @override
  State<EvangelismMapScreen> createState() => _EvangelismMapScreenState();
}

class _EvangelismMapScreenState extends State<EvangelismMapScreen> {
  final MapController _mapController = MapController();

  void _showEditMeetingPointDialog(BuildContext context) {
    final cell = context.read<CellProvider>();
    final route = cell.evangelismRoute;
    if (route == null) return;

    final nameController = TextEditingController(text: route.meetingPointName);
    final addressController = TextEditingController(text: route.meetingPointAddress);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.location_on_rounded, color: Color(0xFFD97706)),
            SizedBox(width: 8),
            Text('Punto de Reunión Semanal', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Fija la casa de reunión para la salida de evangelismo de las 5:00 PM:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: nameController,
              label: 'Nombre de la Casa / Anfitrión',
              hint: 'Ej. Casa de la Familia López',
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: addressController,
              label: 'Dirección Completa',
              hint: 'Ej. Calle Gardenias #102, Col. San Pedro',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              final newAddress = addressController.text.trim();
              if (newName.isNotEmpty && newAddress.isNotEmpty) {
                cell.updateMeetingPoint(newName, newAddress, route.meetingPointCoordinates);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Punto de reunión actualizado! 📍'),
                    backgroundColor: Color(0xFF15803D),
                  ),
                );
              }
            },
            child: const Text('Actualizar Casa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tenant = context.watch<TenantProvider>();
    final cell = context.watch<CellProvider>();
    final route = cell.evangelismRoute;

    if (route == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ruta de Evangelismo')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final meetingPoint = route.meetingPointCoordinates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutas de Evangelismo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_location_alt_outlined),
            tooltip: 'Cambiar Punto de Reunión',
            onPressed: () => _showEditMeetingPointDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Tarjeta Informativa Superior: Horario y Casa de Reunión
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: tenant.primaryColor.withValues(alpha: 0.08),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.access_time_filled_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'SALIDA: ${route.scheduleTime}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFFD97706),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () => _showEditMeetingPointDialog(context),
                            child: const Text(
                              'Cambiar casa',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        route.meetingPointName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        route.meetingPointAddress,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Mapa Interactivo (flutter_map con OpenStreetMap)
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: meetingPoint,
                    initialZoom: 15.5,
                  ),
                  children: [
                    // Capa de tiles OpenStreetMap
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.rebano.app',
                    ),

                    // Polilínea de la ruta de evangelismo trazada
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: route.routePoints,
                          strokeWidth: 4.5,
                          color: tenant.primaryColor.withValues(alpha: 0.85),
                          borderStrokeWidth: 2.0,
                          borderColor: Colors.white,
                        ),
                      ],
                    ),

                    // Marcadores: Punto de encuentro y esquinas
                    MarkerLayer(
                      markers: [
                        // Marcador de Punto de Encuentro (Casa de la semana)
                        Marker(
                          point: meetingPoint,
                          width: 140,
                          height: 70,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD97706),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                ),
                                child: const Text(
                                  'Punto de Salida (5:00 PM)',
                                  style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Icon(
                                Icons.location_on_rounded,
                                color: Color(0xFFD97706),
                                size: 36,
                              ),
                            ],
                          ),
                        ),

                        // Marcador de calles intermedias
                        ...route.routePoints.sublist(1).map((pt) => Marker(
                              point: pt,
                              width: 30,
                              height: 30,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: tenant.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.directions_walk_rounded, color: Colors.white, size: 16),
                              ),
                            )),
                      ],
                    ),
                  ],
                ),

                // Botón flotante de centrado
                Positioned(
                  right: 14,
                  bottom: 14,
                  child: FloatingActionButton.small(
                    heroTag: 'map_center',
                    backgroundColor: Colors.white,
                    foregroundColor: tenant.primaryColor,
                    onPressed: () => _mapController.move(meetingPoint, 15.5),
                    child: const Icon(Icons.my_location_rounded),
                  ),
                ),
              ],
            ),
          ),

          // 3. Panel Inferior: Calles a evangelizar e instrucciones
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
                ],
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Row(
                    children: [
                      Icon(Icons.format_list_bulleted_rounded, size: 20, color: tenant.primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Calles y Manzanas a Evangelizar',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...route.targetStreets.map((street) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF16A34A)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                street,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '💡 ${route.specialInstructions}',
                      style: const TextStyle(color: Color(0xFF92400E), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
