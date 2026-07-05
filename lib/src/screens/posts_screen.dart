import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/posts_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/post_card.dart';
import '../widgets/empty_state.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});
  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  static const _filters = ['all', 'draft', 'scheduled', 'published', 'failed'];
  static const _labels  = ['All',  'Drafts','Scheduled', 'Published',  'Failed'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _filters.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<PostsProvider>().load());
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
              child: TabBarView(
                controller: _tabs,
                children: _filters.map((status) {
                  final posts = provider.byStatus(status);
                  if (posts.isEmpty) {
                    return EmptyState(
                      icon: Icons.article_outlined,
                      title: 'No ${status == "all" ? "" : status} posts',
                      subtitle: status == 'all'
                          ? 'Tap the + button to create your first post.'
                          : 'No $status posts yet.',
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
    );
  }

  Future<void> _publishAndSnack(BuildContext ctx, PostsProvider p, int id) async {
    final res = await p.publish(id);
    if (!ctx.mounted) return;
    final ok = res != null;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(ok ? 'Published successfully!' : (p.error ?? 'Publish failed')),
      backgroundColor: ok ? kSuccess : kDanger,
    ));
  }
}
