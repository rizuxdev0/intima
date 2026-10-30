# Notifications Locales et Rappels

## 1. Philosophie et Fonctionnement

Toutes les notifications d'INTIMA sont gérées de manière **100% locale** via le plugin `flutter_local_notifications` et le package `timezone`.
- Aucun serveur distant, aucun token push FCM ou APNs n'est utilisé.
- Les rappels continuent de fonctionner sans aucune connexion Internet.

## 2. Niveaux de discrétion

Chaque rappel peut être configuré selon 3 niveaux de discrétion :
1. **Discret (par défaut)** : Affiche uniquement le nom de l'application et la mention neutre *« Tu as un rappel personnel. »*.
2. **Personnalisé** : Affiche le titre choisi par l'utilisateur, sans description supplémentaire.
3. **Détaillé** : Affiche le titre et la description complète, à n'activer que si l'utilisateur le désire expressément.

