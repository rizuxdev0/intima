# Guide de Compilation Android

## 1. Prérequis

- Flutter SDK (>= 3.24.0)
- Android SDK avec build-tools récents
- Java Development Kit (JDK 17 recommandé)

## 2. Configuration des permissions et du moteur natif

INTIMA n'utilise **aucune permission réseau**.
Les seules permissions déclarées dans `android/app/src/main/AndroidManifest.xml` concernent :
- `POST_NOTIFICATIONS` : Programmation des rappels locaux.
- `USE_BIOMETRIC` : Déverrouillage par empreinte digitale.

### Core Library Desugaring :
Le plugin `flutter_local_notifications` utilise les API `java.time`. Pour assurer la rétrocompatibilité avec les versions antérieures à Android 8 (API 26), le dé-sucrage (`coreLibraryDesugaring`) est activé dans `android/app/build.gradle.kts` via `desugar_jdk_libs:2.1.4`.

## 3. Production des binaires

### Compilation d'un APK de test :
```bash
flutter build apk --release
```
Le fichier est généré dans `build/app/outputs/flutter-apk/app-release.apk`.

### Compilation d'un Android App Bundle (AAB) pour le Play Store :
```bash
flutter build appbundle --release
```
Le fichier est généré dans `build/app/outputs/bundle/release/app-release.aab`.

