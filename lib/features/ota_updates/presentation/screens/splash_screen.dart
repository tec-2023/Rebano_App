import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/app_version.dart';
import '../controllers/ota_service.dart';
import '../../../tenant/presentation/providers/tenant_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/welcome_screen.dart';
import '../../../navigation/main_navigation_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();
    _checkAppUpdates();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkAppUpdates() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    // Consultamos OTA Service (puedes cambiar simulateUpdateFound a true/false)
    final updateInfo = await OtaService.checkForUpdate(simulateUpdateFound: false);

    if (!mounted) return;

    if (updateInfo.hasUpdate) {
      _showUpdateDialog(updateInfo);
    } else {
      _navigateToNextScreen();
    }
  }

  void _showUpdateDialog(AppVersion updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: false, // Bloqueante como se especificó en el requerimiento
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.system_update_rounded,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Nueva Versión Disponible',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hay una nueva versión de Rebaño lista para instalar:\n'
              '• Versión actual: v${updateInfo.currentVersion}\n'
              '• Nueva versión: v${updateInfo.latestVersion}',
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            const Text(
              'Novedades:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                updateInfo.releaseNotes,
                style: const TextStyle(fontSize: 12.5, height: 1.3),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _navigateToNextScreen();
            },
            child: const Text('Omitir (Modo Demo)'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await OtaService.launchDownloadApk(updateInfo.downloadUrl);
            },
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Descargar APK'),
          ),
        ],
      ),
    );
  }

  void _navigateToNextScreen() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenant = context.watch<TenantProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Icon / Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: tenant.primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: tenant.primaryColor.withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '🐑',
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Rebaño',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: tenant.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tenant.churchName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(tenant.primaryColor),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Verificando actualizaciones...',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
