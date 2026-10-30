# Architecture logicielle d'INTIMA

## 1. Principes fondamentaux

L'application **INTIMA** adopte une architecture modulaire, feature-first, s'inspirant des principes de Clean Architecture pragmatique adaptée à Flutter :

- **Séparation stricte des responsabilités** (UI, Domain, Data, Providers).
- **Zéro dépendance réseau** : fonctionnement 100% hors-ligne.
- **Zéro télémétrie** : aucune fuite de données vers des services tiers.
- **Sécurité au repos** : chiffrement authentifié AES-256-GCM.
- **Gestion d'état réactive** : Flutter Riverpod.
- **Navigation déclarative** : GoRouter avec protection par état de verrouillage.

## 2. Arborescence du code

```text
lib/
├── main.dart                      # Bootstrap & initialisation sécurisée
├── app/
│   ├── app.dart                   # MaterialApp.router, thème & localisation
│   ├── router.dart                # Routes déclaratives GoRouter + redirection sécurisée
│   ├── shell_scaffold.dart        # Barre de navigation à 5 destinations
│   ├── theme/                     # Tokens de couleurs, thème clair & sombre
│   └── localization/             # AppLocalizations générées (FR/EN)
├── core/
│   ├── constants/                 # Constantes globales de l'application
│   ├── errors/                    # Hiérarchie des exceptions typées
│   ├── security/                  # AES-256-GCM, PBKDF2, Keystore/Keychain, LockState
│   ├── storage/                   # Persistance par fichiers JSON chiffrés atomiques
│   ├── notifications/             # Service de notifications locales programmées
│   ├── utils/                     # Formatage de dates et calculs temporels
│   └── widgets/                   # Composants réutilisables (IntimaCard, etc.)
├── features/
│   ├── onboarding/                # Premier démarrage en 5 étapes
│   ├── dashboard/                 # Tableau de bord principal & actions rapides
│   ├── partners/                  # Gestion complète des partenaires
│   ├── encounters/                # Journal intime chronologique
│   ├── menstrual_cycle/           # Calendrier, cycle & moteur de calculs
│   ├── reminders/                 # Centre de rappels locaux
│   ├── statistics/                # Statistiques relationnelles & menstruelles
│   ├── privacy/                   # PIN, biométrie, effacement de données
│   ├── settings/                  # Préférences, langue, thème
│   └── backup/                    # Export & import de sauvegardes chiffrées
└── shared/
    └── models/                    # Modèles métier immuables avec sérialisation JSON
```

## 3. Flux de données et gestion d'état

1. **Persistance** : Fichiers JSON chiffrés sur le disque (`EncryptedStorage`).
2. **Repositories** : Abstraction de lecture/écriture pour chaque entité métier.
3. **AsyncNotifiers Riverpod** : Notifient l'UI en cas de mutation et garantissent la réactivité.
4. **UI** : Widgets stateless ou consumers lisant les providers Riverpod.

