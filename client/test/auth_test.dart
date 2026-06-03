import 'package:devmatch_client/auth.dart' as auth;
import 'package:devmatch_client/screens/login_screen.dart';
import 'package:devmatch_client/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class _HomeStub extends StatelessWidget {
  const _HomeStub();
  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('Home'));
}

GoRouter _router(Widget startScreen, String startPath) => GoRouter(
      initialLocation: startPath,
      routes: [
        GoRoute(path: startPath, builder: (_, __) => startScreen),
        GoRoute(path: '/', builder: (_, __) => const _HomeStub()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ],
    );

Widget _app(Widget screen, String path) => ShadApp.custom(
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadZincColorScheme.light(),
      ),
      appBuilder: (context) => MaterialApp.router(
        routerConfig: _router(screen, path),
        builder: (context, child) => ShadAppBuilder(child: child!),
      ),
    );

void _mockStorage() {
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async => null);
}

void main() {
  setUp(() {
    auth.loggedIn = false;
    _mockStorage();
  });

  group('LoginScreen', () {
    testWidgets('renders sign in heading', (tester) async {
      await tester.pumpWidget(_app(const LoginScreen(), '/login'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in'), findsWidgets);
    });

    testWidgets('sign in navigates to home', (tester) async {
      await tester.pumpWidget(_app(const LoginScreen(), '/login'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ShadButton, 'Sign in').last);
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });
  });

  group('RegisterScreen', () {
    testWidgets('renders first name step', (tester) async {
      await tester.pumpWidget(_app(const RegisterScreen(), '/register'));
      await tester.pumpAndSettle();
      expect(find.textContaining('first name'), findsOneWidget);
    });

    testWidgets('create account navigates to home', (tester) async {
      await tester.pumpWidget(_app(const RegisterScreen(), '/register'));
      await tester.pumpAndSettle();

      for (var i = 0; i < 4; i++) {
        await tester.tap(find.widgetWithText(ShadButton, 'Continue').last);
        await tester.pumpAndSettle();
      }

      await tester.tap(find.widgetWithText(ShadButton, 'Create account').last);
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });
  });
}
