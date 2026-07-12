import 'dart:io';
import 'package:flutter/material.dart';
import '../models/social_account.dart';
import '../theme/app_theme.dart';

void showPostPreview(
  BuildContext context, {
  required String caption,
  required List<SocialAccount> accounts,
  String? imagePath,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PostPreviewModal(
      caption: caption,
      accounts: accounts,
      imagePath: imagePath,
    ),
  );
}

class PostPreviewModal extends StatefulWidget {
  final String caption;
  final List<SocialAccount> accounts;
  final String? imagePath;

  const PostPreviewModal({
    super.key,
    required this.caption,
    required this.accounts,
    this.imagePath,
  });

  @override
  State<PostPreviewModal> createState() => _PostPreviewModalState();
}

class _PostPreviewModalState extends State<PostPreviewModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  static const _platforms = [
    {'key': 'facebook',  'label': 'Facebook',    'color': Color(0xFF1877F2)},
    {'key': 'instagram', 'label': 'Instagram',   'color': Color(0xFFE1306C)},
    {'key': 'x',         'label': 'X (Twitter)', 'color': Color(0xFF000000)},
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _platforms.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: context.cBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(children: [
        // Drag handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.cBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(children: [
            const Icon(Icons.preview_rounded, color: kPrimary, size: 20),
            const SizedBox(width: 8),
            Text('Prévisualisation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.cText)),
          ]),
        ),
        // Platform tabs
        Container(
          color: context.cSurface,
          child: TabBar(
            controller: _tabs,
            tabs: _platforms
                .map((p) => Tab(text: p['label'] as String))
                .toList(),
          ),
        ),
        // Previews
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: _platforms.map((p) => _PlatformPreview(
              platformKey: p['key'] as String,
              platformColor: p['color'] as Color,
              caption: widget.caption,
              accounts: widget.accounts,
              imagePath: widget.imagePath,
            )).toList(),
          ),
        ),
      ]),
    );
  }
}

class _PlatformPreview extends StatelessWidget {
  final String platformKey;
  final Color platformColor;
  final String caption;
  final List<SocialAccount> accounts;
  final String? imagePath;

  const _PlatformPreview({
    required this.platformKey,
    required this.platformColor,
    required this.caption,
    required this.accounts,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final acc = accounts
            .where((a) => a.providerKey == platformKey)
            .firstOrNull ??
        accounts.firstOrNull;
    final name    = acc?.displayName ?? 'Votre compte';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: context.cSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.cBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Account header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              CircleAvatar(
                backgroundColor: platformColor,
                radius: 20,
                child: Text(
                  initial,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(
                    _subtitle(platformKey),
                    style: const TextStyle(fontSize: 12, color: kTextMuted),
                  ),
                ]),
              ),
              const Icon(Icons.more_horiz_rounded, color: kTextMuted),
            ]),
          ),

          // Caption
          if (caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(caption,
                  style: const TextStyle(fontSize: 14, height: 1.5, color: kText)),
            ),

          const SizedBox(height: 10),

          // Image
          if (imagePath != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: Image.file(
                File(imagePath!),
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              height: 140,
              decoration: BoxDecoration(
                color: context.cBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.cBorder),
              ),
              child: const Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.image_outlined, size: 36, color: kTextMuted),
                  SizedBox(height: 6),
                  Text('Aucune image', style: TextStyle(color: kTextMuted, fontSize: 13)),
                ]),
              ),
            ),

          const SizedBox(height: 4),

          // Engagement bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: _EngagementBar(platform: platformKey),
          ),
        ]),
      ),
    );
  }

  String _subtitle(String p) {
    switch (p) {
      case 'facebook':  return 'Public Â· Ã€ l\'instant';
      case 'instagram': return '0 j\'aime Â· Ã€ l\'instant';
      case 'x':         return 'Ã€ l\'instant';
      default:          return 'Ã€ l\'instant';
    }
  }
}

class _EngagementBar extends StatelessWidget {
  final String platform;
  const _EngagementBar({required this.platform});

  @override
  Widget build(BuildContext context) {
    if (platform == 'facebook') {
      return Row(children: [
        _btn(Icons.thumb_up_outlined, 'J\'aime'),
        const SizedBox(width: 20),
        _btn(Icons.chat_bubble_outline_rounded, 'Commenter'),
        const SizedBox(width: 20),
        _btn(Icons.share_outlined, 'Partager'),
      ]);
    }
    if (platform == 'x') {
      return Row(children: [
        _icon(Icons.chat_bubble_outline_rounded),
        const SizedBox(width: 20),
        _icon(Icons.repeat_rounded),
        const SizedBox(width: 20),
        _icon(Icons.favorite_outline_rounded),
        const SizedBox(width: 20),
        _icon(Icons.bar_chart_rounded),
        const Spacer(),
        _icon(Icons.bookmark_outline_rounded),
        const SizedBox(width: 12),
        _icon(Icons.share_outlined),
      ]);
    }
    // Instagram
    return Row(children: [
      _icon(Icons.favorite_outline_rounded),
      const SizedBox(width: 16),
      _icon(Icons.chat_bubble_outline_rounded),
      const SizedBox(width: 16),
      _icon(Icons.send_outlined),
      const Spacer(),
      _icon(Icons.bookmark_outline_rounded),
    ]);
  }

  Widget _icon(IconData icon) =>
      Icon(icon, size: 20, color: kTextMuted);

  Widget _btn(IconData icon, String label) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 18, color: kTextMuted),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: kTextMuted)),
      ]);
}
