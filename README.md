# INTIMA — Private Intimate Life & Wellness Tracker

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-Proprietary-purple.svg)]()
[![Offline First](https://img.shields.io/badge/Network-0%20bytes%20(100%25%20Offline)-brightgreen.svg)]()
[![Security](https://img.shields.io/badge/Encryption-AES--256--GCM-red.svg)]()

**INTIMA** est une application mobile intime, discrète, moderne et hautement sécurisée pour Android et iOS, destinée au suivi de la vie intime, des partenaires, des cycles menstruels, des symptômes et des rappels personnels.

---

## 🔒 Principes d'ingénierie et de confidentialité

1. **Zéro compte, zéro backend, zéro réseau** : Aucune donnée intime ne transite sur Internet. L'application fonctionne à 100% hors-ligne.
2. **Chiffrement authentifié au repos** : Tous les fichiers personnels sont chiffrés en **AES-256-GCM** avec un nonce aléatoire unique de 12 octets à chaque écriture.
3. **Protection matérielle des clés** : Clé principale protégée dans l'Android Keystore (EncryptedSharedPreferences) et le Keychain iOS.
4. **Hachage du PIN** : Code PIN dérivé avec **PBKDF2-HMAC-SHA256** (100 000 itérations), sel aléatoire, comparaison en temps constant et verrouillage progressif.
5. **Authentification biométrique native** : Déverrouillage par empreinte digitale ou reconnaissance faciale (Touch ID / Face ID) avec repli sécurisé sur le PIN.
6. **Bilingue natif** : Interface intégralement disponible en français et en anglais avec changement dynamique immédiat.

---

## 📱 Fonctionnalités clés

- **Tableau de bord intelligent** : Résumé du mois, cartes configurables, raccourcis d'action rapide et bouton discret en un clic.
- **Gestion des partenaires** : Fiches personnalisées, pseudonymes, couleurs d'avatar, historique complet et suppression avec option d'anonymisation.
- **Journal intime chronologique** : Suivi des rencontres et moments personnels, protection utilisée, humeur avant/après, durée et étiquettes.
- **Suivi menstruel et fertilité** : Calendrier mensuel interactif avec distinction claire entre données observées et prédictions calculées.
- **Moteur de calcul scientifique** : Durées moyennes, variabilité (écart-type), estimation des règles, ovulation et fenêtre fertile, avec avertissements d'incertitude.
- **Centre d'éducation médicale** : Fiches pédagogiques sur les phases du cycle, la fertilité, la contraception, les IST et les critères de consultation.
- **Centre de rappels locaux** : Notifications sans réseau avec 3 niveaux de discrétion (discret, personnalisé, détaillé).
- **Sauvegarde chiffrée & Restauration** : Export et réimport sécurisés sans fuite de données.

---

## 🛠️ Stack technique

- **Framework** : Flutter / Dart
- **State Management** : Flutter Riverpod 2.6.x (AsyncNotifiers, Providers déclaratifs)
- **Navigation** : GoRouter 14.x avec redirection protégée par `AppLockState`
- **Chiffrement** : PointyCastle (AES-256-GCM, PBKDF2)
- **Stockage sécurisé** : `flutter_secure_storage`
- **Notifications locales** : `flutter_local_notifications` + `timezone`
- **Authentification biométrique** : `local_auth`
- **Internationalisation** : `flutter_localizations` + `intl` (`.arb` générés)

---

## 🚀 Installation et Démarrage

### 1. Installer les dépendances
```bash
flutter pub get
```

### 2. Générer les traductions
```bash
flutter gen-l10n
```

### 3. Lancer les tests automatisés
```bash
flutter test
```

### 4. Lancer l'analyse statique
```bash
flutter analyze
```

### 5. Exécuter l'application
```bash
flutter run
```

---

## 📚 Documentation détaillée

- [Architecture logicielle](docs/ARCHITECTURE.md)
- [Design System & Thèmes](docs/DESIGN_SYSTEM.md)
- [Sécurité & Chiffrement](docs/SECURITY.md)
- [Stockage local & Fichiers](docs/DATA_STORAGE.md)
- [Moteur de calcul des cycles](docs/CYCLE_CALCULATIONS.md)
- [Notifications locales](docs/NOTIFICATIONS.md)
- [Internationalisation](docs/INTERNATIONALIZATION.md)
- [Stratégie de tests](docs/TESTING.md)
- [Compilation Android](docs/ANDROID_BUILD.md)
- [Compilation iOS](docs/IOS_BUILD.md)
- [Guide Utilisateur](docs/USER_GUIDE.md)
