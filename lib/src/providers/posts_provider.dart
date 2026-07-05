import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/posts_service.dart';

class PostsProvider extends ChangeNotifier {
  List<Post> _posts = [];
  bool  _loading = false;
  String? _error;

  List<Post> get posts   => _posts;
  bool       get loading => _loading;
  String?    get error   => _error;

  List<Post> byStatus(String status) =>
      status == 'all' ? _posts : _posts.where((p) => p.status == status).toList();

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
    bool publishNow = false,
  }) async {
    try {
      final post = await PostsService.create(
        caption: caption, accountIds: accountIds, scheduleAt: scheduleAt,
      );
      if (publishNow) await PostsService.publish(post.id);
      await load();
      return true;
    } catch (e) {
      _error = e.toString(); notifyListeners(); return false;
    }
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
      final res = await PostsService.publish(id);
      await load();
      return res;
    } catch (e) {
      _error = e.toString(); notifyListeners(); return null;
    }
  }
}
