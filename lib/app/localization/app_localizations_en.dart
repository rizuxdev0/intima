// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Intima';

  @override
  String get appTagline => 'Your private space';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonClose => 'Close';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonDone => 'Done';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonOk => 'OK';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonFilter => 'Filter';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonArchive => 'Archive';

  @override
  String get commonRestore => 'Restore';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonError => 'Error';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonWarning => 'Warning';

  @override
  String get commonOptional => 'Optional';

  @override
  String get commonRequired => 'Required';

  @override
  String get commonUnknown => 'Unknown';

  @override
  String get commonAll => 'All';

  @override
  String get commonNone => 'None';

  @override
  String get commonPersonalEvent => 'Personal event';

  @override
  String get navHome => 'Home';

  @override
  String get navPartners => 'Partners';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navInsights => 'Insights';

  @override
  String get navMore => 'More';

  @override
  String get toastSaved => 'Saved successfully.';

  @override
  String get toastChangesSaved => 'Changes saved.';

  @override
  String get toastReminderScheduled => 'Reminder scheduled.';

  @override
  String get toastDataUpdated => 'Data updated.';

  @override
  String get toastError => 'Something went wrong. Please try again.';

  @override
  String get toastIncorrectPin => 'Incorrect PIN.';

  @override
  String get toastBackupCreated => 'Encrypted backup created.';

  @override
  String get toastNoData => 'No data available for this period.';

  @override
  String get toastDeleted => 'Item deleted.';

  @override
  String get toastRestored => 'Item restored.';

  @override
  String get toastArchived => 'Item archived.';

  @override
  String get toastCopied => 'Copied.';

  @override
  String get splashTagline => 'Your intimate, private and secure space.';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Intima';

  @override
  String get onboardingWelcomeSubtitle =>
      'Your personal, private and secure space. No account required. No data shared.';

  @override
  String get onboardingLanguageTitle => 'Choose your language';

  @override
  String get onboardingLanguageSubtitle =>
      'You can change this later in settings.';

  @override
  String get onboardingProfileTitle => 'How would you like to use Intima?';

  @override
  String get onboardingProfileSubtitle =>
      'This personalizes your dashboard. You can change this at any time.';

  @override
  String get onboardingProfilePersonal => 'Personal tracking';

  @override
  String get onboardingProfileRelationships => 'Track my relationships';

  @override
  String get onboardingProfileMenstrual => 'Track my menstrual health';

  @override
  String get onboardingProfileFull => 'Full mode';

  @override
  String get onboardingSecurityTitle => 'Protect your space';

  @override
  String get onboardingSecuritySubtitle =>
      'Create a PIN to secure access to the app.';

  @override
  String get onboardingPreferencesTitle => 'Your preferences';

  @override
  String get onboardingConsentTitle => 'Your data stays on your device';

  @override
  String get onboardingConsentBody =>
      'Intima does not transmit any intimate data over the Internet. Your information is encrypted and stored only on your phone. You can export or delete your data at any time.';

  @override
  String get onboardingConsentNote =>
      'Note: your phone\'s system backups (Google Drive, iCloud) may include app data depending on your settings.';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get pinCreateTitle => 'Create your PIN';

  @override
  String get pinCreateSubtitle => 'Choose a 6-digit PIN to secure access.';

  @override
  String get pinConfirmTitle => 'Confirm your PIN';

  @override
  String get pinConfirmSubtitle => 'Enter your PIN again to confirm.';

  @override
  String get pinEnterTitle => 'Unlock Intima';

  @override
  String get pinEnterSubtitle => 'Enter your PIN.';

  @override
  String get pinMismatch => 'PINs do not match. Please try again.';

  @override
  String get pinTooShort => 'PIN must be 6 digits.';

  @override
  String get pinIncorrect => 'Incorrect PIN.';

  @override
  String pinAttemptsRemaining(int count) {
    return '$count attempt(s) remaining.';
  }

  @override
  String pinLockedOut(int seconds) {
    return 'Too many attempts. Try again in $seconds seconds.';
  }

  @override
  String get pinForgot => 'Forgot PIN?';

  @override
  String get pinBiometricPrompt => 'Unlock with your fingerprint or Face ID.';

  @override
  String get pinUseBiometric => 'Use biometrics';

  @override
  String get pinUsePIN => 'Use PIN';

  @override
  String get dashboardGoodMorning => 'Good morning';

  @override
  String get dashboardGoodAfternoon => 'Good afternoon';

  @override
  String get dashboardGoodEvening => 'Good evening';

  @override
  String get dashboardSummaryTitle => 'Monthly summary';

  @override
  String get dashboardNoData => 'No data recorded this month.';

  @override
  String dashboardEncountersCount(int count) {
    return '$count encounter(s) this month';
  }

  @override
  String get dashboardNextReminder => 'Next reminder';

  @override
  String get dashboardNoReminders => 'No upcoming reminders.';

  @override
  String get dashboardCycleTitle => 'My cycle';

  @override
  String get dashboardCycleNotEnabled => 'Cycle tracking not enabled.';

  @override
  String get dashboardQuickAdd => 'Quick action';

  @override
  String get dashboardAddEncounter => 'Add encounter';

  @override
  String get dashboardAddPartner => 'Add partner';

  @override
  String get dashboardLogPeriod => 'Log my period';

  @override
  String get dashboardLogSymptom => 'Log a symptom';

  @override
  String get dashboardAddReminder => 'Create reminder';

  @override
  String get dashboardOpenCalendar => 'Open calendar';

  @override
  String get partnersTitle => 'Partners';

  @override
  String get partnersEmpty => 'No partners recorded.\nTap + to add one.';

  @override
  String get partnersAdd => 'Add a partner';

  @override
  String get partnerName => 'Name or nickname';

  @override
  String get partnerNameHint => 'Nickname, first name or alias';

  @override
  String get partnerColor => 'Color';

  @override
  String get partnerFirstMet => 'Date first met';

  @override
  String get partnerNotes => 'Personal notes';

  @override
  String get partnerTags => 'Tags';

  @override
  String get partnerArchived => 'Archived';

  @override
  String get partnerShowArchived => 'Show archived';

  @override
  String get partnerDeleteWarning =>
      'Deleting this partner will also erase associated encounters and data. This is irreversible.';

  @override
  String get partnerDeleteKeepData =>
      'Delete profile (keep anonymized encounters)';

  @override
  String get partnerDeleteAll => 'Delete everything (profile + encounters)';

  @override
  String get partnerEncounters => 'Associated encounters';

  @override
  String get partnerNoEncounters => 'No encounters recorded.';

  @override
  String get partnerStats => 'Statistics';

  @override
  String get partnerDetailTitle => 'Partner profile';

  @override
  String get encountersTitle => 'Journal';

  @override
  String get encountersEmpty =>
      'No encounters recorded.\nYour history will appear here.';

  @override
  String get encountersAdd => 'Add encounter';

  @override
  String get encounterDate => 'Date';

  @override
  String get encounterTime => 'Time';

  @override
  String get encounterDuration => 'Duration';

  @override
  String get encounterPartner => 'Partner';

  @override
  String get encounterType => 'Event type';

  @override
  String get encounterTypeIntimate => 'Intimate encounter';

  @override
  String get encounterTypePersonal => 'Personal activity';

  @override
  String get encounterTypeCustom => 'Custom event';

  @override
  String get encounterNotes => 'Personal notes';

  @override
  String get encounterMoodBefore => 'Mood before';

  @override
  String get encounterMoodAfter => 'Mood after';

  @override
  String get encounterProtection => 'Protection used';

  @override
  String get encounterProtectionIssue => 'Protection issue';

  @override
  String get encounterContraception => 'Contraception';

  @override
  String get encounterSymptoms => 'Symptoms or observations';

  @override
  String get encounterTags => 'Tags';

  @override
  String get encounterFollowUpReminder => 'Follow-up reminder';

  @override
  String get encounterDetail => 'Detail';

  @override
  String get encounterDeleteWarning => 'Delete this record?';

  @override
  String get cycleTitle => 'My cycle';

  @override
  String get cycleEmpty =>
      'No cycle recorded. Start by logging the first day of your period.';

  @override
  String get cycleLogPeriod => 'Log my period';

  @override
  String get cyclePeriodStart => 'First day of period';

  @override
  String get cyclePeriodEnd => 'Last day of period';

  @override
  String get cycleDuration => 'Cycle length';

  @override
  String get cyclePeriodDuration => 'Period length';

  @override
  String get cycleAverage => 'Average length';

  @override
  String get cycleVariability => 'Variability';

  @override
  String get cycleNextEstimated => 'Estimated period';

  @override
  String get cycleFertilityWindow => 'Potential fertility window';

  @override
  String get cycleOvulationEstimated => 'Estimated ovulation';

  @override
  String get cycleInsufficient => 'Uncertain estimate: insufficient data.';

  @override
  String get cycleDisclaimer =>
      'The calendar alone is not a reliable method of contraception.';

  @override
  String get cycleSymptoms => 'Symptoms';

  @override
  String get cycleSymptomsAdd => 'Add symptom';

  @override
  String get cycleFlowIntensity => 'Flow intensity';

  @override
  String get cycleFlowLight => 'Light';

  @override
  String get cycleFlowMedium => 'Medium';

  @override
  String get cycleFlowHeavy => 'Heavy';

  @override
  String get cycleCramps => 'Cramps';

  @override
  String get cycleFatigue => 'Fatigue';

  @override
  String get cycleHeadache => 'Headache';

  @override
  String get cycleMood => 'Mood';

  @override
  String get cycleSleep => 'Sleep';

  @override
  String get cycleObservations => 'Free observations';

  @override
  String get cycleTreatment => 'Treatment / contraception';

  @override
  String get cycleHistoryTitle => 'Cycle history';

  @override
  String get cycleDetailsTitle => 'Cycle details';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarLegendPeriod => 'Period';

  @override
  String get calendarLegendEstimated => 'Estimated period';

  @override
  String get calendarLegendFertile => 'Fertile window';

  @override
  String get calendarLegendOvulation => 'Estimated ovulation';

  @override
  String get calendarLegendEncounter => 'Encounter';

  @override
  String get calendarLegendSymptom => 'Symptom';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get remindersEmpty => 'No reminders configured.';

  @override
  String get remindersAdd => 'Create reminder';

  @override
  String get reminderTitle => 'Title';

  @override
  String get reminderDescription => 'Description';

  @override
  String get reminderDate => 'Date';

  @override
  String get reminderTime => 'Time';

  @override
  String get reminderFrequency => 'Frequency';

  @override
  String get reminderFrequencyOnce => 'Once';

  @override
  String get reminderFrequencyDaily => 'Daily';

  @override
  String get reminderFrequencyWeekly => 'Weekly';

  @override
  String get reminderFrequencyMonthly => 'Monthly';

  @override
  String get reminderEndDate => 'End date';

  @override
  String get reminderCategory => 'Category';

  @override
  String get reminderCategoryPersonal => 'Personal';

  @override
  String get reminderCategoryCycle => 'Cycle';

  @override
  String get reminderCategoryHealth => 'Health';

  @override
  String get reminderCategoryMedical => 'Medical';

  @override
  String get reminderDiscretion => 'Discretion level';

  @override
  String get reminderDiscretionDiscreet => 'Discreet';

  @override
  String get reminderDiscretionCustom => 'Custom';

  @override
  String get reminderDiscretionDetailed => 'Detailed';

  @override
  String get reminderActive => 'Active';

  @override
  String get reminderSnooze => 'Snooze';

  @override
  String get reminderDelete => 'Delete reminder';

  @override
  String get statsTitle => 'Insights';

  @override
  String get statsRelational => 'Relationships';

  @override
  String get statsMenstrual => 'Cycles';

  @override
  String get statsPeriodMonth => 'Month';

  @override
  String get statsPeriodQuarter => 'Quarter';

  @override
  String get statsPeriodYear => 'Year';

  @override
  String get statsEncountersTotal => 'Total encounters';

  @override
  String get statsEncountersPerMonth => 'Encounters per month';

  @override
  String get statsByPartner => 'By partner';

  @override
  String get statsByType => 'By type';

  @override
  String get statsAvgCycleDuration => 'Average cycle length';

  @override
  String get statsAvgPeriodDuration => 'Average period length';

  @override
  String get statsVariability => 'Cycle variability';

  @override
  String get statsNoDataSufficient =>
      'Insufficient data to display this statistic.';

  @override
  String get statsMethodExplanation => 'Calculation method';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacyPinChange => 'Change PIN';

  @override
  String get privacyBiometric => 'Biometrics';

  @override
  String get privacyBiometricEnable => 'Enable biometrics';

  @override
  String get privacyAutoLock => 'Auto-lock';

  @override
  String get privacyAutoLockImmediate => 'Immediate';

  @override
  String get privacyAutoLock30s => '30 seconds';

  @override
  String get privacyAutoLock1m => '1 minute';

  @override
  String get privacyAutoLock5m => '5 minutes';

  @override
  String get privacyAutoLock10m => '10 minutes';

  @override
  String get privacyScreenProtection => 'Screen protection';

  @override
  String get privacyHideInRecents => 'Hide in app switcher';

  @override
  String get privacyDiscreetMode => 'Discreet mode';

  @override
  String get privacyDiscreetModeDesc =>
      'Replaces sensitive information with generic labels.';

  @override
  String get privacyDataManagement => 'Data management';

  @override
  String get privacyExportData => 'Export data';

  @override
  String get privacyImportData => 'Import backup';

  @override
  String get privacyDeleteCategory => 'Delete a category';

  @override
  String get privacyDeleteAll => 'Erase all data';

  @override
  String get privacyDeleteAllWarning =>
      'This will permanently delete all your data. This action is irreversible.';

  @override
  String get privacyDeleteAllConfirm =>
      'I confirm I want to erase all my data.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsDateFormat => 'Date format';

  @override
  String get settingsWeekStart => 'First day of week';

  @override
  String get settingsWeekStartMonday => 'Monday';

  @override
  String get settingsWeekStartSunday => 'Sunday';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsHelp => 'Help';

  @override
  String get backupTitle => 'Backup & restore';

  @override
  String get backupExport => 'Create encrypted backup';

  @override
  String get backupImport => 'Restore from backup';

  @override
  String get backupExportDesc =>
      'The backup will be encrypted with your key. Keep it in a safe place.';

  @override
  String get backupImportDesc =>
      'Select an Intima backup file (.enc). Your current data will be replaced.';

  @override
  String get backupImportWarning =>
      'Restoring will replace all your current data. This action is irreversible.';

  @override
  String get backupImportConfirm => 'I understand and want to restore.';

  @override
  String get backupIntegrityError => 'The backup file is corrupted or invalid.';

  @override
  String get backupSuccess => 'Backup created successfully.';

  @override
  String get backupRestoreSuccess => 'Data restored successfully.';

  @override
  String get backupExportNote =>
      'Exporting to an external location may move data outside the app\'s protection boundary.';

  @override
  String get helpTitle => 'Help & Information';

  @override
  String get helpCyclePhases => 'Phases of the menstrual cycle';

  @override
  String get helpCyclePhasesBody =>
      'The menstrual cycle consists of 4 main phases:\n\n1. Menstrual phase (days 1 to 5): Shedding and discharge of the uterine lining (endometrium) when implantation did not occur.\n2. Follicular phase (days 1 to 13): Maturation of an ovarian follicle under FSH stimulation and rising estrogen levels.\n3. Ovulation (around day 14 for an average 28-day cycle): Release of a mature egg triggered by an LH surge.\n4. Luteal phase (days 15 to 28): The corpus luteum secretes progesterone to prepare for a possible pregnancy. If fertilization does not occur, hormone levels drop, initiating the next cycle.';

  @override
  String get helpPeriodVsOvulationTitle =>
      'Difference between period and ovulation';

  @override
  String get helpPeriodVsOvulationBody =>
      'Menstruation (your period) is the shedding of the uterine lining when fertilization has not occurred, marking day 1 of a new cycle.\n\nOvulation occurs around mid-cycle when an ovary releases a mature egg ready for fertilization. Although frequently confused, they are two distinct biological events separated by several days.';

  @override
  String get helpFertility => 'Fertility and its variations';

  @override
  String get helpFertilityBody =>
      'The fertile window spans approximately 6 days per cycle:\n\n• The 5 days leading up to ovulation: sperm can survive for up to 5 days in fertile cervical mucus.\n• The day of ovulation and 24 hours after: lifespan of an unfertilized egg.\n\nFertility varies naturally between cycles and throughout life.';

  @override
  String get helpCycleVariationsTitle => 'Why cycle length varies';

  @override
  String get helpCycleVariationsBody =>
      'Variations of a few days between cycles are completely normal and physiological.\n\nCommon factors influencing cycle duration include:\n• Acute physical or emotional stress.\n• Sleep disruption, shift work, or jet lag.\n• Significant weight or nutritional changes.\n• Starting or discontinuing hormonal contraceptives.\n• Underlying health conditions (e.g. PCOS, thyroid conditions).';

  @override
  String get helpPredictionLimitsTitle => 'Limits of app predictions';

  @override
  String get helpPredictionLimitsBody =>
      'IMPORTANT: Predictions in Intima are statistical estimations based on your historical cycle data.\n\nThey do not constitute biological guarantees or a reliable standalone contraceptive method. No algorithm can predict with absolute certainty the exact day of ovulation. Never rely on this calendar to engage in unprotected intercourse if avoiding pregnancy.';

  @override
  String get helpContraception => 'Contraception methods';

  @override
  String get helpContraceptionBody =>
      'Multiple contraceptive options exist tailored to individual health needs:\n\n• Hormonal methods: combined or progestin-only pills, subdermal implants, transdermal patches, vaginal rings, hormonal IUDs.\n• Non-hormonal methods: copper IUD (spermicidal copper ions), condoms, diaphragms with spermicide.\n• Emergency contraception: morning-after pill (levonorgestrel or ulipristal acetate) or emergency copper IUD insertion.\n\nConsult a healthcare professional to identify the best contraceptive method for you.';

  @override
  String get helpSTI => 'Pregnancy prevention vs STI prevention';

  @override
  String get helpSTIBody =>
      'Warning: Hormonal contraception prevents pregnancy, but DOES NOT protect against Sexually Transmitted Infections (STIs/HIV).\n\nOnly barrier methods (external and internal condoms) effectively reduce STI transmission.\nRegular screening is recommended with your partners, through medical clinics, family planning centers, or anonymous testing facilities.';

  @override
  String get helpWhenToSeeDoctor => 'When to consult a healthcare professional';

  @override
  String get helpWhenToSeeDoctorBody =>
      'Prompt medical evaluation (family physician, gynecologist, midwife, or emergency care) is recommended if you experience:\n\n• Acute, severe pelvic pain unresponsive to common analgesics.\n• Abnormally heavy bleeding (soaking multiple pads per hour for several consecutive hours) or dizziness.\n• Unusual bleeding between periods or after sexual intercourse.\n• Abnormal vaginal discharge (unusual color, strong odor, itching, or burning).\n• Fever accompanied by pelvic pain or abnormal discharge.\n• Unexplained missed period with potential pregnancy risk.';

  @override
  String get helpDisclaimerTitle => 'Educational medical information';

  @override
  String get helpDisclaimerBody =>
      'Information in this app is strictly for educational and preventative purposes. It never replaces professional medical consultation, clinical diagnosis, or medical treatment.';

  @override
  String get aboutTitle => 'About Intima';

  @override
  String get aboutPrivacyTitle => 'Your data, your privacy';

  @override
  String get aboutPrivacyBody =>
      'Intima collects no personal data. No account is required. No data is transmitted over the Internet. Everything stays on your device.';

  @override
  String get onboardingGoalsTitle => 'What are your primary goals?';

  @override
  String get onboardingGoalsSubtitle =>
      'Select your preferences to customize your experience.';

  @override
  String get goalCycle => 'Track cycle & predict periods';

  @override
  String get goalIntimacy => 'Track intimate moments & relationships';

  @override
  String get goalSymptoms => 'Understand symptoms & body signals';

  @override
  String get goalFertility => 'Estimate fertile window & conceive';

  @override
  String get goalJournal => 'Private intimate journal & personal wellness';

  @override
  String get onboardingAboutYouTitle => 'Let\'s get acquainted';

  @override
  String get onboardingAboutYouSubtitle =>
      'These optional details remain strictly stored on your phone.';

  @override
  String get onboardingNameLabel => 'Your name or nickname';

  @override
  String get onboardingNameHint => 'How would you like us to address you?';

  @override
  String get onboardingBirthYearLabel => 'Year of birth';

  @override
  String get onboardingBirthYearHint => 'e.g., 1998 (optional)';

  @override
  String get onboardingGenderLabel => 'Your profile / gender';

  @override
  String get onboardingDiscoveryTitle => 'How did you find out about us?';

  @override
  String get onboardingDiscoverySubtitle =>
      'Help us understand what led you to Intima.';

  @override
  String get discoveryStore => 'App Store / Play Store search';

  @override
  String get discoveryFriend => 'Friend or partner recommendation';

  @override
  String get discoverySocial => 'Social media or Internet';

  @override
  String get discoveryHealth => 'Healthcare provider / doctor';

  @override
  String get discoveryOther => 'Other';

  @override
  String get onboardingTermsTitle => 'Zero-Server Privacy & Agreement';

  @override
  String get onboardingTermsSubtitle =>
      'Intima\'s sacred promise: no data ever leaves your device.';

  @override
  String get onboardingTermsAccept =>
      'I accept the local privacy policy and encrypted on-device storage.';

  @override
  String get onboardingTermsViewFull => 'Read full privacy policy';

  @override
  String get notificationCenterTitle => 'Notification Center';

  @override
  String get notificationCenterSubtitle =>
      'Manage your scheduled discreet reminders and medical alerts.';

  @override
  String get notificationMasterToggle => 'Enable local notifications';

  @override
  String get notificationMasterDesc =>
      'Schedule alerts on this device (offline, no Internet)';

  @override
  String get notificationDiscretionTitle => 'Discretion level';

  @override
  String get notificationDiscretionDesc =>
      'How alerts are formatted on your lock screen';

  @override
  String get notificationDiscretion0 =>
      'Discreet (e.g., \'Personal reminder\')';

  @override
  String get notificationDiscretion1 =>
      'Neutral (e.g., \'Intima: upcoming reminder\')';

  @override
  String get notificationDiscretion2 => 'Detailed (full title)';

  @override
  String get notificationPeriodTitle => 'Upcoming period alert';

  @override
  String get notificationPeriodDesc =>
      'Advance notification prior to estimated cycle start';

  @override
  String notificationPeriodDays(int days) {
    return '$days days before';
  }

  @override
  String get notificationPillTitle => 'Pill / contraception reminder';

  @override
  String get notificationPillDesc => 'Daily reminder at a fixed time';

  @override
  String get notificationCheckinTitle => 'Evening check-in reminder';

  @override
  String get notificationCheckinDesc =>
      'Discreet daily invitation to log how you feel';

  @override
  String get notificationTestButton => 'Send a test notification';

  @override
  String get notificationTestSuccess =>
      'Test notification scheduled successfully!';

  @override
  String get notificationPermissionWarning =>
      'Please allow notifications in Android settings.';
}
