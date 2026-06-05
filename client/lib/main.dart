import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'auth.dart' as auth;
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/company_swipe.dart';

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

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});
  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  int _tab = 0;

  static const _titles = ['DevMatch', 'Explore', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_tab], style: theme.textTheme.h3),
      ),
      body: switch (_tab) {
        0 => const SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 8, 0, 20),
              child: CompanySwipe(),
            ),
          ),
        2 => const ProfileScreen(),
        1 => const ExploreScreen(),
        _ => const ProfileScreen(),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(LucideIcons.sparkles), label: 'Match'),
          NavigationDestination(icon: Icon(LucideIcons.search), label: 'Explore'),
          NavigationDestination(icon: Icon(LucideIcons.user), label: 'Profile'),
        ],
      ),
    );
  }
}
