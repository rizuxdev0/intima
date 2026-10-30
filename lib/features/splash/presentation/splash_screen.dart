import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/security/lock_provider.dart';

/// Écran Splash animé (Écran 1 du Cahier des Charges).
/// Offre une expérience d'entrée élégante, chaleureuse et fluide avec animations
/// de pulsation d'aura, fondu progressif et redirection vers le flux approprié.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _auraAnimation;
  Timer? _navigationTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
      ),
    );

    _auraAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOutSine),
      ),
    );

    _animController.repeat(reverse: true);

    // Après l'animation d'accueil (2 secondes), redirection selon l'état de sécurité
    _navigationTimer = Timer(const Duration(milliseconds: 2000), _proceedToNextScreen);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _proceedToNextScreen() {
    if (!mounted || _hasNavigated) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasNavigated) return;
      final lock = ref.read(lockProvider);

      switch (lock.state) {
        case AppLockState.notConfigured:
          _hasNavigated = true;
          context.go(AppRoutes.onboarding);
          break;
        case AppLockState.locked:
        case AppLockState.lockedOut:
          _hasNavigated = true;
          context.go(AppRoutes.lock);
          break;
        case AppLockState.unlocked:
          _hasNavigated = true;
          context.go(AppRoutes.home);
          break;
        case AppLockState.initializing:
          // Si l'initialisation prend un peu plus de temps, attendre 300ms de plus
          Future.delayed(const Duration(milliseconds: 300), _proceedToNextScreen);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF140E10) : const Color(0xFFFBF7F8),
      body: Center(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo avec halo lumineux / aura respirante
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Halo de fond pulsant
                    Transform.scale(
                      scale: _auraAnimation.value,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.22),
                              AppColors.accent.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Sphère icône centrale
                    Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 96,
                        height: 96,
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
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Typographie INTIMA
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        l10n.appName.toUpperCase(),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 6,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.splashTagline,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Petit indicateur discret de chargement
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

