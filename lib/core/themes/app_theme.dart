import 'package:flutter/material.dart';

abstract class AppTheme {
  // --- Couleurs ---
  static const colors = _AppColors();

  // --- Rayons de bordure (double & BorderRadius) ---
  static const radius = _AppRadius();

  // --- Espacements ---
  static const spacing = _AppSpacing();
}

class _AppColors {
  const _AppColors();

  final Color background = const Color(0xFFF8FAFC);
  final Color surface = const Color(0xFFFFFFFF);
  final Color surfaceMuted = const Color(0xFFF1F5F9);
  final Color primary = const Color(0xFF1E3A8A);
  final Color primarySoft = const Color(0xFFE0E7FF);
  final Color secondary = const Color(0xFF0D9488);
  final Color secondarySoft = const Color(0xFFCCFBF1);
  final Color accent = const Color(0xFFD97706);
  final Color accentSoft = const Color(0xFFFEF3C7);
  final Color success = const Color(0xFF059669);
  final Color successSoft = const Color(0xFFD1FAE5);
  final Color danger = const Color(0xFFE11D48);
  final Color dangerSoft = const Color(0xFFFFE4E6);
  final Color text = const Color(0xFF0F172A);
  final Color textMuted = const Color(0xFF64748B);
  final Color border = const Color(0xFFE2E8F0);
  final Color shadow = const Color(0xFF0F172A);
}

class _AppRadius {
  const _AppRadius();

  final double sm = 8.0;
  final double md = 12.0;
  final double lg = 16.0;
  final double xl = 20.0;

  BorderRadius get smBorder => BorderRadius.circular(sm);
  BorderRadius get mdBorder => BorderRadius.circular(md);
  BorderRadius get lgBorder => BorderRadius.circular(lg);
  BorderRadius get xlBorder => BorderRadius.circular(xl);
}

class _AppSpacing {
  const _AppSpacing();

  final double xs = 4.0;
  final double sm = 8.0;
  final double md = 12.0;
  final double lg = 16.0;
  final double xl = 24.0;
  final double xxl = 32.0;
}