import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/platform_meta.dart';
import '../models/post.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

class PostCard extends StatelessWidget {
  final Post          post;
  final VoidCallback? onDelete;
  final VoidCallback? onPublish;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    this.onDelete,
    this.onPublish,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = post.scheduledAt ?? post.createdAt;
    final fmt  = DateFormat('d MMM y · HH:mm');

    Widget card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Status + date
            Row(children: [
              StatusBadge(post.status),
              const Spacer(),
              if (post.status == 'scheduled')
                const Icon(Icons.schedule_rounded, size: 13, color: kWarning),
              if (post.status == 'scheduled') const SizedBox(width: 4),
              Text(
                fmt.format(date.toLocal()),
                style: const TextStyle(fontSize: 12, color: kTextMuted),
              ),
            ]),

            // Caption
            if (post.caption.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                post.caption,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: kText, height: 1.5),
              ),
            ],

            // Media indicator
            if (post.medias.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.image_outlined, size: 14, color: kTextMuted),
                const SizedBox(width: 4),
                Text(
                  '${post.medias.length} média${post.medias.length > 1 ? "s" : ""}',
                  style: const TextStyle(fontSize: 12, color: kTextMuted),
                ),
              ]),
            ],

            const SizedBox(height: 12),

            // Platform chips
            if (post.accounts.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: post.accounts.map((a) {
                  final key  = a['provider_key'] as String? ?? '';
                  final meta = platformMeta(key);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: meta.color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      meta.abbr,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: meta.color),
                    ),
                  );
                }).toList(),
              ),

            // Publish button for drafts
            if (post.status == 'draft' && onPublish != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: onPublish,
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Publier maintenant'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                ),
              ),
            ],
          ]),
        ),
      ),
    );

    if (onDelete == null) return card;

    return Dismissible(
      key: ValueKey(post.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: kDanger,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
          SizedBox(height: 4),
          Text('Supprimer', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Supprimer ce post ?'),
            content: const Text('Cette action est irréversible.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Supprimer', style: TextStyle(color: kDanger)),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => onDelete!(),
      child: card,
    );
  }
}
