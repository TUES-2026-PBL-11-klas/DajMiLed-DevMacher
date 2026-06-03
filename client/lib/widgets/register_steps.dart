import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
  const RegisterTextStep({
    super.key,
    required this.step,
    required this.controller,
    required this.fieldError,
    required this.onNext,
  });
  final int step;
  final TextEditingController controller;
  final String? fieldError;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final (heading, hint, placeholder, obscure) = _textConfigs[step];
    final keyboard = step == 2
        ? TextInputType.emailAddress
        : obscure
            ? TextInputType.visiblePassword
            : TextInputType.name;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: theme.textTheme.h2),
          if (hint.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(hint, style: theme.textTheme.muted),
          ],
          const SizedBox(height: 40),
          ShadInput(
            controller: controller,
            placeholder: Text(placeholder),
            keyboardType: keyboard,
            obscureText: obscure,
            autofocus: true,
            onSubmitted: (_) => onNext(),
          ),
          if (fieldError != null) ...[
            const SizedBox(height: 8),
            Text(
              fieldError!,
              style: theme.textTheme.muted
                  .copyWith(color: theme.colorScheme.destructive),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ShadButton(onPressed: onNext, child: const Text('Continue')),
          ),
        ],
      ),
    );
  }
}

class RegisterSkillStep extends StatelessWidget {
  const RegisterSkillStep({
    super.key,
    required this.selectedSkills,
    required this.onToggle,
    required this.fieldError,
    required this.onNext,
  });
  final Set<String> selectedSkills;
  final void Function(String) onToggle;
  final String? fieldError;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What are your\nskills?', style: theme.textTheme.h2),
          const SizedBox(height: 8),
          Text('Select the technologies you work with.',
              style: theme.textTheme.muted),
          const SizedBox(height: 28),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills.map((skill) {
                  final active = selectedSkills.contains(skill);
                  return GestureDetector(
                    onTap: () => onToggle(skill),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? theme.colorScheme.primary : Colors.transparent,
                        border: Border.all(
                            color: active ? theme.colorScheme.primary : theme.colorScheme.border),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(skill,
                          style: TextStyle(
                            color: active ? theme.colorScheme.primaryForeground : theme.colorScheme.foreground,
                            fontSize: 13,
                            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                          )),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (fieldError != null) ...[
            const SizedBox(height: 8),
            Text(fieldError!,
                style: theme.textTheme.muted
                    .copyWith(color: theme.colorScheme.destructive)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ShadButton(
                onPressed: onNext, child: const Text('Create account')),
          ),
        ],
      ),
    );
  }
}
