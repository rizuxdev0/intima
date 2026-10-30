import '../../../core/storage/encrypted_storage.dart';
import '../domain/models/educational_guide.dart';

/// Repository gérant les fiches pédagogiques hors ligne et les favoris utilisateur.
class EducationRepository {
  EducationRepository(this._storage);

  final EncryptedStorage _storage;
  static const String _favoritesFilename = 'education_favorites.enc';

  /// Catalogue embarqué de fiches pédagogiques hors-ligne.
  static const List<EducationalGuide> defaultCatalog = [
    EducationalGuide(
      id: 'guide_cycle_phases',
      title: 'Comprendre les 4 phases de son cycle menstruel',
      subtitle: 'Comment les œstrogènes et la progestérone rythment votre énergie et votre bien-être.',
      category: GuideCategory.cyclePhysiology,
      readingTimeMinutes: 4,
      emoji: '🌱',
      isFeatured: true,
      tags: ['Cycle', 'Hormones', 'Ovulation', 'Énergie'],
      medicalReviewNote: 'Recommandations conformes aux publications du Collège National des Gynécologues et Obstétriciens Français (CNGOF).',
      keyTakeaways: [
        'Le cycle commence au 1er jour des saignements (J1).',
        'La phase folliculaire est dynamisante grâce à la montée des œstrogènes.',
        'L\'ovulation correspond au pic de fertilité (environ J14 sur un cycle de 28 jours).',
        'La phase lutéale prépare le corps et peut s\'accompagner d\'introspection ou de SPM.',
      ],
      sections: [
        GuideSection(
          title: '1. Phase Menstruelle (Jours 1 à 5 en moyenne)',
          paragraphs: [
            'Le premier jour des règles marque le tout début d\'un nouveau cycle. Les taux d\'œstrogènes et de progestérone sont à leur niveau le plus bas.',
            'Sur le plan physique, l\'utérus élimine sa muqueuse (l\'endomètre). C\'est une période où le corps réclame naturellement du repos, de l\'hydratation et de la douceur.',
          ],
          calloutText: 'Conseil bien-être : Accordez-vous des nuits complètes et n\'hésitez pas à appliquer une source de chaleur (bouillotte) pour détendre le bas-ventre.',
        ),
        GuideSection(
          title: '2. Phase Folliculaire (Jours 6 à 13)',
          paragraphs: [
            'Dès la fin des saignements, les ovaires sécrètent des œstrogènes sous l\'action de l\'hormone folliculo-stimulante (FSH).',
            'Cette élévation hormonale entraîne un regain d\'énergie, une clarté mentale accrue, une curiosité sociale et une amélioration de l\'élasticité cutanée.',
          ],
          bulletPoints: [
            'Énergie physique en hausse',
            'Idéal pour lancer de nouveaux projets ou pratiquer une activité sportive intense',
            'La glaire cervicale commence à devenir fluide et translucide',
          ],
        ),
        GuideSection(
          title: '3. Phase Ovulatoire (Jours 14 à 16)',
          paragraphs: [
            'Un pic soudain d\'hormone lutéinisante (LH) déclenche la libération de l\'ovocyte par le follicule mûr. L\'ovule vit entre 12 et 24 heures, mais les spermatozoïdes pouvant survivre jusqu\'à 5 jours dans les voies génitales féminines, la fenêtre fertile totale s\'étend sur environ 6 jours.',
            'C\'est souvent le moment où la libido, la confiance en soi et le rayonnement relationnel sont à leur apogée.',
          ],
          calloutText: 'Rappel de sécurité : Même avec un cycle régulier, l\'ovulation peut fluctuer sous l\'effet du stress, d\'un voyage ou d\'une maladie. Les applications d\'estimation ne doivent jamais remplacer un moyen contraceptif.',
        ),
        GuideSection(
          title: '4. Phase Lutéale (Jours 17 à 28+)',
          paragraphs: [
            'Après l\'ovulation, le follicule se transforme en corps jaune et produit de la progestérone. Cette hormone apaise l\'utérus et réchauffe légèrement la température corporelle basale.',
            'Si aucune fécondation n\'a lieu, les taux d\'hormones chutent quelques jours avant les règles, ce qui peut provoquer les manifestations physiques et émotionnelles du SPM (sensibilité, irritabilité, fringales).',
          ],
        ),
      ],
    ),
    EducationalGuide(
      id: 'guide_sti_screening',
      title: 'Dépistage des IST : Délais fenêtres et où consulter',
      subtitle: 'Quand et comment se faire tester efficacement après un rapport à risque.',
      category: GuideCategory.stiPrevention,
      readingTimeMinutes: 5,
      emoji: '🛡️',
      isFeatured: true,
      tags: ['Dépistage', 'VIH', 'Chlamydia', 'CeGIDD', 'Santé'],
      medicalReviewNote: 'Données basées sur les directives de Santé Publique France et de l\'OMS.',
      keyTakeaways: [
        'Chaque IST a un « délai fenêtre » avant d\'être détectable avec certitude.',
        'Le test VIH par prise de sang en laboratoire est 100% fiable à partir de 6 semaines.',
        'Les CeGIDD proposent des dépistages anonymes, gratuits et sans ordonnance.',
        'La grande majorité des IST sont asymptomatiques mais se traitent très facilement.',
      ],
      sections: [
        GuideSection(
          title: 'Pourquoi se faire dépister régulièrement ?',
          paragraphs: [
            'Dans plus de 70% des cas chez les femmes et 50% chez les hommes, les infections comme la chlamydiose ou la gonorrhée ne provoquent aucun symptôme perceptible. Sans traitement, elles peuvent pourtant entraîner des inflammations pelviennes chroniques ou des problèmes de fertilité.',
            'Un bilan régulier permet de se protéger, de protéger ses partenaires et de vivre sa sexualité l\'esprit totalement libre.',
          ],
        ),
        GuideSection(
          title: 'Les Délais Fenêtres Sérologiques',
          paragraphs: [
            'Faire un test le lendemain d\'un rapport à risque est inutile : le système immunitaire et les agents pathogènes ont besoin d\'un temps de latence incompressible pour être détectés.',
          ],
          bulletPoints: [
            'VIH (Sérologie combinée 4e génération Ac/Ag p24) : 6 semaines (42 jours) pour une certitude absolue. Un test rapide TROD est fiable à 3 mois.',
            'Chlamydia & Gonorrhée (PCR sur urine ou auto-prélèvement vaginal/pharyngé) : dès 2 semaines après l\'exposition.',
            'Syphilis (Sérologie TPHA/VDRL) : 4 à 6 semaines.',
            'Hépatite B (Ag HBs) : 6 à 8 semaines.',
            'Hépatite C (Sérologie Ac anti-VHC) : 3 mois.',
          ],
          calloutText: 'En cas de doute immédiat (< 48h) après une exposition majeure au VIH, rendez-vous immédiatement aux urgences d\'un hôpital pour obtenir le TPE (Traitement Post-Exposition).',
        ),
        GuideSection(
          title: 'Où se faire dépister en toute confidentialité ?',
          paragraphs: [
            'En France, vous avez plusieurs options simples et accessibles :',
            '1. Les CeGIDD (Centres Gratuits d\'Information, de Dépistage et de Diagnostic) : consultation médicale, prélèvements et traitements entièrement gratuits, avec option d\'anonymat total.',
            '2. En laboratoire de ville : vous pouvez demander le dispositif "VIHTest" directement au laboratoire, sans ordonnance et sans avance de frais.',
            '3. Chez votre médecin traitant, sage-femme ou gynécologue.',
          ],
        ),
      ],
    ),
    EducationalGuide(
      id: 'guide_consent_fries',
      title: 'Le Consentement Enthousiaste et Réversible',
      subtitle: 'Comprendre la règle d\'or des relations intimes épanouies et sécurisantes.',
      category: GuideCategory.consentCommunication,
      readingTimeMinutes: 3,
      emoji: '💬',
      tags: ['Consentement', 'Respect', 'Communication', 'Relations'],
      medicalReviewNote: 'Ressource pédagogique validée selon le standard international FRIES.',
      keyTakeaways: [
        'Le consentement n\'est pas seulement l\'absence de « non », mais la présence d\'un « oui » sincère.',
        'Il est réversible à tout instant : on a le droit absolu de changer d\'avis.',
        'L\'alcool ou les substances altèrent la capacité de consentir.',
        'Le dialogue intime renforce la complicité et le plaisir partagé.',
      ],
      sections: [
        GuideSection(
          title: 'Le modèle F.R.I.E.S.',
          paragraphs: [
            'Pour qu\'un accord soit authentique et sain, il doit réunir cinq critères fondamentaux :',
          ],
          bulletPoints: [
            'F (Freely Given / Librement consenti) : accord donné sans chantage, pression, peur ou manipulation.',
            'R (Reversible / Réversible) : toute personne a le droit inaliénable de s\'arrêter ou de changer d\'avis à n\'importe quelle seconde, même en plein acte.',
            'I (Informed / Éclairé) : les deux personnes savent ce qui va se passer (par exemple, retirer un préservatif à l\'insu de l\'autre est une infraction grave appelée "stealthing").',
            'E (Enthusiastic / Enthousiaste) : il s\'agit de faire des choses que l\'on désire réellement faire, non de "subir" pour faire plaisir.',
            'S (Specific / Spécifique) : dire oui à un câlin ou un baiser ne signifie pas dire oui à un rapport intime.',
          ],
          calloutText: 'Règle essentielle : Dans le doute, posez toujours la question calmement. "Est-ce que ça te plaît ?", "Tu te sens à l\'aise ?". La tendresse et la clarté rendent l\'intimité infiniment plus sensuelle.',
        ),
      ],
    ),
    EducationalGuide(
      id: 'guide_clitoris_anatomy',
      title: 'Anatomie Clitoridienne & Plaisir Féminin',
      subtitle: 'La réalité anatomique fascinante d\'un organe dédié exclusivement au plaisir.',
      category: GuideCategory.wellnessPleasure,
      readingTimeMinutes: 4,
      emoji: '✨',
      tags: ['Anatomie', 'Plaisir', 'Clitoris', 'Santé'],
      medicalReviewNote: 'Fondé sur les travaux d\'imagerie 3D contemporains du Dr Helen O\'Connell et de l\'Inserm.',
      keyTakeaways: [
        'Le clitoris mesure entre 8 et 12 cm : seule la partie émergente (le gland) est visible.',
        'Il possède plus de 8 000 terminaisons nerveuses sensorielles hautement concentrées.',
        'L\'orgasme est physiologiquement déclenché par le réseau clitoridien dans 90% des cas.',
        'Le plaisir nécessite temps, détente neuromusculaire et lubrification adéquate.',
      ],
      sections: [
        GuideSection(
          title: 'Une merveille d\'anatomie longtemps oubliée',
          paragraphs: [
            'Pendant des siècles, les planches anatomiques n\'ont représenté que le gland du clitoris, laissant croire qu\'il ne s\'agissait que d\'un minuscule bouton.',
            'En réalité, le clitoris ressemble à un magnifique triangle en forme de papillon : il comprend deux piliers (crura) qui descendent le long des os pubiens, deux bulbes vestibulaires qui s\'engorgent de sang lors de l\'excitation, et le corps clitoridien.',
          ],
          calloutText: 'Mythe déconstruit : Il n\'existe pas d\'orgasme "vaginal" distinct de l\'orgasme "clitoridien". Ce que l\'on appelle la zone G correspond en réalité à la stimulation interne des bulbes et des piliers du clitoris à travers la paroi antérieure du vagin.',
        ),
        GuideSection(
          title: 'Le rôle de la lubrification et du temps',
          paragraphs: [
            'L\'excitation féminine mobilise un temps de montée circulatoire : l\'afflux sanguin vers les corps caverneux prend en moyenne 15 à 25 minutes de stimulation sensorielle douce avant une réceptivité optimale.',
            'L\'utilisation d\'un lubrifiant à base d\'eau ou de silicone neutre (sans parfum) protège les muqueuses contre les micro-lésions et décuple les sensations.',
          ],
        ),
      ],
    ),
    EducationalGuide(
      id: 'guide_hpv_vaccine',
      title: 'Vaccin contre les Papillomavirus (HPV)',
      subtitle: 'Pourquoi le vaccin Gardasil 9 est une avancée médicale majeure pour tous.',
      category: GuideCategory.stiPrevention,
      readingTimeMinutes: 4,
      emoji: '💉',
      tags: ['Vaccin', 'HPV', 'Cancer', 'Prévention'],
      medicalReviewNote: 'Recommandations vaccinales de la Haute Autorité de Santé (HAS).',
      keyTakeaways: [
        'Les HPV sont extrêmement fréquents : 80% des personnes sexuellement actives y sont exposées un jour.',
        'Le vaccin protège contre 9 souches majeures responsables de cancers et de verrues (condylomes).',
        'Il est recommandé pour les filles ET les garçons dès l\'âge de 11 ans.',
        'Un rattrapage est recommandé jusqu\'à 19 ans inclus (et 26 ans pour les HSH).',
      ],
      sections: [
        GuideSection(
          title: 'Qu\'est-ce que le virus HPV ?',
          paragraphs: [
            'Les Human Papillomavirus (HPV) regroupent plus de 200 types de virus transmissibles par simple contact cutané ou muqueux lors des caresses ou des rapports, même protégés par préservatif (qui ne couvre pas toute la peau avoisinante).',
            'Dans la majorité des cas, le système immunitaire élimine le virus en un à deux ans. Cependant, certaines souches à haut risque peuvent persister et causer des anomalies cellulaires au niveau du col de l\'utérus, de la gorge ou de la région anale.',
          ],
        ),
        GuideSection(
          title: 'Le rôle du frottis et du test HPV de dépistage',
          paragraphs: [
            'Même vaccinée, toute femme de 25 à 65 ans doit effectuer son dépistage gynécologique régulier :',
            '• Entre 25 et 29 ans : un examen cytologique (frottis) tous les 3 ans.',
            '• À partir de 30 ans : un test HPV tous les 5 ans, particulièrement performant.',
          ],
          calloutText: 'Bonne nouvelle : En combinant vaccination précoce et dépistage de routine, l\'OMS estime que le cancer du col de l\'utérus peut être quasiment éradiqué.',
        ),
      ],
    ),
    EducationalGuide(
      id: 'guide_pms_pmdd',
      title: 'SPM ou TDPM : Quand les hormones bouleversent le quotidien',
      subtitle: 'Différencier le syndrome prémenstruel passager du trouble dysphorique prémenstruel.',
      category: GuideCategory.cyclePhysiology,
      readingTimeMinutes: 4,
      emoji: '🍂',
      tags: ['SPM', 'TDPM', 'Humeur', 'Lutéale'],
      medicalReviewNote: 'Critères diagnostiques conformes au DSM-5 et aux consensus gynécologiques internationaux.',
      keyTakeaways: [
        'Le SPM survient en phase lutéale (7 à 10 jours avant les règles) et cesse avec leur arrivée.',
        'Le TDPM est une forme sévère qui impacte lourdement la vie sociale et émotionnelle.',
        'La cause n\'est pas un "dérèglement", mais une hypersensibilité du cerveau aux variations normales de la progestérone.',
        'Des solutions médicales et hygiéno-diététiques validées existent.',
      ],
      sections: [
        GuideSection(
          title: 'Comprendre ce qui se passe dans votre corps',
          paragraphs: [
            'Durant la phase lutéale, la progestérone métabolisée produit de l\'alloprégnanolone, une molécule qui interagit directement avec les récepteurs GABA et la sérotonine dans le cerveau.',
            'Chez certaines personnes, cette sensibilité accrue induit anxiété soudaine, irritabilité vive, fatigue écrasante ou rétention d\'eau.',
          ],
          calloutText: 'Repérez vos motifs : Grâce au journal intime et au suivi des cycles dans INTIMA, vous pouvez prouver la nature cyclique de vos symptômes à votre professionnel de santé.',
        ),
      ],
    ),
    EducationalGuide(
      id: 'guide_prep_pep',
      title: 'PrEP & TPE : La révolution de la prévention du VIH',
      subtitle: 'Prophylaxie pré-exposition et traitement d\'urgence en cas d\'accident.',
      category: GuideCategory.stiPrevention,
      readingTimeMinutes: 4,
      emoji: '💊',
      tags: ['PrEP', 'TPE', 'VIH', 'Urgences'],
      medicalReviewNote: 'Règles de prescription officielles de l\'ANRS et du ministère de la Santé.',
      keyTakeaways: [
        'La PrEP réduit de plus de 99% le risque de transmission du VIH lors des rapports sexuels.',
        'Elle est disponible en prise quotidienne continue ou "à la demande" (schéma 2-1-1).',
        'Elle est prise en charge à 100% par l\'Assurance Maladie.',
        'En cas d\'accident sans PrEP, le TPE doit être pris dans les 48 heures (idéalement < 4h).',
      ],
      sections: [
        GuideSection(
          title: 'Comment fonctionne la PrEP ?',
          paragraphs: [
            'La PrEP (Prophylaxie Pré-Exposition) consiste à prendre un médicament antirétroviral préventif. Présente dans l\'organisme au moment de l\'exposition, la molécule empêche le VIH de s\'installer et de se multiplier.',
            'Attention : La PrEP protège exclusivement contre le VIH. Elle ne protège pas contre la chlamydia, la syphilis, la gonorrhée ou les papillomavirus, d\'où l\'intérêt de bilans réguliers.',
          ],
          calloutText: 'Urgences TPE : Rupture de préservatif avec un partenaire de statut sérologique inconnu ? Présentez-vous aux urgences sans tarder pour débuter le Traitement Post-Exposition (durée d\'un mois).',
        ),
      ],
    ),
    EducationalGuide(
      id: 'guide_communication_desires',
      title: 'Parler de ses désirs et poser ses limites sans tabou',
      subtitle: 'Les clés de la communication bienveillante au lit et au quotidien.',
      category: GuideCategory.consentCommunication,
      readingTimeMinutes: 4,
      emoji: '🌿',
      tags: ['Communication', 'Désirs', 'Limites', 'Épanouissement'],
      medicalReviewNote: 'Conseils rédigés en collaboration avec des professionnels en sexologie clinique.',
      keyTakeaways: [
        'Exprimer ses envies commence hors de la chambre à coucher, dans un moment neutre et détendu.',
        'Parler en « Je » plutôt qu\'en « Tu » évite que l\'autre se sente jugé ou critiqué.',
        'Savoir ce que l\'on ne veut pas est tout aussi important que savoir ce que l\'on désire.',
        'La sécurité émotionnelle est le premier moteur du lâcher-prise physique.',
      ],
      sections: [
        GuideSection(
          title: 'La méthode des 3 feux',
          paragraphs: [
            'Un outil simple et ludique pour explorer vos envies avec votre partenaire :',
            '🟢 Feu vert : ce que vous adorez et souhaitez continuer ou répéter.',
            '🟡 Feu orange : ce que vous êtes curieux(se) d\'essayer avec précaution et arrêt possible.',
            '🔴 Feu rouge : vos limites strictes, fermes et non négociables.',
          ],
          calloutText: 'Astuce : Noter d\'abord ses ressentis dans son journal intime permet de clarifier ses propres émotions avant de les partager avec sérénité.',
        ),
      ],
    ),
  ];

  /// Récupère la liste de toutes les fiches pédagogiques.
  List<EducationalGuide> getAllGuides() => defaultCatalog;

  /// Trouve une fiche par son identifiant unique.
  EducationalGuide? getGuideById(String id) {
    try {
      return defaultCatalog.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Charge les identifiants des fiches favorites de l'utilisateur.
  Future<Set<String>> getFavoriteIds() async {
    try {
      final list = await _storage.readJsonListFile(_favoritesFilename);
      if (list == null) return <String>{};
      return list.map((e) => e.toString()).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  /// Enregistre les identifiants favoris.
  Future<void> saveFavoriteIds(Set<String> favoriteIds) async {
    await _storage.writeJsonListFile(_favoritesFilename, favoriteIds.toList());
  }

  /// Bascule l'état favori d'une fiche.
  Future<bool> toggleFavorite(String guideId) async {
    final current = await getFavoriteIds();
    final updated = Set<String>.from(current);
    final isFav = updated.contains(guideId);
    if (isFav) {
      updated.remove(guideId);
    } else {
      updated.add(guideId);
    }
    await saveFavoriteIds(updated);
    return !isFav;
  }
}
