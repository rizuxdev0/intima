import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/security/lock_provider.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/presentation/pin_setup_screen.dart';
import '../features/privacy/presentation/lock_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/partners/presentation/partners_list_screen.dart';
import '../features/partners/presentation/partner_form_screen.dart';
import '../features/partners/presentation/partner_detail_screen.dart';
import '../features/encounters/presentation/encounters_list_screen.dart';
import '../features/encounters/presentation/encounter_form_screen.dart';
import '../features/encounters/presentation/encounter_detail_screen.dart';
import '../features/menstrual_cycle/presentation/calendar_screen.dart';
import '../features/menstrual_cycle/presentation/cycle_overview_screen.dart';
import '../features/menstrual_cycle/presentation/cycle_log_screen.dart';
import '../features/menstrual_cycle/presentation/symptom_form_screen.dart';
import '../features/menstrual_cycle/presentation/cycle_history_screen.dart';
import '../features/reminders/presentation/reminders_list_screen.dart';
import '../features/reminders/presentation/reminder_form_screen.dart';
import '../features/statistics/presentation/statistics_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/preferences_screen.dart';
import '../features/privacy/presentation/privacy_center_screen.dart';
import '../features/privacy/presentation/pin_change_screen.dart';
import '../features/privacy/presentation/duress_pin_screen.dart';
import '../features/backup/presentation/backup_screen.dart';
import '../features/settings/presentation/about_screen.dart';
import '../features/settings/presentation/help_screen.dart';
import '../features/settings/presentation/notification_center_screen.dart';
import '../features/settings/presentation/privacy_policy_screen.dart';
import '../features/journal/presentation/journal_screen.dart';
import '../features/journal/presentation/journal_editor_screen.dart';
import '../features/journal/presentation/journal_detail_screen.dart';
import '../features/sexual_health/presentation/sexual_health_screen.dart';
import '../features/sexual_health/presentation/screening_form_screen.dart';
import '../features/sexual_health/presentation/vaccination_form_screen.dart';
import '../features/education/presentation/education_hub_screen.dart';
import '../features/education/presentation/guide_detail_screen.dart';
import '../features/medical_report/presentation/medical_report_screen.dart';
import '../features/search/presentation/global_search_screen.dart';
import 'shell_scaffold.dart';

/// Routes nommées de l'application.
class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const pinSetup = '/pin-setup';
  static const lock = '/lock';
  static const home = '/';
  static const search = '/search';
  static const partners = '/partners';
  static const partnerNew = '/partners/new';
  static const partnerEdit = '/partners/:id/edit';
  static const partnerDetail = '/partners/:id';
  static const encounters = '/encounters';
  static const encounterNew = '/encounters/new';
  static const encounterEdit = '/encounters/:id/edit';
  static const encounterDetail = '/encounters/:id';
  static const calendar = '/calendar';
  static const cycleOverview = '/cycle';
  static const cycleLog = '/cycle/log';
  static const symptomForm = '/cycle/symptom';
  static const cycleHistory = '/cycle/history';
  static const reminders = '/reminders';
  static const reminderNew = '/reminders/new';
  static const reminderEdit = '/reminders/:id/edit';
  static const statistics = '/statistics';
  static const settings = '/settings';
  static const journal = '/journal';
  static const journalNew = '/journal/new';
  static const journalDetail = '/journal/:id';
  static const journalEdit = '/journal/:id/edit';
  static const sexualHealth = '/sexual-health';
  static const sexualHealthScreeningNew = '/sexual-health/screening/new';
  static const sexualHealthVaccineNew = '/sexual-health/vaccine/new';
  static const education = '/education';
  static const educationDetail = '/education/:id';
  static const medicalReport = '/medical-report';
  static const notifications = '/settings/notifications';
  static const preferences = '/settings/preferences';
  static const privacyCenter = '/settings/privacy';
  static const privacyPolicy = '/settings/privacy-policy';
  static const pinChange = '/settings/privacy/pin';
  static const duressPin = '/settings/privacy/duress-pin';
  static const backup = '/settings/backup';
  static const about = '/settings/about';
  static const help = '/settings/help';
}

// Clés Navigator stables de premier niveau pour éviter toute collision dans Flutter keyReservation
final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorHome =
    GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final GlobalKey<NavigatorState> _shellNavigatorPartners =
    GlobalKey<NavigatorState>(debugLabel: 'shellPartners');
final GlobalKey<NavigatorState> _shellNavigatorCalendar =
    GlobalKey<NavigatorState>(debugLabel: 'shellCalendar');
final GlobalKey<NavigatorState> _shellNavigatorStats =
    GlobalKey<NavigatorState>(debugLabel: 'shellStats');
final GlobalKey<NavigatorState> _shellNavigatorSettings =
    GlobalKey<NavigatorState>(debugLabel: 'shellSettings');

/// Provider du routeur GoRouter avec gestion de l'état de verrouillage.
final routerProvider = Provider<GoRouter>((ref) {
  final lockListenable = ValueNotifier<LockStatus>(ref.read(lockProvider));

  ref.listen(lockProvider, (_, next) {
    lockListenable.value = next;
  });

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: lockListenable,
    redirect: (context, state) {
      final lock = lockListenable.value;
      final location = state.uri.path;

      // SplashScreen contrôle son propre cycle d'animation au démarrage
      if (location == AppRoutes.splash) return null;

      // Routes toujours accessibles
      final publicRoutes = [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.pinSetup,
        AppRoutes.lock,
      ];

      switch (lock.state) {
        case AppLockState.initializing:
          return AppRoutes.splash;

        case AppLockState.notConfigured:
          if (!publicRoutes.contains(location)) return AppRoutes.onboarding;
          break;

        case AppLockState.locked:
        case AppLockState.lockedOut:
          if (!publicRoutes.contains(location)) return AppRoutes.lock;
          break;

        case AppLockState.unlocked:
          if (location == AppRoutes.lock ||
              location == AppRoutes.onboarding ||
              location == AppRoutes.pinSetup) {
            return AppRoutes.home;
          }
          break;
      }
      return null;
    },
    routes: [
      // ─── Écran Splash ─────────────────────────────────────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),

      // ─── Routes publiques ────────────────────────────────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.pinSetup,
        builder: (_, __) => const PinSetupScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.lock,
        builder: (_, __) => const LockScreen(),
      ),

      // ─── Shell avec barre de navigation ────────────────────────────────────
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, shell) => ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHome,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, __) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorPartners,
            routes: [
              GoRoute(
                path: AppRoutes.partners,
                builder: (_, __) => const PartnersListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCalendar,
            routes: [
              GoRoute(
                path: AppRoutes.calendar,
                builder: (_, __) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorStats,
            routes: [
              GoRoute(
                path: AppRoutes.statistics,
                builder: (_, __) => const StatisticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSettings,
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (_, __) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // ─── Routes secondaires et modales (Plein écran sur le Root Navigator) ──
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.partnerNew,
        builder: (_, __) => const PartnerFormScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.partnerDetail,
        builder: (_, state) => PartnerDetailScreen(
          partnerId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.partnerEdit,
        builder: (_, state) => PartnerFormScreen(
          partnerId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.encounters,
        builder: (_, __) => const EncountersListScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.encounterNew,
        builder: (_, __) => const EncounterFormScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.encounterDetail,
        builder: (_, state) => EncounterDetailScreen(
          encounterId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.encounterEdit,
        builder: (_, state) => EncounterFormScreen(
          encounterId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.cycleOverview,
        builder: (_, __) => const CycleOverviewScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.cycleLog,
        builder: (_, __) => const CycleLogScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.symptomForm,
        builder: (_, __) => const SymptomFormScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.cycleHistory,
        builder: (_, __) => const CycleHistoryScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.reminders,
        builder: (_, __) => const RemindersListScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.reminderNew,
        builder: (_, __) => const ReminderFormScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.reminderEdit,
        builder: (_, state) => ReminderFormScreen(
          reminderId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.journal,
        builder: (_, __) => const JournalScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.journalNew,
        builder: (_, __) => const JournalEditorScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.journalDetail,
        builder: (_, state) => JournalDetailScreen(
          entryId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.journalEdit,
        builder: (_, state) => JournalEditorScreen(
          entryId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.sexualHealth,
        builder: (_, __) => const SexualHealthScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.sexualHealthScreeningNew,
        builder: (_, __) => const ScreeningFormScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.sexualHealthVaccineNew,
        builder: (_, __) => const VaccinationFormScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.education,
        builder: (_, __) => const EducationHubScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.educationDetail,
        builder: (_, state) => GuideDetailScreen(
          guideId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.notifications,
        builder: (_, __) => const NotificationCenterScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.search,
        builder: (_, __) => const GlobalSearchScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.medicalReport,
        builder: (_, __) => const MedicalReportScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.preferences,
        builder: (_, __) => const PreferencesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.privacyCenter,
        builder: (_, __) => const PrivacyCenterScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.privacyPolicy,
        builder: (_, __) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.pinChange,
        builder: (_, __) => const PinChangeScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.duressPin,
        builder: (_, __) => const DuressPinScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.backup,
        builder: (_, __) => const BackupScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.about,
        builder: (_, __) => const AboutScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.help,
        builder: (_, __) => const HelpScreen(),
      ),
    ],
  );
});
