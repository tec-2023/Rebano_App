import 'package:flutter/material.dart';

enum AlertType { success, error, warning, info }

class AppAlert {
  /// Muestra una notificación emergente flotante con diseño premium y elegante.
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    AlertType type = AlertType.error,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();

    Color bgGradientStart;
    Color bgGradientEnd;
    Color borderColor;
    Color iconBgColor;
    IconData iconData;
    String defaultTitle;

    switch (type) {
      case AlertType.success:
        bgGradientStart = const Color(0xFF064E3B);
        bgGradientEnd = const Color(0xFF022C22);
        borderColor = const Color(0xFF10B981);
        iconBgColor = const Color(0xFF10B981);
        iconData = Icons.check_circle_rounded;
        defaultTitle = title ?? '¡Operación Exitosa!';
        break;
      case AlertType.error:
        bgGradientStart = const Color(0xFF7F1D1D);
        bgGradientEnd = const Color(0xFF450A0A);
        borderColor = const Color(0xFFEF4444);
        iconBgColor = const Color(0xFFEF4444);
        iconData = Icons.error_outline_rounded;
        defaultTitle = title ?? 'Atención Requerida';
        break;
      case AlertType.warning:
        bgGradientStart = const Color(0xFF78350F);
        bgGradientEnd = const Color(0xFF451A03);
        borderColor = const Color(0xFFF59E0B);
        iconBgColor = const Color(0xFFF59E0B);
        iconData = Icons.warning_amber_rounded;
        defaultTitle = title ?? 'Aviso Importante';
        break;
      case AlertType.info:
        bgGradientStart = const Color(0xFF1E3A8A);
        bgGradientEnd = const Color(0xFF0F172A);
        borderColor = const Color(0xFF3B82F6);
        iconBgColor = const Color(0xFF3B82F6);
        defaultTitle = title ?? 'Información';
        iconData = Icons.info_outline_rounded;
        break;
    }

    final snackBar = SnackBar(
      elevation: 8,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      padding: EdgeInsets.zero,
      duration: duration,
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgGradientStart, bgGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor.withValues(alpha: 0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor.withValues(alpha: 0.25),
                shape: BoxShape.circle,
                border: Border.all(color: iconBgColor.withValues(alpha: 0.5)),
              ),
              child: Icon(iconData, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    defaultTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        scaffoldMessenger.hideCurrentSnackBar();
                        onAction();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white38),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              actionLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    scaffoldMessenger.showSnackBar(snackBar);
  }

  static void showError(
    BuildContext context, {
    required String message,
    String? title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AlertType.error,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
  }) {
    show(context, message: message, title: title, type: AlertType.success);
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    String? title,
  }) {
    show(context, message: message, title: title, type: AlertType.warning);
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    String? title,
  }) {
    show(context, message: message, title: title, type: AlertType.info);
  }
}
