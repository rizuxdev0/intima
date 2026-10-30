import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/models/journal_mood.dart';

/// Sélecteur d'émotions et réglette d'intensité émotionnelle.
class JournalMoodSelector extends StatelessWidget {
  const JournalMoodSelector({
    super.key,
    required this.selectedMood,
    required this.intensity,
    required this.onMoodSelected,
    required this.onIntensityChanged,
  });

  final JournalMoodType selectedMood;
  final int intensity;
  final ValueChanged<JournalMoodType> onMoodSelected;
  final ValueChanged<int> onIntensityChanged;

  String _getIntensityLabel(int val, String locale) {
    if (locale == 'en') {
      switch (val) {
        case 1:
          return 'Very mild';
        case 2:
          return 'Mild';
        case 3:
          return 'Moderate';
        case 4:
          return 'Intense';
        case 5:
          return 'Very intense';
        default:
          return '';
      }
    }
    switch (val) {
      case 1:
        return 'Très doux';
      case 2:
        return 'Léger';
      case 3:
        return 'Modéré';
      case 4:
        return 'Intense';
      case 5:
        return 'Très puissant';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.mood_rounded, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              locale == 'en' ? 'Mood & Emotion' : 'Humeur & Émotion',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '${selectedMood.emoji} ${locale == 'en' ? selectedMood.labelEn : selectedMood.labelFr}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selectedMood.color,
                fontSize: 13,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Grille horizontale à défilement des 10 émotions
        SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: JournalMoodType.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final mood = JournalMoodType.values[index];
              final isSelected = mood == selectedMood;

              return InkWell(
                onTap: () => onMoodSelected(mood),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? mood.color.withValues(alpha: 0.18)
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? mood.color : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(mood.emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text(
                        locale == 'en' ? mood.labelEn : mood.labelFr,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? mood.color : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Réglette d'intensité
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              locale == 'en' ? 'Emotional Intensity' : 'Intensité ressentie',
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              _getIntensityLabel(intensity, locale),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: selectedMood.color,
              ),
            ),
          ],
        ),

        Slider(
          value: intensity.toDouble(),
          min: 1.0,
          max: 5.0,
          divisions: 4,
          activeColor: selectedMood.color,
          label: intensity.toString(),
          onChanged: (val) => onIntensityChanged(val.round()),
        ),
      ],
    );
  }
}

