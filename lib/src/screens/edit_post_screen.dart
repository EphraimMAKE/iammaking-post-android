import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/platform_meta.dart';
import '../models/post.dart';
import '../providers/accounts_provider.dart';
import '../providers/posts_provider.dart';
import '../theme/app_theme.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;
  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late final TextEditingController _captionCtrl;
  late final Set<int> _selectedAccountIds;
  bool      _schedule = false;
  DateTime? _scheduledAt;
  bool      _loading = false;
  int       _captionLength = 0;

  @override
  void initState() {
    super.initState();
    _captionCtrl = TextEditingController(text: widget.post.caption);
    _captionLength = widget.post.caption.length;
    _captionCtrl.addListener(
        () => setState(() => _captionLength = _captionCtrl.text.length));

    // Pre-select accounts from the post
    _selectedAccountIds = widget.post.accounts
        .map((a) => a['id'])
        .whereType<int>()
        .toSet();

    // Pre-set schedule if applicable
    if (widget.post.scheduledAt != null) {
      _schedule = true;
      _scheduledAt = widget.post.scheduledAt;
    }

    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AccountsProvider>().load());
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  int _charLimit() {
    final accounts = context.read<AccountsProvider>().accounts;
    if (_selectedAccountIds.isEmpty) return 2200;
    final selected = accounts.where((a) => _selectedAccountIds.contains(a.id));
    if (selected.isEmpty) return 2200;
    return selected
        .map((a) => platformMeta(a.providerKey).charLimit)
        .reduce((a, b) => a < b ? a : b);
  }

  Future<void> _pickDateTime() async {
    final now  = DateTime.now();
    final init = _scheduledAt ?? now.add(const Duration(hours: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: init.isAfter(now) ? init : now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(init));
    if (time == null) return;
    setState(() =>
        _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _save() async {
    if (_captionCtrl.text.trim().isEmpty) {
      _snack('Le caption ne peut pas Ãªtre vide.', error: true);
      return;
    }
    if (_selectedAccountIds.isEmpty) {
      _snack('SÃ©lectionne au moins un compte.', error: true);
      return;
    }
    setState(() => _loading = true);
    final ok = await context.read<PostsProvider>().update(
      postId:     widget.post.id,
      caption:    _captionCtrl.text.trim(),
      accountIds: _selectedAccountIds.toList(),
      scheduleAt: _schedule && _scheduledAt != null
          ? _scheduledAt!.toUtc().toIso8601String()
          : null,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      _snack('Post mis Ã  jour !');
      Navigator.of(context).pop(true);
    } else {
      _snack(context.read<PostsProvider>().error ?? 'Erreur', error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? kDanger : kSuccess,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final accountsP = context.watch<AccountsProvider>();
    final accounts  = accountsP.accounts;
    final fmt       = DateFormat('EEE d MMM, HH:mm');
    final limit     = _charLimit();
    final remain    = limit - _captionLength;
    final isOver    = remain < 0;
    final isWarn    = !isOver && remain < 30;
    final counterColor = isOver ? kDanger : isWarn ? kWarning : kTextMuted;

    return Scaffold(
      backgroundColor: context.cBg,
      appBar: AppBar(
        title: const Text('Modifier le post'),
        actions: [
          if (!_loading)
            TextButton(
              onPressed: _save,
              child: const Text('Enregistrer',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Caption
          Container(
            decoration: BoxDecoration(
              color: context.cSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.cBorder),
            ),
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: _captionCtrl,
              maxLines: 8,
              decoration: const InputDecoration.collapsed(
                hintText: 'Contenu du postâ€¦',
                hintStyle: TextStyle(color: kTextMuted),
              ),
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ),

          const SizedBox(height: 6),

          // Char counter
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text(
              '$_captionLength / $limit',
              style: TextStyle(
                  fontSize: 12,
                  color: counterColor,
                  fontWeight: isOver || isWarn ? FontWeight.w700 : FontWeight.normal),
            ),
          ]),

          const SizedBox(height: 16),

          // Accounts
          const Text('Publier sur',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 10),

          if (accountsP.loading)
            const Center(child: CircularProgressIndicator())
          else if (accounts.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: context.cSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.cBorder)),
              child: const Text('Aucun compte connectÃ©.',
                  style: TextStyle(color: kTextMuted, fontSize: 14)),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: accounts.map((a) {
                final selected = _selectedAccountIds.contains(a.id);
                final meta     = platformMeta(a.providerKey);
                return FilterChip(
                  label: Text(a.displayName),
                  selected: selected,
                  onSelected: (_) => setState(() => selected
                      ? _selectedAccountIds.remove(a.id)
                      : _selectedAccountIds.add(a.id)),
                  selectedColor: meta.color.withOpacity(0.15),
                  checkmarkColor: meta.color,
                  avatar: CircleAvatar(
                    backgroundColor: meta.color,
                    radius: 12,
                    child: Text(meta.abbr,
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 20),

          // Schedule toggle
          Container(
            decoration: BoxDecoration(
                color: context.cSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cBorder)),
            child: Column(children: [
              SwitchListTile(
                title: const Text('Planifier',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                value: _schedule,
                activeColor: kPrimary,
                onChanged: (v) =>
                    setState(() { _schedule = v; if (!v) _scheduledAt = null; }),
              ),
              if (_schedule) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined, color: kPrimary),
                  title: Text(
                    _scheduledAt != null
                        ? fmt.format(_scheduledAt!)
                        : 'Choisir date & heure',
                    style: TextStyle(color: _scheduledAt != null ? kText : kTextMuted),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: kTextMuted),
                  onTap: _pickDateTime,
                ),
              ],
            ]),
          ),

          const SizedBox(height: 28),

          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Enregistrer les modifications'),
            ),

          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}
