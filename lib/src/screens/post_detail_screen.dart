import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/platform_meta.dart';
import '../models/post.dart';
import '../providers/posts_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final fmt      = DateFormat('EEEE d MMMM y, HH:mm', 'fr');
    final fmtShort = DateFormat('d MMM y, HH:mm');
    final provider = context.read<PostsProvider>();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Détail du post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Supprimer',
            onPressed: () => _confirmDelete(context, provider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Status + dates ───────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: Column(children: [
              Row(children: [
                StatusBadge(post.status),
                const Spacer(),
                Text(
                  'Créé le ${fmtShort.format(post.createdAt.toLocal())}',
                  style: const TextStyle(fontSize: 12, color: kTextMuted),
                ),
              ]),
              if (post.scheduledAt != null) ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(Icons.schedule_rounded, size: 16, color: kWarning),
                  const SizedBox(width: 6),
                  Text(
                    'Planifié le ${fmtShort.format(post.scheduledAt!.toLocal())}',
                    style: const TextStyle(fontSize: 13, color: kWarning, fontWeight: FontWeight.w500),
                  ),
                ]),
              ],
            ]),
          ),

          const SizedBox(height: 14),

          // ── Caption ──────────────────────────────────────────
          if (post.caption.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Text('Caption',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kTextMuted)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: post.caption));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Copié dans le presse-papier'),
                        duration: Duration(seconds: 2),
                      ));
                    },
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.copy_rounded, size: 14, color: kTextMuted),
                      SizedBox(width: 4),
                      Text('Copier', style: TextStyle(fontSize: 12, color: kTextMuted)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(
                  post.caption,
                  style: const TextStyle(fontSize: 15, height: 1.6, color: kText),
                ),
                const SizedBox(height: 10),
                Text(
                  '${post.caption.length} caractères',
                  style: const TextStyle(fontSize: 11, color: kTextMuted),
                ),
              ]),
            ),

          const SizedBox(height: 14),

          // ── Media ────────────────────────────────────────────
          if (post.medias.isNotEmpty)
            _MediaSection(medias: post.medias),

          // ── Accounts ─────────────────────────────────────────
          if (post.accounts.isNotEmpty) ...[
            const Text('Comptes',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kTextMuted)),
            const SizedBox(height: 8),
            ...post.accounts.map((a) {
              final key  = a['provider_key'] as String? ?? '';
              final name = a['display_name'] as String? ?? key;
              final user = a['username'] as String? ?? '';
              final meta = platformMeta(key);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kBorder),
                ),
                child: Row(children: [
                  CircleAvatar(
                    backgroundColor: meta.color,
                    radius: 16,
                    child: Text(meta.abbr,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name.isNotEmpty ? name : meta.label,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    if (user.isNotEmpty)
                      Text('@$user',
                          style: const TextStyle(fontSize: 12, color: kTextMuted)),
                  ]),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

          // ── Actions ──────────────────────────────────────────
          if (post.status == 'draft' || post.status == 'scheduled')
            ElevatedButton.icon(
              onPressed: () => _publish(context, provider),
              icon: const Icon(Icons.send_rounded),
              label: const Text('Publier maintenant'),
            ),

          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: () => _confirmDelete(context, provider),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Supprimer le post'),
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

  Future<void> _publish(BuildContext context, PostsProvider provider) async {
    final res = await provider.publish(post.id);
    if (!context.mounted) return;
    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publié !'), backgroundColor: kSuccess));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(provider.error ?? 'Erreur'), backgroundColor: kDanger));
    }
  }

  void _confirmDelete(BuildContext context, PostsProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ce post ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.delete(post.id);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Supprimer', style: TextStyle(color: kDanger)),
          ),
        ],
      ),
    );
  }
}

class _MediaSection extends StatelessWidget {
  final List<Map<String, dynamic>> medias;
  const _MediaSection({required this.medias});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Médias',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kTextMuted)),
      const SizedBox(height: 8),
      ...medias.map((m) {
        final url = m['url'] as String? ?? m['original_url'] as String? ?? '';
        if (url.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            url,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 80,
              color: kBg,
              child: const Center(child: Icon(Icons.broken_image_outlined, color: kTextMuted)),
            ),
          ),
        );
      }),
      const SizedBox(height: 6),
    ]);
  }
}
