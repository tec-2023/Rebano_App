import 'package:url_launcher/url_launcher.dart';

class SupportService {
  static const String supportWhatsAppNumber = '5215512345678';

  /// Abre WhatsApp con mensaje predeterminado para apoyar al ministerio
  static Future<bool> openSupportWhatsApp({
    String? churchName,
    String? pastorName,
  }) async {
    final message = Uri.encodeComponent(
      '¡Hola equipo de Rebaño App! 👋\n\n'
      'Me pongo en contacto desde la congregación "${churchName ?? 'Nuestra Iglesia'}" '
      'para consultar información sobre cómo apoyar este hermoso ministerio y la plataforma Rebaño. '
      '¡Bendiciones!',
    );

    final urlString = 'https://wa.me/$supportWhatsAppNumber?text=$message';
    final uri = Uri.parse(urlString);

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
