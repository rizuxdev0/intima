import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import 'illustrations/intima_illustrations.dart';

/// Carte premium unifiée pour INTIMA.
class IntimaCard extends StatelessWidget {
  const IntimaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveColor = color ??
        (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);

    final effectiveBorder = borderColor ??
        (isDark ? const Color(0xFF3A3748) : const Color(0xFFEDEAE4));

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: effectiveBorder, width: 1),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: content,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: content,
    );
  }
}

/// Widget d'état vide élégant, informatif et animé avec illustrations vectorielles.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.illustrationType,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IntimaIllustrationType? illustrationType;

  IntimaIllustrationType _resolveIllustrationType() {
    if (illustrationType != null) return illustrationType!;
    if (icon == Icons.water_drop_outlined || icon == Icons.water_drop_rounded) {
      return IntimaIllustrationType.cycle;
    }
    if (icon == Icons.people_outline_rounded || icon == Icons.person_outline_rounded) {
      return IntimaIllustrationType.partners;
    }
    if (icon == Icons.menu_book_rounded || icon == Icons.edit_note_rounded) {
      return IntimaIllustrationType.journal;
    }
    if (icon == Icons.health_and_safety_rounded || icon == Icons.security_rounded) {
      return IntimaIllustrationType.shield;
    }
    if (icon == Icons.favorite_outline_rounded || icon == Icons.favorite_rounded) {
      return IntimaIllustrationType.heart;
    }
    return IntimaIllustrationType.emptyBox;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedType = _resolveIllustrationType();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration vectorielle animée
            IntimaAnimatedIllustration(
              type: resolvedType,
              size: 150,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: -0.2,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    height: 1.45,
                  ),
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(
                  actionLabel!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Badge de discrétion pour les données sensibles.
class DiscreetText extends StatelessWidget {
  const DiscreetText({
    super.key,
    required this.realText,
    required this.discreetText,
    required this.isDiscreet,
    this.style,
  });

  final String realText;
  final String discreetText;
  final bool isDiscreet;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      isDiscreet ? discreetText : realText,
      style: style,
    );
  }
}

