import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen(_onChanged);
    _check();
  }

  Future<void> _check() async {
    final result = await Connectivity().checkConnectivity();
    _onChanged(result);
  }

  void _onChanged(List<ConnectivityResult> results) {
    final online = results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi    ||
        r == ConnectivityResult.ethernet);
    if (online != _isOnline) {
      _isOnline = online;
      notifyListeners();
    }
  }
}
