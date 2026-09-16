import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final BoxBorder? border;
  final double borderRadius;
  final bool showShadow;
  final EdgeInsetsGeometry padding;

  final String? logoUrl;

  const AppLogo({
    super.key,
    this.size = 64,
    this.logoUrl,
    this.backgroundColor,
    this.border,
    this.borderRadius = 16,
    this.showShadow = true,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget imageWidget;
    if (logoUrl != null && logoUrl!.trim().isNotEmpty && (logoUrl!.startsWith('http://') || logoUrl!.startsWith('https://'))) {
      imageWidget = Image.network(
        logoUrl!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/rebano_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Center(
              child: Text('🐑', style: TextStyle(fontSize: 28)),
            ),
          );
        },
      );
    } else {
      imageWidget = Image.asset(
        'assets/images/rebano_logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Text('🐑', style: TextStyle(fontSize: 28)),
          );
        },
      );
    }

    return Container(
      width: size,
      height: size,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ??
            Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 1,
            ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 4),
        child: imageWidget,
      ),
    );
  }
}
