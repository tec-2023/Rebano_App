import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../tenant/domain/entities/church_tenant.dart';
import '../../../navigation/main_navigation_shell.dart';

class ChurchCreatedSuccessScreen extends StatelessWidget {
  final ChurchTenant churchTenant;

  const ChurchCreatedSuccessScreen({
    super.key,
    required this.churchTenant,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: churchTenant.code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Código de iglesia copiado al portapapeles!'),
        backgroundColor: Color(0xFF15803D),
      ),
    );
  }

  void _shareCode() {
    Share.share(
      '¡Hola! Te invito a unirte a nuestra iglesia "${churchTenant.name}" en la app Rebaño. 🐑\n\n'
      'Descarga la app e ingresa nuestro Código de Iglesia:\n'
      '🔑 ${churchTenant.code}\n\n'
      '¡Te esperamos en nuestra red de oración y células!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = churchTenant.primaryColor;

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
                      const SizedBox(height: 16),

                      // Badge de éxito con logotipo
                      Center(
                        child: AppLogo(
                          size: 90,
                          borderRadius: 24,
                          padding: const EdgeInsets.all(10),
                          border: Border.all(color: const Color(0xFF86EFAC), width: 2),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        '¡Congregación Creada!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        churchTenant.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        'Comparte este código con tus líderes de célula, tesoreros y miembros para que se unan.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 24),

                      // Tarjeta de Código de Iglesia
                      CustomCard(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                        color: primaryColor.withValues(alpha: 0.08),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.4), width: 1.5),
                        child: Column(
                          children: [
                            const Text(
                              'CÓDIGO DE IGLESIA',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              churchTenant.code,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _copyToClipboard(context),
                                  icon: const Icon(Icons.copy_rounded, size: 16),
                                  label: const Text('Copiar'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: primaryColor,
                                    side: BorderSide(color: primaryColor),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _shareCode,
                                  icon: const Icon(Icons.share_rounded, size: 16),
                                  label: const Text('Compartir'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 24),

                      AppButton(
                        text: 'Ingresar al Panel de mi Iglesia',
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const MainNavigationShell()),
                            (route) => false,
                          );
                        },
                        customColor: primaryColor,
                        icon: Icons.arrow_forward_rounded,
                      ),
                      const SizedBox(height: 16),
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
