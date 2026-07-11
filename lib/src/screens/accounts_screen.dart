import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/platform_meta.dart';
import '../providers/accounts_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/shimmer_card.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});
  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AccountsProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AccountsProvider>();
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(title: const Text('Comptes')),
      body: p.loading
          ? shimmerList(count: 4, item: () => const ShimmerAccountCard())
          : RefreshIndicator(
              onRefresh: p.load,
              child: p.accounts.isEmpty
                  ? EmptyState(
                      icon: Icons.people_outline_rounded,
                      title: 'Aucun compte connecté',
                      subtitle: 'Connecte tes réseaux sociaux depuis\npost.iammaking.com',
                    )
                  : _AccountList(provider: p),
            ),
    );
  }
}

class _AccountList extends StatelessWidget {
  final AccountsProvider provider;
  const _AccountList({required this.provider});

  // Group by platform
  Map<String, List<dynamic>> get _grouped {
    final map = <String, List<dynamic>>{};
    for (final a in provider.accounts) {
      map.putIfAbsent(a.providerKey, () => []).add(a);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final keys    = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      itemCount: keys.length,
      itemBuilder: (_, i) {
        final key      = keys[i];
        final accounts = grouped[key]!;
        final meta     = platformMeta(key);

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Platform header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(children: [
              CircleAvatar(
                backgroundColor: meta.color,
                radius: 12,
                child: Text(meta.abbr,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 8),
              Text(meta.label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: kText)),
              const SizedBox(width: 6),
              Text('(${accounts.length})',
                  style: const TextStyle(fontSize: 12, color: kTextMuted)),
            ]),
          ),

          // Accounts in this platform
          ...accounts.map((a) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              leading: CircleAvatar(
                backgroundColor: meta.color,
                radius: 22,
                child: Text(
                  a.displayName.isNotEmpty ? a.displayName[0].toUpperCase() : '?',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16),
                ),
              ),
              title: Text(a.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: a.username.isNotEmpty
                  ? Text('@${a.username}',
                      style: const TextStyle(fontSize: 12, color: kTextMuted))
                  : null,
              trailing: _StatusPill(active: a.isActive),
            ),
          )),

          const SizedBox(height: 8),
        ]);
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool active;
  const _StatusPill({required this.active});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? kSuccess.withOpacity(0.10) : kDanger.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? kSuccess.withOpacity(0.30) : kDanger.withOpacity(0.30)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: active ? kSuccess : kDanger,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            active ? 'Actif' : 'Inactif',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: active ? kSuccess : kDanger,
            ),
          ),
        ]),
      );
}
