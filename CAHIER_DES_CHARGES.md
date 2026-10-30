# CAHIER DES CHARGES & MASTER PROMPT ANTIGRAVITY
# Projet : INTIMA — Private Intimate Life & Wellness Tracker

## 1. TA MISSION

Tu es une équipe complète composée de :

- Un architecte logiciel senior spécialisé en Flutter.
- Un développeur mobile expert Android et iOS.
- Un expert en stockage local, chiffrement et cybersécurité.
- Un designer UI/UX spécialisé dans les applications premium de santé et de bien-être.
- Un spécialiste des cycles menstruels et du suivi du bien-être intime.
- Un expert en accessibilité, notifications locales, tests et déploiement mobile.

Ta mission est de concevoir et de développer **INTIMA**, une application mobile intime, moderne, discrète, ludique, élégante et extrêmement bien finie, destinée aussi bien aux hommes qu'aux femmes adultes.

L'application doit permettre de suivre les relations intimes, les partenaires, les cycles menstruels, les règles, les symptômes, les rappels personnels et les statistiques privées.

Il ne s'agit pas de produire une simple maquette, un prototype visuel ou une succession d'écrans non fonctionnels. Tu dois développer une application réellement utilisable, avec une architecture propre, une base de données locale, des calculs fiables, une sécurité sérieuse, des tests et une documentation complète.

Travaille de manière autonome, prends les décisions techniques raisonnables et mène le projet jusqu'à un état fonctionnel. Si une fonctionnalité nécessite un arbitrage, privilégie la confidentialité, la simplicité, la sécurité et la fiabilité.

## 2. OBJECTIFS FONDAMENTAUX

L'application doit respecter impérativement les exigences suivantes :

1. Fonctionner entièrement hors ligne.
2. Ne nécessiter aucun compte utilisateur.
3. Ne nécessiter aucun backend, aucune API distante et aucun serveur.
4. Ne transmettre aucune donnée intime sur Internet.
5. Utiliser Flutter pour Android et iOS à partir d'un seul projet.
6. Enregistrer les données dans des fichiers locaux structurés, conformément à la section stockage.
7. Protéger l'accès par code PIN et biométrie lorsque l'appareil le permet.
8. Proposer une interface intégralement disponible en français et en anglais.
9. Permettre le suivi de plusieurs partenaires et de plusieurs cycles menstruels.
10. Offrir des notifications locales et des rappels discrets.
11. Fournir des statistiques compréhensibles sans jugement ni fausses certitudes médicales.
12. Être accessible, fluide, responsive, agréable et visuellement cohérente.
13. Être conçue pour une utilisation privée, même lorsque quelqu'un consulte brièvement l'écran du téléphone.
14. Ne jamais afficher d'informations intimes sensibles sur l'écran verrouillé sans autorisation explicite.

Nom de travail : INTIMA.

Prévois une identité visuelle premium, un logo original et une architecture permettant de modifier facilement le nom, les couleurs et les langues.

## 3. TECHNOLOGIES ET ARCHITECTURE

### 3.1 Stack technique obligatoire

- Flutter : application mobile multiplateforme.
- Dart : langage principal.
- Riverpod : gestion d'état.
- GoRouter : navigation et gestion des routes.
- Freezed et json_serializable : modèles immuables et sérialisation.
- flutter_localizations et intl : internationalisation.
- flutter_local_notifications : notifications locales.
- local_auth : authentification biométrique.
- flutter_secure_storage : stockage sécurisé des secrets et clés de protection.
- Chiffrement local avec une bibliothèque Flutter/Dart reconnue, maintenue et adaptée à un usage cryptographique.
- Fichiers JSON versionnés comme format de persistance métier principal.
- flutter_test et des outils de tests adaptés pour la qualité logicielle.

Vérifie les versions stables et compatibles des dépendances au moment du développement. N'utilise pas des versions inventées, abandonnées ou incompatibles.

### 3.2 Stockage par fichiers

L'utilisateur souhaite que les données soient stockées dans des fichiers, et non dans un backend ou une base distante.

Utilise donc une architecture de stockage locale par fichiers JSON, avec une couche d'abstraction permettant de remplacer ultérieurement le moteur de stockage sans réécrire les fonctionnalités métier.

Exemple d'organisation conceptuelle :

```text
INTIMA/
├── app_config.json
├── database/
│   ├── profile.enc
│   ├── partners.enc
│   ├── encounters.enc
│   ├── menstrual_cycles.enc
│   ├── symptoms.enc
│   ├── reminders.enc
│   ├── preferences.enc
│   └── metadata.json
├── exports/
│   └── encrypted_backup.enc
└── logs/
    └── diagnostics.log
```

Ces noms représentent une organisation logique, pas une obligation de placer les fichiers dans un répertoire publiquement accessible.

**Règles impératives :**

- Stocker les données dans le répertoire privé de l'application.
- Ne jamais placer les fichiers intimes dans le dossier public Documents ou Downloads par défaut.
- Chiffrer les fichiers contenant des informations personnelles.
- Utiliser une clé de chiffrement générée de manière cryptographiquement sûre.
- Protéger la clé avec les mécanismes sécurisés disponibles sur Android et iOS.
- Ne jamais stocker la clé de chiffrement en clair dans un fichier JSON ou dans le code source.
- Utiliser un format de chiffrement authentifié, par exemple AES-256-GCM, via une bibliothèque fiable.
- Gérer correctement les nonces, les erreurs d'intégrité et la rotation des clés si nécessaire.
- Écrire les fichiers de manière atomique afin de limiter les risques de corruption en cas d'arrêt brutal.
- Prévoir des sauvegardes locales chiffrées, une restauration et une migration des versions de fichiers.
- Ne jamais considérer le chiffrement comme une protection absolue si un appareil est compromis.

Les fichiers JSON chiffrés sont la persistance principale. Il est interdit d'utiliser une base distante ou de faire dépendre l'application d'un service externe.

Ne pas confondre stockage des données et stockage des clés : les clés doivent utiliser le mécanisme sécurisé du système d'exploitation.

Si une bibliothèque de chiffrement est incompatible avec une version ciblée, sélectionne une solution maintenue et documente le choix avant de poursuivre.

### 3.3 Architecture logicielle

Utilise une architecture feature-first, modulaire, fondée sur des principes de Clean Architecture pragmatiques.

```text
lib/
├── main.dart
├── bootstrap.dart
├── app/
│   ├── app.dart
│   ├── router.dart
│   ├── theme/
│   └── localization/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── security/
│   ├── storage/
│   ├── notifications/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── onboarding/
│   ├── dashboard/
│   ├── partners/
│   ├── encounters/
│   ├── menstrual_cycle/
│   ├── health_tracking/
│   ├── reminders/
│   ├── statistics/
│   ├── privacy/
│   ├── settings/
│   └── backup/
└── shared/
    ├── models/
    ├── providers/
    └── components/
```

Chaque fonctionnalité importante doit séparer :

- Les modèles et règles métier.
- Les interfaces de repository.
- Les implémentations de persistance.
- Les services applicatifs.
- Les providers.
- Les écrans et composants visuels.
- Les tests unitaires et de widgets.

Ne crée pas un seul fichier gigantesque contenant toute l'application. Évite également les abstractions inutiles qui rendent le projet difficile à maintenir.

## 4. IDENTITÉ VISUELLE ET DESIGN SYSTEM

L'application doit donner une impression de produit premium, contemporain et rassurant.

Inspiration qualitative : la finition d'une application de bien-être haut de gamme, la simplicité d'un agenda personnel moderne et la lisibilité d'une application financière privée.

Ne copie ni l'interface ni l'identité d'une application existante.

### 4.1 Direction artistique

Palette proposée :

- Fond principal : ivoire très clair `#F8F6F2`.
- Surface des cartes : blanc `#FFFFFF`.
- Couleur principale : prune profonde `#6D426D`.
- Accent : corail doux `#E89A8C`.
- Couleur complémentaire : sauge `#9CAF9A`.
- Texte principal : anthracite `#25242A`.
- Texte secondaire : gris doux `#777681`.
- Mode sombre : surfaces profondes, contrastes maîtrisés et accents doux.

Centralise tous les tokens de couleurs, d'espacement, de typographie, de rayons et d'élévation.

Prévois un thème clair et un thème sombre. Le thème sombre doit être réellement conçu, pas obtenu en inversant automatiquement toutes les couleurs.

### 4.2 Principes UX

- Interface épurée et chaleureuse.
- Cartes élégantes, avec espaces généreux.
- Typographie moderne et très lisible.
- Icônes cohérentes.
- Animations courtes et fluides.
- Transitions discrètes.
- Micro-interactions agréables après les actions importantes.
- États vides illustrés et utiles.
- Indicateurs de chargement et de sauvegarde.
- Messages de succès, d'avertissement et d'erreur compréhensibles.
- Toasts discrets et accessibles.
- Boutons tactiles confortables.
- Navigation adaptée aux écrans Android et iOS.
- Prise en charge des tailles de texte du système.

Ne surcharge jamais l'écran de graphiques, de badges, de couleurs ou de statistiques.

Évite les emojis utilisés comme substituts permanents à une véritable iconographie.

N'utilise pas systématiquement des dégradés, des effets de verre ou des ombres fortes. Le rendu doit être sobre, premium et durable.

### 4.3 Navigation principale

Prévois une barre de navigation inférieure avec cinq destinations :

1. **Accueil / Home**
2. **Partenaires / Partners**
3. **Calendrier / Calendar**
4. **Statistiques / Insights**
5. **Plus / More**

Les fonctionnalités secondaires doivent être accessibles depuis des écrans cohérents sans multiplier inutilement les niveaux de navigation.

L'accès à une action sensible, comme consulter le journal intime, peut exiger une authentification supplémentaire selon les paramètres de confidentialité.

## 5. PREMIER DÉMARRAGE ET PROFIL

Créer un onboarding élégant en quelques étapes courtes.

### Étape 1 : langue

- Français.
- English.
- Détection automatique de la langue du système.
- Possibilité de modifier la langue ultérieurement.

### Étape 2 : profil

Permettre de choisir un mode d'utilisation :

- Suivi personnel.
- Suivi de mes relations.
- Suivi de ma santé menstruelle.
- Mode complet.

L'application ne doit pas présumer du genre ou de la situation relationnelle de l'utilisateur.

### Étape 3 : sécurité

Proposer :

- Création d'un code PIN.
- Confirmation du code PIN.
- Activation de l'authentification biométrique si disponible.
- Délai de verrouillage automatique.
- Masquage des informations sensibles dans l'aperçu multitâche.
- Option de notification générique.

### Étape 4 : préférences

- Thème clair ou sombre.
- Langue.
- Format de date.
- Début de semaine.
- Unités et préférences de calendrier.
- Autorisations de notifications expliquées avant leur demande.

### Étape 5 : consentement aux fonctionnalités

Expliquer clairement que les données restent sur l'appareil, sous réserve des limites propres au système et aux sauvegardes.

Ne collecte aucune information inutile pendant l'onboarding.

L'application doit pouvoir fonctionner même si l'utilisateur refuse les notifications ou la biométrie.

## 6. TABLEAU DE BORD PRINCIPAL

Créer un dashboard personnalisable et intelligent.

Il doit présenter, selon les données réellement enregistrées :

- Un message d'accueil discret.
- La date du jour.
- Un résumé du mois.
- Le nombre de relations enregistrées durant la période sélectionnée.
- Les prochains rappels.
- Un résumé du cycle menstruel, si cette fonctionnalité est activée.
- Les dernières activités, uniquement si l'utilisateur autorise leur affichage.
- Des raccourcis vers les actions fréquentes.
- Une indication claire lorsque certaines données sont manquantes.

Exemples de raccourcis :

- Ajouter une rencontre.
- Ajouter un partenaire.
- Enregistrer le début des règles.
- Noter un symptôme.
- Créer un rappel.
- Consulter le calendrier.

Le dashboard ne doit jamais inventer de données ni présenter un indicateur comme fiable lorsque les informations sont insuffisantes.

L'utilisateur doit pouvoir masquer individuellement les cartes les plus sensibles.

## 7. GESTION DE PLUSIEURS PARTENAIRES

Créer un véritable module de gestion des partenaires.

### 7.1 Fiche partenaire

Chaque fiche peut contenir :

- Identifiant interne unique.
- Nom, pseudonyme ou surnom.
- Photo facultative, stockée localement.
- Couleur ou icône personnalisée.
- Date de première rencontre, facultative.
- Notes personnelles facultatives.
- Étiquettes personnalisées.
- Statut d'archivage.
- Paramètres de confidentialité.
- Historique associé.
- Cycle menstruel associé, uniquement si pertinent et renseigné avec autorisation.

Ne rends jamais obligatoires le nom réel, la photo, la date de naissance ou d'autres informations identifiantes.

Ne déduis jamais le statut relationnel, l'exclusivité ou la nature d'une relation à partir des données enregistrées.

### 7.2 Gestion

L'utilisateur doit pouvoir :

- Créer un nombre raisonnable de fiches partenaires sans limite artificielle faible.
- Modifier une fiche.
- Archiver un partenaire.
- Restaurer une fiche archivée.
- Supprimer définitivement une fiche après confirmation.
- Rechercher par pseudonyme.
- Filtrer les partenaires.
- Consulter les statistiques associées.
- Associer et dissocier des rencontres.
- Gérer séparément les données de santé et les données relationnelles.

La suppression d'un partenaire doit expliquer les conséquences sur les rencontres, les notes et les données associées.

Proposer une suppression complète ou une suppression de la fiche conservant, si cela est souhaité, des enregistrements anonymisés. L'utilisateur doit choisir explicitement.

Ne propose pas de partage automatique des fiches ni de synchronisation entre appareils.

## 8. JOURNAL DES RELATIONS INTIMES

C'est une fonctionnalité centrale, mais elle doit rester privée, facultative et non jugeante.

### 8.1 Enregistrement d'une rencontre

Créer un formulaire rapide permettant de renseigner :

- Partenaire concerné, facultatif.
- Date de la rencontre.
- Heure facultative.
- Durée facultative.
- Type d'événement : rencontre intime, autre activité personnelle ou événement personnalisé.
- Notes personnelles facultatives.
- Humeur avant et après, facultative.
- Protection utilisée, si l'utilisateur souhaite le renseigner.
- Rupture ou problème de protection, si pertinent.
- Contraception renseignée, facultative.
- Symptômes ou observations, facultatifs.
- Étiquettes personnalisées.
- Rappel ou suivi éventuel.

Ne demande jamais de détails sexuels graphiques inutiles.

Ne fais pas de classement des partenaires selon leurs performances et n'attribue pas de score de valeur sexuelle.

### 8.2 Actions disponibles

- Ajouter une rencontre.
- Modifier un enregistrement.
- Supprimer un enregistrement.
- Dupliquer un formulaire sans dupliquer accidentellement la date.
- Rechercher par période.
- Filtrer par partenaire.
- Filtrer par type d'événement.
- Filtrer par étiquette.
- Consulter le détail.
- Afficher un historique chronologique.
- Consulter un calendrier privé.

### 8.3 Vue chronologique

Présenter les événements de manière élégante et compacte.

Par défaut, utiliser un libellé neutre comme « Événement personnel ».

Le nom du partenaire, le type de rencontre et les notes sensibles ne doivent apparaître que lorsque l'utilisateur consulte volontairement le détail.

Prévoir un mode discret dans lequel les informations intimes sont remplacées par des libellés génériques.

### 8.4 Rappels après une rencontre

Permettre de créer des rappels personnels, par exemple :

- Penser à acheter des protections.
- Vérifier un besoin de contraception d'urgence.
- Faire un test de grossesse à la date appropriée.
- Prévoir un dépistage selon les conseils d'un professionnel de santé.
- Noter une observation ultérieure.

Ces rappels doivent être configurables, privés et facultatifs.

Pour les événements médicaux, éviter de proposer une date arbitraire présentée comme une recommandation clinique. L'utilisateur doit pouvoir définir la date en fonction de sa situation et des conseils médicaux adaptés.

## 9. SUIVI COMPLET DU CYCLE MENSTRUEL

Construire un module spécialisé, clair et pédagogique.

Le module doit être utilisable par une personne qui souhaite suivre ses propres règles ou par un utilisateur qui, avec le consentement approprié de la personne concernée, consigne des informations utiles à son suivi.

Ne jamais suggérer qu'une personne peut surveiller le corps d'un partenaire sans son accord.

### 9.1 Fiche de cycle

Chaque profil concerné doit pouvoir enregistrer :

- Premier jour des règles.
- Dernier jour des règles, lorsqu'il est connu.
- Durée observée des règles.
- Durée habituelle estimée du cycle.
- Historique des cycles précédents.
- Variations de durée.
- Intensité des saignements, facultative.
- Crampes.
- Fatigue.
- Maux de tête.
- Humeur.
- Sommeil.
- Symptômes personnels.
- Observations libres.
- Retards et cycles irréguliers.
- Traitements ou contraception, facultatifs.
- Grossesse éventuelle, si la personne choisit de renseigner cette information.
- Post-partum ou allaitement, si pertinent et volontairement déclaré.

Les données doivent être saisies manuellement et rester modifiables.

### 9.2 Calendrier menstruel

Créer un calendrier mensuel avec une légende accessible :

- Jours de règles enregistrés.
- Jours de règles prévus.
- Période de fertilité estimée.
- Ovulation estimée.
- Symptômes consignés.
- Jours de rapports enregistrés, uniquement si l'utilisateur active cette option.
- Rappels à venir.

Utiliser des couleurs sobres, des formes distinctes et une légende claire.

Ne pas utiliser uniquement la couleur pour transmettre l'information.

Distinguer visuellement les données observées des estimations calculées.

### 9.3 Calculs

Implémenter des calculs testés à partir des données enregistrées :

- Durée d'un cycle : différence entre le premier jour d'un cycle et le premier jour du cycle suivant.
- Durée des règles : intervalle entre les dates de début et de fin selon une convention documentée.
- Moyenne des cycles connus.
- Variabilité des cycles.
- Estimation des prochaines règles.
- Estimation indicative de la période de fertilité.
- Estimation indicative de l'ovulation.
- Détection de données manquantes ou incohérentes.

Les algorithmes doivent être isolés dans une couche métier indépendante de l'interface.

Les cycles irréguliers, les changements de contraception, la grossesse et d'autres situations peuvent rendre les estimations peu fiables. Afficher clairement ces limites.

Ne jamais utiliser un simple calcul de calendrier pour affirmer qu'un rapport est sans risque de grossesse.

Ne jamais afficher « Sans risque », « Jour garanti sans grossesse » ou « Tu peux avoir un rapport sans protection ».

Préférer :

- « Règles estimées ».
- « Période de fertilité potentielle ».
- « Ovulation estimée ».
- « Estimation incertaine : données insuffisantes ».
- « Le calendrier ne constitue pas une méthode contraceptive fiable à lui seul ».

### 9.4 Questions et informations pédagogiques

Créer une section éducative locale qui explique :

- Les différentes phases du cycle menstruel.
- La différence entre règles et ovulation.
- La fertilité et ses variations.
- Pourquoi la durée des cycles varie.
- Les limites des prédictions.
- Les moyens de contraception.
- La différence entre prévention de grossesse et prévention des IST.
- Les situations dans lesquelles demander un avis médical.

Tous les contenus doivent être disponibles en français et en anglais.

Les contenus médicaux doivent être rédigés prudemment, vérifiés avant publication et présentés sans diagnostic automatique.

### 9.5 Alertes et symptômes

Proposer des informations non diagnostiques lorsqu'un utilisateur renseigne des symptômes préoccupants.

En cas de douleur intense, de saignement très abondant, de malaise ou d'autres signes d'alerte, recommander une évaluation médicale rapide adaptée à la situation.

Ne jamais rassurer automatiquement sur un symptôme potentiellement grave.

## 10. RAPPELS ET NOTIFICATIONS LOCALES

Développer un centre de notifications entièrement local.

### 10.1 Types de rappels

- Rappel de règles estimées.
- Rappel personnel lié au cycle.
- Rappel de saisie quotidienne.
- Rappel de médicament ou de contraception, si l'utilisateur le configure.
- Rappel de test de grossesse.
- Rappel de dépistage.
- Rappel d'un événement personnel.
- Rappel de rendez-vous.
- Rappel personnalisé récurrent.

### 10.2 Configuration

Chaque rappel doit avoir :

- Un titre.
- Une description facultative.
- Une date.
- Une heure.
- Une fréquence.
- Une date de fin facultative.
- Une catégorie.
- Un niveau de discrétion.
- Un état actif ou désactivé.
- Une action permettant de le reporter ou de le supprimer.

Les notifications doivent fonctionner sans connexion Internet.

Prendre en charge les autorisations Android et iOS, les limites des systèmes, les changements de fuseau horaire et la reprogrammation après redémarrage lorsque la plateforme le permet.

Prévoir des solutions adaptées aux restrictions de notifications des versions récentes d'Android et d'iOS.

### 10.3 Confidentialité des notifications

Modes proposés :

1. **Discret** : « Tu as un rappel personnel. »
2. **Personnalisé** : titre choisi par l'utilisateur.
3. **Détaillé** : informations explicites, uniquement après activation volontaire.

Par défaut, utiliser le mode discret.

Ne jamais placer automatiquement le nom d'un partenaire, un événement sexuel ou une information menstruelle sensible dans une notification.

Les notifications ne doivent pas dépendre d'un serveur, d'un service push distant ou d'une connexion réseau.

Les règles métier de rappel doivent être séparées de leur planification système afin de pouvoir les tester.

## 11. TOASTS, FEEDBACK ET MICRO-INTERACTIONS

Chaque action doit fournir un retour visuel adapté.

Exemples de messages français :

- « Enregistrement effectué. »
- « Modifications enregistrées. »
- « Rappel programmé. »
- « Les données ont été mises à jour. »
- « Une erreur est survenue. Réessaie. »
- « Code incorrect. »
- « Sauvegarde chiffrée créée. »
- « Aucune donnée disponible pour cette période. »

Équivalents anglais :

- “Saved successfully.”
- “Changes saved.”
- “Reminder scheduled.”
- “Data updated.”
- “Something went wrong. Please try again.”
- “Incorrect PIN.”
- “Encrypted backup created.”
- “No data available for this period.”

Ne jamais afficher de contenu sensible dans un toast.

Pour les erreurs de persistance, ne pas afficher un message de succès avant que l'opération d'écriture soit réellement terminée.

Utiliser des toasts pour les confirmations simples, des boîtes de dialogue pour les décisions importantes et des écrans dédiés pour les erreurs qui demandent une action.

Prévoir des animations légères de confirmation, des états de chargement et une gestion cohérente des formulaires.

## 12. STATISTIQUES ET INSIGHTS

Créer un module de statistiques interactif, lisible et respectueux de la vie privée.

### 12.1 Statistiques relationnelles

- Nombre de rencontres enregistrées sur une période.
- Répartition par mois.
- Historique par partenaire.
- Évolution de la fréquence des événements.
- Répartition par type d'événement.
- Évolution des notes personnelles, si activée.

### 12.2 Statistiques menstruelles

- Durée moyenne des cycles observés.
- Durée moyenne des règles.
- Variabilité des cycles.
- Comparaison entre estimations et observations.
- Historique des symptômes.
- Tendances personnelles.

### 12.3 Présentation

- Graphiques sobres.
- Filtres par date.
- Vue mensuelle, trimestrielle et annuelle.
- Comparaison de périodes.
- État vide pertinent.
- Explication de la méthode de calcul.

N'affiche aucune statistique trompeuse lorsque l'échantillon est insuffisant.

Ne tire aucune conclusion sur la fidélité, la compatibilité sexuelle, la fertilité certaine ou la qualité d'une relation à partir de simples statistiques.

Toutes les statistiques doivent être calculées localement.

## 13. SÉCURITÉ ET CONFIDENTIALITÉ

Cette section est prioritaire.

### 13.1 Verrouillage de l'application

Implémenter :

- Code PIN configurable.
- Vérification du PIN.
- Biométrie via les mécanismes natifs pris en charge.
- Reconnaissance de l'indisponibilité de la biométrie.
- Retour sécurisé au PIN.
- Verrouillage automatique après une période configurable.
- Verrouillage après passage en arrière-plan.
- Limitation des tentatives incorrectes avec temporisation progressive.
- Protection des écrans sensibles.
- Déconnexion ou verrouillage manuel.
- Réauthentification lors de certaines opérations sensibles.

Ne stocke jamais le PIN en clair. Utilise une vérification cryptographique adaptée et une gestion sûre des tentatives.

La biométrie doit être facultative. Son activation ne doit pas empêcher l'accès de secours par PIN.

### 13.2 Protection de l'écran

- Masquer le contenu sensible dans le sélecteur d'applications lorsque possible.
- Réduire les fuites de données via les captures d'écran lorsque la plateforme le permet.
- Ne jamais placer d'informations intimes dans les logs.
- Ne pas afficher de données sensibles dans les messages d'erreur.
- Ne pas préremplir automatiquement des formulaires sensibles avec des données visibles sur l'écran d'accueil.
- Prévoir un verrouillage lorsque l'application revient au premier plan.
- Ne pas empêcher abusivement les fonctions d'accessibilité du système.

Documenter les différences de comportement entre Android et iOS.

### 13.3 Politique zéro réseau

L'application doit fonctionner sans aucune dépendance réseau à l'exécution.

Interdictions :

- Firebase.
- Analytics distants.
- Crash reporting distant.
- Publicités.
- SDK de suivi.
- API médicales.
- Authentification cloud.
- Synchronisation distante.
- Envoi d'emails depuis l'application.
- Téléchargement automatique de contenus.
- Collecte télémétrique.

Évite également d'ajouter des autorisations Android ou des capacités iOS non nécessaires.

Vérifie le manifeste Android, les entitlements et la configuration iOS.

L'objectif est de limiter les communications de l'application à zéro en fonctionnement normal. Les vérifications de build et de dépendances peuvent nécessiter Internet sur la machine de développement, mais jamais pour utiliser les fonctionnalités quotidiennes.

### 13.4 Gestion des données

L'utilisateur doit pouvoir :

- Consulter les données stockées.
- Exporter une sauvegarde chiffrée.
- Restaurer une sauvegarde après authentification.
- Supprimer une catégorie de données.
- Supprimer un partenaire et ses données associées.
- Effacer toutes les données de l'application.
- Réinitialiser l'application.

Avant une suppression irréversible, demander une confirmation explicite.

Une sauvegarde exportée doit être chiffrée, accompagnée d'une procédure de restauration et ne doit pas révéler les données dans son nom de fichier.

Informer l'utilisateur qu'une exportation volontaire vers un emplacement externe peut sortir du périmètre de protection de l'application.

Ne prétends pas que les données sont totalement effacées de toutes les mémoires flash après suppression : cette garantie n'est pas réaliste sur les appareils modernes.

## 14. INTERNATIONALISATION FRANÇAIS / ANGLAIS

L'application doit être entièrement bilingue.

Cela comprend :

- Tous les écrans.
- Tous les boutons.
- Tous les formulaires.
- Tous les titres.
- Tous les messages d'erreur.
- Tous les toasts.
- Tous les rappels.
- Les notifications locales.
- Les dialogues de confirmation.
- Les paramètres.
- Les contenus pédagogiques.
- Les états vides.
- Les validations.
- Les formats de date et d'heure.

Utiliser le système de localisation Flutter, avec des fichiers de traduction centralisés.

Exemple :

```text
lib/l10n/
├── app_fr.arb
└── app_en.arb
```

Ne place pas de texte utilisateur directement dans les widgets lorsque ce texte doit être traduit.

Ne traduis pas les données saisies par l'utilisateur.

Le changement de langue doit être immédiat, sans perte de données et sans redémarrage forcé de l'application.

## 15. ACCESSIBILITÉ ET ERGONOMIE

L'application doit être utilisable par des personnes ayant des besoins d'accessibilité variés.

Prévoir :

- Contrastes suffisants.
- Compatibilité avec les lecteurs d'écran.
- Libellés accessibles pour les icônes.
- Ordre de navigation cohérent.
- Tailles de texte adaptatives.
- Zones tactiles confortables.
- Messages d'erreur associés aux champs.
- Alternatives textuelles aux graphiques.
- Distinction des états autrement que par la couleur.
- Respect des préférences de réduction des animations lorsque possible.

Les formulaires doivent être rapides à remplir et adaptés au clavier mobile.

Les actions les plus fréquentes doivent être accessibles en quelques interactions.

## 16. FONCTIONNALITÉS COMPLÉMENTAIRES À VALEUR AJOUTÉE

Développe les fonctionnalités suivantes après avoir stabilisé le cœur du produit.

### 16.1 Notes privées

- Notes libres.
- Catégories.
- Recherche locale.
- Favoris.
- Protection renforcée des notes sensibles.

### 16.2 Journal d'humeur et de bien-être

- Humeur quotidienne.
- Énergie.
- Sommeil.
- Symptômes.
- Observations.
- Tendances personnelles.

### 16.3 Recherche globale

Permettre de rechercher localement des partenaires, des événements, des notes, des rappels et des observations, selon les autorisations de confidentialité.

Les résultats doivent être masqués lorsque l'application est verrouillée.

### 16.4 Sauvegarde et restauration

Créer un format de sauvegarde chiffré, versionné et vérifiable.

La restauration doit vérifier l'intégrité des données avant de remplacer l'état existant.

Présenter un aperçu des conséquences avant toute restauration destructive.

### 16.5 Mode discret

Proposer une option qui :

- Affiche un nom neutre.
- Utilise une icône et un nom d'application compatibles avec les mécanismes réellement disponibles sur chaque plateforme, sans prétendre pouvoir les modifier librement si le système l'interdit.
- Masque les données sensibles dans les aperçus.
- Utilise des notifications génériques.
- Permet de masquer certaines cartes du dashboard.

Ne pas promettre une invisibilité totale : le nom du paquet, les paramètres système, les notifications autorisées et les fichiers exportés peuvent laisser des traces.

## 17. ÉCRANS À DÉVELOPPER

Produis au minimum les écrans suivants, entièrement fonctionnels :

1. Splash screen.
2. Onboarding.
3. Sélection de langue.
4. Création du PIN.
5. Déverrouillage.
6. Dashboard.
7. Création et modification d'un partenaire.
8. Liste des partenaires.
9. Détail d'un partenaire.
10. Création d'une rencontre.
11. Historique des rencontres.
12. Détail d'une rencontre.
13. Calendrier mensuel.
14. Vue du cycle menstruel.
15. Enregistrement des règles.
16. Formulaire de symptômes.
17. Historique des cycles.
18. Détail des estimations du cycle.
19. Centre des rappels.
20. Création et modification d'un rappel.
21. Statistiques générales.
22. Statistiques menstruelles.
23. Journal d'humeur.
24. Notes privées.
25. Centre de confidentialité.
26. Configuration biométrique.
27. Configuration des notifications.
28. Paramètres de langue et de thème.
29. Sauvegarde et restauration.
30. Gestion de la suppression des données.
31. Centre d'aide et informations médicales.
32. À propos et mentions de confidentialité.

Ne te limite pas à afficher ces écrans : les boutons, les formulaires, les navigations, les validations, les états vides et les actions doivent fonctionner.

## 18. QUALITÉ DU CODE ET TESTS

La qualité est obligatoire.

### 18.1 Tests unitaires

Tester notamment :

- Les calculs de cycles.
- Les estimations des prochaines règles.
- Les cas de cycles irréguliers.
- Les dates limites de mois et d'année.
- Les années bissextiles.
- Les changements de fuseau horaire.
- Les validations des formulaires.
- Les règles de rappels.
- Les règles de suppression.
- Les sérialisations JSON.
- Les migrations de données.
- Le chiffrement et le déchiffrement.
- La détection des fichiers corrompus.
- Les contrôles d'accès.

### 18.2 Tests de widgets

Tester :

- L'onboarding.
- Le verrouillage.
- Les formulaires.
- Les confirmations.
- Les toasts.
- La navigation.
- Le changement de langue.
- Le thème sombre.
- Les états vides.
- Les erreurs de persistance.
- Le masquage des informations sensibles.

### 18.3 Tests d'intégration

Tester sur émulateurs et appareils lorsque disponibles :

- Création d'un partenaire.
- Création d'une rencontre.
- Fermeture puis réouverture de l'application.
- Persistance des données.
- Enregistrement de plusieurs cycles.
- Programmation des notifications.
- Verrouillage et déverrouillage.
- Export et restauration chiffrés.
- Suppression de toutes les données.

### 18.4 Qualité générale

Exécuter régulièrement :

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

Résoudre les erreurs et avertissements importants.

Ne masque pas les erreurs avec des contournements arbitraires.

Ne marque pas les tests comme réussis s'ils n'ont pas réellement été exécutés.

## 19. PERFORMANCE ET FIABILITÉ

L'application doit :

- Démarrer rapidement.
- Fonctionner sans connexion.
- Ne pas bloquer l'interface pendant les opérations de fichiers.
- Gérer les erreurs de lecture et d'écriture.
- Éviter les pertes de données en cas d'arrêt brutal.
- Limiter les reconstructions inutiles de widgets.
- Paginer ou filtrer les historiques volumineux.
- Utiliser des identifiants stables.
- Gérer correctement les dates et les fuseaux horaires.
- Rester fluide sur des téléphones Android de milieu de gamme.

Les opérations de chiffrement et de persistance potentiellement coûteuses ne doivent pas monopoliser le thread d'interface.

Prévoir des mécanismes de récupération en cas de fichier incomplet ou corrompu.

## 20. COMPATIBILITÉ ANDROID ET IOS

Le projet doit être construit pour les deux plateformes.

### Android

- Interface adaptée aux téléphones Android modernes.
- Gestion des permissions de notifications.
- Intégration biométrique.
- Gestion des tâches et notifications locales.
- Protection de la zone de stockage privée.
- Production d'un APK installable.
- Préparation d'un Android App Bundle pour une éventuelle publication.
- Vérification du comportement sur plusieurs versions d'Android.

### iOS

- Interface adaptée aux conventions iOS.
- Intégration Face ID ou Touch ID lorsque disponibles.
- Stockage des secrets dans le Keychain.
- Gestion des notifications locales.
- Gestion de la suspension et de la reprise de l'application.
- Configuration des capacités de sécurité.
- Préparation d'un build iOS distribuable.
- Vérification du comportement sur les versions iOS ciblées.

La compilation et la signature iOS nécessitent un environnement Apple compatible, généralement macOS avec Xcode. Ne prétends pas avoir généré un IPA signé si l'environnement requis n'est pas disponible.

Documente précisément les étapes de compilation, de signature et d'installation sur chaque plateforme.

## 21. DOCUMENTATION À LIVRER

Génère les fichiers suivants dans le dépôt du projet :

```text
README.md
docs/
├── ARCHITECTURE.md
├── DESIGN_SYSTEM.md
├── SECURITY.md
├── DATA_STORAGE.md
├── CYCLE_CALCULATIONS.md
├── NOTIFICATIONS.md
├── INTERNATIONALIZATION.md
├── TESTING.md
├── ANDROID_BUILD.md
├── IOS_BUILD.md
└── USER_GUIDE.md
```

La documentation doit expliquer :

- Comment installer les dépendances.
- Comment lancer l'application.
- Comment fonctionne le stockage par fichiers.
- Comment les clés sont protégées.
- Comment fonctionnent les rappels.
- Comment sont calculées les estimations menstruelles.
- Comment ajouter une traduction.
- Comment exécuter les tests.
- Comment créer une sauvegarde.
- Comment restaurer une sauvegarde.
- Comment produire une version Android.
- Comment produire une version iOS.
- Quelles sont les limites connues.

Fournis aussi une liste des dépendances utilisées et de leur rôle.

## 22. MÉTHODE DE TRAVAIL OBLIGATOIRE

Avance par phases, sans t'arrêter à la conception.

### Phase 1 — Analyse et fondations

- Examiner l'environnement de travail.
- Créer le projet Flutter.
- Vérifier les outils disponibles.
- Choisir les dépendances compatibles.
- Créer l'architecture.
- Mettre en place les thèmes et la localisation.
- Documenter les choix techniques.

### Phase 2 — Stockage et sécurité

- Implémenter la persistance par fichiers JSON chiffrés.
- Implémenter les modèles.
- Ajouter les migrations.
- Ajouter la gestion des erreurs.
- Mettre en place le PIN et la biométrie.
- Tester le verrouillage.
- Vérifier la confidentialité des fichiers.

### Phase 3 — Fonctionnalités principales

- Profils.
- Partenaires.
- Rencontres.
- Calendrier.
- Cycles menstruels.
- Symptômes.
- Rappels.
- Statistiques.

### Phase 4 — Expérience utilisateur

- Finaliser les écrans.
- Ajouter les animations.
- Ajouter les toasts.
- Améliorer les formulaires.
- Finaliser les états vides et les erreurs.
- Tester les modes clair et sombre.
- Vérifier le français et l'anglais.

### Phase 5 — Fiabilité et confidentialité

- Tests unitaires.
- Tests de widgets.
- Tests d'intégration disponibles.
- Vérification des permissions.
- Vérification de l'absence de télémétrie.
- Vérification des scénarios de corruption et de restauration.
- Vérification des notifications locales.

### Phase 6 — Livraison

- Corriger les défauts identifiés.
- Exécuter les vérifications finales.
- Générer les artefacts possibles dans l'environnement.
- Fournir les instructions d'installation.
- Documenter les limites restantes.

À la fin de chaque phase, indique ce qui a réellement été implémenté, ce qui a été testé et ce qui reste à faire.

Ne remplace jamais une fonctionnalité réelle par un bouton décoratif.

Ne supprime pas des exigences importantes simplement pour obtenir une interface plus rapidement.

## 23. CRITÈRES D'ACCEPTATION

Le projet ne sera considéré comme terminé que lorsque les critères suivants auront été vérifiés :

- [ ] L'application démarre et navigue correctement.
- [ ] Toutes les pages essentielles sont implémentées.
- [ ] Les données persistent après fermeture de l'application.
- [ ] Les données sensibles sont chiffrées au repos selon l'architecture définie.
- [ ] Le code PIN fonctionne.
- [ ] La biométrie fonctionne sur les appareils compatibles.
- [ ] Le retour au PIN fonctionne lorsque la biométrie est indisponible.
- [ ] Plusieurs partenaires peuvent être gérés.
- [ ] Les rencontres peuvent être ajoutées, modifiées et supprimées.
- [ ] Plusieurs cycles menstruels peuvent être suivis.
- [ ] Les calculs de cycle sont testés.
- [ ] Les incertitudes médicales sont affichées correctement.
- [ ] Les rappels locaux fonctionnent dans les conditions autorisées par le système.
- [ ] Les notifications ne divulguent pas d'informations sensibles par défaut.
- [ ] Les toasts sont traduits.
- [ ] Les modes français et anglais fonctionnent.
- [ ] Le thème clair et le thème sombre fonctionnent.
- [ ] Les statistiques utilisent les données réelles.
- [ ] La sauvegarde chiffrée et la restauration ont été testées.
- [ ] La suppression des données est opérationnelle.
- [ ] Aucun compte ou backend n'est requis.
- [ ] Aucune télémétrie ou transmission distante de données intimes n'est présente.
- [ ] `flutter analyze` ne signale aucune erreur bloquante.
- [ ] Les tests automatisés sont exécutés et leurs résultats documentés.
- [ ] Les instructions de build Android et iOS sont disponibles.

## 24. INSTRUCTIONS FINALES

Commence par analyser le projet existant et l'environnement de développement. Si aucun projet Flutter n'existe, crée-le.

Ensuite, construis réellement l'application en respectant toutes les exigences ci-dessus.

Prends des décisions cohérentes sans me demander de valider chaque détail esthétique ou technique. Si une décision nécessite une clarification importante, choisis par défaut l'option la plus sûre et la plus simple à maintenir, puis documente-la.

Ne t'arrête pas après avoir créé les écrans ou les composants visuels. Continue jusqu'à l'implémentation des règles métier, du stockage, de la sécurité, des notifications, des tests et de la documentation.

Si une fonctionnalité ne peut pas être complètement réalisée dans l'environnement disponible, implémente ce qui est possible, explique la limitation et indique précisément ce qui manque. N'invente jamais un résultat de test ou un artefact de compilation.

**Résultat attendu : une véritable application Flutter premium, intime, bilingue, entièrement locale, sécurisée, agréable à utiliser et installable sur Android et iOS, avec une base de code maintenable et des fonctionnalités réellement opérationnelles.**