import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DraftService {
  static const _kCaption    = 'draft_caption';
  static const _kAccounts   = 'draft_account_ids';
  static const _kScheduleAt = 'draft_scheduled_at';

  static Future<void> save({
    required String caption,
    required List<int> accountIds,
    DateTime? scheduledAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (caption.isEmpty && accountIds.isEmpty) {
      await clear();
      return;
    }
    await prefs.setString(_kCaption, caption);
    await prefs.setString(_kAccounts, jsonEncode(accountIds));
    if (scheduledAt != null) {
      await prefs.setString(_kScheduleAt, scheduledAt.toIso8601String());
    } else {
      await prefs.remove(_kScheduleAt);
    }
  }

  static Future<Draft?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final caption = prefs.getString(_kCaption);
    if (caption == null || caption.isEmpty) return null;
    final rawIds    = prefs.getString(_kAccounts);
    final rawDate   = prefs.getString(_kScheduleAt);
    final ids       = rawIds != null
        ? List<int>.from(jsonDecode(rawIds) as List)
        : <int>[];
    final scheduled = rawDate != null ? DateTime.tryParse(rawDate) : null;
    return Draft(caption: caption, accountIds: ids, scheduledAt: scheduled);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCaption);
    await prefs.remove(_kAccounts);
    await prefs.remove(_kScheduleAt);
  }
}

class Draft {
  final String   caption;
  final List<int> accountIds;
  final DateTime? scheduledAt;
  const Draft({required this.caption, required this.accountIds, this.scheduledAt});
}
