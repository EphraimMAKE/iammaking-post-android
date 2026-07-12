import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/platform_meta.dart';
import '../models/post.dart';
import '../providers/auth_provider.dart';
import '../providers/posts_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shimmer_card.dart';
import '../widgets/status_badge.dart';
import 'post_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onCreateTap;
  final VoidCallback onPostsTap;

  const DashboardScreen({
    super.key,
    required this.onCreateTap,
    required this.onPostsTap,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<PostsProvider>().load());
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthProvider>();
    final posts = context.watch<PostsProvider>();
    final firstName = (auth.user?.name ?? '').split(' ').first;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualiser',
            onPressed: posts.load,
          ),
        ],
      ),
      body: posts.loading
          ? shimmerList(count: 3)
          : RefreshIndicator(
              onRefresh: posts.load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Greeting ──────────────────────────────────
                  _Greeting(greeting: _greeting, name: firstName),

                  const SizedBox(height: 24),

                  // ── Stats grid ────────────────────────────────
                  _StatsGrid(provider: posts),

                  const SizedBox(height: 20),

                  // ── Quick create ──────────────────────────────
                  ElevatedButton.icon(
                    onPressed: widget.onCreateTap,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Créer un nouveau post'),
                  ),

                  const SizedBox(height: 28),

                  // ── Upcoming scheduled ────────────────────────
                  if (posts.upcomingScheduled.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Prochains planifiés',
                      count: posts.scheduledCount,
                      onSeeAll: widget.onPostsTap,
                    ),
                    const SizedBox(height: 8),
                    ...posts.upcomingScheduled.take(3).map((p) =>
                        _ScheduledTile(
                          post: p,
                          onTap: () => _openDetail(context, p),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // ── Recent published ──────────────────────────
                  if (posts.recentPublished.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Publiés récemment',
                      count: posts.publishedCount,
                      onSeeAll: widget.onPostsTap,
                    ),
                    const SizedBox(height: 8),
                    ...posts.recentPublished.take(3).map((p) =>
                        _RecentPostTile(
                          post: p,
                          onTap: () => _openDetail(context, p),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // ── Failed posts alert ────────────────────────
                  if (posts.failedCount > 0)
                    _FailedAlert(
                      count: posts.failedCount,
                      onTap: widget.onPostsTap,
                    ),

                  // ── Empty state ───────────────────────────────
                  if (posts.totalCount == 0)
                    _EmptyDashboard(onCreateTap: widget.onCreateTap),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  void _openDetail(BuildContext context, Post post) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)));
  }
}

// ── Greeting ─────────────────────────────────────────────────────────────────

class _Greeting extends StatelessWidget {
  final String greeting;
  final String name;
  const _Greeting({required this.greeting, required this.name});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting,
              style: const TextStyle(fontSize: 15, color: kTextMuted)),
          const SizedBox(height: 2),
          Text(
            name.isNotEmpty ? name : 'IAMMAKING Post',
            style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800, color: kText),
          ),
        ],
      );
}

// ── Stats grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final PostsProvider provider;
  const _StatsGrid({required this.provider});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _StatCard(
          label: 'Total',
          value: provider.totalCount,
          icon: Icons.article_outlined,
          color: kPrimary,
        ),
        _StatCard(
          label: 'Publiés',
          value: provider.publishedCount,
          icon: Icons.check_circle_outline_rounded,
          color: kSuccess,
        ),
        _StatCard(
          label: 'Planifiés',
          value: provider.scheduledCount,
          icon: Icons.schedule_rounded,
          color: kWarning,
        ),
        _StatCard(
          label: 'Brouillons',
          value: provider.draftCount,
          icon: Icons.edit_outlined,
          color: kTextMuted,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(
              value.toString(),
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1),
            ),
            Text(label,
                style: const TextStyle(fontSize: 12, color: kTextMuted)),
          ]),
        ]),
      );
}

// ── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onSeeAll;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
        Text(title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, color: kText)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Text('$count',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kPrimary)),
        ),
        const Spacer(),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          child: const Text('Voir tout',
              style: TextStyle(fontSize: 13, color: kPrimary)),
        ),
      ]);
}

// ── Scheduled tile ───────────────────────────────────────────────────────────

class _ScheduledTile extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const _ScheduledTile({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dt  = post.scheduledAt ?? post.createdAt;
    final fmt = DateFormat('EEE d MMM · HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: kWarning.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.schedule_rounded, color: kWarning, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (post.caption.isNotEmpty)
                  Text(
                    post.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14, color: kText),
                  ),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 12, color: kTextMuted),
                  const SizedBox(width: 4),
                  Text(fmt.format(dt.toLocal()),
                      style: const TextStyle(fontSize: 12, color: kTextMuted)),
                ]),
              ]),
            ),
            // Platform badges
            if (post.accounts.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: post.accounts.take(3).map((a) {
                  final meta = platformMeta(a['provider_key'] as String? ?? '');
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: CircleAvatar(
                      backgroundColor: meta.color,
                      radius: 10,
                      child: Text(meta.abbr,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.w800)),
                    ),
                  );
                }).toList(),
              ),
          ]),
        ),
      ),
    );
  }
}

// ── Recent published tile ────────────────────────────────────────────────────

class _RecentPostTile extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const _RecentPostTile({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM y');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: kSuccess.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.check_circle_outline_rounded,
                  color: kSuccess, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (post.caption.isNotEmpty)
                  Text(
                    post.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14, color: kText),
                  )
                else
                  Text('[Post sans texte]',
                      style: const TextStyle(
                          fontSize: 14, color: kTextMuted,
                          fontStyle: FontStyle.italic)),
                const SizedBox(height: 3),
                Text(fmt.format(post.createdAt.toLocal()),
                    style: const TextStyle(fontSize: 12, color: kTextMuted)),
              ]),
            ),
            StatusBadge(post.status),
          ]),
        ),
      ),
    );
  }
}

// ── Failed alert ─────────────────────────────────────────────────────────────

class _FailedAlert extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _FailedAlert({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kDanger.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kDanger.withOpacity(0.30)),
          ),
          child: Row(children: [
            const Icon(Icons.error_outline_rounded, color: kDanger, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$count post${count > 1 ? "s ont" : " a"} échoué${count > 1 ? "s" : ""}. Appuie pour voir.',
                style: const TextStyle(
                    fontSize: 13, color: kDanger, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: kDanger),
          ]),
        ),
      );
}

// ── Empty dashboard ───────────────────────────────────────────────────────────

class _EmptyDashboard extends StatelessWidget {
  final VoidCallback onCreateTap;
  const _EmptyDashboard({required this.onCreateTap});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.08),
                shape: BoxShape.circle),
            child: const Icon(Icons.rocket_launch_outlined,
                size: 48, color: kPrimary),
          ),
          const SizedBox(height: 20),
          const Text('Prêt à publier ?',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: kText)),
          const SizedBox(height: 8),
          const Text(
            'Crée ton premier post et publie\nsur tous tes réseaux en un clic.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: kTextMuted, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onCreateTap,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Créer mon premier post'),
          ),
        ]),
      );
}
