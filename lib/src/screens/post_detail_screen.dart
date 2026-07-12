import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/platform_meta.dart';
import '../models/post.dart';
import '../providers/posts_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';
import 'edit_post_screen.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final fmtShort = DateFormat('d MMM y, HH:mm');
    final provider = context.read<PostsProvider>();

    return Scaffold(
      backgroundColor: context.cBg,
      appBar: AppBar(
        title: const Text('DÃ©tail du post'),
        actions: [
          // Edit (only for draft/scheduled)
          if (post.status == 'draft' || post.status == 'scheduled')
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Modifier',
              onPressed: () async {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditPostScreen(post: post)),
                );
                if (updated == true && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          // More actions menu
          PopupMenuButton<_Action>(
            onSelected: (a) => _handleAction(context, provider, a),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: _Action.duplicate,
                child: ListTile(
                  leading: Icon(Icons.copy_all_rounded),
                  title: Text('Dupliquer'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (post.status == 'failed')
                const PopupMenuItem(
                  value: _Action.retry,
                  child: ListTile(
                    leading: Icon(Icons.refresh_rounded),
                    title: Text('RÃ©essayer'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              const PopupMenuItem(
                value: _Action.delete,
                child: ListTile(
                  leading: Icon(Icons.delete_outline_rounded, color: kDanger),
                  title: Text('Supprimer', style: TextStyle(color: kDanger)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // â”€â”€ Status + dates â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.cBorder),
            ),
            child: Column(children: [
              Row(children: [
                StatusBadge(post.status),
                const Spacer(),
                Text(
                  'CrÃ©Ã© le ${fmtShort.format(post.createdAt.toLocal())}',
                  style: const TextStyle(fontSize: 12, color: kTextMuted),
                ),
              ]),
              if (post.scheduledAt != null) ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(Icons.schedule_rounded, size: 15, color: kWarning),
                  const SizedBox(width: 6),
                  Text(
                    'PlanifiÃ© le ${fmtShort.format(post.scheduledAt!.toLocal())}',
                    style: const TextStyle(
                        fontSize: 13,
                        color: kWarning,
                        fontWeight: FontWeight.w500),
                  ),
                ]),
              ],
            ]),
          ),

          const SizedBox(height: 14),

          // â”€â”€ Caption â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          if (post.caption.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cBorder),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Text('Caption',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kTextMuted)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: post.caption));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('CopiÃ© dans le presse-papier'),
                        duration: Duration(seconds: 2),
                      ));
                    },
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.copy_rounded, size: 14, color: kTextMuted),
                      SizedBox(width: 4),
                      Text('Copier',
                          style: TextStyle(fontSize: 12, color: kTextMuted)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(post.caption,
                    style: const TextStyle(
                        fontSize: 15, height: 1.6, color: kText)),
                const SizedBox(height: 8),
                Text('${post.caption.length} caractÃ¨res',
                    style: const TextStyle(fontSize: 11, color: kTextMuted)),
              ]),
            ),

          const SizedBox(height: 14),

          // â”€â”€ Media â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          if (post.medias.isNotEmpty) _MediaSection(medias: post.medias),

          // â”€â”€ Accounts â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          if (post.accounts.isNotEmpty) ...[
            const Text('Comptes',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kTextMuted)),
            const SizedBox(height: 8),
            ...post.accounts.map((a) {
              final key  = a['provider_key'] as String? ?? '';
              final name = a['display_name'] as String? ?? key;
              final user = a['username']     as String? ?? '';
              final meta = platformMeta(key);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: context.cSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.cBorder),
                ),
                child: Row(children: [
                  CircleAvatar(
                    backgroundColor: meta.color,
                    radius: 16,
                    child: Text(meta.abbr,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(name.isNotEmpty ? name : meta.label,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      if (user.isNotEmpty)
                        Text('@$user',
                            style: const TextStyle(
                                fontSize: 12, color: kTextMuted)),
                    ]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: meta.color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(meta.label,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: meta.color)),
                  ),
                ]),
              );
            }),
          ],

          const SizedBox(height: 20),

          // â”€â”€ Primary action â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          if (post.status == 'draft' || post.status == 'scheduled')
            ElevatedButton.icon(
              onPressed: () => _publish(context, provider),
              icon: const Icon(Icons.send_rounded),
              label: const Text('Publier maintenant'),
            ),

          if (post.status == 'failed')
            ElevatedButton.icon(
              onPressed: () => _retry(context, provider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('RÃ©essayer la publication'),
              style: ElevatedButton.styleFrom(backgroundColor: kWarning),
            ),

          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: () => _duplicate(context, provider),
            icon: const Icon(Icons.copy_all_rounded),
            label: const Text('Dupliquer ce post'),
          ),

          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: () => _confirmDelete(context, provider),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Supprimer'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kDanger,
              side: const BorderSide(color: kDanger),
            ),
          ),

          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  // â”€â”€ Actions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _handleAction(BuildContext ctx, PostsProvider p, _Action a) {
    switch (a) {
      case _Action.duplicate: _duplicate(ctx, p);
      case _Action.retry:     _retry(ctx, p);
      case _Action.delete:    _confirmDelete(ctx, p);
    }
  }

  Future<void> _publish(BuildContext ctx, PostsProvider p) async {
    final res = await p.publish(post.id);
    if (!ctx.mounted) return;
    if (res != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
              content: Text('PubliÃ© !'), backgroundColor: kSuccess));
      Navigator.of(ctx).pop();
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text(p.error ?? 'Erreur'),
          backgroundColor: kDanger));
    }
  }

  Future<void> _retry(BuildContext ctx, PostsProvider p) async {
    final res = await p.publish(post.id);
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(res != null
          ? 'Publication rÃ©ussie !'
          : (p.error ?? 'Nouvelle tentative Ã©chouÃ©e')),
      backgroundColor: res != null ? kSuccess : kDanger,
    ));
    if (res != null && ctx.mounted) Navigator.of(ctx).pop();
  }

  Future<void> _duplicate(BuildContext ctx, PostsProvider p) async {
    final ok = await p.duplicate(post);
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Post dupliquÃ© en brouillon !'
          : (p.error ?? 'Erreur lors de la duplication')),
      backgroundColor: ok ? kSuccess : kDanger,
    ));
  }

  void _confirmDelete(BuildContext ctx, PostsProvider p) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ce post ?'),
        content: const Text('Cette action est irrÃ©versible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await p.delete(post.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Supprimer',
                style: TextStyle(color: kDanger)),
          ),
        ],
      ),
    );
  }
}

enum _Action { duplicate, retry, delete }

class _MediaSection extends StatelessWidget {
  final List<Map<String, dynamic>> medias;
  const _MediaSection({required this.medias});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('MÃ©dias',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kTextMuted)),
      const SizedBox(height: 8),
      ...medias.map((m) {
        final url = m['url'] as String? ??
            m['original_url'] as String? ?? '';
        if (url.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.cBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            url,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 80,
              color: kBg,
              child: const Center(
                  child: Icon(Icons.broken_image_outlined,
                      color: kTextMuted)),
            ),
          ),
        );
      }),
      const SizedBox(height: 6),
    ]);
  }
}
