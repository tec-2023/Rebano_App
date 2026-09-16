import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../tenant/presentation/providers/tenant_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/welcome_screen.dart';

class WhiteLabelSettingsScreen extends StatefulWidget {
  const WhiteLabelSettingsScreen({super.key});

  @override
  State<WhiteLabelSettingsScreen> createState() => _WhiteLabelSettingsScreenState();
}

class _WhiteLabelSettingsScreenState extends State<WhiteLabelSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _shortNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late Color _selectedColor;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final tenant = context.read<TenantProvider>().currentTenant;
    _nameController = TextEditingController(text: tenant.name);
    _shortNameController = TextEditingController(text: tenant.shortName);
    _addressController = TextEditingController(text: tenant.address);
    _phoneController = TextEditingController(text: tenant.phone);
    _selectedColor = tenant.primaryColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final tenant = context.read<TenantProvider>();

    final success = await tenant.updateCustomization(
      name: _nameController.text.trim(),
      shortName: _shortNameController.text.trim(),
      primaryColor: _selectedColor,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Identidad y Marca Blanca actualizadas en toda la app! 🎨'),
            backgroundColor: Color(0xFF15803D),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tenantProvider = context.watch<TenantProvider>();
    final currentCode = tenantProvider.churchCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marca Blanca & Personalización'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Identidad de tu Iglesia',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Personaliza los colores, logotipo, nombres y detalles visuales que verán todos los miembros y líderes.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),

                // Previsualización del Logo Oficial
                CustomCard(
                  padding: const EdgeInsets.all(16),
                  color: _selectedColor.withValues(alpha: 0.08),
                  border: Border.all(color: _selectedColor.withValues(alpha: 0.35)),
                  child: Row(
                    children: [
                      AppLogo(
                        size: 60,
                        borderRadius: 14,
                        padding: const EdgeInsets.all(6),
                        border: Border.all(color: _selectedColor.withValues(alpha: 0.4), width: 1.5),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('LOGOTIPO OFICIAL REBAÑO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            const SizedBox(height: 2),
                            const Text('Identidad Eclesiástica Activa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text('Código: $currentCode', style: TextStyle(fontSize: 12.5, color: _selectedColor, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 1. Nombre Completo Oficial
                CustomTextField(
                  controller: _nameController,
                  label: 'Nombre Oficial / Completo de la Congregación',
                  hint: 'Ej. Iglesia Bautista Fundamental Independiente El Alfarero',
                  prefixIcon: Icons.church_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Ingresa el nombre oficial de la iglesia';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 2. Nombre Corto / Distintivo
                CustomTextField(
                  controller: _shortNameController,
                  label: 'Nombre Corto / Conocido (Para títulos y menús)',
                  hint: 'Ej. El Alfarero',
                  prefixIcon: Icons.bookmark_border_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Ingresa el nombre corto distintivo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _addressController,
                  label: 'Dirección del Santuario Principal',
                  hint: 'Costado Oeste del Parque Central, Managua, Nicaragua',
                  prefixIcon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _phoneController,
                  label: 'Teléfono de Contacto Pastoral',
                  hint: '+505 2222 3456',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),

                // Selector de Color Primario de Marca Blanca
                const Text(
                  'Color Primario del Tema (Live Theme Switcher)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                ),
                const SizedBox(height: 6),
                Text(
                  'Al tocar un color, la interfaz completa adaptará sus botones, encabezados y contrastes de inmediato:',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: AppColors.themePresets.map((preset) {
                    final isSelected = _selectedColor == preset.primaryColor;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedColor = preset.primaryColor);
                        // Aplicamos el cambio en vivo
                        tenantProvider.updateCustomization(
                          name: _nameController.text.trim(),
                          shortName: _shortNameController.text.trim(),
                          primaryColor: preset.primaryColor,
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: preset.primaryColor.withValues(alpha: isSelected ? 0.18 : 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? preset.primaryColor : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: preset.primaryColor,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  preset.name,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isDark ? Colors.white : preset.primaryColor,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  preset.description,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                AppButton(
                  text: 'Guardar Cambios de Marca Blanca',
                  onPressed: _handleSave,
                  isLoading: _isLoading,
                  customColor: _selectedColor,
                  icon: Icons.save_rounded,
                ),
                const SizedBox(height: 36),

                // 5. Zona de Peligro: Eliminar Congregación
                CustomCard(
                  padding: const EdgeInsets.all(18),
                  color: const Color(0xFFFEE2E2).withValues(alpha: isDark ? 0.2 : 0.8),
                  border: Border.all(color: const Color(0xFFF87171)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 22),
                          SizedBox(width: 8),
                          Text(
                            'ZONA DE PELIGRO',
                            style: TextStyle(
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Eliminar Congregación',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Si esta congregación cerró o deseas eliminar permanentemente todos los registros y datos de este tenant, puedes borrarla aquí.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? Colors.grey[300] : const Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showDeleteChurchDialog(
                            context,
                            tenantProvider,
                            context.read<AuthProvider>(),
                          ),
                          icon: const Icon(Icons.delete_forever_rounded, color: Color(0xFFDC2626)),
                          label: const Text(
                            'Eliminar Iglesia Permanentemente',
                            style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFDC2626)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteChurchDialog(
    BuildContext context,
    TenantProvider tenant,
    AuthProvider auth,
  ) {
    final churchName = tenant.churchName;
    final confirmController = TextEditingController();
    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '¿Eliminar Iglesia?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Esta acción es IRREVERSIBLE. Se eliminará la congregación y se desvinculará a todos los miembros y registros.',
                style: TextStyle(fontSize: 13.5, color: Color(0xFFDC2626), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                  ),
                  children: [
                    const TextSpan(text: 'Para confirmar, escribe el nombre exacto de la iglesia:\n"'),
                    TextSpan(
                      text: churchName,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                    ),
                    const TextSpan(text: '"'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                decoration: const InputDecoration(
                  hintText: 'Escribe el nombre aquí...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              onPressed: isDeleting
                  ? null
                  : () async {
                      if (confirmController.text.trim() != churchName.trim()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('El nombre ingresado no coincide con la congregación'),
                            backgroundColor: Color(0xFFDC2626),
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isDeleting = true);
                      final deleted = await tenant.deleteChurch();
                      if (deleted) {
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.of(dialogCtx).pop();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                            (route) => false,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('La congregación ha sido eliminada permanentemente.'),
                              backgroundColor: Color(0xFF15803D),
                            ),
                          );
                        }
                      } else {
                        setDialogState(() => isDeleting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(tenant.errorMessage ?? 'Error al eliminar la iglesia'),
                              backgroundColor: const Color(0xFFDC2626),
                            ),
                          );
                        }
                      }
                    },
              child: isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Eliminar Definitivamente'),
            ),
          ],
        ),
      ),
    );
  }
}
