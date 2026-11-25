import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController(), _pass = TextEditingController();
  final _auth = AuthService();
  bool _register = false, _busy = false;

  Future<void> _run(Future<void> Function() f) async {
    setState(() => _busy = true);
    try { await f(); } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(padding: const EdgeInsets.all(24), shrinkWrap: true, children: [
              Icon(Icons.travel_explore, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text('اثرنا', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 24),
              TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 12),
              TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : () => _run(() => _register
                    ? _auth.register(_email.text, _pass.text) : _auth.signIn(_email.text, _pass.text)),
                child: Text(_register ? 'Create account' : 'Sign in'),
              ),
              OutlinedButton.icon(
                  onPressed: _busy ? null : () => _run(_auth.google),
                  icon: const Icon(Icons.g_mobiledata, size: 28), label: const Text('Continue with Google')),
              TextButton(onPressed: () => setState(() => _register = !_register),
                  child: Text(_register ? 'Have an account? Sign in' : 'New here? Register')),
            ]),
          ),
        ),
      );
}
