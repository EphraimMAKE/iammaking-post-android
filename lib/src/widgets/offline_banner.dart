import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_service.dart';

class OfflineBanner extends StatelessWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final online = context.watch<ConnectivityService>().isOnline;
    return Column(children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: online ? 0 : 36,
        color: const Color(0xFFB71C1C),
        child: online
            ? const SizedBox.shrink()
            : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.wifi_off_rounded, color: Colors.white, size: 14),
                SizedBox(width: 8),
                Text('Pas de connexion internet',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
      ),
      Expanded(child: child),
    ]);
  }
}
