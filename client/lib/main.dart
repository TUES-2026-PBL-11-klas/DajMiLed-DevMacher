import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
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
        colorScheme: const ShadZincColorScheme.light(),
      ),
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadZincColorScheme.dark(),
      ),
      appBuilder: (context) {
        return MaterialApp(
          title: 'DevMatch',
          debugShowCheckedModeBanner: false,
          theme: Theme.of(context).copyWith(
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
          ),
          localizationsDelegates: const [
            GlobalShadLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('bg'),
          ],
          builder: (context, child) => ShadAppBuilder(child: child!),
          home: const MatchScreen(),
        );
      },
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
        actions: [
          ShadButton.ghost(
            onPressed: () {},
            child: const Text('Profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: const [
            _HeroPanel(),
            SizedBox(height: 16),
            _SectionHeader(
              title: 'Recommended tasks',
              description: 'Matched by your stack, level, and availability.',
            ),
            SizedBox(height: 12),
            TaskCard(
              match: '86%',
              title: 'Backend API for student project hub',
              project: 'StudyMate MVP',
              description:
                  'Build auth, project endpoints, and PostgreSQL models for a student collaboration platform.',
              skills: ['Java', 'Spring Boot', 'PostgreSQL', 'Docker'],
              meta: 'Remote · Junior+ · 4-6 h/week',
            ),
            SizedBox(height: 12),
            TaskCard(
              match: '74%',
              title: 'Flutter onboarding flow',
              project: 'HackLab Teams',
              description:
                  'Create the mobile onboarding screens for skill selection, availability, and GitHub linking.',
              skills: ['Flutter', 'UI/UX', 'Riverpod'],
              meta: 'Hybrid · Beginner friendly · Weekend',
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      title: Text('Find your next project teammate', style: theme.textTheme.h4),
      description: const Text(
        'Swipe through concrete software tasks and apply with your skills.',
      ),
      footer: Row(
        children: [
          Expanded(
            child: ShadButton(
              onPressed: () {},
              child: const Text('Explore tasks'),
            ),
          ),
          const SizedBox(width: 8),
          ShadButton.outline(
            onPressed: () {},
            child: const Text('Post task'),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            ShadBadge.secondary(child: Text('Students')),
            ShadBadge.secondary(child: Text('Juniors')),
            ShadBadge.secondary(child: Text('Founders')),
            ShadBadge.secondary(child: Text('Open-source')),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.h4),
        const SizedBox(height: 4),
        Text(description, style: theme.textTheme.muted),
      ],
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.match,
    required this.title,
    required this.project,
    required this.description,
    required this.skills,
    required this.meta,
  });

  final String match;
  final String title;
  final String project;
  final String description;
  final List<String> skills;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(title, style: theme.textTheme.h4)),
          const SizedBox(width: 8),
          ShadBadge(child: Text('$match match')),
        ],
      ),
      description: Text(project),
      footer: Row(
        children: [
          ShadButton.outline(
            onPressed: () {},
            child: const Text('Skip'),
          ),
          const SizedBox(width: 8),
          ShadButton.secondary(
            onPressed: () {},
            child: const Text('Save'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ShadButton(
              onPressed: () {},
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map((skill) => ShadBadge.outline(child: Text(skill)))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Text(meta, style: theme.textTheme.muted),
          ],
        ),
      ),
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
        NavigationDestination(
          icon: Icon(LucideIcons.sparkles),
          label: 'Match',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.search),
          label: 'Explore',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.folderKanban),
          label: 'Projects',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.messageCircle),
          label: 'Messages',
        ),
      ],
    );
  }
}
