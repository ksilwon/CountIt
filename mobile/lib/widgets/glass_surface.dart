import 'dart:ui';

import 'package:flutter/material.dart';
import '../config/app_palette.dart';
import '../config/app_styles.dart';

class MeshGradientBackground extends StatelessWidget {
  final Brightness brightness;

  const MeshGradientBackground({super.key, required this.brightness});

  @override
  Widget build(BuildContext context) {
    final isDark = brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF070B14) : const Color(0xFFE8EDF5),
      child: Stack(
        children: [
          _blob(
            top: -80,
            left: -60,
            size: 280,
            color: isDark ? const Color(0xFF6366F1).withValues(alpha: 0.35) : const Color(0xFF818CF8).withValues(alpha: 0.45),
          ),
          _blob(
            top: 120,
            right: -90,
            size: 260,
            color: isDark ? const Color(0xFF14B8A6).withValues(alpha: 0.22) : const Color(0xFF2DD4BF).withValues(alpha: 0.35),
          ),
          _blob(
            bottom: 80,
            left: 40,
            size: 240,
            color: isDark ? const Color(0xFF7C3AED).withValues(alpha: 0.28) : const Color(0xFFA78BFA).withValues(alpha: 0.30),
          ),
          _blob(
            bottom: -40,
            right: 30,
            size: 200,
            color: isDark ? const Color(0xFF2563EB).withValues(alpha: 0.20) : const Color(0xFF60A5FA).withValues(alpha: 0.28),
          ),
        ],
      ),
    );
  }

  Widget _blob({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class GlassSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;
  final Color? color;

  const GlassSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadius.md)),
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final fill = color ?? palette.glassFill;

    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: palette.glassBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.28 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            fill,
            fill.withValues(alpha: (fill.a * 0.82).clamp(0.0, 1.0)),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: palette.blurSigma, sigmaY: palette.blurSigma),
          child: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: palette.glassHighlight, width: 1)),
            ),
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: content,
        ),
      );
    }

    return content;
  }
}

class GlassNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  const GlassNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GlassSurface(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        padding: EdgeInsets.zero,
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.primary.withValues(alpha: 0.18),
          destinations: destinations,
        ),
      ),
    );
  }
}
