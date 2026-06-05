import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/dm_widgets.dart';

const skills = [
  'Flutter', 'Dart', 'React', 'Vue', 'Angular', 'TypeScript',
  'JavaScript', 'Python', 'Java', 'Kotlin', 'Swift', 'Go',
  'Rust', 'C++', 'Spring Boot', 'Django', 'FastAPI', 'Node.js',
  'PostgreSQL', 'MySQL', 'MongoDB', 'Redis', 'Docker', 'Kubernetes',
  'AWS', 'Firebase', 'UI/UX', 'Figma', 'Git',
];

const _textConfigs = [
  ("What's your\nfirst name?", "This is how you'll appear on your profile.", 'Ada', false),
  ('And your\nlast name?', '', 'Lovelace', false),
  ('Your email?', "You'll use this to sign in.", 'you@example.com', false),
  ('Create a\npassword', 'At least 8 characters.', '••••••••', true),
];

class RegisterTextStep extends StatelessWidget {
  const RegisterTextStep({super.key, required this.step, required this.controller,
    required this.fieldError, required this.onNext});
  final int step;
  final TextEditingController controller;
  final String? fieldError;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final (heading, hint, placeholder, obscure) = _textConfigs[step];
    final keyboard = step == 2
        ? TextInputType.emailAddress
        : obscure ? TextInputType.visiblePassword : TextInputType.name;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(heading, style: kHeading(30)),
        if (hint.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(hint, style: kBody(15, color: kInk3)),
        ],
        const SizedBox(height: 36),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboard,
          autofocus: true,
          onSubmitted: (_) => onNext(),
          style: kBody(16, color: kInk, weight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: kBody(16, color: kInk3),
            filled: true,
            fillColor: kSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kLine, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kLine, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kAccent, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        if (fieldError != null) ...[
          const SizedBox(height: 8),
          Text(fieldError!, style: kBody(14, color: Colors.red.shade600)),
        ],
        const Spacer(),
        DmBtn(label: 'Continue', full: true, onPressed: onNext),
      ]),
    );
  }
}

class RegisterSkillStep extends StatelessWidget {
  const RegisterSkillStep({super.key, required this.selectedSkills, required this.onToggle,
    required this.fieldError, required this.onNext, this.loading = false});
  final Set<String> selectedSkills;
  final void Function(String) onToggle;
  final String? fieldError;
  final VoidCallback onNext;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('What are your\nskills?', style: kHeading(30)),
        const SizedBox(height: 8),
        Text('Select the technologies you work with.', style: kBody(15, color: kInk3)),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: skills.map((skill) {
                final active = selectedSkills.contains(skill);
                return GestureDetector(
                  onTap: () => onToggle(skill),
                  child: DmTag(skill, tone: active ? DmTagTone.accent : DmTagTone.outline),
                );
              }).toList(),
            ),
          ),
        ),
        if (fieldError != null) ...[
          const SizedBox(height: 8),
          Text(fieldError!, style: kBody(14, color: Colors.red.shade600)),
        ],
        const SizedBox(height: 16),
        DmBtn(
          label: loading ? 'Creating account…' : 'Create account',
          full: true,
          disabled: loading,
          onPressed: onNext,
        ),
      ]),
    );
  }
}
