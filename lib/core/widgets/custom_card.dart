import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final BoxBorder? border;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin = const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    this.onTap,
    this.color,
    this.border,
    this.borderRadius = 16,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultShadow = [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : const Color(0xFF64748B).withValues(alpha: 0.08),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ];

    final cardContent = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ??
            Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 1,
            ),
        boxShadow: boxShadow ?? defaultShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(18),
            child: child,
          ),
        ),
      ),
    );

    return cardContent;
  }
}
