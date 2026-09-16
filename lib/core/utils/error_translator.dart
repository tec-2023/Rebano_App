class ErrorTranslator {
  /// Traduce excepciones de Supabase, Postgres o de red a mensajes humanos y amigables.
  static String translate(dynamic error) {
    if (error == null) return 'Ocurrió un error inesperado.';

    final errorStr = error.toString().toLowerCase();

    // 1. Conflictos de clave única en iglesias (código de acceso repetido)
    if (errorStr.contains('iglesias_codigo_acceso_key') ||
        (errorStr.contains('duplicate key') && errorStr.contains('iglesias'))) {
      return 'Ya existe una congregación registrada con este nombre o código. Si ya creaste tu cuenta, pulsa en "Iniciar Sesión".';
    }

    // 2. Conflictos de usuario ya registrado
    if (errorStr.contains('user already registered') ||
        errorStr.contains('user_already_exists') ||
        errorStr.contains('email address already registered')) {
      return 'Este correo electrónico ya está registrado. Por favor inicia sesión con tu contraseña.';
    }

    // 3. Credenciales incorrectas
    if (errorStr.contains('invalid login credentials') ||
        errorStr.contains('invalid_grant') ||
        errorStr.contains('wrong password') ||
        errorStr.contains('user not found')) {
      return 'El correo electrónico o la contraseña ingresada son incorrectos. Verifica tus datos e intenta nuevamente.';
    }

    // 4. Correo no confirmado
    if (errorStr.contains('email not confirmed')) {
      return 'Tu cuenta requiere confirmación por correo electrónico. Revisa tu bandeja de entrada o spam.';
    }

    // 5. Errores de red o conexión
    if (errorStr.contains('socketexception') ||
        errorStr.contains('connection refused') ||
        errorStr.contains('failed host lookup') ||
        errorStr.contains('network') ||
        errorStr.contains('timeout')) {
      return 'No se pudo conectar con el servidor. Por favor verifica tu conexión a internet.';
    }

    // 6. Contraseña muy corta
    if (errorStr.contains('password should be at least') || errorStr.contains('weak password')) {
      return 'La contraseña debe tener al menos 6 caracteres seguros.';
    }

    // 7. Error RLS (Row Level Security)
    if (errorStr.contains('row-level security policy') || errorStr.contains('rls')) {
      return 'No tienes permisos suficientes para realizar esta acción.';
    }

    // Si es un mensaje limpio sin formato técnico, lo retornamos directo
    final clean = error.toString().replaceAll(RegExp(r'Exception:\s*|AuthException\(message:\s*|\)'), '');
    if (!clean.contains('PostgrestException') && !clean.contains('{') && clean.length < 150) {
      return clean;
    }

    return 'Ocurrió un inconveniente al procesar la solicitud. Por favor intenta nuevamente.';
  }
}
