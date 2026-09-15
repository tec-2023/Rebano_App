import 'package:flutter/material.dart';

class ChurchThemePreset {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final String description;

  const ChurchThemePreset({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.description,
  });
}

class AppColors {
  // Presets de colores para Marca Blanca (White-Label) de iglesias
  static const List<ChurchThemePreset> themePresets = [
    ChurchThemePreset(
      name: 'Azul Celestial',
      primaryColor: Color(0xFF1E5BB8),
      secondaryColor: Color(0xFF4A8FE7),
      description: 'Paz, fidelidad y solemnidad',
    ),
    ChurchThemePreset(
      name: 'Vino Litúrgico',
      primaryColor: Color(0xFF8B1E3F),
      secondaryColor: Color(0xFFC03960),
      description: 'Pacto, devoción y reverencia',
    ),
    ChurchThemePreset(
      name: 'Verde Esperanza',
      primaryColor: Color(0xFF1B6B48),
      secondaryColor: Color(0xFF38A375),
      description: 'Crecimiento, vida y renuevo',
    ),
    ChurchThemePreset(
      name: 'Púrpura Real',
      primaryColor: Color(0xFF5B2C8E),
      secondaryColor: Color(0xFF8D53CA),
      description: 'Majestad, realeza y adoración',
    ),
    ChurchThemePreset(
      name: 'Índigo Profundo',
      primaryColor: Color(0xFF283E68),
      secondaryColor: Color(0xFF4C6A9E),
      description: 'Sabiduría, templanza y guía',
    ),
    ChurchThemePreset(
      name: 'Dorado / Ámbar',
      primaryColor: Color(0xFFC27D0E),
      secondaryColor: Color(0xFFE5A93C),
      description: 'Gloria, gozo y luz',
    ),
    ChurchThemePreset(
      name: 'Turquesa Río de Vida',
      primaryColor: Color(0xFF0F766E),
      secondaryColor: Color(0xFF14B8A6),
      description: 'Gracia, pureza y restauración',
    ),
  ];

  // Colores fijos de estado y UI
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Colores neutros claros
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Colores neutros oscuros
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);

  // Colores de Roles
  static const Color roleAdmin = Color(0xFF7C3AED);
  static const Color roleLeader = Color(0xFF2563EB);
  static const Color roleTreasurer = Color(0xFF059669);
  static const Color roleMember = Color(0xFFD97706);
}
