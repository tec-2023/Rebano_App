import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import '../../../navigation/main_navigation_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'pastor@graciaypaz.org');
  final _passwordController = TextEditingController(text: '123456');
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin({String? email, String? password}) async {
    final targetEmail = email ?? _emailController.text;
    final targetPassword = password ?? _passwordController.text;

    if (email == null && !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(targetEmail, targetPassword);

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
            content: Text(authProvider.errorMessage ?? 'Error al iniciar sesión'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bienvenido de vuelta',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Ingresa con tus credenciales o selecciona una cuenta demo de prueba.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Formulario tradicional
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _emailController,
                      label: 'Correo Electrónico',
                      hint: 'correo@ejemplo.com',
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
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: (val) {
                        if (val == null || val.length < 6) {
                          return 'Mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    AppButton(
                      text: 'Iniciar Sesión',
                      onPressed: () => _handleLogin(),
                      isLoading: _isLoading,
                      icon: Icons.login_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Sección Cuentas Demo Rápidas
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'CUENTAS DEMO (ACCESO DIRECTO)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),

              _buildDemoCard(
                title: 'Pastor David Morales',
                roleBadge: 'Admin / Pastor',
                roleColor: AppColors.roleAdmin,
                email: 'pastor@graciaypaz.org',
                description: 'Acceso total a Todos los Módulos, Tesorería, Células y White-label.',
                icon: Icons.admin_panel_settings_rounded,
              ),
              const SizedBox(height: 10),

              _buildDemoCard(
                title: 'Carlos Mendoza',
                roleBadge: 'Tesorero + Líder Célula',
                roleColor: AppColors.roleTreasurer,
                email: 'carlos.tesorero@graciaypaz.org',
                description: 'Acceso a Módulo de Tesorería, Células, Asistencia y Oración.',
                icon: Icons.account_balance_wallet_rounded,
              ),
              const SizedBox(height: 10),

              _buildDemoCard(
                title: 'María Fernanda Ríos',
                roleBadge: 'Líder de Célula',
                roleColor: AppColors.roleLeader,
                email: 'maria.lider@graciaypaz.org',
                description: 'Acceso a Asistencia de Célula, Mapa de Evangelismo y Oración.',
                icon: Icons.groups_rounded,
              ),
              const SizedBox(height: 10),

              _buildDemoCard(
                title: 'Juan Silva',
                roleBadge: 'Miembro',
                roleColor: AppColors.roleMember,
                email: 'juan.miembro@graciaypaz.org',
                description: 'Acceso a Red de Oración, peticiones y muro congregacional.',
                icon: Icons.person_rounded,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCard({
    required String title,
    required String roleBadge,
    required Color roleColor,
    required String email,
    required String description,
    required IconData icon,
  }) {
    return CustomCard(
      onTap: () {
        _emailController.text = email;
        _handleLogin(email: email, password: 'password123');
      },
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: roleColor, size: 24),
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
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        roleBadge,
                        style: TextStyle(
                          color: roleColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
