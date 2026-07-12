import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/platform_meta.dart';
import '../models/social_account.dart';
import '../providers/accounts_provider.dart';
import '../providers/posts_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/caption_templates_sheet.dart';
import '../widgets/post_preview_modal.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionCtrl   = TextEditingController();
  final _picker        = ImagePicker();
  final Set<int> _selectedAccountIds = {};
  int _captionLength = 0;

  bool      _schedule = false;
  DateTime? _scheduledAt;
  XFile?    _image;
  bool      _loading = false;

  @override
  void initState() {
    super.initState();
    _captionCtrl.addListener(() => setState(() => _captionLength = _captionCtrl.text.length));
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AccountsProvider>().load());
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  // ── Char limit ───────────────────────────────────────────────

  int _charLimit(List<SocialAccount> accounts) {
    if (_selectedAccountIds.isEmpty) return 2200;
    final selected = accounts.where((a) => _selectedAccountIds.contains(a.id));
    if (selected.isEmpty) return 2200;
    return selected
        .map((a) => platformMeta(a.providerKey).charLimit)
        .reduce((a, b) => a < b ? a : b);
  }

  // ── Image picker ─────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (file != null) setState(() => _image = file);
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_library_rounded, color: kPrimary),
            title: const Text('Choisir depuis la galerie'),
            onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded, color: kPrimary),
            title: const Text('Prendre une photo'),
            onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
          ),
          if (_image != null)
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: kDanger),
              title: const Text('Supprimer l\'image', style: TextStyle(color: kDanger)),
              onTap: () { Navigator.pop(context); setState(() => _image = null); },
            ),
        ]),
      ),
    );
  }

  // ── Date/time picker ─────────────────────────────────────────

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(now));
    if (time == null) return;
    setState(() => _scheduledAt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  // ── Preview ──────────────────────────────────────────────────

  void _openPreview(List<SocialAccount> accounts) {
    if (_captionCtrl.text.trim().isEmpty && _image == null) {
      _snack('Écris quelque chose ou ajoute une image.', error: true);
      return;
    }
    final selected = accounts
        .where((a) => _selectedAccountIds.contains(a.id))
        .toList();
    showPostPreview(
      context,
      caption:   _captionCtrl.text.trim(),
      accounts:  selected.isNotEmpty ? selected : accounts,
      imagePath: _image?.path,
    );
  }

  // ── Submit ───────────────────────────────────────────────────

  Future<void> _submit({required bool publishNow}) async {
    if (_captionCtrl.text.trim().isEmpty && _image == null) {
      _snack('Écris quelque chose ou ajoute une image.', error: true);
      return;
    }
    if (_selectedAccountIds.isEmpty) {
      _snack('Sélectionne au moins un compte.', error: true);
      return;
    }
    if (_schedule && _scheduledAt == null) {
      _snack('Choisis une date et une heure.', error: true);
      return;
    }
    setState(() => _loading = true);
    final ok = await context.read<PostsProvider>().create(
      caption:    _captionCtrl.text.trim(),
      accountIds: _selectedAccountIds.toList(),
      scheduleAt: _schedule ? _scheduledAt!.toUtc().toIso8601String() : null,
      imagePath:  _image?.path,
      publishNow: publishNow,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      _snack(publishNow
          ? 'Publié !'
          : _schedule
              ? 'Post planifié !'
              : 'Brouillon sauvegardé !');
      _captionCtrl.clear();
      setState(() {
        _selectedAccountIds.clear();
        _schedule = false;
        _scheduledAt = null;
        _image = null;
      });
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

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final accountsP = context.watch<AccountsProvider>();
    final accounts  = accountsP.accounts;
    final fmt       = DateFormat('EEE d MMM, HH:mm');

    return Scaffold(
      backgroundColor: context.cBg,
      appBar: AppBar(
        title: const Text('Créer un post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded),
            tooltip: 'Templates',
            onPressed: () => showCaptionTemplates(
              context,
              onSelected: (text) {
                _captionCtrl.text = text;
                _captionCtrl.selection = TextSelection.collapsed(
                    offset: text.length);
              },
            ),
          ),
          TextButton.icon(
            onPressed: () => _openPreview(accounts),
            icon: const Icon(Icons.preview_rounded, size: 18),
            label: const Text('Aperçu'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Caption ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: context.cSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.cBorder),
            ),
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: _captionCtrl,
              maxLines: 6,
              maxLength: 2200,
              decoration: const InputDecoration.collapsed(
                hintText: "Qu'est-ce que tu veux publier ?",
                hintStyle: TextStyle(color: kTextMuted),
              ),
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ),

          const SizedBox(height: 6),

          // ── Char counter ──────────────────────────────────────
          Builder(builder: (context) {
            final limit    = _charLimit(accounts);
            final remain   = limit - _captionLength;
            final isOver   = remain < 0;
            final isWarn   = remain >= 0 && remain < 30;
            final color    = isOver ? kDanger : isWarn ? kWarning : kTextMuted;
            return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              if (isOver)
                Text('$remain  ', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
              Text(
                '$_captionLength / $limit',
                style: TextStyle(fontSize: 12, color: color, fontWeight: isOver || isWarn ? FontWeight.w700 : FontWeight.normal),
              ),
            ]);
          }),

          const SizedBox(height: 8),

          // ── Image picker / preview ────────────────────────────
          if (_image != null) ...[
            Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_image!.path),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8, right: 8,
                child: GestureDetector(
                  onTap: () => setState(() => _image = null),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
              Positioned(
                bottom: 8, right: 8,
                child: GestureDetector(
                  onTap: _showImageOptions,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('Changer', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ]),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 12),
          ] else ...[
            OutlinedButton.icon(
              onPressed: _showImageOptions,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Ajouter une image'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: kBorder),
                foregroundColor: kTextMuted,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Account selector ──────────────────────────────────
          const Text('Publier sur',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 10),

          if (accountsP.loading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator()))
          else if (accounts.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: context.cSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.cBorder)),
              child: const Text(
                'Aucun compte connecté. Va dans Comptes pour en ajouter.',
                style: TextStyle(color: kTextMuted, fontSize: 14),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: accounts.map((a) {
                final selected = _selectedAccountIds.contains(a.id);
                return FilterChip(
                  label: Text(a.displayName),
                  selected: selected,
                  onSelected: (_) => setState(() => selected
                      ? _selectedAccountIds.remove(a.id)
                      : _selectedAccountIds.add(a.id)),
                  selectedColor: kPrimary.withOpacity(0.15),
                  checkmarkColor: kPrimary,
                  avatar: CircleAvatar(
                    backgroundColor: kPrimary.withOpacity(0.12),
                    radius: 12,
                    child: Text(
                      a.displayName[0].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: kPrimary),
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 20),

          // ── Schedule ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
                color: context.cSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cBorder)),
            child: Column(children: [
              SwitchListTile(
                title: const Text('Planifier pour plus tard',
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
                    style: TextStyle(
                        color: _scheduledAt != null ? kText : kTextMuted),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: kTextMuted),
                  onTap: _pickDateTime,
                ),
              ],
            ]),
          ),

          const SizedBox(height: 28),

          // ── Actions ───────────────────────────────────────────
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            Column(children: [
              ElevatedButton.icon(
                onPressed: () => _submit(publishNow: true),
                icon: const Icon(Icons.send_rounded),
                label: const Text('Publier maintenant'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _submit(publishNow: false),
                icon: const Icon(Icons.bookmark_outline_rounded),
                label: Text(_schedule ? 'Planifier' : 'Sauvegarder en brouillon'),
              ),
            ]),

          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}
