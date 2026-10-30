import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../errors/app_exceptions.dart';
import '../security/security_service.dart';

/// États possibles du verrou d'application.
enum AppLockState {
  /// Verrou non initialisé (démarrage).
  initializing,

  /// Application non configurée (premier démarrage).
  notConfigured,

  /// Application verrouillée, PIN requis.
  locked,

  /// Application déverrouillée.
  unlocked,

  /// Compte temporairement bloqué après trop d'erreurs.
  lockedOut,
}

/// État du verrou avec informations complémentaires.
@immutable
class LockStatus {
  const LockStatus({
    required this.state,
    this.attemptsRemaining = AppConstants.maxPinAttempts,
    this.lockoutUntil,
    this.errorMessage,
    this.isDuressMode = false,
  });

  final AppLockState state;
  final int attemptsRemaining;
  final DateTime? lockoutUntil;
  final String? errorMessage;

  /// Indique si l'application est déverrouillée sous code leurre (duress).
  final bool isDuressMode;

  bool get isUnlocked => state == AppLockState.unlocked;
  bool get isLocked => state == AppLockState.locked;
  bool get requiresSetup => state == AppLockState.notConfigured;

  LockStatus copyWith({
    AppLockState? state,
    int? attemptsRemaining,
    DateTime? lockoutUntil,
    String? errorMessage,
    bool? isDuressMode,
  }) {
    return LockStatus(
      state: state ?? this.state,
      attemptsRemaining: attemptsRemaining ?? this.attemptsRemaining,
      lockoutUntil: lockoutUntil ?? this.lockoutUntil,
      errorMessage: errorMessage,
      isDuressMode: isDuressMode ?? this.isDuressMode,
    );
  }
}

/// Provider global de l'état du verrou de l'application.
/// Gère le cycle de vie complet : initialisation, PIN, biométrie, verrouillage auto.
class LockNotifier extends Notifier<LockStatus> {
  @override
  LockStatus build() {
    return const LockStatus(state: AppLockState.initializing);
  }

  /// Initialise le verrou au démarrage de l'application.
  Future<void> initialize() async {
    final hasPIN = await SecurityService.hasPinConfigured();
    if (!hasPIN) {
      state = const LockStatus(state: AppLockState.notConfigured);
    } else {
      state = const LockStatus(state: AppLockState.locked);
    }
  }

  /// Tente de déverrouiller avec le PIN fourni.
  /// Met à jour l'état selon le résultat (normal ou leurre).
  Future<bool> unlockWithPin(String pin) async {
    try {
      final result = await SecurityService.verifyPinDetailed(pin);
      switch (result) {
        case PinVerificationResult.success:
          state = const LockStatus(state: AppLockState.unlocked, isDuressMode: false);
          return true;
        case PinVerificationResult.duress:
          // Déverrouillage furtif en mode leurre / sous contrainte
          state = const LockStatus(state: AppLockState.unlocked, isDuressMode: true);
          return true;
        case PinVerificationResult.incorrect:
          final remaining = state.attemptsRemaining - 1;
          state = state.copyWith(
            attemptsRemaining: remaining.clamp(0, AppConstants.maxPinAttempts),
            errorMessage: 'Code PIN incorrect.',
          );
          return false;
      }
    } on TooManyAttemptsException catch (e) {
      state = LockStatus(
        state: AppLockState.lockedOut,
        attemptsRemaining: 0,
        lockoutUntil: e.lockoutUntil,
        errorMessage: 'Trop de tentatives.',
      );
      return false;
    } on AppException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    }
  }

  /// Marque l'application comme déverrouillée après succès biométrique.
  void unlockWithBiometric() {
    state = const LockStatus(state: AppLockState.unlocked);
  }

  /// Verrouille manuellement l'application.
  void lock() {
    state = const LockStatus(state: AppLockState.locked);
  }

  /// Configure le PIN lors du premier démarrage puis déverrouille.
  Future<void> setupPin(String pin) async {
    await SecurityService.setPin(pin);
    state = const LockStatus(state: AppLockState.unlocked);
  }

  /// Change le PIN (requiert l'ancien PIN valide).
  Future<bool> changePin(String oldPin, String newPin) async {
    final ok = await unlockWithPin(oldPin);
    if (!ok) return false;
    await SecurityService.setPin(newPin);
    return true;
  }

  /// Réinitialise après expiration du verrouillage.
  void resetLockout() {
    state = const LockStatus(state: AppLockState.locked);
  }

  /// Complète le setup initial (PIN créé, premier démarrage terminé).
  void completeSetup() {
    state = const LockStatus(state: AppLockState.unlocked);
  }
}

final lockProvider = NotifierProvider<LockNotifier, LockStatus>(
  LockNotifier.new,
);

/// Indique si la session actuelle est en mode leurre (faux PIN entré sous contrainte).
final isDuressModeProvider = Provider<bool>((ref) {
  return ref.watch(lockProvider).isDuressMode;
});

