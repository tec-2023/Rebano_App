import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../tenant/presentation/providers/tenant_provider.dart';
import '../providers/cell_provider.dart';
import 'cell_attendance_screen.dart';
import 'evangelism_map_screen.dart';
import 'cell_report_screen.dart';

class CellOverviewScreen extends StatelessWidget {
  const CellOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tenant = context.watch<TenantProvider>();
    final cell = context.watch<CellProvider>();
    final group = cell.cellGroup;

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mi Célula')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.name,
              style: theme.appBarTheme.titleTextStyle,
            ),
            Text(
              'Líder: ${group.leaderName}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Tarjeta de Información de la Reunión Semanal
          CustomCard(
            padding: const EdgeInsets.all(18),
            color: tenant.primaryColor.withValues(alpha: 0.08),
            border: Border.all(color: tenant.primaryColor.withValues(alpha: 0.35)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: tenant.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'REUNIÓN FAMILIAR SEMANAL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            group.meetingDayTime,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: tenant.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(
                      label: '${cell.attendingCount}/${cell.totalMembersCount} Asist.',
                      type: BadgeType.success,
                      fontSize: 12,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${group.hostName} • ${group.address}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Acciones Rápidas
          Text(
            'Herramientas del Líder',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              // Botón 1: Tomar Asistencia
              Expanded(
                child: CustomCard(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CellAttendanceScreen()),
                    );
                  },
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.checklist_rtl_rounded, color: Color(0xFF15803D), size: 24),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Asistencia',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pase de lista del miniculto',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Botón 2: Rutas de Evangelismo
              Expanded(
                child: CustomCard(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EvangelismMapScreen()),
                    );
                  },
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.map_rounded, color: Color(0xFFD97706), size: 24),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Evangelismo',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mapa y ruta de 5:00 PM',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Botón 3: Reporte de Célula
          CustomCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CellReportScreen()),
              );
            },
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.assignment_turned_in_rounded, color: Color(0xFF7C3AED), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reporte Estadístico Post-Reunión',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Registra asistencia, visitas nuevas y tratados entregados al Pastor',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. Lista de Miembros de la Célula
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Miembros Asignados (${group.members.length})',
                style: theme.textTheme.titleMedium,
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CellAttendanceScreen()),
                  );
                },
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Tomar Lista'),
              ),
            ],
          ),
          const SizedBox(height: 6),

          ...group.members.map((member) => CustomCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: tenant.primaryColor.withValues(alpha: 0.12),
                      child: Text(
                        member.name[0],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: tenant.primaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            '${member.role} • ${member.phone}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(
                      label: member.isAttending ? 'Asistió' : 'Ausente',
                      type: member.isAttending ? BadgeType.success : BadgeType.neutral,
                      fontSize: 11,
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
