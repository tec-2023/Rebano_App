import 'package:flutter/material.dart';

enum BadgeType { success, warning, error, info, neutral, answered }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = BadgeType.info,
    this.icon,
    this.fontSize = 12.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData? defaultIcon;

    switch (type) {
      case BadgeType.success:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        defaultIcon = Icons.check_circle_outline;
        break;
      case BadgeType.warning:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        defaultIcon = Icons.access_time;
        break;
      case BadgeType.error:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        defaultIcon = Icons.error_outline;
        break;
      case BadgeType.info:
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1D4ED8);
        defaultIcon = Icons.info_outline;
        break;
      case BadgeType.neutral:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        break;
      case BadgeType.answered:
        bg = const Color(0xFFEDE9FE);
        fg = const Color(0xFF6D28D9);
        defaultIcon = Icons.auto_awesome;
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null || defaultIcon != null) ...[
            Icon(icon ?? defaultIcon, size: fontSize + 2, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
