import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorder),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: kPrimary.withOpacity(0.15),
                child: Text(
                  user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kPrimary),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(user?.name ?? 'Unknown',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kText)),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '',
                      style: const TextStyle(fontSize: 14, color: kTextMuted)),
                ]),
              ),
            ]),
          ),

          const SizedBox(height: 24),

          // App info
          _Section(title: 'App', children: [
            _Tile(icon: Icons.language_outlined, label: 'Web Dashboard',
                subtitle: 'post.iammaking.com', onTap: () {}),
            _Tile(icon: Icons.info_outline_rounded, label: 'Version', subtitle: '1.0.1'),
          ]),

          const SizedBox(height: 16),

          // Account actions
          _Section(title: 'Account', children: [
            _Tile(
              icon: Icons.logout_rounded,
              label: 'Sign out',
              iconColor: kDanger,
              labelColor: kDanger,
              onTap: () => _confirmLogout(context, auth),
            ),
          ]),

          const SizedBox(height: 32),

          Center(
            child: Text('IAMMAKING Post · post.iammaking.com',
                style: TextStyle(fontSize: 12, color: kTextMuted.withOpacity(0.6))),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to use the app.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () { Navigator.pop(context); auth.logout(); },
            child: const Text('Sign out', style: TextStyle(color: kDanger)),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(title.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTextMuted, letterSpacing: 1.2)),
      ),
      Container(
        decoration: BoxDecoration(
          color: kSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder),
        ),
        child: Column(children: children),
      ),
    ]);
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback? onTap;

  const _Tile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.iconColor,
    this.labelColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? kTextMuted, size: 22),
      title: Text(label, style: TextStyle(color: labelColor ?? kText, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: kTextMuted)) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right_rounded, color: kTextMuted) : null,
      onTap: onTap,
    );
  }
}
