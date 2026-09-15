import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/app_version.dart';

class OtaService {
  static const String currentInstalledVersion = '1.0.0';

  /// Simula la consulta a la nube (Supabase Storage / GitHub Releases / S3)
  static Future<AppVersion> checkForUpdate({bool simulateUpdateFound = false}) async {
    await Future.delayed(const Duration(milliseconds: 900));

    // Si simulateUpdateFound es true, devolvemos versión 1.2.0
    return AppVersion(
      currentVersion: currentInstalledVersion,
      latestVersion: simulateUpdateFound ? '1.2.0' : '1.0.0',
      downloadUrl: 'https://github.com/rebano-app/releases/download/v1.2.0/rebano-v1.2.0.apk',
      releaseNotes: '• Módulo de Células y Evangelismo mejorado.\n• Exportación rápida de tesorería a Excel.\n• Mejoras de rendimiento y corrección de errores.',
      isMandatory: true,
    );
  }

  /// Abre la URL para descargar el APK en el navegador del dispositivo
  static Future<bool> launchDownloadApk(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
