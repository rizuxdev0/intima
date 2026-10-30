import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/security/security_service.dart';
import '../../../core/widgets/intima_card.dart';

/// Écran de configuration du Code PIN Leurre (Mode Sous-Contrainte).
class DuressPinScreen extends ConsumerStatefulWidget {
  const DuressPinScreen({super.key});

  @override
  ConsumerState<DuressPinScreen> createState() => _DuressPinScreenState();
}

class _DuressPinScreenState extends ConsumerState<DuressPinScreen> {
  final _primaryPinController = TextEditingController();
  final _duressPinController = TextEditingController();
  final _confirmDuressPinController = TextEditingController();

  bool _isConfigured = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  @override
  void dispose() {
    _primaryPinController.dispose();
    _duressPinController.dispose();
    _confirmDuressPinController.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    final configured = await SecurityService.hasDuressPinConfigured();
    if (mounted) {
      setState(() => _isConfigured = configured);
    }
  }

  Future<void> _saveDuressPin() async {
    final primaryPin = _primaryPinController.text.trim();
    final duressPin = _duressPinController.text.trim();
    final confirmPin = _confirmDuressPinController.text.trim();

    if (primaryPin.length != AppConstants.pinLength) {
      setState(() => _errorMessage = 'Veuillez saisir votre PIN actuel valide (6 chiffres).');
      return;
    }

    if (duressPin.length != AppConstants.pinLength) {
      setState(() => _errorMessage = 'Le code leurre doit comporter exactement 6 chiffres.');
      return;
    }

    if (duressPin != confirmPin) {
      setState(() => _errorMessage = 'Les deux codes leurre ne correspondent pas.');
      return;
    }

    if (duressPin == primaryPin) {
      setState(() => _errorMessage = 'Le code leurre doit être DIFFÉRENT de votre code PIN réel.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Vérifier que l'utilisateur connaît son vrai code PIN
      final isPrimaryValid = await SecurityService.verifyPin(primaryPin);
      if (!isPrimaryValid) {
        setState(() {
          _errorMessage = 'Code PIN principal incorrect.';
          _isLoading = false;
        });
        return;
      }

      // 2. Enregistrer le PIN leurre
      await SecurityService.setDuressPin(duressPin);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code PIN leurre activé avec succès.'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {
          _isConfigured = true;
          _isLoading = false;
          _primaryPinController.clear();
          _duressPinController.clear();
          _confirmDuressPinController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteDuressPin() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Désactiver le code leurre ?'),
        content: const Text(
          'En désactivant cette protection, seule la saisie de votre PIN principal déverrouillera l\'application.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Désactiver'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await SecurityService.deleteDuressPin();
      setState(() => _isConfigured = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code PIN leurre supprimé.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Code PIN Leurre', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Carte Explicative Mode Sous-Contrainte
          IntimaCard(
            color: AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.08),
            borderColor: AppColors.primary.withValues(alpha: 0.3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.security_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Protection sous contrainte',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Si quelqu\'un vous force à ouvrir l\'application, tapez ce code PIN secondaire sur l\'écran de verrouillage.\n\n'
                        'L\'application s\'ouvrira normalement, mais vos vraies données (rencontres, cycles, partenaires, écrits intimes) resteront strictement masquées et protégées.',
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Statut actuel
          IntimaCard(
            child: Row(
              children: [
                Icon(
                  _isConfigured ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  color: _isConfigured ? AppColors.success : Colors.grey,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isConfigured
                        ? 'Protection leurre active'
                        : 'Aucun code leurre configuré',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (_isConfigured)
                  TextButton(
                    onPressed: _deleteDuressPin,
                    child: const Text('Désactiver', style: TextStyle(color: AppColors.error)),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            _isConfigured ? 'Modifier le code leurre' : 'Définir votre code leurre',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Champ PIN principal
          TextField(
            controller: _primaryPinController,
            keyboardType: TextInputType.number,
            maxLength: AppConstants.pinLength,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Votre code PIN réel actuel (6 chiffres)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              prefixIcon: const Icon(Icons.lock_outline_rounded),
            ),
          ),

          const SizedBox(height: 12),

          // Champ Nouveau PIN Leurre
          TextField(
            controller: _duressPinController,
            keyboardType: TextInputType.number,
            maxLength: AppConstants.pinLength,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Nouveau code leurre (6 chiffres)',
              hintText: 'Ex: 000000',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              prefixIcon: const Icon(Icons.phonelink_lock_rounded, color: AppColors.accent),
            ),
          ),

          const SizedBox(height: 12),

          // Confirmation PIN Leurre
          TextField(
            controller: _confirmDuressPinController,
            keyboardType: TextInputType.number,
            maxLength: AppConstants.pinLength,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirmer le code leurre (6 chiffres)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              prefixIcon: const Icon(Icons.check_circle_outline_rounded),
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: _isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_rounded),
              label: Text(
                _isConfigured ? 'Mettre à jour le code leurre' : 'Activer le code leurre',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: _isLoading ? null : _saveDuressPin,
            ),
          ),
        ],
      ),
    );
  }
}
