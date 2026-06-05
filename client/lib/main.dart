import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth.dart' as auth;
import 'data.dart';
import 'theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/app_shell.dart';

enum _Screen { welcome, auth, onboarding, app }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  await auth.init();
  runApp(DevMatchApp(startLoggedIn: auth.loggedIn));
}

class DevMatchApp extends StatefulWidget {
  final bool startLoggedIn;
  const DevMatchApp({super.key, required this.startLoggedIn});

  @override State<DevMatchApp> createState() => _DevMatchAppState();
}

class _DevMatchAppState extends State<DevMatchApp> {
  late _Screen _screen;
  bool _isSignup = true;
  UserProfile _profile = UserProfile();

  @override
  void initState() {
    super.initState();
    _screen = widget.startLoggedIn ? _Screen.app : _Screen.welcome;
  }

  void _startAuth(bool signup) => setState(() { _isSignup = signup; _screen = _Screen.auth; });

  void _finishAuth(String name, String email, String password) {
    auth.loggedIn = true;
    setState(() {
      _profile = _profile.copyWith(name: name, email: email, password: password);
      _screen = _isSignup ? _Screen.onboarding : _Screen.app;
    });
  }

  void _finishOnboarding(String role, String headline, List<String> skills, List<String> goals, String avail) {
    setState(() {
      _profile = _profile.copyWith(
        role: role.isNotEmpty ? role : 'Full-stack Developer',
        headline: headline,
        skills: skills.isNotEmpty ? skills : ['React', 'Node.js'],
        goals: goals.isNotEmpty ? goals : ['mvp'],
        avail: avail.isNotEmpty ? avail : 'some',
      );
      _screen = _Screen.app;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevMatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kAccent, brightness: Brightness.light),
        scaffoldBackgroundColor: kBg,
        appBarTheme: const AppBarTheme(backgroundColor: kBg, elevation: 0, scrolledUnderElevation: 0),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: _buildScreen(),
    );
  }

  Widget _buildScreen() {
    switch (_screen) {
      case _Screen.welcome:
        return WelcomeScreen(
          onSignup: () => _startAuth(true),
          onSignin: () => _startAuth(false),
        );
      case _Screen.auth:
        return AuthScreen(
          isSignup: _isSignup,
          onBack: () => setState(() => _screen = _Screen.welcome),
          onDone: _finishAuth,
        );
      case _Screen.onboarding:
        return OnboardingScreen(
          onBack: () => setState(() => _screen = _Screen.auth),
          onDone: _finishOnboarding,
        );
      case _Screen.app:
        return AppShell(profile: _profile);
    }
  }
}
