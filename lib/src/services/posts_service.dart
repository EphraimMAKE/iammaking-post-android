import '../core/api_client.dart';
import '../models/post.dart';

class PostsService {
  static Future<List<Post>> list({int page = 1}) async {
    final data = await ApiClient.get('/posts?per_page=30&page=$page');
    final items = data['data'] as List<dynamic>? ?? [];
    return items.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Post> create({
    required String caption,
    required List<int> accountIds,
    String? scheduleAt,
  }) async {
    final body = <String, dynamic>{
      'caption':     caption,
      'account_ids': accountIds,
      if (scheduleAt != null) 'schedule_at': scheduleAt,
    };
    final data = await ApiClient.post('/posts', body);
    return Post.fromJson(data['data'] as Map<String, dynamic>);
  }

  static Future<Map<String, dynamic>> publish(int postId) async {
    return await ApiClient.post('/posts/$postId/publish', {}) as Map<String, dynamic>;
  }

  static Future<void> delete(int postId) async {
    await ApiClient.delete('/posts/$postId');
  }
}
