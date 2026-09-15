import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../tenant/presentation/providers/tenant_provider.dart';
import '../providers/cell_provider.dart';

class CellAttendanceScreen extends StatelessWidget {
  const CellAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tenant = context.watch<TenantProvider>();
    final cell = context.watch<CellProvider>();
    final group = cell.cellGroup;

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Toma de Asistencia')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final attendingCount = cell.attendingCount;
    final totalCount = cell.totalMembersCount;
    final attendancePercentage = totalCount > 0 ? (attendingCount / totalCount * 100).toInt() : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencia del Miniculto'),
      ),
      body: Column(
        children: [
          // Banner de Resumen
          Container(
            padding: const EdgeInsets.all(18),
            color: tenant.primaryColor.withValues(alpha: 0.08),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Presentes: $attendingCount de $totalCount',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Porcentaje de asistencia: $attendancePercentage%',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: tenant.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$attendancePercentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de Miembros con Switches/Checkboxes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: group.members.length,
              itemBuilder: (context, index) {
                final member = group.members[index];

                return CustomCard(
                  onTap: () => cell.toggleMemberAttendance(member.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: member.isAttending
                      ? Border.all(color: const Color(0xFF16A34A), width: 1.5)
                      : null,
                  child: Row(
                    children: [
                      Transform.scale(
                        scale: 1.1,
                        child: Checkbox(
                          value: member.isAttending,
                          activeColor: const Color(0xFF16A34A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          onChanged: (_) => cell.toggleMemberAttendance(member.id),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: member.isAttending
                                    ? null
                                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                              ),
                            ),
                            Text(
                              member.role,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(
                        label: member.isAttending ? 'Presente' : 'Ausente',
                        type: member.isAttending ? BadgeType.success : BadgeType.neutral,
                        fontSize: 11,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Botón de Guardar
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              text: 'Guardar Registro de Asistencia',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Asistencia guardada correctamente! 📋'),
                    backgroundColor: Color(0xFF15803D),
                  ),
                );
                Navigator.of(context).pop();
              },
              icon: Icons.save_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
