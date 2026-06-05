import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
          ShadButton.outline(onPressed: () {}, child: const Text('Skip')),
          const SizedBox(width: 8),
          ShadButton.secondary(onPressed: () {}, child: const Text('Save')),
          const SizedBox(width: 8),
          Expanded(
            child: ShadButton(onPressed: () {}, child: const Text('Apply')),
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
              children:
                  skills.map((s) => ShadBadge.outline(child: Text(s))).toList(),
            ),
            const SizedBox(height: 12),
            Text(meta, style: theme.textTheme.muted),
          ],
        ),
      ),
    );
  }
}
