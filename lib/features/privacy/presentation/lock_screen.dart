import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/security/lock_provider.dart';
import '../../../core/widgets/intima_logo.dart';
import '../../settings/providers/preferences_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> with WidgetsBindingObserver {
  final LocalAuthentication _localAuth = LocalAuthentication();
  String _enteredPin = '';
  String? _errorMessage;
  Timer? _lockoutTimer;
  int _secondsRemaining = 0;
  bool _biometricAttempted = false;
  bool _showingBiometric = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Délai pour laisser le provider se charger complètement avant de lire les prefs.
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometricIfEnabled());
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-déclencher la biométrie si l'app revient au premier plan depuis une pause.
    if (state == AppLifecycleState.resumed && !_biometricAttempted) {
      _tryBiometricIfEnabled();
    }
  }

  /// Tente la biométrie si elle est activée dans les préférences et disponible sur l'appareil.
  Future<void> _tryBiometricIfEnabled() async {
    if (_biometricAttempted || _showingBiometric) return;

    // Attendre que le provider soit chargé avant de lire la valeur.
    final prefs = ref.read(preferencesProvider).valueOrNull;
    if (prefs == null) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (mounted) _tryBiometricIfEnabled();
      return;
    }

    if (prefs.biometricEnabled != true) return;

    await _authenticateBiometric(isManual: false);
  }

  Future<void> _authenticateBiometric({bool isManual = false}) async {
    if (_showingBiometric) return;

    try {
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) {
        if (isManual && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cet appareil ne supporte pas l\'authentification biométrique.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final canCheck = await _localAuth.canCheckBiometrics;
      final available = await _localAuth.getAvailableBiometrics();
      if (!canCheck || available.isEmpty) {
        if (isManual && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucune empreinte enregistrée dans les paramètres Android.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      setState(() => _showingBiometric = true);
      _biometricAttempted = true;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Déverrouillez Intima avec votre biométrie',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated && mounted) {
        ref.read(lockProvider.notifier).unlockWithBiometric();
      }
    } on Exception catch (e) {
      if (isManual && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de la biométrie : ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _showingBiometric = false);
    }
  }

  void _onDigitPressed(String digit) {
    if (_secondsRemaining > 0) return;

    setState(() {
      _errorMessage = null;
      if (_enteredPin.length < AppConstants.pinLength) {
        _enteredPin += digit;
        if (_enteredPin.length == AppConstants.pinLength) {
          _verifyPin();
        }
      }
    });
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty && _secondsRemaining == 0) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  Future<void> _verifyPin() async {
    final success = await ref.read(lockProvider.notifier).unlockWithPin(_enteredPin);

    if (!success && mounted) {
      final lockStatus = ref.read(lockProvider);
      if (lockStatus.state == AppLockState.lockedOut && lockStatus.lockoutUntil != null) {
        final remaining =
            lockStatus.lockoutUntil!.difference(DateTime.now()).inSeconds;
        _startLockoutCountdown(remaining.clamp(1, AppConstants.lockoutDurationSeconds));
      } else {
        setState(() {
          _errorMessage = lockStatus.errorMessage ?? 'Code incorrect';
          _enteredPin = '';
        });
      }
    }
  }

  void _startLockoutCountdown(int seconds) {
    setState(() {
      _secondsRemaining = seconds;
      _enteredPin = '';
      _errorMessage = 'Trop d\'essais. Réessayez dans $_secondsRemaining s.';
    });

    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
          _errorMessage = 'Trop d\'essais. Réessayez dans $_secondsRemaining s.';
        });
      } else {
        timer.cancel();
        ref.read(lockProvider.notifier).resetLockout();
        setState(() {
          _secondsRemaining = 0;
          _errorMessage = null;
          // Réinitialiser pour autoriser un nouvel essai biométrique après le lockout.
          _biometricAttempted = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final prefsAsync = ref.watch(preferencesProvider);
    final prefs = prefsAsync.valueOrNull;
    final biometricEnabled = prefs?.biometricEnabled == true;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 1),
              // Emblème Signature INTIMA avec aura pulsante et déclencheur biométrique
              IntimaBrandLogo(
                size: 78,
                showAura: true,
                isPulsating: true,
                icon: biometricEnabled ? Icons.fingerprint_rounded : Icons.favorite_rounded,
                badgeIcon: biometricEnabled ? Icons.favorite_rounded : Icons.lock_rounded,
                onTap: biometricEnabled ? () => _authenticateBiometric(isManual: true) : null,
                tooltip: biometricEnabled
                    ? 'Toucher pour vous identifier par empreinte'
                    : 'Application protégée',
              ),
              const SizedBox(height: 28),
              Text(
                l10n.pinEnterTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                biometricEnabled
                    ? l10n.pinBiometricPrompt
                    : l10n.pinEnterSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 36),

              // Indicateurs PIN avec animation
              _PinDots(
                pinLength: AppConstants.pinLength,
                filledCount: _enteredPin.length,
                hasError: _errorMessage != null,
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              const Spacer(flex: 1),

              // Indicateur de chargement biométrique
              if (_showingBiometric)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vérification biométrique…',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

              // Clavier
              _LockKeypad(
                onDigitPressed: _onDigitPressed,
                onDeletePressed: _onDeletePressed,
                onBiometricPressed: biometricEnabled && !_showingBiometric
                    ? () => _authenticateBiometric(isManual: true)
                    : null,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Indicateurs de saisie PIN avec animation de remplissage.
class _PinDots extends StatelessWidget {
  const _PinDots({
    required this.pinLength,
    required this.filledCount,
    this.hasError = false,
  });

  final int pinLength;
  final int filledCount;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pinLength, (index) {
        final isFilled = index < filledCount;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: isFilled ? 18 : 16,
          height: isFilled ? 18 : 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasError
                ? AppColors.error
                : isFilled
                    ? AppColors.primary
                    : Colors.transparent,
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : isFilled
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}

class _LockKeypad extends StatelessWidget {
  const _LockKeypad({
    required this.onDigitPressed,
    required this.onDeletePressed,
    this.onBiometricPressed,
  });

  final ValueChanged<String> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback? onBiometricPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['1', '2', '3']
              .map((d) => _KeypadNum(text: d, onPressed: () => onDigitPressed(d)))
              .toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['4', '5', '6']
              .map((d) => _KeypadNum(text: d, onPressed: () => onDigitPressed(d)))
              .toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7', '8', '9']
              .map((d) => _KeypadNum(text: d, onPressed: () => onDigitPressed(d)))
              .toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: onBiometricPressed != null
                  ? _KeypadAction(
                      icon: Icons.fingerprint_rounded,
                      onPressed: onBiometricPressed!,
                      color: AppColors.primary,
                    )
                  : const SizedBox.shrink(),
            ),
            _KeypadNum(text: '0', onPressed: () => onDigitPressed('0')),
            _KeypadAction(
              icon: Icons.backspace_outlined,
              onPressed: onDeletePressed,
            ),
          ],
        ),
      ],
    );
  }
}

class _KeypadAction extends StatelessWidget {
  const _KeypadAction({
    required this.icon,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        iconSize: 30,
        color: color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }
}

class _KeypadNum extends StatelessWidget {
  const _KeypadNum({required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: theme.colorScheme.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
