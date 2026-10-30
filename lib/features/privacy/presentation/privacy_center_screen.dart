import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/security/lock_provider.dart';
import '../../../core/security/security_service.dart';
import '../../../core/storage/encrypted_storage.dart';
import '../../../core/widgets/intima_card.dart';
import '../../../shared/models/app_preferences.dart';
import '../../settings/providers/preferences_provider.dart';

class PrivacyCenterScreen extends ConsumerWidget {
  const PrivacyCenterScreen({super.key});

  Future<void> _handleBiometricToggle(
    BuildContext context,
    WidgetRef ref,
    bool enable,
  ) async {
    final notifier = ref.read(preferencesProvider.notifier);

    if (!enable) {
      await notifier.setBiometricEnabled(false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Déverrouillage biométrique désactivé.')),
        );
      }
      return;
    }

    final localAuth = LocalAuthentication();
    try {
      final isSupported = await localAuth.isDeviceSupported();
      if (!isSupported) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cet appareil ne supporte pas l\'authentification biométrique.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final canCheck = await localAuth.canCheckBiometrics;
      final available = await localAuth.getAvailableBiometrics();

      if (!canCheck || available.isEmpty) {
        if (context.mounted) {
          showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Aucune biométrie enregistrée'),
              content: const Text(
                'Veuillez d\'abord enregistrer une empreinte digitale ou une reconnaissance faciale dans les Paramètres de sécurité de votre téléphone Android.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Compris'),
                ),
              ],
            ),
          );
        }
        return;
      }

      final authenticated = await localAuth.authenticate(
        localizedReason: 'Confirmez votre identité pour activer la biométrie Intima',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        await notifier.setBiometricEnabled(true);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biométrie activée avec succès !'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentification annulée ou échouée.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur biométrique : ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteAllConfirmation(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.privacyDeleteAll),
        content: Text(l10n.privacyDeleteAllWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.privacyDeleteAllConfirm),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await EncryptedStorage.deleteAllData();
      await SecurityService.deleteAll();
      if (context.mounted) {
        context.go(AppRoutes.onboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(preferencesProvider).valueOrNull ?? const AppPreferences();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Verrouillage & PIN
          IntimaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Authentification',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.pin_rounded),
                  title: Text(l10n.privacyPinChange),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.pinChange),
                ),
                if (!ref.watch(isDuressModeProvider)) ...[
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.phonelink_lock_rounded, color: AppColors.accent),
                    title: const Text('Code PIN Leurre (Sous-contrainte)'),
                    subtitle: const Text('Faux profil vide si forcé(e) à déverrouiller'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.duressPin),
                  ),
                ],
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.fingerprint_rounded),
                  title: Text(l10n.privacyBiometric),
                  subtitle: Text(l10n.privacyBiometricEnable),
                  value: prefs.biometricEnabled,
                  onChanged: (val) => _handleBiometricToggle(context, ref, val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Discrétion & Sécurité visuelle
          IntimaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.privacyScreenProtection,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.visibility_off_outlined),
                  title: Text(l10n.privacyDiscreetMode),
                  subtitle: Text(l10n.privacyDiscreetModeDesc),
                  value: prefs.discreetMode,
                  onChanged: (val) {
                    ref.read(preferencesProvider.notifier).setDiscreetMode(val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Zone de danger (Suppression de toutes les données)
          IntimaCard(
            borderColor: AppColors.error.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.privacyDataManagement,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_forever, color: AppColors.error),
                  title: Text(
                    l10n.privacyDeleteAll,
                    style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _showDeleteAllConfirmation(context, l10n),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
