import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/dm_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onSignup;
  final VoidCallback onSignin;
  const WelcomeScreen({super.key, required this.onSignup, required this.onSignin});

  @override
  Widget build(BuildContext context) {
    const skills = ['Java', 'React', 'Flutter', 'Figma', 'Docker'];
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(children: [
          // main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  // logo + name
                  Row(children: [
                    const DmLogo(size: 42),
                    const SizedBox(width: 11),
                    Text('DevMatch', style: kHeading(26)),
                  ]),
                  const SizedBox(height: 30),
                  // headline
                  Text(
                    'Find the teammates your project is missing.',
                    style: kHeading(40).copyWith(height: 1.04),
                  ),
                  const SizedBox(height: 16),
                  // subtitle
                  Text(
                    'Swipe through real tasks and developers.\nMatch on skills, build something together.',
                    style: kBody(16.5),
                  ),
                  const SizedBox(height: 26),
                  // skill tags
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: skills.map((s) => DmTag(s, tone: DmTagTone.outline)).toList(),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          // buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: Column(children: [
              DmBtn(label: 'Create your profile', full: true,
                icon: Icons.auto_awesome, onPressed: onSignup),
              const SizedBox(height: 11),
              DmBtn(label: 'I already have an account', full: true,
                variant: DmBtnVariant.outline, onPressed: onSignin),
            ]),
          ),
        ]),
      ),
    );
  }
}
