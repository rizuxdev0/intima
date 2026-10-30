import '../../../core/constants/app_constants.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/storage/encrypted_storage.dart';
import '../domain/models/prep_record.dart';
import '../domain/models/sti_screening.dart';
import '../domain/models/vaccination_record.dart';

/// Données globales de santé sexuelle regroupées.
class SexualHealthData {
  const SexualHealthData({
    this.screenings = const [],
    this.vaccinations = const [],
    this.prep = const PrepRecord(),
  });

  final List<StiScreening> screenings;
  final List<VaccinationRecord> vaccinations;
  final PrepRecord prep;

  Map<String, dynamic> toJson() => {
        'screenings': screenings.map((s) => s.toJson()).toList(),
        'vaccinations': vaccinations.map((v) => v.toJson()).toList(),
        'prep': prep.toJson(),
      };

  factory SexualHealthData.fromJson(Map<String, dynamic> json) {
    return SexualHealthData(
      screenings: (json['screenings'] as List<dynamic>?)
              ?.map((s) => StiScreening.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      vaccinations: (json['vaccinations'] as List<dynamic>?)
              ?.map((v) => VaccinationRecord.fromJson(v as Map<String, dynamic>))
              .toList() ??
          const [],
      prep: json['prep'] != null
          ? PrepRecord.fromJson(json['prep'] as Map<String, dynamic>)
          : const PrepRecord(),
    );
  }
}

/// Repository pour le stockage local et chiffré de la santé sexuelle.
class SexualHealthRepository {
  const SexualHealthRepository(this._storage);

  final EncryptedStorage _storage;

  Future<SexualHealthData> load() async {
    final json = await _storage.readJsonFile(AppConstants.sexualHealthFile);
    if (json == null) return const SexualHealthData();
    return SexualHealthData.fromJson(json);
  }

  Future<void> save(SexualHealthData data) async {
    await _storage.writeJsonFile(
      AppConstants.sexualHealthFile,
      data.toJson(),
    );
  }

  Future<void> saveScreening(StiScreening screening) async {
    final current = await load();
    final list = current.screenings.toList();
    final idx = list.indexWhere((s) => s.id == screening.id);
    if (idx >= 0) {
      list[idx] = screening;
    } else {
      list.insert(0, screening);
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    await save(SexualHealthData(
      screenings: list,
      vaccinations: current.vaccinations,
      prep: current.prep,
    ));

    // Si une date de prochain rappel est configurée, programmer la notification locale discrète
    if (screening.nextReminderDate != null &&
        screening.nextReminderDate!.isAfter(DateTime.now())) {
      try {
        await NotificationService.scheduleNotification(
          id: screening.id.hashCode,
          title: 'Santé & Prévention',
          body: 'Rappel de bilan de santé et dépistage de routine.',
          scheduledDate: screening.nextReminderDate!,
          discretionLevel: 0,
        );
      } catch (_) {}
    }
  }

  Future<void> deleteScreening(String id) async {
    final current = await load();
    final list = current.screenings.where((s) => s.id != id).toList();
    await save(SexualHealthData(
      screenings: list,
      vaccinations: current.vaccinations,
      prep: current.prep,
    ));
    await NotificationService.cancelNotification(id.hashCode);
  }

  Future<void> saveVaccination(VaccinationRecord record) async {
    final current = await load();
    final list = current.vaccinations.toList();
    final idx = list.indexWhere((v) => v.id == record.id);
    if (idx >= 0) {
      list[idx] = record;
    } else {
      list.add(record);
    }
    await save(SexualHealthData(
      screenings: current.screenings,
      vaccinations: list,
      prep: current.prep,
    ));
  }

  Future<void> deleteVaccination(String id) async {
    final current = await load();
    final list = current.vaccinations.where((v) => v.id != id).toList();
    await save(SexualHealthData(
      screenings: current.screenings,
      vaccinations: list,
      prep: current.prep,
    ));
  }

  Future<void> savePrep(PrepRecord prep) async {
    final current = await load();
    await save(SexualHealthData(
      screenings: current.screenings,
      vaccinations: current.vaccinations,
      prep: prep,
    ));
  }
}

