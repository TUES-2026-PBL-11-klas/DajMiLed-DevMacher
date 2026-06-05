import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'auth.dart' as auth;
import 'screens/login_screen.dart';
import 'screens/match_screen.dart';
import 'screens/register_screen.dart';

final _router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';
    if (!auth.loggedIn && !isAuthRoute) return '/login';
    if (auth.loggedIn && isAuthRoute) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/', builder: (_, __) => const MatchScreen()),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await auth.init();
  runApp(const DevMatchApp());
}

class DevMatchApp extends StatelessWidget {
  const DevMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.custom(
      themeMode: ThemeMode.light,
      theme: ShadThemeData(
          brightness: Brightness.light,
          colorScheme: const ShadZincColorScheme.light()),
      darkTheme: ShadThemeData(
          brightness: Brightness.dark,
          colorScheme: const ShadZincColorScheme.dark()),
      appBuilder: (context) => MaterialApp.router(
        title: 'DevMatch',
        debugShowCheckedModeBanner: false,
        theme: Theme.of(context).copyWith(
          appBarTheme: const AppBarTheme(
              centerTitle: false, elevation: 0, scrolledUnderElevation: 0),
        ),
        localizationsDelegates: const [
          GlobalShadLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('bg')],
        builder: (context, child) => ShadAppBuilder(child: child!),
        routerConfig: _router,
      ),
    );
  }
}
