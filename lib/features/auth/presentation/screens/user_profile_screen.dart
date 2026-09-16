import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../tenant/presentation/providers/tenant_provider.dart';
import '../providers/auth_provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (newPass.isNotEmpty) {
      if (newPass.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La nueva contraseña debe tener al menos 6 caracteres'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
        return;
      }
      if (newPass != confirmPass) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Las contraseñas no coinciden'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();

    final success = await auth.updateUserProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      newPassword: newPass.isNotEmpty ? newPass : null,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Tu perfil ha sido actualizado exitosamente! 👤✨'),
            backgroundColor: Color(0xFF15803D),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Error al actualizar perfil'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tenant = context.watch<TenantProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    final userInitial = (user?.name.isNotEmpty ?? false)
        ? user!.name.trim()[0].toUpperCase()
        : 'U';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil de Usuario'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Tarjeta de Encabezado de Usuario
                CustomCard(
                  padding: const EdgeInsets.all(20),
                  color: tenant.primaryColor.withValues(alpha: 0.08),
                  border: Border.all(color: tenant.primaryColor.withValues(alpha: 0.35)),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: tenant.primaryColor,
                        child: Text(
                          userInitial,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Usuario',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              user?.email ?? 'correo@ejemplo.com',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey[400] : Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: (user?.roles ?? []).map((role) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: role.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: role.color.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    role.label,
                                    style: TextStyle(
                                      color: role.color,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Información de Congregación
                CustomCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(Icons.church_rounded, color: tenant.primaryColor, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CONGREGACIÓN ASOCIADA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tenant.shortName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              tenant.churchName,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: tenant.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tenant.churchCode,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: tenant.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Datos Personales',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Estos son tus datos como siervo o miembro en la congregación.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                // Nombre Completo
                CustomTextField(
                  controller: _nameController,
                  label: 'Nombre y Apellidos',
                  hint: 'Ej. Juan Manuel Silva',
                  prefixIcon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Ingresa tu nombre completo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Teléfono Móvil
                CustomTextField(
                  controller: _phoneController,
                  label: 'Teléfono Móvil (WhatsApp)',
                  hint: '+505 8888 8888',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Correo Electrónico (Solo Lectura)
                CustomTextField(
                  controller: _emailController,
                  label: 'Correo Electrónico (No editable)',
                  hint: 'correo@ejemplo.com',
                  prefixIcon: Icons.email_outlined,
                  readOnly: true,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 28),

                // 3. Sección de Seguridad / Cambio de Contraseña
                Text(
                  'Seguridad y Contraseña',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Deja estos campos en blanco si no deseas cambiar tu clave actual.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                // Nueva Contraseña con botón de ojo visible
                CustomTextField(
                  controller: _newPasswordController,
                  label: 'Nueva Contraseña (Opcional)',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Confirmar Contraseña con botón de ojo visible
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmar Nueva Contraseña',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Botón Guardar Cambios
                AppButton(
                  text: 'Guardar Cambios de Perfil',
                  onPressed: _handleSaveProfile,
                  isLoading: _isLoading,
                  icon: Icons.save_rounded,
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
