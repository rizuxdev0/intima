import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/encounters/data/encounters_repository.dart';
import '../../features/encounters/providers/encounters_provider.dart';
import '../../features/journal/data/journal_reminders_repository.dart';
import '../../features/journal/data/journal_repository.dart';
import '../../features/journal/domain/models/journal_entry.dart';
import '../../features/journal/domain/models/journal_mood.dart';
import '../../features/journal/domain/models/journal_reminder.dart';
import '../../features/journal/providers/journal_provider.dart';
import '../../features/journal/providers/journal_reminders_provider.dart';
import '../../features/menstrual_cycle/data/menstrual_cycle_repository.dart';
import '../../features/menstrual_cycle/providers/menstrual_cycle_provider.dart';
import '../../features/partners/data/partners_repository.dart';
import '../../features/partners/providers/partners_provider.dart';
import '../../features/reminders/data/reminders_repository.dart';
import '../../features/reminders/providers/reminders_provider.dart';
import '../../features/sexual_health/data/sexual_health_repository.dart';
import '../../features/sexual_health/domain/models/prep_record.dart';
import '../../features/sexual_health/domain/models/sti_screening.dart';
import '../../features/sexual_health/domain/models/vaccination_record.dart';
import '../../features/sexual_health/providers/sexual_health_provider.dart';
import '../../features/statistics/providers/correlation_provider.dart';
import '../../features/settings/data/preferences_repository.dart';
import '../../features/settings/providers/preferences_provider.dart';
import '../../shared/models/app_preferences.dart';
import '../../shared/models/encounter.dart';
import '../../shared/models/menstrual_cycle.dart';
import '../../shared/models/partner.dart';
import '../../shared/models/reminder.dart';
import '../security/lock_provider.dart';
import '../security/security_service.dart';
import '../storage/storage_provider.dart';

/// Service utilitaire pour générer un jeu de données de démonstration complet,
/// réaliste et cohérent dans l'application INTIMA.
///
/// Remplit :
/// - Les préférences utilisateur (Onboarding validé, profil complet, nom, genre, objectifs)
/// - Le code PIN par défaut ("123456") si aucun n'est configuré
/// - Des partenaires avec couleurs, notes et étiquettes
/// - Des rencontres intimes réparties sur les 3 derniers mois avec protections et évaluations
/// - Des cycles menstruels sur 4 mois avec symptômes et prédictions
/// - Des rappels médicaux et quotidiens programmés
class DemoDataSeeder {
  DemoDataSeeder._();

  static Future<void> seedAll(WidgetRef ref) async {
    final storage = await ref.read(encryptedStorageProvider.future);

    // 1. Initialiser le PIN si nécessaire (code par défaut: "123456")
    final hasPin = await SecurityService.hasPinConfigured();
    if (!hasPin) {
      await SecurityService.setPin('123456');
    }

    // 2. Déverrouiller le lockProvider
    ref.read(lockProvider.notifier).unlockWithBiometric();

    // 3. Préférences utilisateur
    final now = DateTime.now();
    final prefsRepo = PreferencesRepository(storage);
    const populatedPrefs = AppPreferences(
      locale: 'fr',
      userName: 'Alex',
      userGender: UserGender.female,
      birthYear: 1998,
      usageMode: UsageMode.full,
      onboardingCompleted: true,
      acceptedPrivacyPolicy: true,
      referralSource: 'store',
      goals: ['cycle', 'intimacy', 'symptoms', 'fertility', 'journal'],
      notificationsEnabled: true,
      biometricEnabled: true,
      showEncountersOnDashboard: true,
      showCycleOnDashboard: true,
      showRemindersOnDashboard: true,
      periodReminderDaysBefore: 2,
      pillReminderEnabled: true,
      pillReminderTime: '20:00',
      dailyCheckinReminderEnabled: true,
      dailyCheckinReminderTime: '21:30',
    );
    await prefsRepo.save(populatedPrefs);

    // 4. Partenaires
    final partnersRepo = PartnersRepository(storage);
    final partner1 = Partner(
      id: 'partner_lucas_01',
      name: 'Lucas',
      color: 0xFF88293E, // Grenat Intima
      emoji: '❤️',
      createdAt: now.subtract(const Duration(days: 180)),
      firstMetDate: now.subtract(const Duration(days: 180)),
      notes: 'Relation stable et de confiance mutuelle. Dépistage IST récent négatif.',
      tags: const ['Régulier', 'Complice', 'Testé IST négatif'],
    );

    final partner2 = Partner(
      id: 'partner_camille_02',
      name: 'Camille',
      color: 0xFF2D5A46, // Vert Sauge
      emoji: '✨',
      createdAt: now.subtract(const Duration(days: 300)),
      firstMetDate: now.subtract(const Duration(days: 300)),
      notes: 'Moments intimes partagés dans la douceur et le respect réciproque.',
      tags: const ['Ami(e)', 'Occasionnel'],
    );

    final partner3 = Partner(
      id: 'partner_sam_03',
      name: 'Sam',
      color: 0xFFC97A63, // Accent terracotta
      emoji: '🌙',
      createdAt: now.subtract(const Duration(days: 45)),
      firstMetDate: now.subtract(const Duration(days: 45)),
      notes: 'Nouvelle rencontre prometteuse. Dialogue très ouvert sur la santé et la contraception.',
      tags: const ['Nouvelle relation'],
    );

    await partnersRepo.saveAll([partner1, partner2, partner3]);

    // 5. Rencontres intimes (8 événements répartis sur 90 jours)
    final encountersRepo = EncountersRepository(storage);
    final encounters = [
      Encounter(
        id: 'enc_01',
        partnerId: partner1.id,
        date: now.subtract(const Duration(days: 3)),
        time: '22:15',
        durationMinutes: 45,
        type: EncounterType.intimate,
        protectionUsed: ProtectionType.condom,
        moodBefore: 4,
        moodAfter: 5,
        notes: 'Moment magique et complice après un dîner en amoureux.',
        tags: const ['Romantique', 'Doux', 'Spontané'],
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Encounter(
        id: 'enc_02',
        partnerId: partner1.id,
        date: now.subtract(const Duration(days: 11)),
        time: '23:00',
        durationMinutes: 35,
        type: EncounterType.intimate,
        protectionUsed: ProtectionType.other,
        contraception: 'Pilule',
        moodBefore: 5,
        moodAfter: 5,
        notes: 'Plein d\'énergie et de connexion émotionnelle.',
        tags: const ['Passionné', 'Week-end'],
        createdAt: now.subtract(const Duration(days: 11)),
      ),
      Encounter(
        id: 'enc_03',
        partnerId: null, // Activité personnelle
        date: now.subtract(const Duration(days: 17)),
        time: '21:30',
        durationMinutes: 20,
        type: EncounterType.personal,
        moodBefore: 3,
        moodAfter: 4,
        notes: 'Moment de reconnexion avec mon propre corps.',
        tags: const ['Bien-être', 'Détente'],
        createdAt: now.subtract(const Duration(days: 17)),
      ),
      Encounter(
        id: 'enc_04',
        partnerId: partner1.id,
        date: now.subtract(const Duration(days: 25)),
        time: '18:45',
        durationMinutes: 50,
        type: EncounterType.intimate,
        protectionUsed: ProtectionType.condom,
        moodBefore: 4,
        moodAfter: 5,
        notes: 'Retrouvailles chaleureuses après une longue semaine de travail.',
        tags: const ['Complice'],
        createdAt: now.subtract(const Duration(days: 25)),
      ),
      Encounter(
        id: 'enc_05',
        partnerId: partner2.id,
        date: now.subtract(const Duration(days: 39)),
        time: '21:00',
        durationMinutes: 40,
        type: EncounterType.intimate,
        protectionUsed: ProtectionType.condom,
        moodBefore: 4,
        moodAfter: 4,
        notes: 'Discussion sincère sur le consentement et les désirs.',
        tags: const ['Bienveillance'],
        createdAt: now.subtract(const Duration(days: 39)),
      ),
      Encounter(
        id: 'enc_06',
        partnerId: partner1.id,
        date: now.subtract(const Duration(days: 52)),
        time: '22:30',
        durationMinutes: 30,
        type: EncounterType.intimate,
        protectionUsed: ProtectionType.other,
        contraception: 'Pilule',
        moodBefore: 3,
        moodAfter: 4,
        tags: const ['Spontané'],
        createdAt: now.subtract(const Duration(days: 52)),
      ),
      Encounter(
        id: 'enc_07',
        partnerId: partner1.id,
        date: now.subtract(const Duration(days: 68)),
        time: '16:00',
        durationMinutes: 60,
        type: EncounterType.intimate,
        protectionUsed: ProtectionType.condom,
        moodBefore: 5,
        moodAfter: 5,
        notes: 'Après-midi pluvieux très réconfortant.',
        tags: const ['Romantique', 'Week-end'],
        createdAt: now.subtract(const Duration(days: 68)),
      ),
      Encounter(
        id: 'enc_08',
        partnerId: partner3.id,
        date: now.subtract(const Duration(days: 82)),
        time: '20:15',
        durationMinutes: 35,
        type: EncounterType.intimate,
        protectionUsed: ProtectionType.condom,
        moodBefore: 4,
        moodAfter: 4,
        notes: 'Première rencontre intime très respectueuse.',
        tags: const ['Découverte'],
        createdAt: now.subtract(const Duration(days: 82)),
      ),
    ];
    await encountersRepo.saveAll(encounters);

    // 6. Cycles menstruels (4 cycles réguliers de 28 jours pour des prédictions parfaites)
    final cycleRepo = MenstrualCycleRepository(storage);
    final cycle1Start = now.subtract(const Duration(days: 88));
    final cycle2Start = now.subtract(const Duration(days: 60));
    final cycle3Start = now.subtract(const Duration(days: 32));
    final cycle4Start = now.subtract(const Duration(days: 4)); // Cycle en cours (J4)

    final cycles = [
      // Cycle 1 (il y a 3 mois)
      MenstrualCycle(
        id: 'cycle_01',
        profileId: 'self',
        startDate: cycle1Start,
        endDate: cycle1Start.add(const Duration(days: 4)),
        flowIntensity: 1, // Moyen
        symptoms: [
          CycleSymptom(date: cycle1Start, type: SymptomType.cramps, intensity: 3),
          CycleSymptom(date: cycle1Start.add(const Duration(days: 1)), type: SymptomType.fatigue, intensity: 2),
          CycleSymptom(date: cycle1Start.add(const Duration(days: 13)), type: SymptomType.moodSwings, intensity: 1),
        ],
        createdAt: cycle1Start,
      ),
      // Cycle 2 (il y a 2 mois)
      MenstrualCycle(
        id: 'cycle_02',
        profileId: 'self',
        startDate: cycle2Start,
        endDate: cycle2Start.add(const Duration(days: 4)),
        flowIntensity: 2, // Abondant
        symptoms: [
          CycleSymptom(date: cycle2Start, type: SymptomType.cramps, intensity: 4),
          CycleSymptom(date: cycle2Start.add(const Duration(days: 2)), type: SymptomType.headache, intensity: 2),
          CycleSymptom(date: cycle2Start.add(const Duration(days: 26)), type: SymptomType.bloating, intensity: 2),
        ],
        createdAt: cycle2Start,
      ),
      // Cycle 3 (le mois dernier)
      MenstrualCycle(
        id: 'cycle_03',
        profileId: 'self',
        startDate: cycle3Start,
        endDate: cycle3Start.add(const Duration(days: 4)),
        flowIntensity: 1, // Moyen
        symptoms: [
          CycleSymptom(date: cycle3Start, type: SymptomType.cramps, intensity: 2),
          CycleSymptom(date: cycle3Start.add(const Duration(days: 13)), type: SymptomType.breastTenderness, intensity: 1),
          CycleSymptom(date: cycle3Start.add(const Duration(days: 25)), type: SymptomType.moodSwings, intensity: 2),
        ],
        createdAt: cycle3Start,
      ),
      // Cycle 4 (en cours : Jour 4 des règles)
      MenstrualCycle(
        id: 'cycle_04',
        profileId: 'self',
        startDate: cycle4Start,
        endDate: cycle4Start.add(const Duration(days: 4)),
        flowIntensity: 0, // Léger aujourd'hui
        symptoms: [
          CycleSymptom(date: cycle4Start, type: SymptomType.cramps, intensity: 3),
          CycleSymptom(date: cycle4Start.add(const Duration(days: 1)), type: SymptomType.fatigue, intensity: 2),
          CycleSymptom(date: now, type: SymptomType.bloating, intensity: 1),
        ],
        createdAt: cycle4Start,
      ),
    ];
    await cycleRepo.saveAll(cycles);

    // 7. Rappels programmés
    final remindersRepo = RemindersRepository(storage);
    final reminders = [
      Reminder(
        id: 'rem_01',
        title: 'Pilule contraceptive quotidienne',
        description: 'Prise régulière à heure fixe.',
        scheduledDate: now,
        scheduledTime: '20:00',
        frequency: ReminderFrequency.daily,
        category: ReminderCategory.medical,
        discretionLevel: 0, // Discret
        isActive: true,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Reminder(
        id: 'rem_02',
        title: 'Règles prévues dans 24 jours',
        description: 'Début estimé de votre prochain cycle menstruel.',
        scheduledDate: now.add(const Duration(days: 24)),
        scheduledTime: '08:00',
        frequency: ReminderFrequency.once,
        category: ReminderCategory.cycle,
        discretionLevel: 1, // Neutre
        isActive: true,
        createdAt: now,
      ),
      Reminder(
        id: 'rem_03',
        title: 'Consultation gynécologique annuelle',
        description: 'Dr. Martin - Bilan de santé intime et frottis de routine.',
        scheduledDate: now.add(const Duration(days: 14)),
        scheduledTime: '14:30',
        frequency: ReminderFrequency.once,
        category: ReminderCategory.medical,
        discretionLevel: 2, // Détaillé
        isActive: true,
        createdAt: now,
      ),
      Reminder(
        id: 'rem_04',
        title: 'Check-in bien-être du soir',
        description: 'Noter l\'humeur et les éventuels symptômes ressentis.',
        scheduledDate: now,
        scheduledTime: '21:30',
        frequency: ReminderFrequency.daily,
        category: ReminderCategory.personal,
        discretionLevel: 0,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    ];
    await remindersRepo.saveAll(reminders);

    // 8. Journal Intime — Écrits réalistes
    final journalRepo = JournalRepository(storage);
    final journalEntries = [
      JournalEntry(
        id: 'journal_01',
        title: 'Retrouver son calme et s\'écouter',
        content:
            'Aujourd\'hui a été une journée douce et apaisante. J\'ai pris le temps de marcher un peu, de respirer profondément et de me recentrer sur ce qui compte vraiment. Apprendre à écouter son corps et ses limites émotionnelles est une véritable libération.',
        date: now,
        createdAt: now,
        updatedAt: now,
        mood: JournalMoodType.peaceful,
        moodIntensity: 4,
        categoryId: 'cat_personal',
        tags: const ['BienEtre', 'Sérénité', 'Respiration'],
        isFavorite: true,
      ),
      JournalEntry(
        id: 'journal_02',
        title: 'Moments précieux et complicité partagée',
        content:
            'Soirée magique avec Lucas. Nous avons longuement discuté de nos envies, de nos projets et de notre complicité. Cette confiance mutuelle que nous construisons pas à pas me réchauffe le cœur. C\'est tellement précieux de pouvoir être 100% soi-même sans aucun jugement.',
        date: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        mood: JournalMoodType.inLove,
        moodIntensity: 5,
        categoryId: 'cat_love',
        tags: const ['Amour', 'Lucas', 'Confiance'],
        isFavorite: true,
      ),
      JournalEntry(
        id: 'journal_03',
        title: 'Poser ses limites avec bienveillance',
        content:
            'Réflexion du soir : savoir dire non sans culpabilité. Longtemps j\'ai eu tendance à faire passer les besoins des autres avant les miens. Aujourd\'hui, j\'ai réussi à exprimer clairement ce dont j\'avais besoin au travail. Une petite victoire personnelle qui fait beaucoup de bien.',
        date: now.subtract(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
        mood: JournalMoodType.grateful,
        moodIntensity: 4,
        categoryId: 'cat_reflections',
        tags: const ['Limites', 'ConfianceEnSoi', 'DéveloppementPersonnel'],
      ),
      JournalEntry(
        id: 'journal_04',
        title: 'Regain d\'énergie et nouveaux objectifs',
        content:
            'Fin des règles hier et regain net d\'énergie physique ! C\'est fou comme la phase folliculaire transforme mon niveau de dynamisme. J\'ai envie de reprendre le sport, de tester de nouvelles recettes saines et de planifier un weekend nature.',
        date: now.subtract(const Duration(days: 18)),
        createdAt: now.subtract(const Duration(days: 18)),
        updatedAt: now.subtract(const Duration(days: 18)),
        mood: JournalMoodType.motivated,
        moodIntensity: 5,
        categoryId: 'cat_goals',
        tags: const ['Énergie', 'Cycle', 'Objectifs', 'Sport'],
      ),
      JournalEntry(
        id: 'journal_05',
        title: 'Fatigue passagère et besoin de repos',
        content:
            'Journée chargée et un peu stressante. J\'ai ressenti une grosse baisse d\'énergie en fin d\'après-midi avec de légères tensions dans le dos. Ce soir : tisane, lecture au chaud et extinction des écrans tôt.',
        date: now.subtract(const Duration(days: 28)),
        createdAt: now.subtract(const Duration(days: 28)),
        updatedAt: now.subtract(const Duration(days: 28)),
        mood: JournalMoodType.tired,
        moodIntensity: 3,
        categoryId: 'cat_personal',
        tags: const ['Fatigue', 'Repos', 'PrendreSoinDeSoi'],
      ),
      JournalEntry(
        id: 'journal_06',
        title: 'Souvenir d\'une escapade lumineuse',
        content:
            'Ce week-end en bord de mer était exactement ce dont j\'avais besoin. Le bruit des vagues, l\'odeur des pins et le soleil qui réchauffe la peau. Ces moments simples sont les plus beaux trésors.',
        date: now.subtract(const Duration(days: 45)),
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 45)),
        mood: JournalMoodType.happy,
        moodIntensity: 4,
        categoryId: 'cat_memories',
        tags: const ['Souvenirs', 'Nature', 'Gratitude'],
      ),
      JournalEntry(
        id: 'journal_07',
        title: 'Pleine confiance et joie communicative',
        content:
            'Journée particulièrement épanouissante en phase ovulatoire. Je me sens alignée, sûre de moi et d\'humeur très sociable. Ces jours de pic sont toujours un plaisir à vivre.',
        date: now.subtract(const Duration(days: 14)),
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(days: 14)),
        mood: JournalMoodType.happy,
        moodIntensity: 5,
        categoryId: 'cat_goals',
        tags: const ['Ovulation', 'Confiance', 'Énergie'],
      ),
      JournalEntry(
        id: 'journal_08',
        title: 'Prendre le temps d\'atterrir',
        content:
            'Fin de journée calme à la maison. Un bon bain chaud, de la musique douce et quelques pages de lecture. Écouter son corps en phase lutéale change vraiment tout.',
        date: now.subtract(const Duration(days: 8)),
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 8)),
        mood: JournalMoodType.peaceful,
        moodIntensity: 4,
        categoryId: 'cat_personal',
        tags: const ['Cocooning', 'Lutéale', 'Calme'],
      ),
      JournalEntry(
        id: 'journal_09',
        title: 'Anxiété passagère et respiration',
        content:
            'Moment de surcharge mentale cet après-midi. Les échéances professionnelles s\'accumulent. J\'ai fait 10 minutes de cohérence cardiaque et marché un peu au grand air pour faire redescendre la pression.',
        date: now.subtract(const Duration(days: 22)),
        createdAt: now.subtract(const Duration(days: 22)),
        updatedAt: now.subtract(const Duration(days: 22)),
        mood: JournalMoodType.anxious,
        moodIntensity: 3,
        categoryId: 'cat_reflections',
        tags: const ['Stress', 'Respiration', 'LâcherPrise'],
      ),
      JournalEntry(
        id: 'journal_10',
        title: 'Gratitude pour les petits bonheurs',
        content:
            'Prendre un café au soleil sur le balcon ce matin. Parfois on cherche le bonheur loin alors qu\'il réside simplement dans ces instants suspendus. Reconnaissante pour ma santé et mes proches.',
        date: now.subtract(const Duration(days: 36)),
        createdAt: now.subtract(const Duration(days: 36)),
        updatedAt: now.subtract(const Duration(days: 36)),
        mood: JournalMoodType.grateful,
        moodIntensity: 5,
        categoryId: 'cat_personal',
        tags: const ['Gratitude', 'PleineConscience', 'Soleil'],
        isFavorite: true,
      ),
      JournalEntry(
        id: 'journal_11',
        title: 'Courbatures et fatigue post-sport',
        content:
            'Séance de yoga dynamique ce midi. Beaucoup de bien mais le corps réclame du repos ce soir. Pas de travail tardif aujourd\'hui.',
        date: now.subtract(const Duration(days: 58)),
        createdAt: now.subtract(const Duration(days: 58)),
        updatedAt: now.subtract(const Duration(days: 58)),
        mood: JournalMoodType.tired,
        moodIntensity: 2,
        categoryId: 'cat_goals',
        tags: const ['Yoga', 'Corps', 'Repos'],
      ),
      JournalEntry(
        id: 'journal_12',
        title: 'Joie des retrouvailles',
        content:
            'Déjeuner avec Camille après presque un mois sans s\'être vus. Rires, confidences et projets de vacances communes. Ce genre de connexion nourrit l\'âme.',
        date: now.subtract(const Duration(days: 72)),
        createdAt: now.subtract(const Duration(days: 72)),
        updatedAt: now.subtract(const Duration(days: 72)),
        mood: JournalMoodType.happy,
        moodIntensity: 4,
        categoryId: 'cat_memories',
        tags: const ['Amitié', 'Camille', 'Joie'],
      ),
    ];
    await journalRepo.saveAll(journalEntries);

    // Rappel d'écriture du soir
    final journalRemindersRepo = JournalRemindersRepository(storage);
    await journalRemindersRepo.save(
      JournalReminder(
        id: 'rem_journal_evening',
        time: '21:00',
        repeatDays: const [1, 2, 3, 4, 5, 6, 7],
        message: 'Prends quelques minutes pour noter tes pensées.',
        isActive: true,
        discretionLevel: 0,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    );

    // 9. Santé Sexuelle & Dépistages (2 bilans négatifs, vaccins HPV et Hépatite B)
    final sexualHealthRepo = SexualHealthRepository(storage);
    final demoScreening1 = StiScreening(
      id: 'screening_01',
      date: now.subtract(const Duration(days: 45)),
      laboratoryOrClinic: 'CeGIDD Saint-Louis',
      status: ScreeningStatus.negative,
      testedStis: const [
        'VIH',
        'Chlamydia',
        'Gonorrhée',
        'Syphilis',
        'Hépatite B',
        'Hépatite C',
      ],
      partnerId: 'partner_lucas_01',
      partnerName: 'Lucas',
      nextReminderDate: now.add(const Duration(days: 135)),
      notes: 'Bilan complet de routine avec Lucas avant d\'envisager l\'arrêt du préservatif.',
      createdAt: now.subtract(const Duration(days: 45)),
    );

    final demoScreening2 = StiScreening(
      id: 'screening_02',
      date: now.subtract(const Duration(days: 220)),
      laboratoryOrClinic: 'Laboratoire de Biologie Médicale Pasteur',
      status: ScreeningStatus.negative,
      testedStis: const [
        'VIH',
        'Chlamydia',
        'Gonorrhée',
        'Syphilis',
      ],
      nextReminderDate: null,
      notes: 'Bilan de santé annuel de contrôle.',
      createdAt: now.subtract(const Duration(days: 220)),
    );

    final demoVaccineHPV = VaccinationRecord(
      id: 'vac_01',
      vaccineName: 'HPV (Papillomavirus - Gardasil 9)',
      doseNumber: 2,
      totalDoses: 3,
      dateAdministered: now.subtract(const Duration(days: 60)),
      nextDoseDate: now.add(const Duration(days: 120)),
      notes: 'Deuxième dose effectuée au centre de santé.',
      createdAt: now.subtract(const Duration(days: 60)),
    );

    final demoVaccineHepB = VaccinationRecord(
      id: 'vac_02',
      vaccineName: 'Hépatite B (Engerix B)',
      doseNumber: 3,
      totalDoses: 3,
      dateAdministered: now.subtract(const Duration(days: 360)),
      nextDoseDate: null,
      notes: 'Schéma vaccinal complet à 3 doses.',
      createdAt: now.subtract(const Duration(days: 360)),
    );

    await sexualHealthRepo.save(
      SexualHealthData(
        screenings: [demoScreening1, demoScreening2],
        vaccinations: [demoVaccineHPV, demoVaccineHepB],
        prep: const PrepRecord(regimen: PrepRegimen.inactive),
      ),
    );

    // 10. Invalider tous les providers Riverpod pour actualisation immédiate de l'interface
    ref.invalidate(preferencesProvider);
    ref.invalidate(partnersProvider);
    ref.invalidate(encountersProvider);
    ref.invalidate(menstrualCycleProvider);
    ref.invalidate(remindersProvider);
    ref.invalidate(journalEntriesProvider);
    ref.invalidate(journalRemindersProvider);
    ref.invalidate(sexualHealthProvider);
    ref.invalidate(correlationReportProvider);
  }
}
