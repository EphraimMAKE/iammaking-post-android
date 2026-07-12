import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/notification_service.dart';
import '../services/posts_service.dart';

class PostsProvider extends ChangeNotifier {
  List<Post> _posts = [];
  bool    _loading = false;
  String? _error;

  List<Post> get posts   => _posts;
  bool       get loading => _loading;
  String?    get error   => _error;

  // Stats
  int get totalCount     => _posts.length;
  int get publishedCount => _posts.where((p) => p.status == 'published').length;
  int get scheduledCount => _posts.where((p) => p.status == 'scheduled').length;
  int get draftCount     => _posts.where((p) => p.status == 'draft').length;
  int get failedCount    => _posts.where((p) => p.status == 'failed').length;

  List<Post> byStatus(String status, {String query = ''}) {
    var list = status == 'all' ? _posts : _posts.where((p) => p.status == status).toList();
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((p) => p.caption.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  List<Post> get upcomingScheduled {
    final now = DateTime.now();
    return _posts
        .where((p) => p.status == 'scheduled' && (p.scheduledAt?.isAfter(now) ?? false))
        .toList()
      ..sort((a, b) => (a.scheduledAt ?? a.createdAt).compareTo(b.scheduledAt ?? b.createdAt));
  }

  List<Post> get recentPublished {
    return _posts
        .where((p) => p.status == 'published')
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> load() async {
    _loading = true; _error = null; notifyListeners();
    try {
      _posts = await PostsService.list();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false; notifyListeners();
  }

  Future<bool> create({
    required String caption,
    required List<int> accountIds,
    String? scheduleAt,
    String? imagePath,
    bool publishNow = false,
  }) async {
    try {
      final post = await PostsService.create(
        caption:    caption,
        accountIds: accountIds,
        scheduleAt: scheduleAt,
        imagePath:  imagePath,
      );
      if (publishNow) {
        await PostsService.publish(post.id);
        NotificationService.notifyPublished(caption);
      } else if (scheduleAt != null) {
        final dt = DateTime.tryParse(scheduleAt);
        if (dt != null) NotificationService.notifyScheduled(caption: caption, scheduledAt: dt);
      }
      await load();
      return true;
    } catch (e) {
      _error = e.toString(); notifyListeners(); return false;
    }
  }

  Future<bool> update({
    required int postId,
    required String caption,
    required List<int> accountIds,
    String? scheduleAt,
  }) async {
    try {
      await PostsService.update(
        postId:     postId,
        caption:    caption,
        accountIds: accountIds,
        scheduleAt: scheduleAt,
      );
      await load();
      return true;
    } catch (e) {
      _error = e.toString(); notifyListeners(); return false;
    }
  }

  Future<bool> duplicate(Post post) async {
    final accountIds = post.accounts
        .map((a) => a['id'])
        .whereType<int>()
        .toList();
    return create(
      caption:    post.caption,
      accountIds: accountIds,
      publishNow: false,
    );
  }

  Future<bool> delete(int id) async {
    try {
      await PostsService.delete(id);
      _posts.removeWhere((p) => p.id == id);
      notifyListeners(); return true;
    } catch (e) {
      _error = e.toString(); notifyListeners(); return false;
    }
  }

  Future<Map<String, dynamic>?> publish(int id) async {
    try {
      final res  = await PostsService.publish(id);
      final post = _posts.firstWhere((p) => p.id == id, orElse: () => _posts.first);
      NotificationService.notifyPublished(post.caption);
      await load();
      return res;
    } catch (e) {
      _error = e.toString(); notifyListeners(); return null;
    }
  }
}
