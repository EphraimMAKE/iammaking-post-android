import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/providers/accounts_provider.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/posts_provider.dart';
import 'src/providers/theme_provider.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/login_screen.dart';
import 'src/services/connectivity_service.dart';
import 'src/services/notification_service.dart';
import 'src/theme/app_theme.dart';
import 'src/widgets/offline_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => PostsProvider()),
        ChangeNotifierProvider(create: (_) => AccountsProvider()),
      ],
      child: const PostApp(),
    ),
  );
}

class PostApp extends StatelessWidget {
  const PostApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().mode;
    return MaterialApp(
      title: 'IAMMAKING Post',
      theme: appTheme(),
      darkTheme: darkTheme(),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    switch (auth.status) {
      case AuthStatus.unknown:
        return const Scaffold(
            body: Center(child: CircularProgressIndicator()));
      case AuthStatus.authenticated:
        return const OfflineBanner(child: HomeScreen());
      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}
