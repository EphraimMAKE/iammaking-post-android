import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/accounts_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});
  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AccountsProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AccountsProvider>();
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(title: const Text('Accounts')),
      body: p.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: p.load,
              child: p.accounts.isEmpty
                  ? EmptyState(
                      icon: Icons.people_outline_rounded,
                      title: 'No accounts connected',
                      subtitle: 'Connect your social media accounts from the web dashboard at post.iammaking.com.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: p.accounts.length,
                      itemBuilder: (_, i) {
                        final a = p.accounts[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: kPrimary.withOpacity(0.12),
                              child: Text(
                                a.displayName.isNotEmpty ? a.displayName[0].toUpperCase() : '?',
                                style: const TextStyle(fontWeight: FontWeight.w700, color: kPrimary),
                              ),
                            ),
                            title: Text(a.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              a.username.isNotEmpty ? '@${a.username}  ·  ${a.providerKey}' : a.providerKey,
                              style: const TextStyle(fontSize: 12, color: kTextMuted),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: a.isActive ? kSuccess.withOpacity(0.12) : kDanger.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                a.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700,
                                  color: a.isActive ? kSuccess : kDanger,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
