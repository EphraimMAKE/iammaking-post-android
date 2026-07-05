import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

const _platformIcons = <String, String>{
  'facebook':   'F', 'instagram': 'I', 'x':       'X',
  'tiktok':     'T', 'linkedin':  'in','youtube':  'Y',
  'pinterest':  'P', 'threads':   'Th','reddit':   'R',
  'tumblr':     'Tu','discord':   'D', 'bluesky':  'B',
  'mastodon':   'M', 'telegram':  'Tg','twitch':   'Tw',
  'snapchat':   'S', 'messenger': 'Mg','deviantart':'Da',
  'xing':       'Xi',
};

class PostCard extends StatelessWidget {
  final Post    post;
  final VoidCallback? onDelete;
  final VoidCallback? onPublish;

  const PostCard({super.key, required this.post, this.onDelete, this.onPublish});

  @override
  Widget build(BuildContext context) {
    final date = post.scheduledAt ?? post.createdAt;
    final fmt  = DateFormat('MMM d, y · HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onLongPress: onDelete != null ? () => _confirmDelete(context) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Status + date row
            Row(children: [
              StatusBadge(post.status),
              const Spacer(),
              Text(fmt.format(date.toLocal()),
                  style: const TextStyle(fontSize: 12, color: kTextMuted)),
            ]),
            const SizedBox(height: 10),

            // Caption
            if (post.caption.isNotEmpty)
              Text(
                post.caption,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: kText, height: 1.5),
              ),

            const SizedBox(height: 12),

            // Platform chips
            if (post.accounts.isNotEmpty)
              Wrap(spacing: 6, children: post.accounts.map((a) {
                final key    = a['provider_key'] as String? ?? '';
                final letter = _platformIcons[key] ?? key.substring(0, 1).toUpperCase();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(letter,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kPrimary)),
                );
              }).toList()),

            // Publish action for drafts
            if (post.status == 'draft' && onPublish != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: onPublish,
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Publish now'),
                  style: ElevatedButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 14)),
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () { Navigator.pop(context); onDelete!(); },
            child: const Text('Delete', style: TextStyle(color: kDanger)),
          ),
        ],
      ),
    );
  }
}
