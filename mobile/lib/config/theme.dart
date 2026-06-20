import 'package:flutter/material.dart';

const Color _primary = Color(0xFF5B54E8);
const Color _secondary = Color(0xFF00BFA6);

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _primary,
    secondary: _secondary,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: const Color(0xFFF5F6FA),
  appBarTheme: AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: const Color(0xFFF5F6FA),
    foregroundColor: const Color(0xFF1A1A2E),
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1A1A2E),
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.grey.shade200),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _primary, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 52),
      elevation: 0,
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    elevation: 0,
    backgroundColor: Colors.white,
    indicatorColor: _primary.withValues(alpha: 0.12),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _primary);
      }
      return TextStyle(fontSize: 12, color: Colors.grey.shade600);
    }),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: _primary,
    foregroundColor: Colors.white,
    elevation: 4,
  ),
);
