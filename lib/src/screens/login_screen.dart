import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form     = GlobalKey<FormState>();
  final _email    = TextEditingController();
  final _password = TextEditingController();
  bool _loading   = false;
  bool _obscure   = true;

  @override
  void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await context.read<AuthProvider>().login(_email.text.trim(), _password.text);
    if (!ok && mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 24),

              // Logo
              Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text('IAMMAKING Post',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kText)),
              ]),

              const SizedBox(height: 48),
              const Text('Sign in', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: kText)),
              const SizedBox(height: 6),
              const Text('Publish to 20+ social platforms in one tap.',
                  style: TextStyle(fontSize: 15, color: kTextMuted)),

              const SizedBox(height: 36),

              // Email
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 14),

              // Password
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => (v == null || v.length < 6) ? 'Password too short' : null,
              ),

              const SizedBox(height: 10),

              // Error
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(auth.error!, style: const TextStyle(color: kDanger, fontSize: 13)),
                ),

              const SizedBox(height: 6),

              // Submit
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Sign in'),
              ),

              const SizedBox(height: 32),
              Center(
                child: Text('post.iammaking.com',
                    style: TextStyle(fontSize: 13, color: kTextMuted.withOpacity(0.7))),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
