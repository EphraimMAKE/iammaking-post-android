import '../core/api_client.dart';
import '../models/social_account.dart';

class AccountsService {
  static Future<List<SocialAccount>> list() async {
    final data = await ApiClient.get('/accounts');
    final items = data['data'] as List<dynamic>? ?? [];
    return items.map((e) => SocialAccount.fromJson(e as Map<String, dynamic>)).toList();
  }
}
