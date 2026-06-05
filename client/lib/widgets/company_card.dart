import 'package:flutter/material.dart';
import '../theme.dart';
import 'dm_widgets.dart';

class SwipeTask {
  final int projectId;
  final int taskId;
  final String projectTitle;
  final String ownerName;
  final String taskTitle;
  final String? description;
  final List<String> skills;
  final Color color;

  const SwipeTask({
    required this.projectId,
    required this.taskId,
    required this.projectTitle,
    required this.ownerName,
    required this.taskTitle,
    this.description,
    required this.skills,
    required this.color,
  });
}

Color colorFromTitle(String title) {
  const palette = [
    Color(0xFF635BFF), Color(0xFF10B981), Color(0xFF5E6AD2),
    Color(0xFFF24E1E), Color(0xFF0EA5E9), Color(0xFF8B5CF6),
    Color(0xFFF59E0B), Color(0xFF047857),
  ];
  return palette[title.codeUnits.fold(0, (a, b) => a + b) % palette.length];
}

class CompanyCard extends StatelessWidget {
  const CompanyCard({super.key, required this.task});
  final SwipeTask task;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 24, offset: Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          decoration: BoxDecoration(
            color: task.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: Center(child: Text(
                task.projectTitle.isNotEmpty ? task.projectTitle[0].toUpperCase() : '?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: task.color),
              )),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(task.projectTitle,
                style: const TextStyle(color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.w700, letterSpacing: -0.3),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text('by ${task.ownerName}',
                style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13)),
            ])),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('TASK', style: kLabel()),
              const SizedBox(height: 6),
              Text(task.taskTitle,
                style: kBody(18, color: kInk, weight: FontWeight.w700)),
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(task.description!, style: kBody(14, color: kInk2),
                  maxLines: 4, overflow: TextOverflow.ellipsis),
              ],
              const Spacer(),
              if (task.skills.isNotEmpty) ...[
                Text('SKILLS', style: kLabel()),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6,
                  children: task.skills.map((s) => DmTag(s, tone: DmTagTone.outline)).toList()),
              ],
            ]),
          ),
        ),
      ]),
    );
  }
}
