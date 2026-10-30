# Stratégie de Tests et Qualité

## 1. Vue d'ensemble

Le projet INTIMA inclut une suite de tests automatisés couvrant les couches critiques :
- **Sécurité et chiffrement** : Validation du chiffrement authentifié AES-256-GCM, détection des altérations de données et gestion des clés.
- **Règles métier & Calculs de cycles** : Validation des durées de cycles, des moyennes, de la variabilité, de la fenêtre de fertilité, des dates limites et des cas de cycles irréguliers.
- **Tests de widgets & Rendu UI** : Validation du montage de l'arbre de widgets, du routage et de la compatibilité des thèmes.

## 2. Exécution des tests

Pour lancer l'ensemble des tests automatisés :
```bash
flutter test
```

Pour exécuter un test spécifique :
```bash
flutter test test/core/security/aes_gcm_cipher_test.dart
flutter test test/features/menstrual_cycle/cycle_calculation_engine_test.dart
flutter test test/widget_test.dart
```

## 3. Analyse statique

Pour vérifier la conformité du code avec les règles de linting officielles de Flutter :
```bash
flutter analyze
```

