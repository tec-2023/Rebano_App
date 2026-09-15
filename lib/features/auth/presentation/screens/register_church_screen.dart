import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../tenant/presentation/providers/tenant_provider.dart';
import '../providers/auth_provider.dart';
import 'church_created_success_screen.dart';

class RegisterChurchScreen extends StatefulWidget {
  const RegisterChurchScreen({super.key});

  @override
  State<RegisterChurchScreen> createState() => _RegisterChurchScreenState();
}

class _RegisterChurchScreenState extends State<RegisterChurchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _churchNameController = TextEditingController();
  final _pastorNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Color _selectedPrimaryColor = AppColors.themePresets.first.primaryColor;
  bool _isLoading = false;

  @override
  void dispose() {
    _churchNameController.dispose();
    _pastorNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegisterChurch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final tenantProvider = context.read<TenantProvider>();
    final authProvider = context.read<AuthProvider>();

    // 1. Registramos la iglesia y generamos su código
    final newChurch = await tenantProvider.registerChurch(
      name: _churchNameController.text.trim(),
      pastorName: _pastorNameController.text.trim(),
      email: _emailController.text.trim(),
      primaryColor: _selectedPrimaryColor,
    );

    if (newChurch != null) {
      // 2. Registramos al Pastor como Administrador de este Tenant
      await authProvider.registerAdmin(
        name: _pastorNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        churchId: newChurch.id,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ChurchCreatedSuccessScreen(churchTenant: newChurch),
          ),
        );
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tenantProvider.errorMessage ?? 'Error al registrar iglesia'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Congregación'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Encabezado
                Text(
                  'Crea el espacio digital de tu iglesia',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Como Pastor o Administrador, tendrás acceso al control total de células, tesorería y red de oración.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Campos del formulario
                CustomTextField(
                  controller: _churchNameController,
                  label: 'Nombre de la Iglesia / Congregación',
                  hint: 'Ej. Comunidad Cristiana Gracia y Paz',
                  prefixIcon: Icons.church_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Por favor ingresa el nombre de la iglesia';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _pastorNameController,
                  label: 'Nombre completo del Pastor / Líder',
                  hint: 'Ej. Pastor David Morales',
                  prefixIcon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Por favor ingresa el nombre del pastor';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _emailController,
                  label: 'Correo electrónico de administración',
                  hint: 'pastor@mi-iglesia.org',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || !val.contains('@')) {
                      return 'Ingresa un correo electrónico válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _passwordController,
                  label: 'Contraseña de acceso',
                  hint: 'Mínimo 6 caracteres',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (val) {
                    if (val == null || val.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Selector de Color Primario de la Iglesia
                const Text(
                  'Color de Marca Blanca (Identidad Visual)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Personaliza la paleta de colores para todos los miembros de tu congregación:',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: AppColors.themePresets.map((preset) {
                    final isSelected = _selectedPrimaryColor == preset.primaryColor;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedPrimaryColor = preset.primaryColor);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: preset.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? preset.primaryColor : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: preset.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              preset.name,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: preset.primaryColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 36),

                AppButton(
                  text: 'Crear Iglesia y Generar Código',
                  onPressed: _handleRegisterChurch,
                  isLoading: _isLoading,
                  customColor: _selectedPrimaryColor,
                  icon: Icons.check_circle_outline,
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
