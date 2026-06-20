import 'dart:ui';

import 'package:flutter/material.dart';
import 'app_styles.dart';

enum AppThemeMode { light, dark, system }

extension AppThemeModeStorage on AppThemeMode {
  String get storageKey => name;

  static AppThemeMode fromStorage(String? value) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AppThemeMode.system,
    );
  }

  String get label {
    switch (this) {
      case AppThemeMode.light:
        return 'Jasny';
      case AppThemeMode.dark:
        return 'Ciemny';
      case AppThemeMode.system:
        return 'Systemowy';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeMode.light:
        return Icons.light_mode_rounded;
      case AppThemeMode.dark:
        return Icons.dark_mode_rounded;
      case AppThemeMode.system:
        return Icons.blur_on_rounded;
    }
  }
}

class AppPalette extends ThemeExtension<AppPalette> {
  final bool useGlass;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color glassFill;
  final Color glassBorder;
  final Color glassHighlight;
  final Color tabPillBackground;
  final Color tabPillSelected;
  final Color dangerSoft;
  final Color successSoft;
  final double blurSigma;

  const AppPalette({
    required this.useGlass,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.glassFill,
    required this.glassBorder,
    required this.glassHighlight,
    required this.tabPillBackground,
    required this.tabPillSelected,
    required this.dangerSoft,
    required this.successSoft,
    required this.blurSigma,
  });

  static AppPalette forBrightness(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    if (isDark) {
      return AppPalette(
        useGlass: true,
        background: const Color(0xFF070B14),
        surface: const Color(0xFF111827).withValues(alpha: 0.82),
        textPrimary: Colors.white,
        textSecondary: Colors.white.withValues(alpha: 0.72),
        textMuted: Colors.white.withValues(alpha: 0.48),
        border: Colors.white.withValues(alpha: 0.10),
        glassFill: const Color(0xFF0F172A).withValues(alpha: 0.78),
        glassBorder: Colors.white.withValues(alpha: 0.10),
        glassHighlight: Colors.white.withValues(alpha: 0.05),
        tabPillBackground: const Color(0xFF0A1018).withValues(alpha: 0.72),
        tabPillSelected: const Color(0xFF1E293B).withValues(alpha: 0.88),
        dangerSoft: const Color(0xFF2A1218),
        successSoft: const Color(0xFF0F241C),
        blurSigma: 28,
      );
    }

    return AppPalette(
      useGlass: true,
      background: const Color(0xFFE8EDF5),
      surface: Colors.white.withValues(alpha: 0.24),
      textPrimary: const Color(0xFF0F172A),
      textSecondary: const Color(0xFF475569),
      textMuted: const Color(0xFF64748B),
      border: Colors.white.withValues(alpha: 0.42),
      glassFill: Colors.white.withValues(alpha: 0.22),
      glassBorder: Colors.white.withValues(alpha: 0.48),
      glassHighlight: Colors.white.withValues(alpha: 0.35),
      tabPillBackground: Colors.white.withValues(alpha: 0.18),
      tabPillSelected: Colors.white.withValues(alpha: 0.42),
      dangerSoft: AppColors.errorSoft,
      successSoft: AppColors.successSoft,
      blurSigma: 24,
    );
  }

  @override
  AppPalette copyWith({
    bool? useGlass,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? glassFill,
    Color? glassBorder,
    Color? glassHighlight,
    Color? tabPillBackground,
    Color? tabPillSelected,
    Color? dangerSoft,
    Color? successSoft,
    double? blurSigma,
  }) {
    return AppPalette(
      useGlass: useGlass ?? this.useGlass,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      glassFill: glassFill ?? this.glassFill,
      glassBorder: glassBorder ?? this.glassBorder,
      glassHighlight: glassHighlight ?? this.glassHighlight,
      tabPillBackground: tabPillBackground ?? this.tabPillBackground,
      tabPillSelected: tabPillSelected ?? this.tabPillSelected,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      successSoft: successSoft ?? this.successSoft,
      blurSigma: blurSigma ?? this.blurSigma,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      useGlass: t < 0.5 ? useGlass : other.useGlass,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassHighlight: Color.lerp(glassHighlight, other.glassHighlight, t)!,
      tabPillBackground: Color.lerp(tabPillBackground, other.tabPillBackground, t)!,
      tabPillSelected: Color.lerp(tabPillSelected, other.tabPillSelected, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.forBrightness(Theme.of(this).brightness);
}
