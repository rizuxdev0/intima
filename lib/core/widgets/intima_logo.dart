import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// Logo emblématique d'INTIMA avec aura radiale pulsante et dégradé Signature.
///
/// Utilisé de manière cohérente à travers toute l'application :
/// - Écran d'accueil Splash
/// - Écran de verrouillage / Déverrouillage biométrique
/// - Écran de configuration du PIN
/// - En-têtes d'authentification
class IntimaBrandLogo extends StatefulWidget {
  const IntimaBrandLogo({
    super.key,
    this.size = 84.0,
    this.showAura = true,
    this.isPulsating = true,
    this.icon = Icons.favorite_rounded,
    this.badgeIcon,
    this.onTap,
    this.tooltip,
  });

  /// Diamètre de la sphère centrale de l'emblème.
  final double size;

  /// Active l'aura radiale externe nébuleuse.
  final bool showAura;

  /// Active l'effet de respiration / pulsation douce.
  final bool isPulsating;

  /// Icône affichée au centre de l'emblème (par défaut le cœur Intima).
  final IconData icon;

  /// Icône secondaire optionnelle en badge (ex: empreinte biométrique ou cadenas).
  final IconData? badgeIcon;

  /// Action déclenchée au toucher (ex: déclencher l'empreinte biométrique).
  final VoidCallback? onTap;

  /// Infobulle affichée au survol ou appui long.
  final String? tooltip;

  @override
  State<IntimaBrandLogo> createState() => _IntimaBrandLogoState();
}

class _IntimaBrandLogoState extends State<IntimaBrandLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _auraAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.04).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOutSine,
      ),
    );

    _auraAnimation = Tween<double>(begin: 0.88, end: 1.28).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOutSine,
      ),
    );

    if (widget.isPulsating) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant IntimaBrandLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsating != oldWidget.isPulsating) {
      if (widget.isPulsating) {
        _animController.repeat(reverse: true);
      } else {
        _animController.stop();
        _animController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auraSize = widget.size * 1.85;

    Widget logoContent = AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final scale = widget.isPulsating ? _scaleAnimation.value : 1.0;
        final auraScale = widget.isPulsating ? _auraAnimation.value : 1.0;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Aura radiale pulsante
            if (widget.showAura)
              Transform.scale(
                scale: auraScale,
                child: Container(
                  width: auraSize,
                  height: auraSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: isDark ? 0.38 : 0.24),
                        AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.08),
                        AppColors.primary.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),

            // Sphère centrale emblématique avec dégradé chaud grenat-rose
            Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.accent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.38),
                      blurRadius: widget.size * 0.3,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: widget.size * 0.48,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Badge secondaire optionnel (ex: empreinte ou cadenas)
            if (widget.badgeIcon != null)
              Positioned(
                right: (auraSize - widget.size) / 2 - 4,
                bottom: (auraSize - widget.size) / 2 - 4,
                child: Container(
                  padding: EdgeInsets.all(widget.size * 0.08),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.badgeIcon,
                    size: widget.size * 0.26,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        );
      },
    );

    if (widget.onTap != null) {
      logoContent = Tooltip(
        message: widget.tooltip ?? 'Déverrouiller avec la biométrie',
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: logoContent,
        ),
      );
    }

    return SizedBox(
      width: auraSize,
      height: auraSize,
      child: Center(child: logoContent),
    );
  }
}

