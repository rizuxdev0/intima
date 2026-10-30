import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/security/lock_provider.dart';

class PinChangeScreen extends ConsumerStatefulWidget {
  const PinChangeScreen({super.key});

  @override
  ConsumerState<PinChangeScreen> createState() => _PinChangeScreenState();
}

class _PinChangeScreenState extends ConsumerState<PinChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _changePin() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final oldPin = _oldPinController.text.trim();
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (newPin != confirmPin) {
      setState(() => _errorMessage = l10n.pinMismatch);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await ref
          .read(lockProvider.notifier)
          .changePin(oldPin, newPin);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.toastChangesSaved)),
          );
          context.pop();
        }
      } else {
        if (mounted) {
          setState(() => _errorMessage = l10n.toastIncorrectPin);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = l10n.toastError);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyPinChange),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _oldPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: AppConstants.pinLength,
              decoration: const InputDecoration(
                labelText: 'Ancien code PIN',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (v) => v == null || v.length != AppConstants.pinLength
                  ? l10n.pinTooShort
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: AppConstants.pinLength,
              decoration: InputDecoration(
                labelText: l10n.pinCreateTitle,
                prefixIcon: const Icon(Icons.pin_rounded),
              ),
              validator: (v) => v == null || v.length != AppConstants.pinLength
                  ? l10n.pinTooShort
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: AppConstants.pinLength,
              decoration: InputDecoration(
                labelText: l10n.pinConfirmTitle,
                prefixIcon: const Icon(Icons.check_circle_outline),
              ),
              validator: (v) => v == null || v.length != AppConstants.pinLength
                  ? l10n.pinTooShort
                  : null,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _changePin,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.commonSave),
            ),
          ],
        ),
      ),
    );
  }
}

