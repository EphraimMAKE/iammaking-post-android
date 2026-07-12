import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'accounts_screen.dart';
import 'create_post_screen.dart';
import 'dashboard_screen.dart';
import 'posts_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  void _goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        onCreateTap: () => _goTo(2),
        onPostsTap:  () => _goTo(1),
      ),
      const PostsScreen(),
      const CreatePostScreen(),
      const AccountsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      floatingActionButton: _index <= 1
          ? FloatingActionButton(
              onPressed: () => _goTo(2),
              backgroundColor: kPrimary,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: const [
          NavigationDestination(
            icon:         Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon:         Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article_rounded),
            label: 'Posts',
          ),
          NavigationDestination(
            icon:         Icon(Icons.add_circle_outline_rounded),
            selectedIcon: Icon(Icons.add_circle_rounded),
            label: 'Créer',
          ),
          NavigationDestination(
            icon:         Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Comptes',
          ),
          NavigationDestination(
            icon:         Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Réglages',
          ),
        ],
      ),
    );
  }
}
