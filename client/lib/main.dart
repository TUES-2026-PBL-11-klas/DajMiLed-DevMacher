import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'auth.dart' as auth;
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/project_detail_screen.dart';
import 'screens/my_applications_screen.dart';
import 'screens/create_project_screen.dart';
import 'widgets/company_swipe.dart';
import 'widgets/dm_widgets.dart';

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
    GoRoute(path: '/projects/create', builder: (_, __) => const CreateProjectScreen()),
    GoRoute(
      path: '/projects/:id',
      builder: (_, state) => ProjectDetailScreen(
        projectId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/applications',
      builder: (_, state) => MyApplicationsScreen(
        initialTab: (state.extra as int?) ?? 0,
      ),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  await auth.init();
  runApp(const DevMatchApp());
}

class DevMatchApp extends StatelessWidget {
  const DevMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DevMatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kAccent, brightness: Brightness.light),
        scaffoldBackgroundColor: kBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: kBg, elevation: 0, scrolledUnderElevation: 0,
          foregroundColor: kInk,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      routerConfig: _router,
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

  static const _titles = ['DevMatch', 'Explore', 'Projects', 'Profile'];
  static const _icons = [Icons.explore_outlined, Icons.search, Icons.folder_outlined, Icons.person_outline];
  static const _activeIcons = [Icons.explore, Icons.search, Icons.folder, Icons.person];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Row(children: [
          const DmLogo(size: 28),
          const SizedBox(width: 10),
          Text(_titles[_tab], style: kHeading(20)),
        ]),
      ),
      body: switch (_tab) {
        0 => const SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: CompanySwipe(),
            ),
          ),
        1 => const ExploreScreen(),
        2 => const MyApplicationsScreen(initialTab: 1),
        3 => const ProfileScreen(),
        _ => const ProfileScreen(),
      },
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kLine, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(children: List.generate(_titles.length, (i) {
              final on = _tab == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(on ? _activeIcons[i] : _icons[i],
                      size: 24, color: on ? kAccent : kInk3),
                    const SizedBox(height: 4),
                    Text(_titles[i],
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: on ? kAccentInk : kInk3,
                      )),
                  ]),
                ),
              );
            })),
          ),
        ),
      ),
    );
  }
}
