# CAHIER DES CHARGES — MODULE JOURNAL INTIME

**Version :** 1.0  
**Type :** Module de journal personnel  
**Plateformes :** Android et iOS  
**Technologie :** Flutter / Dart  
**Stockage :** Local et hors ligne

## 1. Présentation

Le module Journal intime permet à chaque utilisateur de tenir un journal personnel numérique dans lequel il peut enregistrer ses pensées, ses émotions, ses expériences quotidiennes, ses souvenirs et les événements importants de sa vie.

L'objectif est de proposer un espace personnel, confidentiel et agréable dans lequel l'utilisateur peut s'exprimer librement, sans jugement et sans contrainte.

Le module doit être utilisable par tous les adultes, indépendamment de leur sexe ou de leur situation personnelle.

## 2. Objectifs

- Permettre la rédaction d'entrées personnelles.
- Conserver les souvenirs et expériences quotidiennes.
- Suivre l'évolution des émotions et de l'humeur.
- Ajouter des photos et des pièces jointes aux entrées.
- Retrouver facilement les anciennes publications.
- Protéger les écrits contre les accès non autorisés.
- Fonctionner entièrement hors ligne.

## 3. Fonctionnalités principales

### 3.1. Création d'une entrée

L'utilisateur doit pouvoir créer une nouvelle entrée comprenant :

- Un titre facultatif.
- Un contenu textuel.
- Une date et une heure.
- Une humeur ou une émotion.
- Une catégorie.
- Des mots-clés ou tags.
- Des photos facultatives.
- Des notes complémentaires.

L'éditeur doit proposer une expérience agréable avec :

- Mise en forme du texte.
- Paragraphes.
- Listes.
- Gras et italique.
- Possibilité d'enregistrer un brouillon.
- Sauvegarde automatique pendant la rédaction.

### 3.2. Gestion des entrées

L'utilisateur doit pouvoir :

- Consulter toutes ses entrées.
- Modifier une entrée existante.
- Supprimer une entrée.
- Archiver une entrée.
- Épingler ses entrées favorites.
- Dupliquer une entrée.
- Consulter les entrées par date.
- Rechercher une entrée par son titre ou son contenu.

Une confirmation doit être demandée avant toute suppression définitive.

### 3.3. Gestion des émotions et de l'humeur

Chaque entrée peut être associée à une émotion.

Exemples :

- Heureux.
- Triste.
- Amoureux.
- Stressé.
- En colère.
- Reconnaissant.
- Motivé.
- Fatigué.
- Anxieux.
- Paisible.

L'utilisateur peut également définir une intensité émotionnelle.

L'application doit permettre de visualiser l'évolution de son humeur au fil du temps.

### 3.4. Catégories et tags

Les entrées peuvent être organisées selon différentes catégories :

- Vie personnelle.
- Famille.
- Amour et relations.
- Travail.
- Études.
- Objectifs personnels.
- Souvenirs.
- Réflexions.
- Autres.

L'utilisateur doit pouvoir créer ses propres catégories et tags.

### 3.5. Calendrier du journal

Une vue calendrier doit permettre de :

- Visualiser les jours contenant des entrées.
- Consulter les entrées d'une journée.
- Naviguer entre les mois.
- Identifier les journées sans écriture.
- Retrouver rapidement un souvenir à partir de sa date.

### 3.6. Recherche et filtres

Le module doit proposer une recherche permettant de retrouver les entrées selon :

- Le titre.
- Le contenu.
- La date ou une période.
- L'émotion.
- La catégorie.
- Les tags.
- Les entrées favorites.

### 3.7. Rappels d'écriture

L'utilisateur doit pouvoir programmer des rappels pour écrire dans son journal.

Fonctionnalités :

- Choix de l'heure.
- Choix des jours de répétition.
- Activation et désactivation.
- Modification et suppression.
- Notifications locales discrètes.

Exemples de rappels :

- « Prends quelques minutes pour toi. »
- « Comment s'est passée ta journée ? »
- « Prends le temps de noter tes pensées. »

### 3.8. Tableau de bord et statistiques

Le module peut présenter :

- Le nombre total d'entrées.
- Le nombre d'entrées par mois.
- La fréquence d'écriture.
- Les émotions les plus fréquentes.
- Les catégories les plus utilisées.
- Les séries de jours consécutifs d'écriture.
- L'évolution de l'humeur.

Les statistiques doivent rester simples, visuelles et compréhensibles.

## 4. Confidentialité et sécurité

Le journal contient des informations personnelles. Sa protection est donc prioritaire.

Exigences :

- Fonctionnement entièrement hors ligne.
- Aucun backend obligatoire.
- Aucune synchronisation cloud automatique.
- Stockage local des données.
- Chiffrement des contenus sensibles.
- Protection par code PIN.
- Authentification biométrique facultative.
- Verrouillage automatique après inactivité.
- Protection des aperçus dans le sélecteur d'applications.
- Possibilité d'exporter une sauvegarde chiffrée.
- Possibilité de supprimer toutes les données du journal.

Aucune entrée ne doit être transmise à un service externe sans action explicite de l'utilisateur.

## 5. Interface utilisateur

L'interface doit proposer une expérience moderne, élégante et immersive.

Éléments attendus :

- Une page d'accueil présentant les dernières entrées.
- Un bouton de création rapide.
- Un éditeur de texte agréable.
- Une vue calendrier.
- Des cartes d'entrées avec dates et émotions.
- Des animations légères.
- Des transitions fluides.
- Des graphiques interactifs.
- Un thème clair et un thème sombre.
- Une interface en français et en anglais.

L'application doit privilégier la simplicité et laisser une place importante à la lecture et à l'écriture.

## 6. Architecture technique

| Élément | Technologie |
|---|---|
| Framework | Flutter |
| Langage | Dart |
| Gestion d'état | Riverpod |
| Navigation | GoRouter |
| Stockage | Fichiers JSON locaux |
| Chiffrement | AES-256-GCM |
| Stockage des clés | Keychain / Android Keystore |
| Authentification biométrique | local_auth |
| Notifications | flutter_local_notifications |
| Graphiques | Bibliothèque Flutter adaptée |
| Internationalisation | Flutter localization |

### Organisation recommandée

Le module doit être indépendant fonctionnellement du reste de l'application.

Il doit posséder ses propres :

- Models.
- Repositories.
- Services.
- Providers.
- Screens.
- Widgets.
- Utils.

## 7. Modèles de données prévisionnels

- `JournalEntry` : entrée du journal.
- `JournalCategory` : catégorie d'une entrée.
- `JournalTag` : mot-clé associé.
- `JournalMood` : humeur ou émotion.
- `JournalAttachment` : photo ou pièce jointe.
- `JournalReminder` : rappel d'écriture.
- `JournalPreference` : préférences du module.

Chaque entrée doit posséder un identifiant unique, une date de création et une date de dernière modification.

## 8. Critères de validation

Le module sera considéré comme fonctionnel lorsque :

- L'utilisateur pourra créer et modifier des entrées.
- Il pourra supprimer et archiver ses écrits.
- Il pourra associer des émotions et des catégories.
- Il pourra ajouter des photos.
- Il pourra rechercher et filtrer ses entrées.
- Il pourra consulter son journal dans un calendrier.
- Il pourra programmer des rappels.
- Il pourra consulter ses statistiques.
- Ses données resteront accessibles hors ligne.
- Ses écrits seront protégés par un mécanisme de sécurité.
- Le module fonctionnera sur Android et iOS.

## 9. Recommandation finale

Le module Journal intime doit être conçu comme un espace personnel indépendant au sein de l'application principale.

L'architecture doit permettre de faire évoluer facilement le module avec de nouvelles fonctionnalités, sans modifier les autres parties de l'application.

La priorité doit être donnée à trois aspects : **la simplicité d'écriture, la confidentialité absolue et une excellente expérience utilisateur.**