import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'widgets/company_swipe.dart';

void main() => runApp(const DevMatchApp());

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
      appBuilder: (context) => MaterialApp(
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
        home: const MatchScreen(),
      ),
    );
  }
}

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('DevMatch', style: theme.textTheme.h3),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 20),
          child: CompanySwipe(),
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      destinations: const [
        NavigationDestination(icon: Icon(LucideIcons.sparkles), label: 'Match'),
        NavigationDestination(icon: Icon(LucideIcons.search), label: 'Explore'),
        NavigationDestination(icon: Icon(LucideIcons.user), label: 'Profile'),
      ],
    );
  }
}
