import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/posts_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/post_card.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});
  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  static const _filters = ['all', 'draft', 'scheduled', 'published', 'failed'];
  static const _labels  = ['Tous', 'Brouillons', 'Planifiés', 'Publiés', 'Échoués'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _filters.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<PostsProvider>().load());
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostsProvider>();
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Posts'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _labels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.load,
              child: Column(children: [
                // ── Stats bar ──────────────────────────────────
                if (provider.totalCount > 0)
                  _StatsBar(
                    total:     provider.totalCount,
                    published: provider.publishedCount,
                    scheduled: provider.scheduledCount,
                    drafts:    provider.draftCount,
                    failed:    provider.failedCount,
                    onTap:     _tabs.animateTo,
                  ),
                // ── Tab content ────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: _filters.map((status) {
                      final posts = provider.byStatus(status);
                      if (posts.isEmpty) {
                        return EmptyState(
                          icon: Icons.article_outlined,
                          title: status == 'all'
                              ? 'Aucun post'
                              : 'Aucun post ${_labelFor(status)}',
                          subtitle: status == 'all'
                              ? 'Appuie sur + pour créer ton premier post.'
                              : 'Pas encore de posts ${_labelFor(status)}.',
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: posts.length,
                        itemBuilder: (_, i) => PostCard(
                          post: posts[i],
                          onDelete:  () => provider.delete(posts[i].id),
                          onPublish: posts[i].status == 'draft'
                              ? () => _publishAndSnack(context, provider, posts[i].id)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ]),
            ),
    );
  }

  String _labelFor(String status) {
    switch (status) {
      case 'draft':     return 'en brouillon';
      case 'scheduled': return 'planifiés';
      case 'published': return 'publiés';
      case 'failed':    return 'échoués';
      default:          return status;
    }
  }

  Future<void> _publishAndSnack(
      BuildContext ctx, PostsProvider p, int id) async {
    final res = await p.publish(id);
    if (!ctx.mounted) return;
    final ok = res != null;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(ok ? 'Publié avec succès !' : (p.error ?? 'Échec de publication')),
      backgroundColor: ok ? kSuccess : kDanger,
    ));
  }
}

// ── Stats bar widget ─────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  final int total, published, scheduled, drafts, failed;
  final void Function(int) onTap;

  const _StatsBar({
    required this.total,
    required this.published,
    required this.scheduled,
    required this.drafts,
    required this.failed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kSurface,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          _StatChip(
            label: 'Total',
            count: total,
            color: kPrimary,
            onTap: () => onTap(0),
          ),
          const SizedBox(width: 8),
          _StatChip(
            label: 'Publiés',
            count: published,
            color: kSuccess,
            onTap: () => onTap(3),
          ),
          const SizedBox(width: 8),
          _StatChip(
            label: 'Planifiés',
            count: scheduled,
            color: kWarning,
            onTap: () => onTap(2),
          ),
          const SizedBox(width: 8),
          _StatChip(
            label: 'Brouillons',
            count: drafts,
            color: kTextMuted,
            onTap: () => onTap(1),
          ),
          if (failed > 0) ...[
            const SizedBox(width: 8),
            _StatChip(
              label: 'Échoués',
              count: failed,
              color: kDanger,
              onTap: () => onTap(4),
            ),
          ],
        ]),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ]),
      ),
    );
  }
}
