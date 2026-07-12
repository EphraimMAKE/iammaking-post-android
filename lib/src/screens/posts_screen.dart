import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/posts_provider.dart';
import '../screens/post_detail_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/post_card.dart';
import '../widgets/shimmer_card.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});
  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  static const _filters = ['all', 'draft', 'scheduled', 'published', 'failed'];
  static const _labels  = ['Tous', 'Brouillons', 'PlanifiÃ©s', 'PubliÃ©s', 'Ã‰chouÃ©s'];

  bool   _searchOpen = false;
  String _query      = '';

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
      backgroundColor: context.cBg,
      appBar: AppBar(
        title: _searchOpen
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Rechercher dans vos postsâ€¦',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: kTextMuted),
                ),
                onChanged: (v) => setState(() => _query = v),
              )
            : const Text('Posts'),
        actions: [
          IconButton(
            icon: Icon(_searchOpen
                ? Icons.close_rounded
                : Icons.search_rounded),
            onPressed: () => setState(() {
              _searchOpen = !_searchOpen;
              if (!_searchOpen) _query = '';
            }),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _labels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: provider.loading
          ? shimmerList(count: 4)
          : RefreshIndicator(
              onRefresh: provider.load,
              child: Column(children: [
                // Stats bar
                if (provider.totalCount > 0 && !_searchOpen)
                  _StatsBar(
                    total:     provider.totalCount,
                    published: provider.publishedCount,
                    scheduled: provider.scheduledCount,
                    drafts:    provider.draftCount,
                    failed:    provider.failedCount,
                    onTap:     _tabs.animateTo,
                  ),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: _filters.map((status) {
                      final posts = provider.byStatus(status, query: _query);
                      if (posts.isEmpty) {
                        return EmptyState(
                          icon: _query.isNotEmpty
                              ? Icons.search_off_rounded
                              : Icons.article_outlined,
                          title: _query.isNotEmpty
                              ? 'Aucun rÃ©sultat'
                              : 'Aucun post ${_labelFor(status)}',
                          subtitle: _query.isNotEmpty
                              ? 'Essaie un autre mot-clÃ©.'
                              : status == 'all'
                                  ? 'Appuie sur + pour crÃ©er ton premier post.'
                                  : 'Pas encore de posts ${_labelFor(status)}.',
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: posts.length,
                        itemBuilder: (_, i) => PostCard(
                          post:      posts[i],
                          onTap:     () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => PostDetailScreen(post: posts[i])),
                          ),
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
      case 'scheduled': return 'planifiÃ©s';
      case 'published': return 'publiÃ©s';
      case 'failed':    return 'Ã©chouÃ©s';
      default:          return '';
    }
  }

  Future<void> _publishAndSnack(
      BuildContext ctx, PostsProvider p, int id) async {
    final res = await p.publish(id);
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(res != null
          ? 'PubliÃ© avec succÃ¨s !'
          : (p.error ?? 'Ã‰chec de publication')),
      backgroundColor: res != null ? kSuccess : kDanger,
    ));
  }
}

// â”€â”€ Stats bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
  Widget build(BuildContext context) => Container(
        color: context.cSurface,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            _Chip(label: 'Total',      count: total,     color: kPrimary,   onTap: () => onTap(0)),
            const SizedBox(width: 8),
            _Chip(label: 'PubliÃ©s',    count: published, color: kSuccess,   onTap: () => onTap(3)),
            const SizedBox(width: 8),
            _Chip(label: 'PlanifiÃ©s',  count: scheduled, color: kWarning,   onTap: () => onTap(2)),
            const SizedBox(width: 8),
            _Chip(label: 'Brouillons', count: drafts,    color: kTextMuted, onTap: () => onTap(1)),
            if (failed > 0) ...[
              const SizedBox(width: 8),
              _Chip(label: 'Ã‰chouÃ©s', count: failed, color: kDanger, onTap: () => onTap(4)),
            ],
          ]),
        ),
      );
}

class _Chip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(count.toString(),
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500, color: color)),
          ]),
        ),
      );
}
