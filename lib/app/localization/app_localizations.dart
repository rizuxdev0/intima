import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'Intima'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In fr, this message translates to:
  /// **'Votre espace privé'**
  String get appTagline;

  /// No description provided for @commonSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get commonEdit;

  /// No description provided for @commonClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonClose;

  /// No description provided for @commonConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get commonConfirm;

  /// No description provided for @commonBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get commonNext;

  /// No description provided for @commonSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get commonSkip;

  /// No description provided for @commonDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get commonDone;

  /// No description provided for @commonYes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get commonNo;

  /// No description provided for @commonOk.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get commonSearch;

  /// No description provided for @commonFilter.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer'**
  String get commonFilter;

  /// No description provided for @commonAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get commonAdd;

  /// No description provided for @commonArchive.
  ///
  /// In fr, this message translates to:
  /// **'Archiver'**
  String get commonArchive;

  /// No description provided for @commonRestore.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer'**
  String get commonRestore;

  /// No description provided for @commonLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get commonLoading;

  /// No description provided for @commonRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonRetry;

  /// No description provided for @commonError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Succès'**
  String get commonSuccess;

  /// No description provided for @commonWarning.
  ///
  /// In fr, this message translates to:
  /// **'Attention'**
  String get commonWarning;

  /// No description provided for @commonOptional.
  ///
  /// In fr, this message translates to:
  /// **'Facultatif'**
  String get commonOptional;

  /// No description provided for @commonRequired.
  ///
  /// In fr, this message translates to:
  /// **'Requis'**
  String get commonRequired;

  /// No description provided for @commonUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Inconnu'**
  String get commonUnknown;

  /// No description provided for @commonAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get commonAll;

  /// No description provided for @commonNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get commonNone;

  /// No description provided for @commonPersonalEvent.
  ///
  /// In fr, this message translates to:
  /// **'Événement personnel'**
  String get commonPersonalEvent;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navPartners.
  ///
  /// In fr, this message translates to:
  /// **'Partenaires'**
  String get navPartners;

  /// No description provided for @navCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier'**
  String get navCalendar;

  /// No description provided for @navInsights.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get navInsights;

  /// No description provided for @navMore.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get navMore;

  /// No description provided for @toastSaved.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement effectué.'**
  String get toastSaved;

  /// No description provided for @toastChangesSaved.
  ///
  /// In fr, this message translates to:
  /// **'Modifications enregistrées.'**
  String get toastChangesSaved;

  /// No description provided for @toastReminderScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Rappel programmé.'**
  String get toastReminderScheduled;

  /// No description provided for @toastDataUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Les données ont été mises à jour.'**
  String get toastDataUpdated;

  /// No description provided for @toastError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessaie.'**
  String get toastError;

  /// No description provided for @toastIncorrectPin.
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect.'**
  String get toastIncorrectPin;

  /// No description provided for @toastBackupCreated.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde chiffrée créée.'**
  String get toastBackupCreated;

  /// No description provided for @toastNoData.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée disponible pour cette période.'**
  String get toastNoData;

  /// No description provided for @toastDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Élément supprimé.'**
  String get toastDeleted;

  /// No description provided for @toastRestored.
  ///
  /// In fr, this message translates to:
  /// **'Élément restauré.'**
  String get toastRestored;

  /// No description provided for @toastArchived.
  ///
  /// In fr, this message translates to:
  /// **'Élément archivé.'**
  String get toastArchived;

  /// No description provided for @toastCopied.
  ///
  /// In fr, this message translates to:
  /// **'Copié.'**
  String get toastCopied;

  /// No description provided for @splashTagline.
  ///
  /// In fr, this message translates to:
  /// **'Votre espace intime, privé et sécurisé.'**
  String get splashTagline;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue dans Intima'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre espace personnel, privé et sécurisé. Aucun compte requis. Aucune donnée partagée.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingLanguageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre langue'**
  String get onboardingLanguageTitle;

  /// No description provided for @onboardingLanguageSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vous pourrez modifier ce choix dans les paramètres.'**
  String get onboardingLanguageSubtitle;

  /// No description provided for @onboardingProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comment souhaitez-vous utiliser Intima ?'**
  String get onboardingProfileTitle;

  /// No description provided for @onboardingProfileSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce choix personnalise votre tableau de bord. Vous pouvez le modifier à tout moment.'**
  String get onboardingProfileSubtitle;

  /// No description provided for @onboardingProfilePersonal.
  ///
  /// In fr, this message translates to:
  /// **'Suivi personnel'**
  String get onboardingProfilePersonal;

  /// No description provided for @onboardingProfileRelationships.
  ///
  /// In fr, this message translates to:
  /// **'Suivi de mes relations'**
  String get onboardingProfileRelationships;

  /// No description provided for @onboardingProfileMenstrual.
  ///
  /// In fr, this message translates to:
  /// **'Suivi de ma santé menstruelle'**
  String get onboardingProfileMenstrual;

  /// No description provided for @onboardingProfileFull.
  ///
  /// In fr, this message translates to:
  /// **'Mode complet'**
  String get onboardingProfileFull;

  /// No description provided for @onboardingSecurityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Protégez votre espace'**
  String get onboardingSecurityTitle;

  /// No description provided for @onboardingSecuritySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez un code PIN pour sécuriser l\'accès à l\'application.'**
  String get onboardingSecuritySubtitle;

  /// No description provided for @onboardingPreferencesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos préférences'**
  String get onboardingPreferencesTitle;

  /// No description provided for @onboardingConsentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos données restent sur votre appareil'**
  String get onboardingConsentTitle;

  /// No description provided for @onboardingConsentBody.
  ///
  /// In fr, this message translates to:
  /// **'Intima ne transmet aucune donnée intime sur Internet. Vos informations sont chiffrées et stockées uniquement sur votre téléphone. Vous pouvez exporter ou supprimer vos données à tout moment.'**
  String get onboardingConsentBody;

  /// No description provided for @onboardingConsentNote.
  ///
  /// In fr, this message translates to:
  /// **'Note : les sauvegardes système du téléphone (Google Drive, iCloud) peuvent inclure les données de l\'application selon votre configuration.'**
  String get onboardingConsentNote;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get onboardingGetStarted;

  /// No description provided for @pinCreateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer votre code PIN'**
  String get pinCreateTitle;

  /// No description provided for @pinCreateSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un code PIN à 6 chiffres pour protéger l\'accès.'**
  String get pinCreateSubtitle;

  /// No description provided for @pinConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer votre code PIN'**
  String get pinConfirmTitle;

  /// No description provided for @pinConfirmSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez à nouveau votre code PIN pour confirmer.'**
  String get pinConfirmSubtitle;

  /// No description provided for @pinEnterTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déverrouiller Intima'**
  String get pinEnterTitle;

  /// No description provided for @pinEnterSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre code PIN.'**
  String get pinEnterSubtitle;

  /// No description provided for @pinMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les codes PIN ne correspondent pas. Réessayez.'**
  String get pinMismatch;

  /// No description provided for @pinTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le code PIN doit comporter 6 chiffres.'**
  String get pinTooShort;

  /// No description provided for @pinIncorrect.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN incorrect.'**
  String get pinIncorrect;

  /// No description provided for @pinAttemptsRemaining.
  ///
  /// In fr, this message translates to:
  /// **'{count} tentative(s) restante(s).'**
  String pinAttemptsRemaining(int count);

  /// No description provided for @pinLockedOut.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives. Réessayez dans {seconds} secondes.'**
  String pinLockedOut(int seconds);

  /// No description provided for @pinForgot.
  ///
  /// In fr, this message translates to:
  /// **'Code oublié ?'**
  String get pinForgot;

  /// No description provided for @pinBiometricPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Déverrouillez avec votre empreinte ou Face ID.'**
  String get pinBiometricPrompt;

  /// No description provided for @pinUseBiometric.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser la biométrie'**
  String get pinUseBiometric;

  /// No description provided for @pinUsePIN.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser le code PIN'**
  String get pinUsePIN;

  /// No description provided for @dashboardGoodMorning.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get dashboardGoodMorning;

  /// No description provided for @dashboardGoodAfternoon.
  ///
  /// In fr, this message translates to:
  /// **'Bon après-midi'**
  String get dashboardGoodAfternoon;

  /// No description provided for @dashboardGoodEvening.
  ///
  /// In fr, this message translates to:
  /// **'Bonsoir'**
  String get dashboardGoodEvening;

  /// No description provided for @dashboardSummaryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Résumé du mois'**
  String get dashboardSummaryTitle;

  /// No description provided for @dashboardNoData.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée enregistrée ce mois.'**
  String get dashboardNoData;

  /// No description provided for @dashboardEncountersCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} rencontre(s) ce mois'**
  String dashboardEncountersCount(int count);

  /// No description provided for @dashboardNextReminder.
  ///
  /// In fr, this message translates to:
  /// **'Prochain rappel'**
  String get dashboardNextReminder;

  /// No description provided for @dashboardNoReminders.
  ///
  /// In fr, this message translates to:
  /// **'Aucun rappel à venir.'**
  String get dashboardNoReminders;

  /// No description provided for @dashboardCycleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon cycle'**
  String get dashboardCycleTitle;

  /// No description provided for @dashboardCycleNotEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Suivi du cycle non activé.'**
  String get dashboardCycleNotEnabled;

  /// No description provided for @dashboardQuickAdd.
  ///
  /// In fr, this message translates to:
  /// **'Action rapide'**
  String get dashboardQuickAdd;

  /// No description provided for @dashboardAddEncounter.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une rencontre'**
  String get dashboardAddEncounter;

  /// No description provided for @dashboardAddPartner.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un partenaire'**
  String get dashboardAddPartner;

  /// No description provided for @dashboardLogPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer mes règles'**
  String get dashboardLogPeriod;

  /// No description provided for @dashboardLogSymptom.
  ///
  /// In fr, this message translates to:
  /// **'Noter un symptôme'**
  String get dashboardLogSymptom;

  /// No description provided for @dashboardAddReminder.
  ///
  /// In fr, this message translates to:
  /// **'Créer un rappel'**
  String get dashboardAddReminder;

  /// No description provided for @dashboardOpenCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Voir le calendrier'**
  String get dashboardOpenCalendar;

  /// No description provided for @partnersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Partenaires'**
  String get partnersTitle;

  /// No description provided for @partnersEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun partenaire enregistré.\nAppuyez sur + pour en ajouter un.'**
  String get partnersEmpty;

  /// No description provided for @partnersAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un partenaire'**
  String get partnersAdd;

  /// No description provided for @partnerName.
  ///
  /// In fr, this message translates to:
  /// **'Nom ou surnom'**
  String get partnerName;

  /// No description provided for @partnerNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Pseudonyme, prénom ou surnom'**
  String get partnerNameHint;

  /// No description provided for @partnerColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get partnerColor;

  /// No description provided for @partnerFirstMet.
  ///
  /// In fr, this message translates to:
  /// **'Date de première rencontre'**
  String get partnerFirstMet;

  /// No description provided for @partnerNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes personnelles'**
  String get partnerNotes;

  /// No description provided for @partnerTags.
  ///
  /// In fr, this message translates to:
  /// **'Étiquettes'**
  String get partnerTags;

  /// No description provided for @partnerArchived.
  ///
  /// In fr, this message translates to:
  /// **'Archivé'**
  String get partnerArchived;

  /// No description provided for @partnerShowArchived.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les archivés'**
  String get partnerShowArchived;

  /// No description provided for @partnerDeleteWarning.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce partenaire effacera également les rencontres et données associées. Cette action est irréversible.'**
  String get partnerDeleteWarning;

  /// No description provided for @partnerDeleteKeepData.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la fiche (conserver les rencontres anonymisées)'**
  String get partnerDeleteKeepData;

  /// No description provided for @partnerDeleteAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout supprimer (fiche + rencontres)'**
  String get partnerDeleteAll;

  /// No description provided for @partnerEncounters.
  ///
  /// In fr, this message translates to:
  /// **'Rencontres associées'**
  String get partnerEncounters;

  /// No description provided for @partnerNoEncounters.
  ///
  /// In fr, this message translates to:
  /// **'Aucune rencontre enregistrée.'**
  String get partnerNoEncounters;

  /// No description provided for @partnerStats.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get partnerStats;

  /// No description provided for @partnerDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil partenaire'**
  String get partnerDetailTitle;

  /// No description provided for @encountersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Journal'**
  String get encountersTitle;

  /// No description provided for @encountersEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune rencontre enregistrée.\nVotre historique apparaîtra ici.'**
  String get encountersEmpty;

  /// No description provided for @encountersAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une rencontre'**
  String get encountersAdd;

  /// No description provided for @encounterDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get encounterDate;

  /// No description provided for @encounterTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure'**
  String get encounterTime;

  /// No description provided for @encounterDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée'**
  String get encounterDuration;

  /// No description provided for @encounterPartner.
  ///
  /// In fr, this message translates to:
  /// **'Partenaire'**
  String get encounterPartner;

  /// No description provided for @encounterType.
  ///
  /// In fr, this message translates to:
  /// **'Type d\'événement'**
  String get encounterType;

  /// No description provided for @encounterTypeIntimate.
  ///
  /// In fr, this message translates to:
  /// **'Rencontre intime'**
  String get encounterTypeIntimate;

  /// No description provided for @encounterTypePersonal.
  ///
  /// In fr, this message translates to:
  /// **'Activité personnelle'**
  String get encounterTypePersonal;

  /// No description provided for @encounterTypeCustom.
  ///
  /// In fr, this message translates to:
  /// **'Événement personnalisé'**
  String get encounterTypeCustom;

  /// No description provided for @encounterNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes personnelles'**
  String get encounterNotes;

  /// No description provided for @encounterMoodBefore.
  ///
  /// In fr, this message translates to:
  /// **'Humeur avant'**
  String get encounterMoodBefore;

  /// No description provided for @encounterMoodAfter.
  ///
  /// In fr, this message translates to:
  /// **'Humeur après'**
  String get encounterMoodAfter;

  /// No description provided for @encounterProtection.
  ///
  /// In fr, this message translates to:
  /// **'Protection utilisée'**
  String get encounterProtection;

  /// No description provided for @encounterProtectionIssue.
  ///
  /// In fr, this message translates to:
  /// **'Problème de protection'**
  String get encounterProtectionIssue;

  /// No description provided for @encounterContraception.
  ///
  /// In fr, this message translates to:
  /// **'Contraception'**
  String get encounterContraception;

  /// No description provided for @encounterSymptoms.
  ///
  /// In fr, this message translates to:
  /// **'Symptômes ou observations'**
  String get encounterSymptoms;

  /// No description provided for @encounterTags.
  ///
  /// In fr, this message translates to:
  /// **'Étiquettes'**
  String get encounterTags;

  /// No description provided for @encounterFollowUpReminder.
  ///
  /// In fr, this message translates to:
  /// **'Rappel de suivi'**
  String get encounterFollowUpReminder;

  /// No description provided for @encounterDetail.
  ///
  /// In fr, this message translates to:
  /// **'Détail'**
  String get encounterDetail;

  /// No description provided for @encounterDeleteWarning.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cet enregistrement ?'**
  String get encounterDeleteWarning;

  /// No description provided for @cycleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon cycle'**
  String get cycleTitle;

  /// No description provided for @cycleEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun cycle enregistré. Commencez par noter le premier jour de vos règles.'**
  String get cycleEmpty;

  /// No description provided for @cycleLogPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer mes règles'**
  String get cycleLogPeriod;

  /// No description provided for @cyclePeriodStart.
  ///
  /// In fr, this message translates to:
  /// **'Premier jour des règles'**
  String get cyclePeriodStart;

  /// No description provided for @cyclePeriodEnd.
  ///
  /// In fr, this message translates to:
  /// **'Dernier jour des règles'**
  String get cyclePeriodEnd;

  /// No description provided for @cycleDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée du cycle'**
  String get cycleDuration;

  /// No description provided for @cyclePeriodDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée des règles'**
  String get cyclePeriodDuration;

  /// No description provided for @cycleAverage.
  ///
  /// In fr, this message translates to:
  /// **'Durée moyenne'**
  String get cycleAverage;

  /// No description provided for @cycleVariability.
  ///
  /// In fr, this message translates to:
  /// **'Variabilité'**
  String get cycleVariability;

  /// No description provided for @cycleNextEstimated.
  ///
  /// In fr, this message translates to:
  /// **'Règles estimées'**
  String get cycleNextEstimated;

  /// No description provided for @cycleFertilityWindow.
  ///
  /// In fr, this message translates to:
  /// **'Période de fertilité potentielle'**
  String get cycleFertilityWindow;

  /// No description provided for @cycleOvulationEstimated.
  ///
  /// In fr, this message translates to:
  /// **'Ovulation estimée'**
  String get cycleOvulationEstimated;

  /// No description provided for @cycleInsufficient.
  ///
  /// In fr, this message translates to:
  /// **'Estimation incertaine : données insuffisantes.'**
  String get cycleInsufficient;

  /// No description provided for @cycleDisclaimer.
  ///
  /// In fr, this message translates to:
  /// **'Le calendrier ne constitue pas une méthode contraceptive fiable à lui seul.'**
  String get cycleDisclaimer;

  /// No description provided for @cycleSymptoms.
  ///
  /// In fr, this message translates to:
  /// **'Symptômes'**
  String get cycleSymptoms;

  /// No description provided for @cycleSymptomsAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un symptôme'**
  String get cycleSymptomsAdd;

  /// No description provided for @cycleFlowIntensity.
  ///
  /// In fr, this message translates to:
  /// **'Intensité des saignements'**
  String get cycleFlowIntensity;

  /// No description provided for @cycleFlowLight.
  ///
  /// In fr, this message translates to:
  /// **'Légère'**
  String get cycleFlowLight;

  /// No description provided for @cycleFlowMedium.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne'**
  String get cycleFlowMedium;

  /// No description provided for @cycleFlowHeavy.
  ///
  /// In fr, this message translates to:
  /// **'Abondante'**
  String get cycleFlowHeavy;

  /// No description provided for @cycleCramps.
  ///
  /// In fr, this message translates to:
  /// **'Crampes'**
  String get cycleCramps;

  /// No description provided for @cycleFatigue.
  ///
  /// In fr, this message translates to:
  /// **'Fatigue'**
  String get cycleFatigue;

  /// No description provided for @cycleHeadache.
  ///
  /// In fr, this message translates to:
  /// **'Maux de tête'**
  String get cycleHeadache;

  /// No description provided for @cycleMood.
  ///
  /// In fr, this message translates to:
  /// **'Humeur'**
  String get cycleMood;

  /// No description provided for @cycleSleep.
  ///
  /// In fr, this message translates to:
  /// **'Sommeil'**
  String get cycleSleep;

  /// No description provided for @cycleObservations.
  ///
  /// In fr, this message translates to:
  /// **'Observations libres'**
  String get cycleObservations;

  /// No description provided for @cycleTreatment.
  ///
  /// In fr, this message translates to:
  /// **'Traitement / contraception'**
  String get cycleTreatment;

  /// No description provided for @cycleHistoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique des cycles'**
  String get cycleHistoryTitle;

  /// No description provided for @cycleDetailsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Détail du cycle'**
  String get cycleDetailsTitle;

  /// No description provided for @calendarTitle.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier'**
  String get calendarTitle;

  /// No description provided for @calendarLegendPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Règles'**
  String get calendarLegendPeriod;

  /// No description provided for @calendarLegendEstimated.
  ///
  /// In fr, this message translates to:
  /// **'Règles prévues'**
  String get calendarLegendEstimated;

  /// No description provided for @calendarLegendFertile.
  ///
  /// In fr, this message translates to:
  /// **'Période fertile'**
  String get calendarLegendFertile;

  /// No description provided for @calendarLegendOvulation.
  ///
  /// In fr, this message translates to:
  /// **'Ovulation estimée'**
  String get calendarLegendOvulation;

  /// No description provided for @calendarLegendEncounter.
  ///
  /// In fr, this message translates to:
  /// **'Rencontre'**
  String get calendarLegendEncounter;

  /// No description provided for @calendarLegendSymptom.
  ///
  /// In fr, this message translates to:
  /// **'Symptôme'**
  String get calendarLegendSymptom;

  /// No description provided for @remindersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rappels'**
  String get remindersTitle;

  /// No description provided for @remindersEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun rappel configuré.'**
  String get remindersEmpty;

  /// No description provided for @remindersAdd.
  ///
  /// In fr, this message translates to:
  /// **'Créer un rappel'**
  String get remindersAdd;

  /// No description provided for @reminderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get reminderTitle;

  /// No description provided for @reminderDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get reminderDescription;

  /// No description provided for @reminderDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get reminderDate;

  /// No description provided for @reminderTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure'**
  String get reminderTime;

  /// No description provided for @reminderFrequency.
  ///
  /// In fr, this message translates to:
  /// **'Fréquence'**
  String get reminderFrequency;

  /// No description provided for @reminderFrequencyOnce.
  ///
  /// In fr, this message translates to:
  /// **'Une fois'**
  String get reminderFrequencyOnce;

  /// No description provided for @reminderFrequencyDaily.
  ///
  /// In fr, this message translates to:
  /// **'Quotidien'**
  String get reminderFrequencyDaily;

  /// No description provided for @reminderFrequencyWeekly.
  ///
  /// In fr, this message translates to:
  /// **'Hebdomadaire'**
  String get reminderFrequencyWeekly;

  /// No description provided for @reminderFrequencyMonthly.
  ///
  /// In fr, this message translates to:
  /// **'Mensuel'**
  String get reminderFrequencyMonthly;

  /// No description provided for @reminderEndDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de fin'**
  String get reminderEndDate;

  /// No description provided for @reminderCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get reminderCategory;

  /// No description provided for @reminderCategoryPersonal.
  ///
  /// In fr, this message translates to:
  /// **'Personnel'**
  String get reminderCategoryPersonal;

  /// No description provided for @reminderCategoryCycle.
  ///
  /// In fr, this message translates to:
  /// **'Cycle'**
  String get reminderCategoryCycle;

  /// No description provided for @reminderCategoryHealth.
  ///
  /// In fr, this message translates to:
  /// **'Santé'**
  String get reminderCategoryHealth;

  /// No description provided for @reminderCategoryMedical.
  ///
  /// In fr, this message translates to:
  /// **'Médical'**
  String get reminderCategoryMedical;

  /// No description provided for @reminderDiscretion.
  ///
  /// In fr, this message translates to:
  /// **'Niveau de discrétion'**
  String get reminderDiscretion;

  /// No description provided for @reminderDiscretionDiscreet.
  ///
  /// In fr, this message translates to:
  /// **'Discret'**
  String get reminderDiscretionDiscreet;

  /// No description provided for @reminderDiscretionCustom.
  ///
  /// In fr, this message translates to:
  /// **'Personnalisé'**
  String get reminderDiscretionCustom;

  /// No description provided for @reminderDiscretionDetailed.
  ///
  /// In fr, this message translates to:
  /// **'Détaillé'**
  String get reminderDiscretionDetailed;

  /// No description provided for @reminderActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get reminderActive;

  /// No description provided for @reminderSnooze.
  ///
  /// In fr, this message translates to:
  /// **'Reporter'**
  String get reminderSnooze;

  /// No description provided for @reminderDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le rappel'**
  String get reminderDelete;

  /// No description provided for @statsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get statsTitle;

  /// No description provided for @statsRelational.
  ///
  /// In fr, this message translates to:
  /// **'Relations'**
  String get statsRelational;

  /// No description provided for @statsMenstrual.
  ///
  /// In fr, this message translates to:
  /// **'Cycles'**
  String get statsMenstrual;

  /// No description provided for @statsPeriodMonth.
  ///
  /// In fr, this message translates to:
  /// **'Mois'**
  String get statsPeriodMonth;

  /// No description provided for @statsPeriodQuarter.
  ///
  /// In fr, this message translates to:
  /// **'Trimestre'**
  String get statsPeriodQuarter;

  /// No description provided for @statsPeriodYear.
  ///
  /// In fr, this message translates to:
  /// **'Année'**
  String get statsPeriodYear;

  /// No description provided for @statsEncountersTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total des rencontres'**
  String get statsEncountersTotal;

  /// No description provided for @statsEncountersPerMonth.
  ///
  /// In fr, this message translates to:
  /// **'Rencontres par mois'**
  String get statsEncountersPerMonth;

  /// No description provided for @statsByPartner.
  ///
  /// In fr, this message translates to:
  /// **'Par partenaire'**
  String get statsByPartner;

  /// No description provided for @statsByType.
  ///
  /// In fr, this message translates to:
  /// **'Par type'**
  String get statsByType;

  /// No description provided for @statsAvgCycleDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée moyenne du cycle'**
  String get statsAvgCycleDuration;

  /// No description provided for @statsAvgPeriodDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée moyenne des règles'**
  String get statsAvgPeriodDuration;

  /// No description provided for @statsVariability.
  ///
  /// In fr, this message translates to:
  /// **'Variabilité des cycles'**
  String get statsVariability;

  /// No description provided for @statsNoDataSufficient.
  ///
  /// In fr, this message translates to:
  /// **'Données insuffisantes pour afficher cette statistique.'**
  String get statsNoDataSufficient;

  /// No description provided for @statsMethodExplanation.
  ///
  /// In fr, this message translates to:
  /// **'Méthode de calcul'**
  String get statsMethodExplanation;

  /// No description provided for @privacyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get privacyTitle;

  /// No description provided for @privacyPinChange.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le code PIN'**
  String get privacyPinChange;

  /// No description provided for @privacyBiometric.
  ///
  /// In fr, this message translates to:
  /// **'Biométrie'**
  String get privacyBiometric;

  /// No description provided for @privacyBiometricEnable.
  ///
  /// In fr, this message translates to:
  /// **'Activer la biométrie'**
  String get privacyBiometricEnable;

  /// No description provided for @privacyAutoLock.
  ///
  /// In fr, this message translates to:
  /// **'Verrouillage automatique'**
  String get privacyAutoLock;

  /// No description provided for @privacyAutoLockImmediate.
  ///
  /// In fr, this message translates to:
  /// **'Immédiat'**
  String get privacyAutoLockImmediate;

  /// No description provided for @privacyAutoLock30s.
  ///
  /// In fr, this message translates to:
  /// **'30 secondes'**
  String get privacyAutoLock30s;

  /// No description provided for @privacyAutoLock1m.
  ///
  /// In fr, this message translates to:
  /// **'1 minute'**
  String get privacyAutoLock1m;

  /// No description provided for @privacyAutoLock5m.
  ///
  /// In fr, this message translates to:
  /// **'5 minutes'**
  String get privacyAutoLock5m;

  /// No description provided for @privacyAutoLock10m.
  ///
  /// In fr, this message translates to:
  /// **'10 minutes'**
  String get privacyAutoLock10m;

  /// No description provided for @privacyScreenProtection.
  ///
  /// In fr, this message translates to:
  /// **'Protection de l\'écran'**
  String get privacyScreenProtection;

  /// No description provided for @privacyHideInRecents.
  ///
  /// In fr, this message translates to:
  /// **'Masquer dans le sélecteur d\'applications'**
  String get privacyHideInRecents;

  /// No description provided for @privacyDiscreetMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode discret'**
  String get privacyDiscreetMode;

  /// No description provided for @privacyDiscreetModeDesc.
  ///
  /// In fr, this message translates to:
  /// **'Remplace les informations sensibles par des libellés génériques.'**
  String get privacyDiscreetModeDesc;

  /// No description provided for @privacyDataManagement.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des données'**
  String get privacyDataManagement;

  /// No description provided for @privacyExportData.
  ///
  /// In fr, this message translates to:
  /// **'Exporter les données'**
  String get privacyExportData;

  /// No description provided for @privacyImportData.
  ///
  /// In fr, this message translates to:
  /// **'Importer une sauvegarde'**
  String get privacyImportData;

  /// No description provided for @privacyDeleteCategory.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer une catégorie'**
  String get privacyDeleteCategory;

  /// No description provided for @privacyDeleteAll.
  ///
  /// In fr, this message translates to:
  /// **'Effacer toutes les données'**
  String get privacyDeleteAll;

  /// No description provided for @privacyDeleteAllWarning.
  ///
  /// In fr, this message translates to:
  /// **'Cette action supprimera définitivement toutes vos données. Elle est irréversible.'**
  String get privacyDeleteAllWarning;

  /// No description provided for @privacyDeleteAllConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Je confirme vouloir effacer toutes mes données.'**
  String get privacyDeleteAllConfirm;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get settingsThemeSystem;

  /// No description provided for @settingsDateFormat.
  ///
  /// In fr, this message translates to:
  /// **'Format de date'**
  String get settingsDateFormat;

  /// No description provided for @settingsWeekStart.
  ///
  /// In fr, this message translates to:
  /// **'Premier jour de la semaine'**
  String get settingsWeekStart;

  /// No description provided for @settingsWeekStartMonday.
  ///
  /// In fr, this message translates to:
  /// **'Lundi'**
  String get settingsWeekStartMonday;

  /// No description provided for @settingsWeekStartSunday.
  ///
  /// In fr, this message translates to:
  /// **'Dimanche'**
  String get settingsWeekStartSunday;

  /// No description provided for @settingsNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsHelp.
  ///
  /// In fr, this message translates to:
  /// **'Aide'**
  String get settingsHelp;

  /// No description provided for @backupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde et restauration'**
  String get backupTitle;

  /// No description provided for @backupExport.
  ///
  /// In fr, this message translates to:
  /// **'Créer une sauvegarde chiffrée'**
  String get backupExport;

  /// No description provided for @backupImport.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer depuis une sauvegarde'**
  String get backupImport;

  /// No description provided for @backupExportDesc.
  ///
  /// In fr, this message translates to:
  /// **'La sauvegarde sera chiffrée avec votre clé. Conservez-la en lieu sûr.'**
  String get backupExportDesc;

  /// No description provided for @backupImportDesc.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez un fichier de sauvegarde Intima (.enc). Vos données actuelles seront remplacées.'**
  String get backupImportDesc;

  /// No description provided for @backupImportWarning.
  ///
  /// In fr, this message translates to:
  /// **'La restauration remplacera toutes vos données actuelles. Cette action est irréversible.'**
  String get backupImportWarning;

  /// No description provided for @backupImportConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Je comprends et je souhaite restaurer.'**
  String get backupImportConfirm;

  /// No description provided for @backupIntegrityError.
  ///
  /// In fr, this message translates to:
  /// **'Le fichier de sauvegarde est corrompu ou invalide.'**
  String get backupIntegrityError;

  /// No description provided for @backupSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde créée avec succès.'**
  String get backupSuccess;

  /// No description provided for @backupRestoreSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Données restaurées avec succès.'**
  String get backupRestoreSuccess;

  /// No description provided for @backupExportNote.
  ///
  /// In fr, this message translates to:
  /// **'Une exportation vers un emplacement externe peut sortir du périmètre de protection de l\'application.'**
  String get backupExportNote;

  /// No description provided for @helpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aide et informations'**
  String get helpTitle;

  /// No description provided for @helpCyclePhases.
  ///
  /// In fr, this message translates to:
  /// **'Les phases du cycle menstruel'**
  String get helpCyclePhases;

  /// No description provided for @helpCyclePhasesBody.
  ///
  /// In fr, this message translates to:
  /// **'Le cycle menstruel comprend 4 phases principales :\n\n1. Phase menstruelle (jours 1 à 5) : Décollement et évacuation de la muqueuse utérine (endomètre) en l\'absence de nidation.\n2. Phase folliculaire (jours 1 à 13) : Maturation d\'un follicule sous l\'influence de la FSH et montée progressive des œstrogènes.\n3. Ovulation (environ jour 14 pour un cycle régulier de 28 jours) : Libération de l\'ovocyte mature déclenchée par un pic d\'hormone lutéinisante (LH).\n4. Phase lutéale (jours 15 à 28) : Le corps jaune résiduel sécrète de la progestérone pour préparer une éventuelle grossesse. En l\'absence de fécondation, le corps jaune dégénère, les taux d\'hormones chutent et déclenchent le cycle suivant.'**
  String get helpCyclePhasesBody;

  /// No description provided for @helpPeriodVsOvulationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Différence entre règles et ovulation'**
  String get helpPeriodVsOvulationTitle;

  /// No description provided for @helpPeriodVsOvulationBody.
  ///
  /// In fr, this message translates to:
  /// **'Les règles correspondent à l\'élimination de la muqueuse utérine devenue inutile lorsque la fécondation n\'a pas eu lieu. Elles marquent le tout premier jour d\'un nouveau cycle.\n\nL\'ovulation, quant à elle, a lieu en milieu de cycle : un ovaire libère un ovocyte prêt à être fécondé. Confondre règles et ovulation est fréquent, mais ce sont deux événements biologiques distincts séparés par plusieurs jours.'**
  String get helpPeriodVsOvulationBody;

  /// No description provided for @helpFertility.
  ///
  /// In fr, this message translates to:
  /// **'La fertilité et ses variations'**
  String get helpFertility;

  /// No description provided for @helpFertilityBody.
  ///
  /// In fr, this message translates to:
  /// **'La fenêtre de fertilité physiologique s\'étend sur environ 6 jours par cycle :\n\n• Les 5 jours précédant l\'ovulation : les spermatozoïdes peuvent survivre jusqu\'à 5 jours dans les voies génitales féminines grâce à la glaire cervicale fertile.\n• Le jour de l\'ovulation et les 24 heures suivantes : durée de vie de l\'ovocyte non fécondé.\n\nLa fertilité varie grandement d\'un cycle à l\'autre et au cours de la vie.'**
  String get helpFertilityBody;

  /// No description provided for @helpCycleVariationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pourquoi la durée des cycles varie'**
  String get helpCycleVariationsTitle;

  /// No description provided for @helpCycleVariationsBody.
  ///
  /// In fr, this message translates to:
  /// **'Une variation de quelques jours d\'un cycle à l\'autre est tout à fait physiologique et fréquente.\n\nLes facteurs courants influençant la durée incluent :\n• Le stress physique ou émotionnel aigu.\n• Les troubles du sommeil ou le décalage horaire.\n• Les variations de poids ou d\'alimentation.\n• Les changements de contraception ou l\'arrêt récent de contraceptifs hormonaux.\n• Des états médicaux sous-jacents (SOPK, troubles thyroïdiens).'**
  String get helpCycleVariationsBody;

  /// No description provided for @helpPredictionLimitsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Limites des prédictions de l\'application'**
  String get helpPredictionLimitsTitle;

  /// No description provided for @helpPredictionLimitsBody.
  ///
  /// In fr, this message translates to:
  /// **'IMPORTANT : Les prédictions d\'Intima sont des estimations statistiques basées sur l\'historique de vos données passées.\n\nElles ne constituent en aucun cas une garantie biologique ni une méthode de contraception fiable à elles seules. Aucun algorithme ne peut prédire avec certitude le jour exact d\'une ovulation future. Ne jamais se baser sur ce calendrier pour avoir un rapport sans contraception si une grossesse n\'est pas désirée.'**
  String get helpPredictionLimitsBody;

  /// No description provided for @helpContraception.
  ///
  /// In fr, this message translates to:
  /// **'Les méthodes de contraception'**
  String get helpContraception;

  /// No description provided for @helpContraceptionBody.
  ///
  /// In fr, this message translates to:
  /// **'Il existe différentes méthodes adaptées aux besoins de chacun(e) :\n\n• Contraception hormonale : pilule combinée ou progestative, implant sous-cutané, patch transdermique, anneau vaginal, DIU hormonal (stérilet).\n• Contraception non hormonale : DIU au cuivre (action spermicide mécanique), préservatifs, diaphragme avec gel spermicide.\n• Contraception d\'urgence : pilule du lendemain (lévonorgestrel ou ulipristal) ou pose rapide d\'un DIU cuivre.\n\nDiscutez avec votre médecin ou sage-femme pour choisir la méthode la plus adaptée à votre profil.'**
  String get helpContraceptionBody;

  /// No description provided for @helpSTI.
  ///
  /// In fr, this message translates to:
  /// **'Prévention de grossesse vs prévention des IST'**
  String get helpSTI;

  /// No description provided for @helpSTIBody.
  ///
  /// In fr, this message translates to:
  /// **'Attention : La contraception hormonale (pilule, implant, stérilet) empêche la grossesse mais ne protège AUCUNEMENT contre les Infections Sexuellement Transmissibles (IST/VIH).\n\nSeuls les préservatifs (externes ou internes) offrent une barrière protectrice efficace contre les IST.\nUn dépistage régulier est vivement recommandé avec vos partenaires, en laboratoire d\'analyses, chez votre médecin ou dans un CeGIDD gratuit et anonyme.'**
  String get helpSTIBody;

  /// No description provided for @helpWhenToSeeDoctor.
  ///
  /// In fr, this message translates to:
  /// **'Quand consulter un professionnel de santé'**
  String get helpWhenToSeeDoctor;

  /// No description provided for @helpWhenToSeeDoctorBody.
  ///
  /// In fr, this message translates to:
  /// **'Une consultation médicale rapide (médecin traitant, gynécologue, sage-femme ou urgences) est nécessaire en cas de :\n\n• Douleurs pelviennes aiguës ou très violentes non soulagées par les antalgiques habituels.\n• Saignements très abondants (plusieurs serviettes saturées par heure pendant plusieurs heures consécutives) ou vertiges.\n• Saignements anormaux après un rapport ou en dehors des périodes de règles.\n• Pertes vaginales anormales (couleur inhabituelle, odeur forte, démangeaisons, brûlures).\n• Fièvre associée à des douleurs pelviennes ou des pertes anormales.\n• Retard de règles inexpliqué avec risque de grossesse.'**
  String get helpWhenToSeeDoctorBody;

  /// No description provided for @helpDisclaimerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Information médicale éducative'**
  String get helpDisclaimerTitle;

  /// No description provided for @helpDisclaimerBody.
  ///
  /// In fr, this message translates to:
  /// **'Les informations fournies dans cette application sont strictement éducatives et préventives. Elles ne remplacent en aucun cas une consultation médicale, un diagnostic clinique ou un avis de professionnel de santé.'**
  String get helpDisclaimerBody;

  /// No description provided for @aboutTitle.
  ///
  /// In fr, this message translates to:
  /// **'À propos d\'Intima'**
  String get aboutTitle;

  /// No description provided for @aboutPrivacyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos données, votre vie privée'**
  String get aboutPrivacyTitle;

  /// No description provided for @aboutPrivacyBody.
  ///
  /// In fr, this message translates to:
  /// **'Intima ne collecte aucune donnée personnelle. Aucun compte n\'est requis. Aucune donnée n\'est transmise sur Internet. Tout reste sur votre appareil.'**
  String get aboutPrivacyBody;

  /// No description provided for @onboardingGoalsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quels sont vos objectifs ?'**
  String get onboardingGoalsTitle;

  /// No description provided for @onboardingGoalsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez vos attentes pour adapter au mieux votre expérience.'**
  String get onboardingGoalsSubtitle;

  /// No description provided for @goalCycle.
  ///
  /// In fr, this message translates to:
  /// **'Suivre mon cycle & prédire mes règles'**
  String get goalCycle;

  /// No description provided for @goalIntimacy.
  ///
  /// In fr, this message translates to:
  /// **'Suivre mes rapports & ma vie intime'**
  String get goalIntimacy;

  /// No description provided for @goalSymptoms.
  ///
  /// In fr, this message translates to:
  /// **'Comprendre mes symptômes & signaux du corps'**
  String get goalSymptoms;

  /// No description provided for @goalFertility.
  ///
  /// In fr, this message translates to:
  /// **'Estimer ma fertilité & concevoir'**
  String get goalFertility;

  /// No description provided for @goalJournal.
  ///
  /// In fr, this message translates to:
  /// **'Journal intime privé & bien-être personnel'**
  String get goalJournal;

  /// No description provided for @onboardingAboutYouTitle.
  ///
  /// In fr, this message translates to:
  /// **'Faisons connaissance'**
  String get onboardingAboutYouTitle;

  /// No description provided for @onboardingAboutYouSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ces informations facultatives restent stockées exclusivement sur votre téléphone.'**
  String get onboardingAboutYouSubtitle;

  /// No description provided for @onboardingNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Votre prénom ou pseudo'**
  String get onboardingNameLabel;

  /// No description provided for @onboardingNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Comment souhaitez-vous qu\'on vous appelle ?'**
  String get onboardingNameHint;

  /// No description provided for @onboardingBirthYearLabel.
  ///
  /// In fr, this message translates to:
  /// **'Année de naissance'**
  String get onboardingBirthYearLabel;

  /// No description provided for @onboardingBirthYearHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: 1998 (facultatif)'**
  String get onboardingBirthYearHint;

  /// No description provided for @onboardingGenderLabel.
  ///
  /// In fr, this message translates to:
  /// **'Votre profil / genre'**
  String get onboardingGenderLabel;

  /// No description provided for @onboardingDiscoveryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comment nous avez-vous découverts ?'**
  String get onboardingDiscoveryTitle;

  /// No description provided for @onboardingDiscoverySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Aidez-nous à savoir ce qui vous a guidé(e) vers Intima.'**
  String get onboardingDiscoverySubtitle;

  /// No description provided for @discoveryStore.
  ///
  /// In fr, this message translates to:
  /// **'Recherche App Store / Play Store'**
  String get discoveryStore;

  /// No description provided for @discoveryFriend.
  ///
  /// In fr, this message translates to:
  /// **'Recommandation d\'un(e) ami(e) ou partenaire'**
  String get discoveryFriend;

  /// No description provided for @discoverySocial.
  ///
  /// In fr, this message translates to:
  /// **'Réseaux sociaux ou Internet'**
  String get discoverySocial;

  /// No description provided for @discoveryHealth.
  ///
  /// In fr, this message translates to:
  /// **'Professionnel de santé / médecin'**
  String get discoveryHealth;

  /// No description provided for @discoveryOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre moyen'**
  String get discoveryOther;

  /// No description provided for @onboardingTermsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Engagement Zéro Serveur & Confidentialité'**
  String get onboardingTermsTitle;

  /// No description provided for @onboardingTermsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'La promesse sacrée d\'Intima : aucune donnée ne quitte votre appareil.'**
  String get onboardingTermsSubtitle;

  /// No description provided for @onboardingTermsAccept.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte la politique de confidentialité locale et l\'utilisation chiffrée sur mon téléphone.'**
  String get onboardingTermsAccept;

  /// No description provided for @onboardingTermsViewFull.
  ///
  /// In fr, this message translates to:
  /// **'Consulter la politique de confidentialité complète'**
  String get onboardingTermsViewFull;

  /// No description provided for @notificationCenterTitle.
  ///
  /// In fr, this message translates to:
  /// **'Centre de notifications'**
  String get notificationCenterTitle;

  /// No description provided for @notificationCenterSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérez vos rappels programmés et leur niveau de discrétion.'**
  String get notificationCenterSubtitle;

  /// No description provided for @notificationMasterToggle.
  ///
  /// In fr, this message translates to:
  /// **'Activer les notifications locales'**
  String get notificationMasterToggle;

  /// No description provided for @notificationMasterDesc.
  ///
  /// In fr, this message translates to:
  /// **'Programmer des rappels sur cet appareil (sans passer par Internet)'**
  String get notificationMasterDesc;

  /// No description provided for @notificationDiscretionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Niveau de discrétion'**
  String get notificationDiscretionTitle;

  /// No description provided for @notificationDiscretionDesc.
  ///
  /// In fr, this message translates to:
  /// **'Format d\'affichage des alertes sur votre écran verrouillé'**
  String get notificationDiscretionDesc;

  /// No description provided for @notificationDiscretion0.
  ///
  /// In fr, this message translates to:
  /// **'Discret (ex: \'Rappel personnel\')'**
  String get notificationDiscretion0;

  /// No description provided for @notificationDiscretion1.
  ///
  /// In fr, this message translates to:
  /// **'Neutre (ex: \'Intima : un rappel prévu\')'**
  String get notificationDiscretion1;

  /// No description provided for @notificationDiscretion2.
  ///
  /// In fr, this message translates to:
  /// **'Détaillé (titre exact)'**
  String get notificationDiscretion2;

  /// No description provided for @notificationPeriodTitle.
  ///
  /// In fr, this message translates to:
  /// **'Alerte de règles à venir'**
  String get notificationPeriodTitle;

  /// No description provided for @notificationPeriodDesc.
  ///
  /// In fr, this message translates to:
  /// **'Notification préventive avant la date estimée de début'**
  String get notificationPeriodDesc;

  /// No description provided for @notificationPeriodDays.
  ///
  /// In fr, this message translates to:
  /// **'{days} jours avant'**
  String notificationPeriodDays(int days);

  /// No description provided for @notificationPillTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rappel de pilule ou contraception'**
  String get notificationPillTitle;

  /// No description provided for @notificationPillDesc.
  ///
  /// In fr, this message translates to:
  /// **'Rappel quotidien à une heure fixe'**
  String get notificationPillDesc;

  /// No description provided for @notificationCheckinTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rappel de journal du soir'**
  String get notificationCheckinTitle;

  /// No description provided for @notificationCheckinDesc.
  ///
  /// In fr, this message translates to:
  /// **'Invitation discrète à noter vos ressentis de la journée'**
  String get notificationCheckinDesc;

  /// No description provided for @notificationTestButton.
  ///
  /// In fr, this message translates to:
  /// **'Tester une notification maintenant'**
  String get notificationTestButton;

  /// No description provided for @notificationTestSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Notification test programmée avec succès !'**
  String get notificationTestSuccess;

  /// No description provided for @notificationPermissionWarning.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez autoriser les notifications dans les paramètres Android.'**
  String get notificationPermissionWarning;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
