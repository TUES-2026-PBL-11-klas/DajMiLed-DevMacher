import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

const _skills = ['Flutter', 'Dart', 'React', 'TypeScript', 'PostgreSQL', 'Docker', 'AWS'];

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
          color: theme.colorScheme.primary,
          child: Column(children: [
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.background,
              ),
              child: Center(child: Text('DY', style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ))),
            ),
            const SizedBox(height: 14),
            const Text('Daniel Yordanov', style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Full-stack Developer · Sofia, BG',
                style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 14)),
          ]),
        ),

        // Stats
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Row(children: const [
            _Stat('12', 'Applied'),
            _Stat('3', 'Matched'),
            _Stat('8', 'Saved'),
          ]),
        ),

        // Skills
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Skills', style: theme.textTheme.h4),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _skills.map((s) => ShadBadge.secondary(child: Text(s))).toList(),
            ),
          ]),
        ),

        // Settings
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
          child: ShadCard(
            padding: EdgeInsets.zero,
            child: Column(children: const [
              _Tile(icon: LucideIcons.pencil, label: 'Edit profile'),
              _Tile(icon: LucideIcons.bell, label: 'Notifications'),
              _Tile(icon: LucideIcons.shield, label: 'Privacy'),
              Divider(height: 1),
              _Tile(icon: LucideIcons.logOut, label: 'Sign out', destructive: true),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value, label;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Expanded(
      child: Column(children: [
        Text(value, style: theme.textTheme.h3),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.muted),
      ]),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label, this.destructive = false});
  final IconData icon; final String label; final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final color = destructive ? theme.colorScheme.destructive : theme.colorScheme.foreground;
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(label, style: TextStyle(color: color, fontSize: 15)),
      trailing: destructive
          ? null
          : Icon(LucideIcons.chevronRight, size: 16, color: theme.colorScheme.mutedForeground),
      onTap: () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}
