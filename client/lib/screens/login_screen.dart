import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../auth.dart' as auth;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _submit(BuildContext context) {
    auth.loggedIn = true;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DevMatch', style: theme.textTheme.muted),
              const SizedBox(height: 16),
              Text('Sign in', style: theme.textTheme.h2),
              const SizedBox(height: 4),
              Text('Welcome back.', style: theme.textTheme.muted),
              const SizedBox(height: 56),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Email', style: theme.textTheme.small),
                  const SizedBox(height: 6),
                  const ShadInput(
                    placeholder: Text('you@example.com'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  Text('Password', style: theme.textTheme.small),
                  const SizedBox(height: 6),
                  const ShadInput(
                    placeholder: Text('••••••••'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  ShadButton(
                    onPressed: () => _submit(context),
                    child: const Text('Sign in'),
                  ),
                  const SizedBox(height: 8),
                  ShadButton.ghost(
                    onPressed: () => context.push('/register'),
                    child: const Text("Don't have an account? Sign up"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
