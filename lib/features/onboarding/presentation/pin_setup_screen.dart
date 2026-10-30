import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/security/lock_provider.dart';
import '../../../core/widgets/intima_logo.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  String _firstPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String? _errorMessage;

  void _onDigitPressed(String digit) {
    setState(() {
      _errorMessage = null;
      if (!_isConfirming) {
        if (_firstPin.length < AppConstants.pinLength) {
          _firstPin += digit;
          if (_firstPin.length == AppConstants.pinLength) {
            _isConfirming = true;
          }
        }
      } else {
        if (_confirmPin.length < AppConstants.pinLength) {
          _confirmPin += digit;
          if (_confirmPin.length == AppConstants.pinLength) {
            _validatePins();
          }
        }
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      _errorMessage = null;
      if (!_isConfirming) {
        if (_firstPin.isNotEmpty) {
          _firstPin = _firstPin.substring(0, _firstPin.length - 1);
        }
      } else {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          _isConfirming = false;
        }
      }
    });
  }

  Future<void> _validatePins() async {
    final l10n = AppLocalizations.of(context);
    if (_firstPin == _confirmPin) {
      await ref.read(lockProvider.notifier).setupPin(_firstPin);
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go(AppRoutes.home);
          }
        });
      }
    } else {
      setState(() {
        _errorMessage = l10n.pinMismatch;
        _confirmPin = '';
        _firstPin = '';
        _isConfirming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final currentPin = _isConfirming ? _confirmPin : _firstPin;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 1),
              IntimaBrandLogo(
                size: 72,
                showAura: true,
                isPulsating: false,
                icon: _isConfirming ? Icons.check_rounded : Icons.lock_rounded,
                badgeIcon: Icons.shield_rounded,
              ),
              const SizedBox(height: 24),
              Text(
                _isConfirming ? l10n.pinConfirmTitle : l10n.pinCreateTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isConfirming
                    ? l10n.pinConfirmSubtitle
                    : l10n.pinCreateSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),

              // PIN Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(AppConstants.pinLength, (index) {
                  final isFilled = index < currentPin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? AppColors.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.15),
                      border: Border.all(
                        color: isFilled
                            ? AppColors.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const Spacer(flex: 1),

              // Clavier numérique
              _PinKeypad(
                onDigitPressed: _onDigitPressed,
                onDeletePressed: _onDeletePressed,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinKeypad extends StatelessWidget {
  const _PinKeypad({
    required this.onDigitPressed,
    required this.onDeletePressed,
  });

  final ValueChanged<String> onDigitPressed;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _KeypadButton(text: '1', onPressed: () => onDigitPressed('1')),
            _KeypadButton(text: '2', onPressed: () => onDigitPressed('2')),
            _KeypadButton(text: '3', onPressed: () => onDigitPressed('3')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _KeypadButton(text: '4', onPressed: () => onDigitPressed('4')),
            _KeypadButton(text: '5', onPressed: () => onDigitPressed('5')),
            _KeypadButton(text: '6', onPressed: () => onDigitPressed('6')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _KeypadButton(text: '7', onPressed: () => onDigitPressed('7')),
            _KeypadButton(text: '8', onPressed: () => onDigitPressed('8')),
            _KeypadButton(text: '9', onPressed: () => onDigitPressed('9')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 72, height: 72),
            _KeypadButton(text: '0', onPressed: () => onDigitPressed('0')),
            SizedBox(
              width: 72,
              height: 72,
              child: IconButton(
                onPressed: onDeletePressed,
                icon: const Icon(Icons.backspace_outlined),
                iconSize: 26,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.text,
    required this.onPressed,
  });

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
        elevation: 0,
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

