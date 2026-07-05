import 'package:flutter/foundation.dart';
import '../models/social_account.dart';
import '../services/accounts_service.dart';

class AccountsProvider extends ChangeNotifier {
  List<SocialAccount> _accounts = [];
  bool    _loading = false;
  String? _error;

  List<SocialAccount> get accounts => _accounts;
  bool                get loading  => _loading;
  String?             get error    => _error;

  Future<void> load() async {
    _loading = true; _error = null; notifyListeners();
    try {
      _accounts = await AccountsService.list();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false; notifyListeners();
  }
}
