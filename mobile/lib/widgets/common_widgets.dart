import 'package:flutter/material.dart';
import '../config/app_palette.dart';
import '../config/app_styles.dart';
import '../config/constants.dart';
import 'glass_surface.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                  letterSpacing: -0.3,
                ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final List<BoxShadow>? shadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.margin,
    this.color,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    if (onTap == null) {
      return GlassSurface(
        margin: margin,
        padding: padding,
        color: color,
        child: child,
      );
    }

    return GlassSurface(
      margin: margin,
      padding: padding,
      onTap: onTap,
      color: color,
      child: child,
    );
  }
}

class CategoryBadge extends StatelessWidget {
  final String category;
  final double size;

  const CategoryBadge({super.key, required this.category, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.22),
            AppColors.accent.withValues(alpha: 0.16),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: palette.glassBorder),
      ),
      child: Center(
        child: Text(categoryEmoji[category] ?? '📦', style: TextStyle(fontSize: size * 0.46)),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final Color? color;

  const UserAvatar({super.key, required this.name, this.radius = 22, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return CircleAvatar(
      radius: radius,
      backgroundColor: c.withValues(alpha: 0.12),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: c,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    Color bg;
    Color fg;
    switch (status) {
      case 'CONFIRMED':
        bg = palette.successSoft;
        fg = AppColors.success;
        break;
      case 'CLAIMED':
        bg = AppColors.warningSoft.withValues(alpha: palette.useGlass && Theme.of(context).brightness == Brightness.dark ? 0.45 : 0.55);
        fg = AppColors.warning;
        break;
      case 'REJECTED':
        bg = palette.dangerSoft;
        fg = AppColors.error;
        break;
      default:
        bg = palette.tabPillBackground;
        fg = palette.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.glassBorder),
      ),
      child: Text(
        '${statusEmoji[status] ?? '❓'} ${statusLabel[status] ?? status}',
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyState({super.key, required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(color: palette.glassBorder),
              ),
              child: Icon(icon, size: 40, color: AppColors.primary.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.textSecondary, height: 1.4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AmountLabel extends StatelessWidget {
  final double amount;
  final String? suffix;
  final bool highlight;

  const AmountLabel({super.key, required this.amount, this.suffix, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          amount.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: highlight ? AppColors.primary : palette.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        Text(
          suffix ?? 'PLN',
          style: TextStyle(fontSize: 11, color: palette.textMuted),
        ),
      ],
    );
  }
}

class PillTabBar extends StatelessWidget {
  final TabController? controller;
  final List<String> tabs;

  const PillTabBar({super.key, this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: palette.tabPillBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: palette.glassBorder),
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: palette.tabPillSelected,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.soft,
          border: Border.all(color: palette.glassBorder),
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: palette.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        tabs: tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}