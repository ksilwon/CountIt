import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_palette.dart';
import '../config/app_styles.dart';
import '../providers/theme_provider.dart';
import 'glass_surface.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final palette = context.palette;

    return GlassSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                'Motyw aplikacji',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            themeProvider.mode == AppThemeMode.system
                ? 'Liquid glass + tryb jasny/ciemny urządzenia'
                : 'Liquid glass · wymuszony tryb ${themeProvider.mode.label.toLowerCase()}',
            style: TextStyle(color: palette.textSecondary, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 16),
          SegmentedButton<AppThemeMode>(
            segments: AppThemeMode.values
                .map(
                  (mode) => ButtonSegment(
                    value: mode,
                    icon: Icon(mode.icon, size: 18),
                    label: Text(mode.label),
                  ),
                )
                .toList(),
            selected: {themeProvider.mode},
            onSelectionChanged: (selection) => themeProvider.setMode(selection.first),
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return AppColors.primary;
                return palette.textSecondary;
              }),
              side: WidgetStateProperty.all(BorderSide(color: palette.border)),
            ),
          ),
        ],
      ),
    );
  }
}
