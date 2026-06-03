import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../widgets/task_card.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('DevMatch', style: theme.textTheme.h3),
        actions: [
          ShadButton.ghost(onPressed: () {}, child: const Text('Profile')),
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
      title: Text('Find your next developer role', style: theme.textTheme.h4),
      description:
          const Text('Swipe through open tasks and apply with your skills.'),
      footer: Row(
        children: [
          Expanded(
            child: ShadButton(onPressed: () {}, child: const Text('Explore tasks')),
          ),
          const SizedBox(width: 8),
          ShadButton.outline(onPressed: () {}, child: const Text('Post task')),
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
  const _SectionHeader({required this.title, required this.description});
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

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      destinations: const [
        NavigationDestination(icon: Icon(LucideIcons.sparkles), label: 'Match'),
        NavigationDestination(icon: Icon(LucideIcons.search), label: 'Explore'),
        NavigationDestination(
            icon: Icon(LucideIcons.folderKanban), label: 'Projects'),
        NavigationDestination(
            icon: Icon(LucideIcons.messageCircle), label: 'Messages'),
      ],
    );
  }
}
