import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

/// Barre d'outils de mise en forme pour l'éditeur du Journal Intime.
class JournalTextToolbar extends StatelessWidget {
  const JournalTextToolbar({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  void _wrapSelection(String prefix, String suffix) {
    final text = controller.text;
    final selection = controller.selection;

    if (!selection.isValid || selection.start == selection.end) {
      // Pas de sélection : insérer le symbole
      final newText = text.replaceRange(selection.start, selection.end, '$prefix$suffix');
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + prefix.length),
      );
      return;
    }

    final selectedText = text.substring(selection.start, selection.end);
    final replacement = '$prefix$selectedText$suffix';
    final newText = text.replaceRange(selection.start, selection.end, replacement);

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: selection.start + prefix.length,
        extentOffset: selection.start + prefix.length + selectedText.length,
      ),
    );
  }

  void _insertAtBeginningOfLine(String prefix) {
    final text = controller.text;
    final selection = controller.selection;
    final pos = selection.start;

    // Trouver le début de la ligne actuelle
    int lineStart = 0;
    if (pos > 0) {
      final lastNewline = text.lastIndexOf('\n', pos - 1);
      if (lastNewline != -1) {
        lineStart = lastNewline + 1;
      }
    }

    final newText = text.replaceRange(lineStart, lineStart, prefix);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: pos + prefix.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ToolbarButton(
              icon: Icons.format_bold_rounded,
              tooltip: 'Gras (**texte**)',
              onPressed: () => _wrapSelection('**', '**'),
            ),
            _ToolbarButton(
              icon: Icons.format_italic_rounded,
              tooltip: 'Italique (*texte*)',
              onPressed: () => _wrapSelection('*', '*'),
            ),
            const VerticalDivider(width: 16, thickness: 1),
            _ToolbarButton(
              icon: Icons.format_list_bulleted_rounded,
              tooltip: 'Liste à puces',
              onPressed: () => _insertAtBeginningOfLine('• '),
            ),
            _ToolbarButton(
              icon: Icons.format_list_numbered_rounded,
              tooltip: 'Liste numérotée',
              onPressed: () => _insertAtBeginningOfLine('1. '),
            ),
            _ToolbarButton(
              icon: Icons.format_quote_rounded,
              tooltip: 'Citation',
              onPressed: () => _insertAtBeginningOfLine('> '),
            ),
            const VerticalDivider(width: 16, thickness: 1),
            _ToolbarButton(
              icon: Icons.check_box_outlined,
              tooltip: 'Case à cocher',
              onPressed: () => _insertAtBeginningOfLine('[ ] '),
            ),
            _ToolbarButton(
              icon: Icons.horizontal_rule_rounded,
              tooltip: 'Ligne de séparation',
              onPressed: () {
                final pos = controller.selection.start;
                final text = controller.text;
                final newText = text.replaceRange(pos, pos, '\n---\n');
                controller.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(offset: pos + 5),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      splashRadius: 18,
      color: AppColors.primary,
      onPressed: onPressed,
    );
  }
}

