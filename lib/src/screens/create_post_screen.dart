import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/social_account.dart';
import '../providers/accounts_provider.dart';
import '../providers/posts_provider.dart';
import '../theme/app_theme.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionCtrl   = TextEditingController();
  final Set<int> _selectedAccountIds = {};
  bool _schedule = false;
  DateTime? _scheduledAt;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AccountsProvider>().load());
  }

  @override
  void dispose() { _captionCtrl.dispose(); super.dispose(); }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context, initialDate: now.add(const Duration(hours: 1)),
      firstDate: now, lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(now));
    if (time == null) return;
    setState(() => _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _submit({required bool publishNow}) async {
    if (_captionCtrl.text.trim().isEmpty) {
      _snack('Write something first.', error: true); return;
    }
    if (_selectedAccountIds.isEmpty) {
      _snack('Select at least one account.', error: true); return;
    }
    if (_schedule && _scheduledAt == null) {
      _snack('Choose a date and time.', error: true); return;
    }
    setState(() => _loading = true);
    final ok = await context.read<PostsProvider>().create(
      caption:     _captionCtrl.text.trim(),
      accountIds:  _selectedAccountIds.toList(),
      scheduleAt:  _schedule ? _scheduledAt!.toUtc().toIso8601String() : null,
      publishNow:  publishNow,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      _snack(publishNow ? 'Published!' : _schedule ? 'Scheduled!' : 'Draft saved!');
      _captionCtrl.clear();
      setState(() { _selectedAccountIds.clear(); _schedule = false; _scheduledAt = null; });
    } else {
      _snack(context.read<PostsProvider>().error ?? 'Error', error: true);
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
    final fmt       = DateFormat('EEE MMM d, HH:mm');

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(title: const Text('Create Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Caption
          Container(
            decoration: BoxDecoration(
              color: kSurface, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: _captionCtrl,
              maxLines: 6,
              maxLength: 2200,
              decoration: const InputDecoration.collapsed(
                hintText: "What's on your mind?",
                hintStyle: TextStyle(color: kTextMuted),
              ),
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ),

          const SizedBox(height: 20),
          const Text('Post to', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 10),

          // Account chips
          if (accountsP.loading)
            const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
          else if (accounts.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
              child: const Text('No accounts connected. Go to Accounts to connect social platforms.',
                  style: TextStyle(color: kTextMuted, fontSize: 14)),
            )
          else
            Wrap(
              spacing: 8, runSpacing: 8,
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
                    child: Text(a.displayName[0].toUpperCase(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kPrimary)),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 20),

          // Schedule toggle
          Container(
            decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
            child: Column(children: [
              SwitchListTile(
                title: const Text('Schedule for later', style: TextStyle(fontWeight: FontWeight.w600)),
                value: _schedule,
                activeColor: kPrimary,
                onChanged: (v) => setState(() { _schedule = v; if (!v) _scheduledAt = null; }),
              ),
              if (_schedule) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined, color: kPrimary),
                  title: Text(
                    _scheduledAt != null ? fmt.format(_scheduledAt!) : 'Choose date & time',
                    style: TextStyle(color: _scheduledAt != null ? kText : kTextMuted),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: kTextMuted),
                  onTap: _pickDateTime,
                ),
              ],
            ]),
          ),

          const SizedBox(height: 28),

          // Action buttons
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            Column(children: [
              ElevatedButton.icon(
                onPressed: () => _submit(publishNow: true),
                icon: const Icon(Icons.send_rounded),
                label: const Text('Publish Now'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _submit(publishNow: false),
                icon: const Icon(Icons.bookmark_outline_rounded),
                label: Text(_schedule ? 'Schedule' : 'Save as Draft'),
              ),
            ]),

          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}
