import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  /// URL de tu proyecto en Supabase
  /// Puede ser provisto en tiempo de compilación con --dart-define=SUPABASE_URL=...
  /// o configurado directamente aquí.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://wkzydkksaiyamjrsapou.supabase.co',
  );

  /// Clave pública anónima o publicable (anon / publishable key) de tu proyecto en Supabase
  /// Puede ser provisto en tiempo de compilación con --dart-define=SUPABASE_ANON_KEY=...
  /// o configurado directamente aquí.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_3qPgVCbXnAqoeaOG8yPDig_H31QFZUc',
  );

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Retorna la instancia global del cliente de Supabase
  static SupabaseClient get client {
    return Supabase.instance.client;
  }

  /// Inicializa la conexión con el backend de Supabase
  static Future<void> initialize() async {
    try {
      if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
        await Supabase.initialize(
          url: supabaseUrl,
          // ignore: deprecated_member_use
          anonKey: supabaseAnonKey,
          debug: kDebugMode,
        );
        _isInitialized = true;
        debugPrint('[SupabaseConfig] Supabase inicializado correctamente con URL: $supabaseUrl');
      }
    } catch (e) {
      debugPrint('[SupabaseConfig] Advertencia al inicializar Supabase: $e');
      _isInitialized = false;
    }
  }
}
