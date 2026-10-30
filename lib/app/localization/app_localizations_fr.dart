// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Intima';

  @override
  String get appTagline => 'Votre espace privé';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonNext => 'Suivant';

  @override
  String get commonSkip => 'Passer';

  @override
  String get commonDone => 'Terminer';

  @override
  String get commonYes => 'Oui';

  @override
  String get commonNo => 'Non';

  @override
  String get commonOk => 'OK';

  @override
  String get commonSearch => 'Rechercher';

  @override
  String get commonFilter => 'Filtrer';

  @override
  String get commonAdd => 'Ajouter';

  @override
  String get commonArchive => 'Archiver';

  @override
  String get commonRestore => 'Restaurer';

  @override
  String get commonLoading => 'Chargement…';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonError => 'Erreur';

  @override
  String get commonSuccess => 'Succès';

  @override
  String get commonWarning => 'Attention';

  @override
  String get commonOptional => 'Facultatif';

  @override
  String get commonRequired => 'Requis';

  @override
  String get commonUnknown => 'Inconnu';

  @override
  String get commonAll => 'Tous';

  @override
  String get commonNone => 'Aucun';

  @override
  String get commonPersonalEvent => 'Événement personnel';

  @override
  String get navHome => 'Accueil';

  @override
  String get navPartners => 'Partenaires';

  @override
  String get navCalendar => 'Calendrier';

  @override
  String get navInsights => 'Statistiques';

  @override
  String get navMore => 'Plus';

  @override
  String get toastSaved => 'Enregistrement effectué.';

  @override
  String get toastChangesSaved => 'Modifications enregistrées.';

  @override
  String get toastReminderScheduled => 'Rappel programmé.';

  @override
  String get toastDataUpdated => 'Les données ont été mises à jour.';

  @override
  String get toastError => 'Une erreur est survenue. Réessaie.';

  @override
  String get toastIncorrectPin => 'Code incorrect.';

  @override
  String get toastBackupCreated => 'Sauvegarde chiffrée créée.';

  @override
  String get toastNoData => 'Aucune donnée disponible pour cette période.';

  @override
  String get toastDeleted => 'Élément supprimé.';

  @override
  String get toastRestored => 'Élément restauré.';

  @override
  String get toastArchived => 'Élément archivé.';

  @override
  String get toastCopied => 'Copié.';

  @override
  String get splashTagline => 'Votre espace intime, privé et sécurisé.';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue dans Intima';

  @override
  String get onboardingWelcomeSubtitle =>
      'Votre espace personnel, privé et sécurisé. Aucun compte requis. Aucune donnée partagée.';

  @override
  String get onboardingLanguageTitle => 'Choisissez votre langue';

  @override
  String get onboardingLanguageSubtitle =>
      'Vous pourrez modifier ce choix dans les paramètres.';

  @override
  String get onboardingProfileTitle =>
      'Comment souhaitez-vous utiliser Intima ?';

  @override
  String get onboardingProfileSubtitle =>
      'Ce choix personnalise votre tableau de bord. Vous pouvez le modifier à tout moment.';

  @override
  String get onboardingProfilePersonal => 'Suivi personnel';

  @override
  String get onboardingProfileRelationships => 'Suivi de mes relations';

  @override
  String get onboardingProfileMenstrual => 'Suivi de ma santé menstruelle';

  @override
  String get onboardingProfileFull => 'Mode complet';

  @override
  String get onboardingSecurityTitle => 'Protégez votre espace';

  @override
  String get onboardingSecuritySubtitle =>
      'Créez un code PIN pour sécuriser l\'accès à l\'application.';

  @override
  String get onboardingPreferencesTitle => 'Vos préférences';

  @override
  String get onboardingConsentTitle => 'Vos données restent sur votre appareil';

  @override
  String get onboardingConsentBody =>
      'Intima ne transmet aucune donnée intime sur Internet. Vos informations sont chiffrées et stockées uniquement sur votre téléphone. Vous pouvez exporter ou supprimer vos données à tout moment.';

  @override
  String get onboardingConsentNote =>
      'Note : les sauvegardes système du téléphone (Google Drive, iCloud) peuvent inclure les données de l\'application selon votre configuration.';

  @override
  String get onboardingGetStarted => 'Commencer';

  @override
  String get pinCreateTitle => 'Créer votre code PIN';

  @override
  String get pinCreateSubtitle =>
      'Choisissez un code PIN à 6 chiffres pour protéger l\'accès.';

  @override
  String get pinConfirmTitle => 'Confirmer votre code PIN';

  @override
  String get pinConfirmSubtitle =>
      'Saisissez à nouveau votre code PIN pour confirmer.';

  @override
  String get pinEnterTitle => 'Déverrouiller Intima';

  @override
  String get pinEnterSubtitle => 'Saisissez votre code PIN.';

  @override
  String get pinMismatch => 'Les codes PIN ne correspondent pas. Réessayez.';

  @override
  String get pinTooShort => 'Le code PIN doit comporter 6 chiffres.';

  @override
  String get pinIncorrect => 'Code PIN incorrect.';

  @override
  String pinAttemptsRemaining(int count) {
    return '$count tentative(s) restante(s).';
  }

  @override
  String pinLockedOut(int seconds) {
    return 'Trop de tentatives. Réessayez dans $seconds secondes.';
  }

  @override
  String get pinForgot => 'Code oublié ?';

  @override
  String get pinBiometricPrompt =>
      'Déverrouillez avec votre empreinte ou Face ID.';

  @override
  String get pinUseBiometric => 'Utiliser la biométrie';

  @override
  String get pinUsePIN => 'Utiliser le code PIN';

  @override
  String get dashboardGoodMorning => 'Bonjour';

  @override
  String get dashboardGoodAfternoon => 'Bon après-midi';

  @override
  String get dashboardGoodEvening => 'Bonsoir';

  @override
  String get dashboardSummaryTitle => 'Résumé du mois';

  @override
  String get dashboardNoData => 'Aucune donnée enregistrée ce mois.';

  @override
  String dashboardEncountersCount(int count) {
    return '$count rencontre(s) ce mois';
  }

  @override
  String get dashboardNextReminder => 'Prochain rappel';

  @override
  String get dashboardNoReminders => 'Aucun rappel à venir.';

  @override
  String get dashboardCycleTitle => 'Mon cycle';

  @override
  String get dashboardCycleNotEnabled => 'Suivi du cycle non activé.';

  @override
  String get dashboardQuickAdd => 'Action rapide';

  @override
  String get dashboardAddEncounter => 'Ajouter une rencontre';

  @override
  String get dashboardAddPartner => 'Ajouter un partenaire';

  @override
  String get dashboardLogPeriod => 'Enregistrer mes règles';

  @override
  String get dashboardLogSymptom => 'Noter un symptôme';

  @override
  String get dashboardAddReminder => 'Créer un rappel';

  @override
  String get dashboardOpenCalendar => 'Voir le calendrier';

  @override
  String get partnersTitle => 'Partenaires';

  @override
  String get partnersEmpty =>
      'Aucun partenaire enregistré.\nAppuyez sur + pour en ajouter un.';

  @override
  String get partnersAdd => 'Ajouter un partenaire';

  @override
  String get partnerName => 'Nom ou surnom';

  @override
  String get partnerNameHint => 'Pseudonyme, prénom ou surnom';

  @override
  String get partnerColor => 'Couleur';

  @override
  String get partnerFirstMet => 'Date de première rencontre';

  @override
  String get partnerNotes => 'Notes personnelles';

  @override
  String get partnerTags => 'Étiquettes';

  @override
  String get partnerArchived => 'Archivé';

  @override
  String get partnerShowArchived => 'Afficher les archivés';

  @override
  String get partnerDeleteWarning =>
      'Supprimer ce partenaire effacera également les rencontres et données associées. Cette action est irréversible.';

  @override
  String get partnerDeleteKeepData =>
      'Supprimer la fiche (conserver les rencontres anonymisées)';

  @override
  String get partnerDeleteAll => 'Tout supprimer (fiche + rencontres)';

  @override
  String get partnerEncounters => 'Rencontres associées';

  @override
  String get partnerNoEncounters => 'Aucune rencontre enregistrée.';

  @override
  String get partnerStats => 'Statistiques';

  @override
  String get partnerDetailTitle => 'Profil partenaire';

  @override
  String get encountersTitle => 'Journal';

  @override
  String get encountersEmpty =>
      'Aucune rencontre enregistrée.\nVotre historique apparaîtra ici.';

  @override
  String get encountersAdd => 'Ajouter une rencontre';

  @override
  String get encounterDate => 'Date';

  @override
  String get encounterTime => 'Heure';

  @override
  String get encounterDuration => 'Durée';

  @override
  String get encounterPartner => 'Partenaire';

  @override
  String get encounterType => 'Type d\'événement';

  @override
  String get encounterTypeIntimate => 'Rencontre intime';

  @override
  String get encounterTypePersonal => 'Activité personnelle';

  @override
  String get encounterTypeCustom => 'Événement personnalisé';

  @override
  String get encounterNotes => 'Notes personnelles';

  @override
  String get encounterMoodBefore => 'Humeur avant';

  @override
  String get encounterMoodAfter => 'Humeur après';

  @override
  String get encounterProtection => 'Protection utilisée';

  @override
  String get encounterProtectionIssue => 'Problème de protection';

  @override
  String get encounterContraception => 'Contraception';

  @override
  String get encounterSymptoms => 'Symptômes ou observations';

  @override
  String get encounterTags => 'Étiquettes';

  @override
  String get encounterFollowUpReminder => 'Rappel de suivi';

  @override
  String get encounterDetail => 'Détail';

  @override
  String get encounterDeleteWarning => 'Supprimer cet enregistrement ?';

  @override
  String get cycleTitle => 'Mon cycle';

  @override
  String get cycleEmpty =>
      'Aucun cycle enregistré. Commencez par noter le premier jour de vos règles.';

  @override
  String get cycleLogPeriod => 'Enregistrer mes règles';

  @override
  String get cyclePeriodStart => 'Premier jour des règles';

  @override
  String get cyclePeriodEnd => 'Dernier jour des règles';

  @override
  String get cycleDuration => 'Durée du cycle';

  @override
  String get cyclePeriodDuration => 'Durée des règles';

  @override
  String get cycleAverage => 'Durée moyenne';

  @override
  String get cycleVariability => 'Variabilité';

  @override
  String get cycleNextEstimated => 'Règles estimées';

  @override
  String get cycleFertilityWindow => 'Période de fertilité potentielle';

  @override
  String get cycleOvulationEstimated => 'Ovulation estimée';

  @override
  String get cycleInsufficient =>
      'Estimation incertaine : données insuffisantes.';

  @override
  String get cycleDisclaimer =>
      'Le calendrier ne constitue pas une méthode contraceptive fiable à lui seul.';

  @override
  String get cycleSymptoms => 'Symptômes';

  @override
  String get cycleSymptomsAdd => 'Ajouter un symptôme';

  @override
  String get cycleFlowIntensity => 'Intensité des saignements';

  @override
  String get cycleFlowLight => 'Légère';

  @override
  String get cycleFlowMedium => 'Moyenne';

  @override
  String get cycleFlowHeavy => 'Abondante';

  @override
  String get cycleCramps => 'Crampes';

  @override
  String get cycleFatigue => 'Fatigue';

  @override
  String get cycleHeadache => 'Maux de tête';

  @override
  String get cycleMood => 'Humeur';

  @override
  String get cycleSleep => 'Sommeil';

  @override
  String get cycleObservations => 'Observations libres';

  @override
  String get cycleTreatment => 'Traitement / contraception';

  @override
  String get cycleHistoryTitle => 'Historique des cycles';

  @override
  String get cycleDetailsTitle => 'Détail du cycle';

  @override
  String get calendarTitle => 'Calendrier';

  @override
  String get calendarLegendPeriod => 'Règles';

  @override
  String get calendarLegendEstimated => 'Règles prévues';

  @override
  String get calendarLegendFertile => 'Période fertile';

  @override
  String get calendarLegendOvulation => 'Ovulation estimée';

  @override
  String get calendarLegendEncounter => 'Rencontre';

  @override
  String get calendarLegendSymptom => 'Symptôme';

  @override
  String get remindersTitle => 'Rappels';

  @override
  String get remindersEmpty => 'Aucun rappel configuré.';

  @override
  String get remindersAdd => 'Créer un rappel';

  @override
  String get reminderTitle => 'Titre';

  @override
  String get reminderDescription => 'Description';

  @override
  String get reminderDate => 'Date';

  @override
  String get reminderTime => 'Heure';

  @override
  String get reminderFrequency => 'Fréquence';

  @override
  String get reminderFrequencyOnce => 'Une fois';

  @override
  String get reminderFrequencyDaily => 'Quotidien';

  @override
  String get reminderFrequencyWeekly => 'Hebdomadaire';

  @override
  String get reminderFrequencyMonthly => 'Mensuel';

  @override
  String get reminderEndDate => 'Date de fin';

  @override
  String get reminderCategory => 'Catégorie';

  @override
  String get reminderCategoryPersonal => 'Personnel';

  @override
  String get reminderCategoryCycle => 'Cycle';

  @override
  String get reminderCategoryHealth => 'Santé';

  @override
  String get reminderCategoryMedical => 'Médical';

  @override
  String get reminderDiscretion => 'Niveau de discrétion';

  @override
  String get reminderDiscretionDiscreet => 'Discret';

  @override
  String get reminderDiscretionCustom => 'Personnalisé';

  @override
  String get reminderDiscretionDetailed => 'Détaillé';

  @override
  String get reminderActive => 'Actif';

  @override
  String get reminderSnooze => 'Reporter';

  @override
  String get reminderDelete => 'Supprimer le rappel';

  @override
  String get statsTitle => 'Statistiques';

  @override
  String get statsRelational => 'Relations';

  @override
  String get statsMenstrual => 'Cycles';

  @override
  String get statsPeriodMonth => 'Mois';

  @override
  String get statsPeriodQuarter => 'Trimestre';

  @override
  String get statsPeriodYear => 'Année';

  @override
  String get statsEncountersTotal => 'Total des rencontres';

  @override
  String get statsEncountersPerMonth => 'Rencontres par mois';

  @override
  String get statsByPartner => 'Par partenaire';

  @override
  String get statsByType => 'Par type';

  @override
  String get statsAvgCycleDuration => 'Durée moyenne du cycle';

  @override
  String get statsAvgPeriodDuration => 'Durée moyenne des règles';

  @override
  String get statsVariability => 'Variabilité des cycles';

  @override
  String get statsNoDataSufficient =>
      'Données insuffisantes pour afficher cette statistique.';

  @override
  String get statsMethodExplanation => 'Méthode de calcul';

  @override
  String get privacyTitle => 'Confidentialité';

  @override
  String get privacyPinChange => 'Modifier le code PIN';

  @override
  String get privacyBiometric => 'Biométrie';

  @override
  String get privacyBiometricEnable => 'Activer la biométrie';

  @override
  String get privacyAutoLock => 'Verrouillage automatique';

  @override
  String get privacyAutoLockImmediate => 'Immédiat';

  @override
  String get privacyAutoLock30s => '30 secondes';

  @override
  String get privacyAutoLock1m => '1 minute';

  @override
  String get privacyAutoLock5m => '5 minutes';

  @override
  String get privacyAutoLock10m => '10 minutes';

  @override
  String get privacyScreenProtection => 'Protection de l\'écran';

  @override
  String get privacyHideInRecents =>
      'Masquer dans le sélecteur d\'applications';

  @override
  String get privacyDiscreetMode => 'Mode discret';

  @override
  String get privacyDiscreetModeDesc =>
      'Remplace les informations sensibles par des libellés génériques.';

  @override
  String get privacyDataManagement => 'Gestion des données';

  @override
  String get privacyExportData => 'Exporter les données';

  @override
  String get privacyImportData => 'Importer une sauvegarde';

  @override
  String get privacyDeleteCategory => 'Supprimer une catégorie';

  @override
  String get privacyDeleteAll => 'Effacer toutes les données';

  @override
  String get privacyDeleteAllWarning =>
      'Cette action supprimera définitivement toutes vos données. Elle est irréversible.';

  @override
  String get privacyDeleteAllConfirm =>
      'Je confirme vouloir effacer toutes mes données.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsDateFormat => 'Format de date';

  @override
  String get settingsWeekStart => 'Premier jour de la semaine';

  @override
  String get settingsWeekStartMonday => 'Lundi';

  @override
  String get settingsWeekStartSunday => 'Dimanche';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get settingsHelp => 'Aide';

  @override
  String get backupTitle => 'Sauvegarde et restauration';

  @override
  String get backupExport => 'Créer une sauvegarde chiffrée';

  @override
  String get backupImport => 'Restaurer depuis une sauvegarde';

  @override
  String get backupExportDesc =>
      'La sauvegarde sera chiffrée avec votre clé. Conservez-la en lieu sûr.';

  @override
  String get backupImportDesc =>
      'Sélectionnez un fichier de sauvegarde Intima (.enc). Vos données actuelles seront remplacées.';

  @override
  String get backupImportWarning =>
      'La restauration remplacera toutes vos données actuelles. Cette action est irréversible.';

  @override
  String get backupImportConfirm => 'Je comprends et je souhaite restaurer.';

  @override
  String get backupIntegrityError =>
      'Le fichier de sauvegarde est corrompu ou invalide.';

  @override
  String get backupSuccess => 'Sauvegarde créée avec succès.';

  @override
  String get backupRestoreSuccess => 'Données restaurées avec succès.';

  @override
  String get backupExportNote =>
      'Une exportation vers un emplacement externe peut sortir du périmètre de protection de l\'application.';

  @override
  String get helpTitle => 'Aide et informations';

  @override
  String get helpCyclePhases => 'Les phases du cycle menstruel';

  @override
  String get helpCyclePhasesBody =>
      'Le cycle menstruel comprend 4 phases principales :\n\n1. Phase menstruelle (jours 1 à 5) : Décollement et évacuation de la muqueuse utérine (endomètre) en l\'absence de nidation.\n2. Phase folliculaire (jours 1 à 13) : Maturation d\'un follicule sous l\'influence de la FSH et montée progressive des œstrogènes.\n3. Ovulation (environ jour 14 pour un cycle régulier de 28 jours) : Libération de l\'ovocyte mature déclenchée par un pic d\'hormone lutéinisante (LH).\n4. Phase lutéale (jours 15 à 28) : Le corps jaune résiduel sécrète de la progestérone pour préparer une éventuelle grossesse. En l\'absence de fécondation, le corps jaune dégénère, les taux d\'hormones chutent et déclenchent le cycle suivant.';

  @override
  String get helpPeriodVsOvulationTitle =>
      'Différence entre règles et ovulation';

  @override
  String get helpPeriodVsOvulationBody =>
      'Les règles correspondent à l\'élimination de la muqueuse utérine devenue inutile lorsque la fécondation n\'a pas eu lieu. Elles marquent le tout premier jour d\'un nouveau cycle.\n\nL\'ovulation, quant à elle, a lieu en milieu de cycle : un ovaire libère un ovocyte prêt à être fécondé. Confondre règles et ovulation est fréquent, mais ce sont deux événements biologiques distincts séparés par plusieurs jours.';

  @override
  String get helpFertility => 'La fertilité et ses variations';

  @override
  String get helpFertilityBody =>
      'La fenêtre de fertilité physiologique s\'étend sur environ 6 jours par cycle :\n\n• Les 5 jours précédant l\'ovulation : les spermatozoïdes peuvent survivre jusqu\'à 5 jours dans les voies génitales féminines grâce à la glaire cervicale fertile.\n• Le jour de l\'ovulation et les 24 heures suivantes : durée de vie de l\'ovocyte non fécondé.\n\nLa fertilité varie grandement d\'un cycle à l\'autre et au cours de la vie.';

  @override
  String get helpCycleVariationsTitle => 'Pourquoi la durée des cycles varie';

  @override
  String get helpCycleVariationsBody =>
      'Une variation de quelques jours d\'un cycle à l\'autre est tout à fait physiologique et fréquente.\n\nLes facteurs courants influençant la durée incluent :\n• Le stress physique ou émotionnel aigu.\n• Les troubles du sommeil ou le décalage horaire.\n• Les variations de poids ou d\'alimentation.\n• Les changements de contraception ou l\'arrêt récent de contraceptifs hormonaux.\n• Des états médicaux sous-jacents (SOPK, troubles thyroïdiens).';

  @override
  String get helpPredictionLimitsTitle =>
      'Limites des prédictions de l\'application';

  @override
  String get helpPredictionLimitsBody =>
      'IMPORTANT : Les prédictions d\'Intima sont des estimations statistiques basées sur l\'historique de vos données passées.\n\nElles ne constituent en aucun cas une garantie biologique ni une méthode de contraception fiable à elles seules. Aucun algorithme ne peut prédire avec certitude le jour exact d\'une ovulation future. Ne jamais se baser sur ce calendrier pour avoir un rapport sans contraception si une grossesse n\'est pas désirée.';

  @override
  String get helpContraception => 'Les méthodes de contraception';

  @override
  String get helpContraceptionBody =>
      'Il existe différentes méthodes adaptées aux besoins de chacun(e) :\n\n• Contraception hormonale : pilule combinée ou progestative, implant sous-cutané, patch transdermique, anneau vaginal, DIU hormonal (stérilet).\n• Contraception non hormonale : DIU au cuivre (action spermicide mécanique), préservatifs, diaphragme avec gel spermicide.\n• Contraception d\'urgence : pilule du lendemain (lévonorgestrel ou ulipristal) ou pose rapide d\'un DIU cuivre.\n\nDiscutez avec votre médecin ou sage-femme pour choisir la méthode la plus adaptée à votre profil.';

  @override
  String get helpSTI => 'Prévention de grossesse vs prévention des IST';

  @override
  String get helpSTIBody =>
      'Attention : La contraception hormonale (pilule, implant, stérilet) empêche la grossesse mais ne protège AUCUNEMENT contre les Infections Sexuellement Transmissibles (IST/VIH).\n\nSeuls les préservatifs (externes ou internes) offrent une barrière protectrice efficace contre les IST.\nUn dépistage régulier est vivement recommandé avec vos partenaires, en laboratoire d\'analyses, chez votre médecin ou dans un CeGIDD gratuit et anonyme.';

  @override
  String get helpWhenToSeeDoctor => 'Quand consulter un professionnel de santé';

  @override
  String get helpWhenToSeeDoctorBody =>
      'Une consultation médicale rapide (médecin traitant, gynécologue, sage-femme ou urgences) est nécessaire en cas de :\n\n• Douleurs pelviennes aiguës ou très violentes non soulagées par les antalgiques habituels.\n• Saignements très abondants (plusieurs serviettes saturées par heure pendant plusieurs heures consécutives) ou vertiges.\n• Saignements anormaux après un rapport ou en dehors des périodes de règles.\n• Pertes vaginales anormales (couleur inhabituelle, odeur forte, démangeaisons, brûlures).\n• Fièvre associée à des douleurs pelviennes ou des pertes anormales.\n• Retard de règles inexpliqué avec risque de grossesse.';

  @override
  String get helpDisclaimerTitle => 'Information médicale éducative';

  @override
  String get helpDisclaimerBody =>
      'Les informations fournies dans cette application sont strictement éducatives et préventives. Elles ne remplacent en aucun cas une consultation médicale, un diagnostic clinique ou un avis de professionnel de santé.';

  @override
  String get aboutTitle => 'À propos d\'Intima';

  @override
  String get aboutPrivacyTitle => 'Vos données, votre vie privée';

  @override
  String get aboutPrivacyBody =>
      'Intima ne collecte aucune donnée personnelle. Aucun compte n\'est requis. Aucune donnée n\'est transmise sur Internet. Tout reste sur votre appareil.';

  @override
  String get onboardingGoalsTitle => 'Quels sont vos objectifs ?';

  @override
  String get onboardingGoalsSubtitle =>
      'Sélectionnez vos attentes pour adapter au mieux votre expérience.';

  @override
  String get goalCycle => 'Suivre mon cycle & prédire mes règles';

  @override
  String get goalIntimacy => 'Suivre mes rapports & ma vie intime';

  @override
  String get goalSymptoms => 'Comprendre mes symptômes & signaux du corps';

  @override
  String get goalFertility => 'Estimer ma fertilité & concevoir';

  @override
  String get goalJournal => 'Journal intime privé & bien-être personnel';

  @override
  String get onboardingAboutYouTitle => 'Faisons connaissance';

  @override
  String get onboardingAboutYouSubtitle =>
      'Ces informations facultatives restent stockées exclusivement sur votre téléphone.';

  @override
  String get onboardingNameLabel => 'Votre prénom ou pseudo';

  @override
  String get onboardingNameHint =>
      'Comment souhaitez-vous qu\'on vous appelle ?';

  @override
  String get onboardingBirthYearLabel => 'Année de naissance';

  @override
  String get onboardingBirthYearHint => 'Ex: 1998 (facultatif)';

  @override
  String get onboardingGenderLabel => 'Votre profil / genre';

  @override
  String get onboardingDiscoveryTitle => 'Comment nous avez-vous découverts ?';

  @override
  String get onboardingDiscoverySubtitle =>
      'Aidez-nous à savoir ce qui vous a guidé(e) vers Intima.';

  @override
  String get discoveryStore => 'Recherche App Store / Play Store';

  @override
  String get discoveryFriend => 'Recommandation d\'un(e) ami(e) ou partenaire';

  @override
  String get discoverySocial => 'Réseaux sociaux ou Internet';

  @override
  String get discoveryHealth => 'Professionnel de santé / médecin';

  @override
  String get discoveryOther => 'Autre moyen';

  @override
  String get onboardingTermsTitle =>
      'Engagement Zéro Serveur & Confidentialité';

  @override
  String get onboardingTermsSubtitle =>
      'La promesse sacrée d\'Intima : aucune donnée ne quitte votre appareil.';

  @override
  String get onboardingTermsAccept =>
      'J\'accepte la politique de confidentialité locale et l\'utilisation chiffrée sur mon téléphone.';

  @override
  String get onboardingTermsViewFull =>
      'Consulter la politique de confidentialité complète';

  @override
  String get notificationCenterTitle => 'Centre de notifications';

  @override
  String get notificationCenterSubtitle =>
      'Gérez vos rappels programmés et leur niveau de discrétion.';

  @override
  String get notificationMasterToggle => 'Activer les notifications locales';

  @override
  String get notificationMasterDesc =>
      'Programmer des rappels sur cet appareil (sans passer par Internet)';

  @override
  String get notificationDiscretionTitle => 'Niveau de discrétion';

  @override
  String get notificationDiscretionDesc =>
      'Format d\'affichage des alertes sur votre écran verrouillé';

  @override
  String get notificationDiscretion0 => 'Discret (ex: \'Rappel personnel\')';

  @override
  String get notificationDiscretion1 =>
      'Neutre (ex: \'Intima : un rappel prévu\')';

  @override
  String get notificationDiscretion2 => 'Détaillé (titre exact)';

  @override
  String get notificationPeriodTitle => 'Alerte de règles à venir';

  @override
  String get notificationPeriodDesc =>
      'Notification préventive avant la date estimée de début';

  @override
  String notificationPeriodDays(int days) {
    return '$days jours avant';
  }

  @override
  String get notificationPillTitle => 'Rappel de pilule ou contraception';

  @override
  String get notificationPillDesc => 'Rappel quotidien à une heure fixe';

  @override
  String get notificationCheckinTitle => 'Rappel de journal du soir';

  @override
  String get notificationCheckinDesc =>
      'Invitation discrète à noter vos ressentis de la journée';

  @override
  String get notificationTestButton => 'Tester une notification maintenant';

  @override
  String get notificationTestSuccess =>
      'Notification test programmée avec succès !';

  @override
  String get notificationPermissionWarning =>
      'Veuillez autoriser les notifications dans les paramètres Android.';
}
