import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/encrypted_storage.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/widgets/intima_card.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _isLoading = false;

  Future<void> _exportBackup() async {
    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context);

    try {
      final dbPath = await EncryptedStorage.dbDirPath;
      final exportDir = await EncryptedStorage.exportsDirPath;
      final now = DateTime.now().millisecondsSinceEpoch;
      final backupFilePath = '$exportDir/backup_$now${AppConstants.backupExtension}';

      final dbDirectory = Directory(dbPath);
      final files = dbDirectory.listSync().whereType<File>().toList();

      final backupFile = File(backupFilePath);
      final sink = backupFile.openWrite();

      // En-tête de sauvegarde
      sink.write('${AppConstants.backupMagicHeader}\n');
      sink.write('${files.length}\n');

      for (final file in files) {
        final filename = file.uri.pathSegments.last;
        final bytes = await file.readAsBytes();
        sink.write('$filename\n');
        sink.write('${bytes.length}\n');
        sink.add(bytes);
        sink.write('\n');
      }

      await sink.flush();
      await sink.close();

      // Proposer le partage / l'enregistrement externe
      await Share.shareXFiles(
        [XFile(backupFilePath)],
        subject: 'Sauvegarde Intima',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupSuccess)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.toastError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showRestoreDialog() async {
    final l10n = AppLocalizations.of(context);
    final exportDir = await EncryptedStorage.exportsDirPath;
    final dir = Directory(exportDir);
    final backupFiles = dir.existsSync()
        ? dir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith(AppConstants.backupExtension))
            .toList()
        : <File>[];

    if (!mounted) return;

    if (backupFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune sauvegarde locale trouvée dans le dossier exports.'),
        ),
      );
      return;
    }

    // Sélection de la sauvegarde à restaurer
    final selectedFile = await showModalBottomSheet<File>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.backupImport,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: backupFiles.length,
                  itemBuilder: (context, index) {
                    final file = backupFiles[index];
                    final stat = file.statSync();
                    final name = file.uri.pathSegments.last;
                    return ListTile(
                      leading: const Icon(Icons.archive_outlined, color: AppColors.primary),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(
                        '${du.DateUtils.formatDateTime(stat.modified)} • ${(stat.size / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () => Navigator.of(ctx).pop(file),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedFile == null || !mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.commonWarning),
        content: Text(l10n.backupImportWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.backupImportConfirm),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final lines = await selectedFile.readAsLines();

      if (lines.isEmpty || lines.first != AppConstants.backupMagicHeader) {
        throw Exception('Format de sauvegarde invalide');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupRestoreSuccess)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupIntegrityError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.backupTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Carte Exporter
          IntimaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.upload_file_rounded, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      l10n.backupExport,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.backupExportDesc,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _exportBackup,
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: Text(l10n.backupExport),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Carte Importer
          IntimaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.download_rounded, color: AppColors.sage),
                    const SizedBox(width: 12),
                    Text(
                      l10n.backupImport,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.backupImportDesc,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _showRestoreDialog,
                  icon: const Icon(Icons.file_upload_outlined, size: 18),
                  label: Text(l10n.backupImport),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Note sur la sécurité
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              l10n.backupExportNote,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
