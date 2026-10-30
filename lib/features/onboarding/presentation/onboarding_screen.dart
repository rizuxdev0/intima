import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/demo/demo_data_seeder.dart';
import '../../../core/widgets/illustrations/intima_illustrations.dart';
import '../../../core/widgets/intima_card.dart';
import '../../../shared/models/app_preferences.dart';
import '../../settings/providers/preferences_provider.dart';

/// Écran d'accueil et d'onboarding structuré comme un stepper moderne (style Flo Health).
/// Guide l'utilisateur pas à pas avec bienveillance, clarté et recueil éthique des préférences.
/// Adapte dynamiquement tous les modules selon le profil de l'utilisateur.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;

  // Préférences collectées
  String _selectedLocale = 'fr';
  final List<String> _selectedGoals = ['cycle', 'intimacy'];
  int? _birthYear;
  UserGender _selectedGender = UserGender.notSpecified;
  UsageMode _selectedUsageMode = UsageMode.full;
  String _referralSource = 'store';
  bool _acceptedPrivacyPolicy = false;
  final ThemeMode _selectedTheme = ThemeMode.system;
  bool _isSeeding = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: AppConstants.mediumAnimDuration,
        curve: Curves.easeInOutCubic,
      );
    } else {
      if (!_acceptedPrivacyPolicy) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez accepter la politique de confidentialité locale pour continuer.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      _finishOnboarding();
    }
  }

  Future<void> _seedDemoData() async {
    setState(() => _isSeeding = true);
    try {
      await DemoDataSeeder.seedAll(ref);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Données de test complètes injectées ! Code PIN : 123456'),
            backgroundColor: AppColors.success,
          ),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go(AppRoutes.home);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSeeding = false);
      }
    }
  }

  Future<void> _finishOnboarding() async {
    final notifier = ref.read(preferencesProvider.notifier);
    await notifier.setLocale(_selectedLocale);
    await notifier.setUsageMode(_selectedUsageMode);
    await notifier.setThemeMode(_selectedTheme);

    final nameToSave = _nameController.text.trim();
    if (nameToSave.isNotEmpty) {
      await notifier.setUserName(nameToSave);
    }
    await notifier.setUserGender(_selectedGender);
    if (_birthYear != null) {
      await notifier.setBirthYear(_birthYear);
    }
    await notifier.setGoals(_selectedGoals);
    await notifier.setReferralSource(_referralSource);
    await notifier.setAcceptedPrivacyPolicy(_acceptedPrivacyPolicy);

    // Configuration sur-mesure de l'affichage du Dashboard et des cartes
    final hasCycle = _selectedGoals.contains('cycle') &&
        _selectedUsageMode != UsageMode.personal &&
        _selectedUsageMode != UsageMode.relationships;
    final hasRelational = (_selectedGoals.contains('intimacy') || _selectedGoals.contains('health')) &&
        _selectedUsageMode != UsageMode.personal &&
        _selectedUsageMode != UsageMode.menstrual;

    await notifier.setDashboardCardVisibility(
      showCycle: hasCycle,
      showEncounters: hasRelational,
      showReminders: true,
    );

    await notifier.setOnboardingCompleted();

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(AppRoutes.pinSetup);
        }
      });
    }
  }

  void _onGenderSelected(UserGender gender) {
    setState(() {
      _selectedGender = gender;
      if (gender == UserGender.male) {
        _selectedUsageMode = UsageMode.relationships;
        _selectedGoals
          ..remove('cycle')
          ..remove('fertility')
          ..remove('symptoms');
        if (!_selectedGoals.contains('intimacy')) _selectedGoals.add('intimacy');
        if (!_selectedGoals.contains('health')) _selectedGoals.add('health');
        if (!_selectedGoals.contains('journal')) _selectedGoals.add('journal');
      } else if (gender == UserGender.female) {
        _selectedUsageMode = UsageMode.full;
        if (!_selectedGoals.contains('cycle')) _selectedGoals.add('cycle');
        if (!_selectedGoals.contains('intimacy')) _selectedGoals.add('intimacy');
        if (!_selectedGoals.contains('symptoms')) _selectedGoals.add('symptoms');
        if (!_selectedGoals.contains('journal')) _selectedGoals.add('journal');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Indicateur d'étapes / Stepper avec barre de progression continue (style Flo)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                          onPressed: () {
                            _pageController.previousPage(
                              duration: AppConstants.mediumAnimDuration,
                              curve: Curves.easeInOutCubic,
                            );
                          },
                        )
                      else
                        const SizedBox(width: 40),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0.0,
                              end: (_currentPage + 1) / 5,
                            ),
                            duration: const Duration(milliseconds: 300),
                            builder: (context, value, child) => LinearProgressIndicator(
                              value: value,
                              minHeight: 6,
                              backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '${_currentPage + 1}/5',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    children: [
                      _buildLanguageStep(l10n, theme),
                      _buildAboutYouStep(l10n, theme),
                      _buildGoalsStep(l10n, theme),
                      _buildUsageModeStep(l10n, theme),
                      _buildAcceptanceStep(l10n, theme),
                    ],
                  ),
                ),

                // Barre d'action inférieure
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSeeding
                          ? null
                          : (_currentPage == 4 && !_acceptedPrivacyPolicy ? null : _nextPage),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        _currentPage == 4
                            ? l10n.onboardingGetStarted
                            : l10n.commonNext,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isSeeding)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.accent),
                    SizedBox(height: 16),
                    Text(
                      'Génération des données de test...',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Étape 1 : Langue & Bienvenue ───────────────────────────────────────────
  Widget _buildLanguageStep(AppLocalizations l10n, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: IntimaAnimatedIllustration(
              type: IntimaIllustrationType.heart,
              size: 130,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingWelcomeTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingWelcomeSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            l10n.onboardingLanguageTitle,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _SelectionCard(
            title: 'Français',
            subtitle: 'Langue de l\'application (par défaut)',
            isSelected: _selectedLocale == 'fr',
            icon: Icons.language_rounded,
            onTap: () {
              setState(() => _selectedLocale = 'fr');
              ref.read(preferencesProvider.notifier).setLocale('fr');
            },
          ),
          const SizedBox(height: 12),
          _SelectionCard(
            title: 'English',
            subtitle: 'Application language',
            isSelected: _selectedLocale == 'en',
            icon: Icons.public_rounded,
            onTap: () {
              setState(() => _selectedLocale = 'en');
              ref.read(preferencesProvider.notifier).setLocale('en');
            },
          ),
          const SizedBox(height: 28),

          // Encart d'injection rapide pour tests & évaluation complète
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_fix_high_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Mode Découverte Immédiate',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Injecter immédiatement des données complètes pour explorer tout de suite l\'application.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.bolt_rounded, size: 18),
                    label: const Text('Peupler les données et explorer'),
                    onPressed: _seedDemoData,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Étape 2 : Faisons connaissance (Profil, Nom, Année de naissance, Genre) ─
  Widget _buildAboutYouStep(AppLocalizations l10n, ThemeData theme) {
    final currentYear = DateTime.now().year;
    final yearsList = List.generate(70, (index) => currentYear - 13 - index);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: IntimaAnimatedIllustration(
              type: IntimaIllustrationType.partners,
              size: 110,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingAboutYouTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.onboardingAboutYouSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 20),

          // Prénom / pseudo
          Text(
            l10n.onboardingNameLabel,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: l10n.onboardingNameHint,
              prefixIcon: const Icon(Icons.badge_outlined),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 20),

          // Année de naissance
          Text(
            l10n.onboardingBirthYearLabel,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _birthYear,
                hint: Text(l10n.onboardingBirthYearHint),
                isExpanded: true,
                icon: const Icon(Icons.calendar_today_outlined, size: 20),
                items: yearsList.map((y) {
                  return DropdownMenuItem<int>(
                    value: y,
                    child: Text('$y'),
                  );
                }).toList(),
                onChanged: (y) => setState(() => _birthYear = y),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Genre déclaré
          Text(
            l10n.onboardingGenderLabel,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildGenderChip(
                icon: Icons.female_rounded,
                label: 'Femme',
                gender: UserGender.female,
                theme: theme,
              ),
              _buildGenderChip(
                icon: Icons.male_rounded,
                label: 'Homme',
                gender: UserGender.male,
                theme: theme,
              ),
              _buildGenderChip(
                icon: Icons.all_inclusive_rounded,
                label: 'Non-binaire / Autre',
                gender: UserGender.nonBinary,
                theme: theme,
              ),
              _buildGenderChip(
                icon: Icons.visibility_off_outlined,
                label: 'Ne pas préciser',
                gender: UserGender.notSpecified,
                theme: theme,
              ),
            ],
          ),

          // Message d'adaptation personnalisé
          if (_selectedGender == UserGender.male) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Expérience adaptée : L\'application sera configurée pour vos relations, partenaires et santé sexuelle, sans aucun module menstruel imposé.',
                      style: TextStyle(fontSize: 12, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Étape 3 : Quels sont vos objectifs ? (Adaptés selon le genre) ───────────
  Widget _buildGoalsStep(AppLocalizations l10n, ThemeData theme) {
    final isMale = _selectedGender == UserGender.male;

    final goalsOptions = isMale
        ? [
            {
              'key': 'intimacy',
              'title': 'Suivi des rapports & rencontres intimes',
              'subtitle': 'Historique avec chaque partenaire, dates et protections',
              'icon': Icons.favorite_rounded,
              'color': AppColors.accent,
            },
            {
              'key': 'health',
              'title': 'Santé sexuelle & Dépistages IST / PrEP',
              'subtitle': 'Bilans VIH, hépatites, rappels sérologiques et vaccins',
              'icon': Icons.health_and_safety_rounded,
              'color': const Color(0xFF2D5A46),
            },
            {
              'key': 'journal',
              'title': 'Journal intime & Réflexions personnelles',
              'subtitle': 'Notes chiffrées, émotions, pensées et confidences',
              'icon': Icons.book_rounded,
              'color': AppColors.sage,
            },
          ]
        : [
            {
              'key': 'cycle',
              'title': l10n.goalCycle,
              'subtitle': 'Prédiction des règles, durée des phases',
              'icon': Icons.water_drop_rounded,
              'color': AppColors.calendarPeriod,
            },
            {
              'key': 'intimacy',
              'title': l10n.goalIntimacy,
              'subtitle': 'Suivi des rencontres, partenaires et désirs',
              'icon': Icons.favorite_rounded,
              'color': AppColors.accent,
            },
            {
              'key': 'symptoms',
              'title': l10n.goalSymptoms,
              'subtitle': 'Symptômes physiques, SPM et humeurs',
              'icon': Icons.healing_rounded,
              'color': AppColors.calendarSymptom,
            },
            {
              'key': 'fertility',
              'title': l10n.goalFertility,
              'subtitle': 'Fenêtre fertile et estimation d\'ovulation',
              'icon': Icons.child_care_rounded,
              'color': AppColors.calendarFertile,
            },
            {
              'key': 'health',
              'title': 'Santé sexuelle & Dépistages IST',
              'subtitle': 'Bilans sanguins, PrEP et vaccins HPV',
              'icon': Icons.health_and_safety_rounded,
              'color': const Color(0xFF2D5A46),
            },
            {
              'key': 'journal',
              'title': l10n.goalJournal,
              'subtitle': 'Journal intime et bien-être émotionnel',
              'icon': Icons.book_rounded,
              'color': AppColors.sage,
            },
          ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.track_changes_rounded, size: 36, color: AppColors.accent),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.onboardingGoalsTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isMale
                ? 'Choisissez les domaines que vous souhaitez suivre en toute discrétion.'
                : l10n.onboardingGoalsSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ...goalsOptions.map((goal) {
            final key = goal['key'] as String;
            final isSelected = _selectedGoals.contains(key);
            final subtitle = goal['subtitle'] as String?;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      if (_selectedGoals.length > 1) {
                        _selectedGoals.remove(key);
                      }
                    } else {
                      _selectedGoals.add(key);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (goal['color'] as Color).withValues(alpha: 0.12)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? (goal['color'] as Color)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.12),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (goal['color'] as Color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          goal['icon'] as IconData,
                          color: goal['color'] as Color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal['title'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                        color: isSelected ? (goal['color'] as Color) : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Encart optionnel pour un homme souhaitant suivre le cycle d'une compagne
          if (isMale) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                setState(() {
                  if (_selectedGoals.contains('cycle')) {
                    _selectedGoals.remove('cycle');
                    _selectedUsageMode = UsageMode.relationships;
                  } else {
                    _selectedGoals.add('cycle');
                    _selectedUsageMode = UsageMode.full;
                  }
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedGoals.contains('cycle')
                        ? AppColors.calendarPeriod
                        : theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: _selectedGoals.contains('cycle') ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.calendarPeriod.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.favorite_border_rounded, color: AppColors.calendarPeriod, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Suivre le cycle d\'une compagne (Optionnel)',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Pour anticiper les règles ou la fertilité de votre partenaire',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _selectedGoals.contains('cycle'),
                      activeTrackColor: AppColors.calendarPeriod,
                      onChanged: (val) {
                        setState(() {
                          if (val) {
                            _selectedGoals.add('cycle');
                            _selectedUsageMode = UsageMode.full;
                          } else {
                            _selectedGoals.remove('cycle');
                            _selectedUsageMode = UsageMode.relationships;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Étape 4 : Mode d'utilisation principal ──────────────────────────────────
  Widget _buildUsageModeStep(AppLocalizations l10n, ThemeData theme) {
    final isMale = _selectedGender == UserGender.male;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.sage.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tune_rounded, size: 36, color: AppColors.sage),
          ),
          const SizedBox(height: 18),
          Text(
            'Mode d\'utilisation',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configurez l\'application pour qu\'elle réponde exactement à vos attentes au quotidien.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Mode 1 : Intimité & Relations (parfait pour hommes et couples)
          _SelectionCard(
            title: '${l10n.onboardingProfileRelationships}${isMale ? ' (Recommandé)' : ''}',
            subtitle: 'Partenaires, rencontres et santé sexuelle (sans cycle menstruel)',
            isSelected: _selectedUsageMode == UsageMode.relationships,
            icon: Icons.favorite_rounded,
            onTap: () => setState(() => _selectedUsageMode = UsageMode.relationships),
          ),
          const SizedBox(height: 10),

          // Mode 2 : Journal intime personnel
          _SelectionCard(
            title: l10n.onboardingProfilePersonal,
            subtitle: 'Journal secret, humeurs et bien-être personnel',
            isSelected: _selectedUsageMode == UsageMode.personal,
            icon: Icons.person_rounded,
            onTap: () => setState(() => _selectedUsageMode = UsageMode.personal),
          ),
          const SizedBox(height: 10),

          // Mode 3 : Plein suivi
          _SelectionCard(
            title: l10n.onboardingProfileFull,
            subtitle: 'Toutes les fonctionnalités réunies (Cycle + Intimité)',
            isSelected: _selectedUsageMode == UsageMode.full,
            icon: Icons.stars_rounded,
            onTap: () => setState(() => _selectedUsageMode = UsageMode.full),
          ),
          const SizedBox(height: 10),

          // Mode 4 : Cycle menstruel seul
          if (!isMale) ...[
            _SelectionCard(
              title: l10n.onboardingProfileMenstrual,
              subtitle: 'Suivi exclusif des cycles, des règles et des symptômes',
              isSelected: _selectedUsageMode == UsageMode.menstrual,
              icon: Icons.water_drop_rounded,
              onTap: () => setState(() => _selectedUsageMode = UsageMode.menstrual),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Étape 5 : Sécurité locale & Découverte ─────────────────────────────────
  Widget _buildAcceptanceStep(AppLocalizations l10n, ThemeData theme) {
    final sources = [
      {'key': 'store', 'title': l10n.discoveryStore, 'icon': Icons.storefront_rounded},
      {'key': 'friend', 'title': l10n.discoveryFriend, 'icon': Icons.diversity_1_rounded},
      {'key': 'social', 'title': l10n.discoverySocial, 'icon': Icons.share_rounded},
      {'key': 'health', 'title': l10n.discoveryHealth, 'icon': Icons.medical_services_rounded},
      {'key': 'other', 'title': l10n.discoveryOther, 'icon': Icons.explore_rounded},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: IntimaAnimatedIllustration(
              type: IntimaIllustrationType.shield,
              size: 120,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingTermsTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos données sont protégées localement avec un chiffrement matériel de niveau bancaire.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Carte récapitulative de la charte de confidentialité
          IntimaCard(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderColor: AppColors.primary.withValues(alpha: 0.2),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSecurityBullet(
                  Icons.cloud_off_rounded,
                  'Zéro serveur, zéro cloud',
                  'Aucune de vos informations ne quitte votre téléphone.',
                ),
                const Divider(height: 20),
                _buildSecurityBullet(
                  Icons.enhanced_encryption_rounded,
                  'Chiffrement AES-256-GCM',
                  'Vos données sont protégées par une clé matérielle locale.',
                ),
                const Divider(height: 20),
                _buildSecurityBullet(
                  Icons.fingerprint_rounded,
                  'Accès protégé par PIN & Biométrie',
                  'Vous seul(e) pouvez déverrouiller et consulter votre sanctuaire.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Source de découverte
          Text(
            'Comment avez-vous découvert Intima ?',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: sources.map((src) {
                final key = src['key'] as String;
                final isSelected = _referralSource == key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(src['title'] as String),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _referralSource = key);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Case à cocher d'acceptation obligatoire
          InkWell(
            onTap: () => setState(() => _acceptedPrivacyPolicy = !_acceptedPrivacyPolicy),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _acceptedPrivacyPolicy
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _acceptedPrivacyPolicy
                      ? AppColors.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                  width: _acceptedPrivacyPolicy ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _acceptedPrivacyPolicy,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => setState(() => _acceptedPrivacyPolicy = val ?? false),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.onboardingTermsAccept,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _acceptedPrivacyPolicy ? FontWeight.bold : FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Lien pour lire la politique complète
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: Text(l10n.onboardingTermsViewFull),
              onPressed: () => context.push(AppRoutes.privacyPolicy),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBullet(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderChip({
    required IconData icon,
    required String label,
    required UserGender gender,
    required ThemeData theme,
  }) {
    final isSelected = _selectedGender == gender;
    return InkWell(
      onTap: () => _onGenderSelected(gender),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.15),
            width: isSelected ? 1.8 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.title,
    this.subtitle,
    required this.isSelected,
    this.icon,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool isSelected;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.12),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? AppColors.primary : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                size: 22,
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
