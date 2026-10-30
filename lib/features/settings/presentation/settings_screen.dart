import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/demo/demo_data_seeder.dart';
import '../../../core/security/lock_provider.dart';
import '../../../core/widgets/intima_card.dart';
import '../../../shared/models/app_preferences.dart';
import '../providers/preferences_provider.dart';

/// Écran des Paramètres moderne, épuré et structuré.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmAndSeedDemoData(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.auto_fix_high_rounded, color: AppColors.accent),
            SizedBox(width: 10),
            Expanded(child: Text('Charger les données de test ?')),
          ],
        ),
        content: const Text(
          'Cette action va injecter un jeu de données complet et réaliste :\n\n'
          '• 3 partenaires avec tags, couleurs et notes\n'
          '• 8 rencontres intimes réparties sur 3 mois\n'
          '• 4 cycles menstruels réguliers de 28 jours\n'
          '• 8 écrits dans le journal intime avec différentes humeurs\n'
          '• Bilans IST récents et vaccins HPV à jour\n'
          '• Rappels programmés et profil complet (Alex, 1998)\n\n'
          'Toutes les statistiques, prédictions et corrélations seront immédiatement enrichies.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Générer les données'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 14),
              Text('Génération des données en cours...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      try {
        await DemoDataSeeder.seedAll(ref);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Données injectées avec succès ! Tout est prêt à être exploré.'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, AppPreferences prefs) {
    final nameCtrl = TextEditingController(text: prefs.userName);
    final yearCtrl = TextEditingController(text: prefs.birthYear?.toString() ?? '');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Modifier mon profil',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Prénom ou surnom',
                  hintText: 'Ex: Alex, Sam...',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: yearCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Année de naissance',
                  hintText: 'Ex: 1998',
                  prefixIcon: Icon(Icons.cake_outlined),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final newName = nameCtrl.text.trim();
                    final newYear = int.tryParse(yearCtrl.text.trim());
                    final notifier = ref.read(preferencesProvider.notifier);
                    await notifier.setUserName(newName);
                    await notifier.setBirthYear(newYear);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  child: const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final prefs = ref.watch(preferencesProvider).valueOrNull ?? const AppPreferences();
    final isDuress = ref.watch(isDuressModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Carte Hero : Profil utilisateur
          _buildProfileHero(context, ref, prefs, theme),

          const SizedBox(height: 20),

          // Section 1 : Sécurité & Confidentialité
          _buildSectionHeader(context, 'SÉCURITÉ & CONFIDENTIALITÉ'),
          IntimaCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  iconColor: AppColors.primary,
                  iconBgColor: AppColors.primary.withValues(alpha: 0.12),
                  title: l10n.privacyTitle,
                  subtitle: 'Gestion du code PIN, biométrie et effacement des données',
                  onTap: () => context.push(AppRoutes.privacyCenter),
                ),
                if (!isDuress) ...[
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.security_update_warning_rounded,
                    iconColor: Colors.deepOrange,
                    iconBgColor: Colors.deepOrange.withValues(alpha: 0.12),
                    title: 'Code PIN Leurre (Sous-contrainte)',
                    subtitle: 'Déni plausible : déverrouille une interface factice en cas d\'urgence',
                    onTap: () => context.push(AppRoutes.duressPin),
                  ),
                ],
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  iconColor: Colors.grey.shade700,
                  iconBgColor: Colors.grey.withValues(alpha: 0.12),
                  title: 'Verrouiller l\'application',
                  subtitle: 'Fermer la session immédiatement',
                  onTap: () {
                    ref.read(lockProvider.notifier).lock();
                    context.go(AppRoutes.lock);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section 2 : Modules de suivi & Bien-être
          _buildSectionHeader(context, 'MODULES & SUIVI'),
          IntimaCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.menu_book_rounded,
                  iconColor: const Color(0xFF7E57C2),
                  iconBgColor: const Color(0xFF7E57C2).withValues(alpha: 0.12),
                  title: 'Journal Intime & Humeurs',
                  subtitle: 'Espace d\'écriture privé, calendrier émotionnel et souvenirs',
                  onTap: () => context.push(AppRoutes.journal),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.health_and_safety_rounded,
                  iconColor: const Color(0xFF2D5A46),
                  iconBgColor: const Color(0xFF2D5A46).withValues(alpha: 0.12),
                  title: 'Santé Sexuelle & Dépistages',
                  subtitle: 'Carnet de tests IST, vaccins HPV et rappels préventifs',
                  onTap: () => context.push(AppRoutes.sexualHealth),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.water_drop_rounded,
                  iconColor: AppColors.calendarPeriod,
                  iconBgColor: AppColors.calendarPeriod.withValues(alpha: 0.12),
                  title: 'Cycles & Règles',
                  subtitle: 'Calendrier des règles, symptômes et prédictions physiologiques',
                  onTap: () => context.push(AppRoutes.cycleOverview),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.people_outline_rounded,
                  iconColor: AppColors.accent,
                  iconBgColor: AppColors.accent.withValues(alpha: 0.12),
                  title: 'Partenaires & Relations',
                  subtitle: 'Carnet relationnel privé et historique des rencontres',
                  onTap: () => context.push(AppRoutes.partners),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.lightbulb_outline_rounded,
                  iconColor: const Color(0xFFE5A93C),
                  iconBgColor: const Color(0xFFE5A93C).withValues(alpha: 0.12),
                  title: 'Guide & Fiches Bien-être',
                  subtitle: 'Fiches pratiques : cycles, IST, consentement & plaisir',
                  onTap: () => context.push(AppRoutes.education),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section 3 : Préférences générales & Système
          _buildSectionHeader(context, 'SYSTÈME & PRÉFÉRENCES'),
          IntimaCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.notifications_active_outlined,
                  iconColor: const Color(0xFFE65100),
                  iconBgColor: const Color(0xFFE65100).withValues(alpha: 0.12),
                  title: l10n.notificationCenterTitle,
                  subtitle: l10n.notificationCenterSubtitle,
                  onTap: () => context.push(AppRoutes.notifications),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.palette_outlined,
                  iconColor: const Color(0xFF00897B),
                  iconBgColor: const Color(0xFF00897B).withValues(alpha: 0.12),
                  title: l10n.settingsTheme,
                  subtitle: 'Thèmes sombres/clairs, langue et options d\'affichage',
                  onTap: () => context.push(AppRoutes.preferences),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.backup_outlined,
                  iconColor: const Color(0xFF1E88E5),
                  iconBgColor: const Color(0xFF1E88E5).withValues(alpha: 0.12),
                  title: l10n.backupTitle,
                  subtitle: 'Sauvegarde locale chiffrée AES-256 et restauration',
                  onTap: () => context.push(AppRoutes.backup),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.picture_as_pdf_rounded,
                  iconColor: const Color(0xFFD32F2F),
                  iconBgColor: const Color(0xFFD32F2F).withValues(alpha: 0.12),
                  title: 'Export de Rapport Médical (PDF)',
                  subtitle: 'Dossier confidentiel pour médecin, gynécologue ou sage-femme',
                  onTap: () => context.push(AppRoutes.medicalReport),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section 4 : Informations & Légal
          _buildSectionHeader(context, 'TRANSPARENCE & ENGAGEMENT'),
          IntimaCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.verified_user_outlined,
                  iconColor: const Color(0xFF2E7D32),
                  iconBgColor: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                  title: 'Politique de confidentialité',
                  subtitle: 'Engagement 100% hors-ligne, zéro serveur, zéro pistage',
                  onTap: () => context.push(AppRoutes.privacyPolicy),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  iconColor: const Color(0xFF6A1B9A),
                  iconBgColor: const Color(0xFF6A1B9A).withValues(alpha: 0.12),
                  title: l10n.settingsHelp,
                  subtitle: 'Foire aux questions et guide d\'utilisation',
                  onTap: () => context.push(AppRoutes.help),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: Colors.blueGrey,
                  iconBgColor: Colors.blueGrey.withValues(alpha: 0.12),
                  title: l10n.settingsAbout,
                  subtitle: 'INTIMA v1.0.0 • Conçu pour votre intimité et votre liberté',
                  onTap: () => context.push(AppRoutes.about),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section 5 : Outil Développeur & Démo
          _buildSectionHeader(context, 'DÉMONSTRATION & TEST'),
          IntimaCard(
            color: AppColors.accent.withValues(alpha: 0.05),
            borderColor: AppColors.accent.withValues(alpha: 0.25),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_fix_high_rounded, color: AppColors.accent, size: 22),
              ),
              title: const Text(
                'Peupler le jeu de données complet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: const Text(
                'Générer 4 cycles, 8 écrits au journal, 8 rencontres, bilans IST et rappels',
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _confirmAndSeedDemoData(context, ref),
            ),
          ),

          const SizedBox(height: 24),

          // Footer intime
          Center(
            child: Column(
              children: [
                const Icon(Icons.lock_rounded, size: 16, color: Colors.grey),
                const SizedBox(height: 4),
                Text(
                  'INTIMA • Vos données ne quittent jamais cet appareil',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileHero(
    BuildContext context,
    WidgetRef ref,
    AppPreferences prefs,
    ThemeData theme,
  ) {
    final displayName = prefs.userName.trim().isNotEmpty ? prefs.userName.trim() : 'Mon Profil Intima';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'I';
    final currentYear = DateTime.now().year;
    final ageText = prefs.birthYear != null ? '${currentYear - prefs.birthYear!} ans' : null;

    return IntimaCard(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar avec anneau coloré
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: [
                        if (ageText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              ageText,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            prefs.usageMode == UsageMode.full
                                ? 'Suivi Complet'
                                : (prefs.usageMode == UsageMode.menstrual
                                    ? 'Cycle Seul'
                                    : (prefs.usageMode == UsageMode.personal
                                        ? 'Journal Personnel'
                                        : 'Intimité & Relations')),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: 'Modifier le profil',
                onPressed: () => _showEditProfileDialog(context, ref, prefs),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Stockage matériel chiffré AES-256-GCM actif',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}

/// Tuile de paramètre stylisée avec conteneur d'icône arrondi.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }
}
