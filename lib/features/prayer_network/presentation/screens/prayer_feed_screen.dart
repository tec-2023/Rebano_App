import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../tenant/presentation/providers/tenant_provider.dart';
import '../../domain/entities/prayer_request.dart';
import '../providers/prayer_provider.dart';
import 'add_prayer_dialog.dart';

class PrayerFeedScreen extends StatelessWidget {
  const PrayerFeedScreen({super.key});

  void _showMarkAnsweredDialog(BuildContext context, PrayerRequest prayer) {
    final testimonyController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🎉 ', style: TextStyle(fontSize: 24)),
            Expanded(
              child: Text(
                '¡Testimonio de Victoria!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparte con la iglesia cómo Dios respondió a esta oración:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: testimonyController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Escribe el testimonio de respuesta...',
              ),
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
              final testimony = testimonyController.text.trim();
              if (testimony.isNotEmpty) {
                context.read<PrayerProvider>().markAsAnswered(prayer.id, testimony);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Gloria a Dios! Petición marcada como contestada 🎉'),
                    backgroundColor: Color(0xFF6D28D9),
                  ),
                );
              }
            },
            child: const Text('Celebrar Respuesta'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tenant = context.watch<TenantProvider>();
    final prayer = context.watch<PrayerProvider>();
    final intercessor = prayer.intercessorToday;
    final filteredList = prayer.filteredRequests;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Red de Oración',
              style: theme.appBarTheme.titleTextStyle,
            ),
            Text(
              tenant.churchName,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => prayer.loadPrayers(tenant.currentTenant.id),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => prayer.loadPrayers(tenant.currentTenant.id),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // 1. Banner Superior: Encargado del Día (Intercesor del Día)
            if (intercessor != null) _buildIntercessorBanner(context, intercessor),

            const SizedBox(height: 16),

            // 2. Filtros de peticiones
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(context, 'Todas', PrayerFilter.all, prayer.requests.length),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    'Pendientes',
                    PrayerFilter.pending,
                    prayer.requests.where((r) => !r.isAnswered).length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    'Contestadas 🎉',
                    PrayerFilter.answered,
                    prayer.requests.where((r) => r.isAnswered).length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    'Alabanzas 🙌',
                    PrayerFilter.praise,
                    prayer.requests.where((r) => r.category == PrayerCategory.praise).length,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Lista de peticiones o Vista Vacía
            if (filteredList.isEmpty)
              EmptyStateView(
                icon: Icons.favorite_border_rounded,
                title: 'No hay peticiones aquí',
                description: 'Sé el primero en compartir una necesidad o motivo de oración con tu congregación.',
                buttonText: 'Crear Petición',
                onButtonPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AddPrayerDialog(),
                  );
                },
              )
            else
              ...filteredList.map((item) => _buildPrayerCard(context, item)),

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddPrayerDialog(),
          );
        },
        backgroundColor: tenant.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Pedir Oración', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, PrayerFilter filter, int count) {
    final prayer = context.watch<PrayerProvider>();
    final isSelected = prayer.currentFilter == filter;
    final primaryColor = Theme.of(context).primaryColor;

    return FilterChip(
      selected: isSelected,
      label: Text('$label ($count)'),
      selectedColor: primaryColor.withValues(alpha: 0.15),
      checkmarkColor: primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? primaryColor : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 13,
      ),
      onSelected: (_) => prayer.setFilter(filter),
    );
  }

  Widget _buildIntercessorBanner(BuildContext context, dynamic intercessor) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return CustomCard(
      padding: const EdgeInsets.all(16),
      color: primaryColor.withValues(alpha: 0.07),
      border: Border.all(color: primaryColor.withValues(alpha: 0.35), width: 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'ENCARGADO DEL DÍA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                DateFormatter.formatShortDate(DateTime.now()),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: primaryColor.withValues(alpha: 0.2),
                child: Text(
                  intercessor.memberName[0],
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      intercessor.memberName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      'Enfoque: ${intercessor.prayerFocus}',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '"${intercessor.bibleVerse}" — ${intercessor.scriptureReference}',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCard(BuildContext context, PrayerRequest prayer) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      border: prayer.isAnswered
          ? Border.all(color: const Color(0xFF8B5CF6), width: 1.5)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de Petición Contestada
          if (prayer.isAnswered) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFDDD6FE)),
              ),
              child: const Row(
                children: [
                  Text('🎉 ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      '¡ORACIÓN CONTESTADA POR DIOS!',
                      style: TextStyle(
                        color: Color(0xFF6D28D9),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Cabecera de la petición: Autor, Categoría, Fecha
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: primaryColor.withValues(alpha: 0.15),
                child: Text(
                  prayer.authorName.isNotEmpty ? prayer.authorName[0] : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prayer.authorName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      DateFormatter.formatRelative(prayer.createdAt),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: '${prayer.category.emoji} ${prayer.category.label}',
                type: prayer.isAnswered ? BadgeType.answered : BadgeType.info,
                fontSize: 11.5,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Título
          Text(
            prayer.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),

          // Descripción
          Text(
            prayer.description,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : const Color(0xFF334155),
              height: 1.4,
            ),
          ),

          // Testimonio si está contestada
          if (prayer.isAnswered && prayer.testimony != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF5FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9D5FF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.format_quote_rounded, color: Color(0xFF7C3AED), size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Testimonio de Respuesta:',
                        style: TextStyle(
                          color: Color(0xFF6D28D9),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prayer.testimony!,
                    style: const TextStyle(
                      color: Color(0xFF4C1D95),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Botones de Acción: "Estoy Orando" y "¡Marcar Contestada!"
          Row(
            children: [
              // Botón Estoy Orando
              InkWell(
                onTap: () {
                  context.read<PrayerProvider>().togglePraying(prayer.id);
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        prayer.isUserPraying ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 20,
                        color: prayer.isUserPraying ? const Color(0xFFDC2626) : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        prayer.isUserPraying ? 'Orando' : 'Unirme en oración',
                        style: TextStyle(
                          fontWeight: prayer.isUserPraying ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                          color: prayer.isUserPraying ? const Color(0xFFDC2626) : null,
                        ),
                      ),
                      if (prayer.prayingCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (prayer.isUserPraying ? const Color(0xFFDC2626) : Colors.grey)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${prayer.prayingCount}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: prayer.isUserPraying ? const Color(0xFFDC2626) : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Botón Marcar Contestada (solo si aún no está contestada)
              if (!prayer.isAnswered)
                TextButton.icon(
                  onPressed: () => _showMarkAnsweredDialog(context, prayer),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('¡Dios Respondió!'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF7C3AED),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
