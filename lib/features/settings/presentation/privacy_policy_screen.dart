import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/intima_card.dart';

/// Écran complet de la Politique de Confidentialité et d'Engagement Zéro Serveur.
/// Accessible depuis l'onboarding (stepper) et depuis le centre de confidentialité / À propos.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Politique de Confidentialité'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // En-tête d'engagement
          IntimaCard(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderColor: AppColors.primary.withValues(alpha: 0.25),
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Engagement Zéro Serveur & Zéro Donnée',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Intima est une application 100% hors-ligne ("Offline-First"). Vos données intimes ne transitent sur aucun serveur distant.',
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Article 1 : Collecte & Hébergement
          _buildPolicySection(
            theme,
            icon: Icons.cloud_off_rounded,
            title: '1. Aucune transmission distante',
            content:
                'Contrairement à la majorité des applications de santé intime ou de suivi de règles, Intima ne possède aucun serveur d\'application, aucune base de données cloud, aucun compte utilisateur avec e-mail ou mot de passe, et aucun mécanisme de télémétrie ou de traçage commercial.\n\nTout ce que vous enregistrez (cycles, relations, partenaires, symptômes, notes, rappels) reste strictement cantonné à la mémoire interne de votre appareil.',
          ),
          const SizedBox(height: 12),

          // Article 2 : Chiffrement AES-256-GCM
          _buildPolicySection(
            theme,
            icon: Icons.enhanced_encryption_rounded,
            title: '2. Chiffrement militaire local',
            content:
                'Toutes les données sensibles sont systématiquement chiffrées au repos au format AES-256-GCM (Galois/Counter Mode). La clé cryptographique est générée de manière sécurisée et conservée dans le coffre matériel de votre appareil (Android Keystore / iOS Keychain). Même en cas de perte de votre téléphone, vos données demeurent illisibles sans votre code PIN ou votre déverrouillage biométrique.',
          ),
          const SizedBox(height: 12),

          // Article 3 : Données facultatives & Consentement
          _buildPolicySection(
            theme,
            icon: Icons.how_to_reg_rounded,
            title: '3. Collecte volontaire et éclairée',
            content:
                'Toutes les informations demandées lors du premier démarrage (prénom ou pseudonyme, année de naissance, genre, objectifs, comment vous nous avez découverts) sont strictement facultatives.\n\nElles ont pour unique vocation de personnaliser votre interface, d\'affiner les calculs statistiques de vos cycles menstruels et de vous fournir une expérience adaptée.',
          ),
          const SizedBox(height: 12),

          // Article 4 : Sauvegardes & Restauration
          _buildPolicySection(
            theme,
            icon: Icons.backup_rounded,
            title: '4. Vos sauvegardes sous votre contrôle exclusif',
            content:
                'Vous êtes l\'unique propriétaire de vos informations. Vous pouvez générer à tout moment un fichier de sauvegarde chiffré (.enc) protégé par votre clé et le stocker où bon vous semble. L\'application n\'envoie jamais cette sauvegarde sur Google Drive ou iCloud sans votre manipulation manuelle directe.',
          ),
          const SizedBox(height: 12),

          // Article 5 : Droit à l\'effacement immédiat
          _buildPolicySection(
            theme,
            icon: Icons.delete_forever_rounded,
            title: '5. Droit à l\'oubli et suppression instantanée',
            content:
                'Dans le Centre de Confidentialité, un bouton de purge intégrale permet d\'effacer définitivement l\'intégralité de vos enregistrements, clés de chiffrement et préférences en un seul geste. Cette action est irréversible et immédiate.',
          ),
          const SizedBox(height: 12),

          // Article 6 : Avertissement médical
          _buildPolicySection(
            theme,
            icon: Icons.medical_services_outlined,
            title: '6. Avertissement médical préventif',
            content:
                'Intima fournit des estimations statistiques et des outils d\'auto-observation. L\'application ne se substitue en aucun cas à un diagnostic médical, à un suivi gynécologique professionnel ni à un moyen de contraception homologué.',
          ),
          const SizedBox(height: 24),

          Center(
            child: Text(
              'Intima Version 1.0.0 • Conçu avec rigueur et bienveillance',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPolicySection(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return IntimaCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.45,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

