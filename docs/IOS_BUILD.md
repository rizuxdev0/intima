# Guide de Compilation iOS

## 1. Prérequis

- Machine macOS avec Xcode installé (Xcode >= 15)
- CocoaPods (`sudo gem install cocoapods`)
- Profil de provisionnement et certificat de signature Apple Developer

## 2. Configuration Info.plist

Les clés suivantes sont configurées dans `ios/Runner/Info.plist` :
- `NSFaceIDUsageDescription` : Autorise le déverrouillage sécurisé par Face ID / Touch ID.

## 3. Production du binaire

1. Installer les pods :
```bash
cd ios && pod install && cd ..
```
2. Compiler l'archive :
```bash
flutter build ipa --release
```
3. Ouvrir `Runner.xcworkspace` dans Xcode pour la signature et le téléversement sur TestFlight / App Store.

