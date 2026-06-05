import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth.dart' as auth;
import '../theme.dart';
import '../widgets/dm_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    final err = await auth.login(_email.text.trim(), _password.text);
    if (!mounted) return;
    if (err != null) {
      setState(() { _loading = false; _error = err; });
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const DmLogo(),
            const SizedBox(height: 32),
            Text('Welcome back', style: kHeading(32)),
            const SizedBox(height: 6),
            Text('Sign in to continue', style: kBody(16, color: kInk3)),
            const SizedBox(height: 40),
            _Field(label: 'Email', controller: _email,
              keyboard: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _Field(label: 'Password', controller: _password,
              obscure: true, onSubmit: _submit),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: kBody(14, color: Colors.red.shade600)),
            ],
            const SizedBox(height: 28),
            DmBtn(
              label: _loading ? 'Signing in…' : 'Sign in',
              full: true,
              disabled: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 14),
            Center(
              child: GestureDetector(
                onTap: () => context.push('/register'),
                child: Text("Don't have an account? Sign up",
                  style: kBody(15, color: kAccentInk, weight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboard;
  final VoidCallback? onSubmit;
  const _Field({required this.label, required this.controller,
    this.obscure = false, this.keyboard = TextInputType.text, this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: kLabel()),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        onSubmitted: onSubmit != null ? (_) => onSubmit!() : null,
        style: kBody(16, color: kInk, weight: FontWeight.w500),
        decoration: InputDecoration(
          filled: true,
          fillColor: kSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kLine, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kLine, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kAccent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    ]);
  }
}
