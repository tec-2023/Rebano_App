import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../tenant/presentation/providers/tenant_provider.dart';

class WhiteLabelSettingsScreen extends StatefulWidget {
  const WhiteLabelSettingsScreen({super.key});

  @override
  State<WhiteLabelSettingsScreen> createState() => _WhiteLabelSettingsScreenState();
}

class _WhiteLabelSettingsScreenState extends State<WhiteLabelSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late Color _selectedColor;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final tenant = context.read<TenantProvider>().currentTenant;
    _nameController = TextEditingController(text: tenant.name);
    _addressController = TextEditingController(text: tenant.address);
    _phoneController = TextEditingController(text: tenant.phone);
    _selectedColor = tenant.primaryColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
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
                  'Personaliza los colores, nombres y detalles visuales que verán todos los miembros y líderes.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),

                // Badge de Código de Iglesia
                CustomCard(
                  padding: const EdgeInsets.all(14),
                  color: _selectedColor.withValues(alpha: 0.08),
                  border: Border.all(color: _selectedColor.withValues(alpha: 0.35)),
                  child: Row(
                    children: [
                      Icon(Icons.vpn_key_rounded, color: _selectedColor, size: 24),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CÓDIGO DE IGLESIA (TENANT)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          Text(
                            currentCode,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _selectedColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  controller: _nameController,
                  label: 'Nombre de la Congregación',
                  hint: 'Ej. Comunidad Cristiana Gracia y Paz',
                  prefixIcon: Icons.church_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Ingresa el nombre de la iglesia';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _addressController,
                  label: 'Dirección del Santuario Principal',
                  hint: 'Calle y número, colonia, ciudad',
                  prefixIcon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _phoneController,
                  label: 'Teléfono de Contacto Pastoral',
                  hint: '+52 55 1234 5678',
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
                                shape: BoxShape.circle,
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
