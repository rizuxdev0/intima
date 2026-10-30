import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router.dart';
import '../../../core/widgets/intima_card.dart';
import '../../../shared/models/partner.dart';
import '../providers/partners_provider.dart';

class PartnersListScreen extends ConsumerStatefulWidget {
  const PartnersListScreen({super.key});

  @override
  ConsumerState<PartnersListScreen> createState() => _PartnersListScreenState();
}

class _PartnersListScreenState extends ConsumerState<PartnersListScreen> {
  String _searchQuery = '';
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final partnersAsync = ref.watch(partnersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.partnersTitle),
        actions: [
          IconButton(
            icon: Icon(_showArchived ? Icons.archive : Icons.archive_outlined),
            tooltip: l10n.partnerShowArchived,
            onPressed: () {
              setState(() => _showArchived = !_showArchived);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.partnerNew),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, size: 20),
                hintText: l10n.commonSearch,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (q) => setState(() => _searchQuery = q.toLowerCase()),
            ),
          ),
          Expanded(
            child: partnersAsync.when(
              data: (partners) {
                var filtered = partners.where((p) {
                  if (_showArchived) {
                    return p.isArchived;
                  } else {
                    return !p.isArchived;
                  }
                }).toList();

                if (_searchQuery.isNotEmpty) {
                  filtered = filtered.where((p) {
                    final name = (p.name ?? '').toLowerCase();
                    return name.contains(_searchQuery);
                  }).toList();
                }

                if (filtered.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.people_outline_rounded,
                    title: l10n.partnersEmpty,
                    actionLabel: l10n.partnersAdd,
                    onAction: () => context.push(AppRoutes.partnerNew),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final partner = filtered[index];
                    return _PartnerTile(partner: partner);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(child: Text(l10n.toastError)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnerTile extends StatelessWidget {
  const _PartnerTile({required this.partner});

  final Partner partner;

  @override
  Widget build(BuildContext context) {
    return IntimaCard(
      onTap: () => context.push('/partners/${partner.id}'),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(partner.color),
            foregroundColor: Colors.white,
            radius: 24,
            child: partner.emoji != null
                ? Text(partner.emoji!, style: const TextStyle(fontSize: 22))
                : Text(
                    partner.displayName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partner.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (partner.tags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    children: partner.tags.map((tag) {
                      return Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 10)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          if (partner.isArchived)
            const Chip(
              label: Text('Archivé', style: TextStyle(fontSize: 10)),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            )
          else
            const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

