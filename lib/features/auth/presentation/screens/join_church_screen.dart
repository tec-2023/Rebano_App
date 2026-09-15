import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../tenant/presentation/providers/tenant_provider.dart';
import '../providers/auth_provider.dart';
import '../../../navigation/main_navigation_shell.dart';

class JoinChurchScreen extends StatefulWidget {
  const JoinChurchScreen({super.key});

  @override
  State<JoinChurchScreen> createState() => _JoinChurchScreenState();
}

class _JoinChurchScreenState extends State<JoinChurchScreen> {
  final _codeFormKey = GlobalKey<FormState>();
  final _userFormKey = GlobalKey<FormState>();

  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isCodeVerified = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _verifyChurchCode() async {
    if (!_codeFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final tenantProvider = context.read<TenantProvider>();
    final success = await tenantProvider.loadTenantByCode(_codeController.text.trim());

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isCodeVerified = success;
      });

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tenantProvider.errorMessage ?? 'Código de iglesia no válido'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _registerMember() async {
    if (!_userFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final tenantProvider = context.read<TenantProvider>();
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.registerMember(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      churchId: tenantProvider.currentTenant.id,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Error al registrarse'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tenantProvider = context.watch<TenantProvider>();
    final church = tenantProvider.currentTenant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unirme a mi Iglesia'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado
              Text(
                'Ingresa el Código de tu Iglesia',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Tu pastor o líder de célula te proporcionó una clave de acceso (Ej: REB-1054).',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Paso 1: Código de Iglesia
              Form(
                key: _codeFormKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _codeController,
                      label: 'Código de Iglesia',
                      hint: 'REB-1054',
                      prefixIcon: Icons.vpn_key_outlined,
                      readOnly: _isCodeVerified,
                      textCapitalization: TextCapitalization.characters,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Ingresa el código de la iglesia';
                        }
                        return null;
                      },
                      suffixIcon: _isCodeVerified
                          ? IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () {
                                setState(() {
                                  _isCodeVerified = false;
                                });
                              },
                            )
                          : null,
                    ),
                    if (!_isCodeVerified) ...[
                      const SizedBox(height: 16),
                      AppButton(
                        text: 'Validar Código',
                        onPressed: _verifyChurchCode,
                        isLoading: _isLoading,
                        icon: Icons.check_circle_outline,
                      ),
                      const SizedBox(height: 14),
                      // Sugerencias de códigos para testing rápido
                      Wrap(
                        spacing: 8,
                        children: [
                          const Text('Códigos de prueba: ', style: TextStyle(fontSize: 12)),
                          ActionChip(
                            label: const Text('REB-1054', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              _codeController.text = 'REB-1054';
                              _verifyChurchCode();
                            },
                          ),
                          ActionChip(
                            label: const Text('REB-2048', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              _codeController.text = 'REB-2048';
                              _verifyChurchCode();
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Paso 2: Datos del Miembro (Solo si el código es válido)
              if (_isCodeVerified) ...[
                const SizedBox(height: 24),

                // Tarjeta de Iglesia Verificada
                CustomCard(
                  color: church.primaryColor.withValues(alpha: 0.08),
                  border: Border.all(color: church.primaryColor.withValues(alpha: 0.4)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: church.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.church_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    church.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.5,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.verified, color: Color(0xFF15803D), size: 18),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              church.pastorName,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  'Completa tu registro de Miembro',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 14),

                Form(
                  key: _userFormKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _nameController,
                        label: 'Nombre Completo',
                        hint: 'Ej. Juan Silva Morales',
                        prefixIcon: Icons.person_outline,
                        textCapitalization: TextCapitalization.words,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Ingresa tu nombre completo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      CustomTextField(
                        controller: _emailController,
                        label: 'Correo Electrónico',
                        hint: 'juan.silva@ejemplo.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || !val.contains('@')) {
                            return 'Ingresa un correo válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      CustomTextField(
                        controller: _passwordController,
                        label: 'Contraseña',
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
                      const SizedBox(height: 28),

                      AppButton(
                        text: 'Completar Registro y Entrar',
                        onPressed: _registerMember,
                        isLoading: _isLoading,
                        customColor: church.primaryColor,
                        icon: Icons.login_rounded,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
