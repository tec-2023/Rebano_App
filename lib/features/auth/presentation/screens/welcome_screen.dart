import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../tenant/presentation/providers/tenant_provider.dart';
import 'register_church_screen.dart';
import 'join_church_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tenant = context.watch<TenantProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),

                      // Header & Official Logo
                      Center(
                        child: AppLogo(
                          size: 96,
                          borderRadius: 24,
                          padding: const EdgeInsets.all(10),
                          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          border: Border.all(
                            color: tenant.primaryColor.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Rebaño',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: tenant.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Plataforma integral de gestión eclesiástica y comunión congregacional',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Registrar Iglesia (Pastor)
                      CustomCard(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterChurchScreen(),
                            ),
                          );
                        },
                        padding: const EdgeInsets.all(20),
                        border: Border.all(
                          color: tenant.primaryColor.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: tenant.primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.church_rounded,
                                color: tenant.primaryColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Registrar mi Iglesia',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Para Pastores y Administradores. Crea el espacio digital de tu congregación.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: tenant.primaryColor,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Unirme a mi Iglesia (Miembro)
                      CustomCard(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const JoinChurchScreen(),
                            ),
                          );
                        },
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.group_add_rounded,
                                color: Color(0xFFD97706),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Unirme a mi Iglesia',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ingresa con el código que te proporcionó tu pastor o líder de célula.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 20),

                      // Separador elegante
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '¿YA TIENES CUENTA?',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Botón de Iniciar Sesión
                      AppButton(
                        text: 'Iniciar Sesión en mi Cuenta',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        variant: AppButtonVariant.secondary,
                        icon: Icons.login_rounded,
                      ),

                      const SizedBox(height: 14),
                      Text(
                        'Versión 1.0.0 • Distribución APK Segura',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[500] : Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
