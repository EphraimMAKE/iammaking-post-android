import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final themeP    = context.watch<ThemeProvider>();
    final user      = auth.user;
    final initial   = user?.name.isNotEmpty == true
        ? user!.name[0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Profile card ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.cSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.cBorder),
            ),
            child: Row(children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimary, kPrimaryDk],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                    user?.name ?? '—',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: context.cText),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user?.email ?? '',
                    style:
                        TextStyle(fontSize: 13, color: context.cMuted),
                  ),
                ]),
              ),
            ]),
          ),

          const SizedBox(height: 24),

          // ── Apparence ─────────────────────────────────────────
          _Section(
            title: 'Apparence',
            children: [
              _ThemeTile(currentMode: themeP.mode, onChanged: themeP.setMode),
            ],
          ),

          const SizedBox(height: 16),

          // ── Application ───────────────────────────────────────
          _Section(
            title: 'Application',
            children: [
              _Tile(
                icon: Icons.language_outlined,
                label: 'Tableau de bord web',
                subtitle: 'post.iammaking.com',
                onTap: () {},
              ),
              _Tile(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                subtitle: 'Posts planifiés et publiés',
                trailing: Switch(
                  value: true,
                  onChanged: (_) {},
                  activeColor: kPrimary,
                ),
              ),
              _Tile(
                icon: Icons.info_outline_rounded,
                label: 'Version',
                subtitle: '1.6 · build CI',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Support ───────────────────────────────────────────
          _Section(
            title: 'Support',
            children: [
              _Tile(
                icon: Icons.help_outline_rounded,
                label: 'Documentation',
                onTap: () {},
              ),
              _Tile(
                icon: Icons.bug_report_outlined,
                label: 'Signaler un problème',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Compte ────────────────────────────────────────────
          _Section(
            title: 'Compte',
            children: [
              _Tile(
                icon: Icons.logout_rounded,
                label: 'Se déconnecter',
                iconColor: kDanger,
                labelColor: kDanger,
                onTap: () => _confirmLogout(context, auth),
              ),
            ],
          ),

          const SizedBox(height: 32),

          Center(
            child: Column(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.send_rounded, size: 14, color: kPrimary),
                  SizedBox(width: 6),
                  Text('IAMMAKING Post',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kPrimary)),
                ]),
              ),
              const SizedBox(height: 8),
              Text(
                'Publier sur 20+ réseaux en un tap.',
                style: TextStyle(fontSize: 12, color: context.cMuted),
              ),
            ]),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text(
            'Tu devras te reconnecter pour utiliser l\'application.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              auth.logout();
            },
            child: const Text('Déconnexion',
                style: TextStyle(color: kDanger)),
          ),
        ],
      ),
    );
  }
}

// ── Theme selector tile ───────────────────────────────────────────────────────

class _ThemeTile extends StatelessWidget {
  final ThemeMode currentMode;
  final void Function(ThemeMode) onChanged;

  const _ThemeTile({required this.currentMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.palette_outlined, color: context.cMuted, size: 22),
          const SizedBox(width: 14),
          Text('Thème',
              style: TextStyle(
                  color: context.cText, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _ModeChip(
            icon: Icons.phone_android_rounded,
            label: 'Système',
            selected: currentMode == ThemeMode.system,
            onTap: () => onChanged(ThemeMode.system),
          ),
          const SizedBox(width: 8),
          _ModeChip(
            icon: Icons.light_mode_rounded,
            label: 'Clair',
            selected: currentMode == ThemeMode.light,
            onTap: () => onChanged(ThemeMode.light),
          ),
          const SizedBox(width: 8),
          _ModeChip(
            icon: Icons.dark_mode_rounded,
            label: 'Sombre',
            selected: currentMode == ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.dark),
          ),
        ]),
      ]),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? kPrimary.withOpacity(0.12)
                  : context.cBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? kPrimary : context.cBorder,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon,
                  size: 20, color: selected ? kPrimary : context.cMuted),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? kPrimary : context.cMuted,
                ),
              ),
            ]),
          ),
        ),
      );
}

// ── Reusable section & tile ───────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: context.cMuted,
                  letterSpacing: 1.2),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: context.cSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.cBorder),
            ),
            child: Column(
              children: children
                  .asMap()
                  .entries
                  .map((e) => Column(children: [
                        e.value,
                        if (e.key < children.length - 1)
                          Divider(
                              height: 1,
                              indent: 52,
                              color: context.cBorder),
                      ]))
                  .toList(),
            ),
          ),
        ],
      );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _Tile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.iconColor,
    this.labelColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: iconColor ?? context.cMuted, size: 22),
        title: Text(label,
            style: TextStyle(
                color: labelColor ?? context.cText,
                fontWeight: FontWeight.w500)),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: TextStyle(fontSize: 12, color: context.cMuted))
            : null,
        trailing: trailing ??
            (onTap != null
                ? Icon(Icons.chevron_right_rounded,
                    color: context.cMuted)
                : null),
        onTap: onTap,
      );
}
