import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../tenant/presentation/providers/tenant_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/prayer_request.dart';
import '../providers/prayer_provider.dart';

class AddPrayerDialog extends StatefulWidget {
  const AddPrayerDialog({super.key});

  @override
  State<AddPrayerDialog> createState() => _AddPrayerDialogState();
}

class _AddPrayerDialogState extends State<AddPrayerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  PrayerCategory _selectedCategory = PrayerCategory.health;
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final tenant = context.read<TenantProvider>();
    final auth = context.read<AuthProvider>();
    final prayer = context.read<PrayerProvider>();

    await prayer.addPrayerRequest(
      churchId: tenant.currentTenant.id,
      authorName: auth.currentUser?.name ?? 'Miembro de la Iglesia',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      isAnonymous: _isAnonymous,
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Petición compartida en el muro congregacional! 🙏'),
          backgroundColor: Color(0xFF15803D),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite_outline, color: theme.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Nueva Petición de Oración',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Selector de categoría
              const Text(
                'Categoría de la petición',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PrayerCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text('${cat.emoji} ${cat.label}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                    selectedColor: theme.primaryColor.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12.5,
                      color: isSelected ? theme.primaryColor : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _titleController,
                label: 'Motivo de oración (Título)',
                hint: 'Ej. Salud por mi abuela, examen de admisión',
                textCapitalization: TextCapitalization.sentences,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Ingresa un título o motivo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _descriptionController,
                label: 'Detalle de la petición',
                hint: 'Explica cómo la congregación puede respaldarte en oración...',
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Ingresa una breve descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Switch Anónimo
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Publicar de forma anónima', style: TextStyle(fontSize: 14)),
                subtitle: const Text(
                  'Tu nombre no aparecerá en el muro',
                  style: TextStyle(fontSize: 12),
                ),
                value: _isAnonymous,
                onChanged: (val) => setState(() => _isAnonymous = val),
              ),
              const SizedBox(height: 20),

              AppButton(
                text: 'Publicar Petición',
                onPressed: _handleSubmit,
                isLoading: _isSubmitting,
                icon: Icons.send_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
