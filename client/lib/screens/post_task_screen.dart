import 'package:flutter/material.dart';
import '../theme.dart';
import '../data.dart';
import '../widgets/dm_widgets.dart';

class PostTaskScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onPublish;
  const PostTaskScreen({super.key, required this.onBack, required this.onPublish});

  @override State<PostTaskScreen> createState() => _PostTaskScreenState();
}

class _PostTaskScreenState extends State<PostTaskScreen> {
  final _titleCtrl = TextEditingController();
  final _projectCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  String _category = 'Backend';
  final List<String> _skills = [];

  static const _cats = ['Backend', 'Frontend', 'Mobile', 'DevOps', 'ML', 'Design'];

  bool get _canPublish =>
      _titleCtrl.text.length > 4 && _projectCtrl.text.length > 1 && _skills.isNotEmpty;

  @override
  void dispose() {
    _titleCtrl.dispose(); _projectCtrl.dispose(); _summaryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(children: [
          // top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(children: [
              DmNavBtn(onPressed: widget.onBack),
              const SizedBox(width: 12),
              Text('Post a task', style: kBody(17, color: kInk, weight: FontWeight.w700)),
            ]),
          ),
          // form
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
              children: [
                _field('TASK TITLE', _titleCtrl, 'e.g. Backend dev for a tournament app'),
                const SizedBox(height: 20),
                _field('PROJECT NAME', _projectCtrl, 'e.g. BracketUp'),
                const SizedBox(height: 20),
                // category
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('CATEGORY', style: kLabel()),
                  const SizedBox(height: 9),
                  Wrap(spacing: 8, runSpacing: 8, children: _cats.map((c) {
                    final on = _category == c;
                    return GestureDetector(
                      onTap: () => setState(() => _category = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: on ? kAccentSoft : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: on ? kAccent : kLine, width: 1.5),
                        ),
                        child: Text(c, style: kBody(14, color: on ? kAccentInk : kInk, weight: FontWeight.w600)),
                      ),
                    );
                  }).toList()),
                ]),
                const SizedBox(height: 20),
                // skills
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('SKILLS NEEDED', style: kLabel()),
                  const SizedBox(height: 9),
                  Wrap(spacing: 7, runSpacing: 7, children: kAllSkills.take(16).map((s) {
                    final on = _skills.contains(s);
                    return GestureDetector(
                      onTap: () => setState(() => on ? _skills.remove(s) : _skills.add(s)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 130),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: on ? kAccent : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: on ? kAccent : kLine, width: 1.5),
                        ),
                        child: Text(on ? s : '+ $s',
                          style: kMono(13, color: on ? Colors.white : kInk2)),
                      ),
                    );
                  }).toList()),
                ]),
                const SizedBox(height: 20),
                // description
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('DESCRIPTION', style: kLabel()),
                  const SizedBox(height: 9),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kLine, width: 1.5),
                    ),
                    child: TextField(
                      controller: _summaryCtrl,
                      maxLines: 4, minLines: 4,
                      style: kBody(15.5, color: kInk),
                      decoration: InputDecoration(
                        hintText: 'What\'s the project, and who are you looking for?',
                        hintStyle: kBody(15.5, color: kInk3),
                        contentPadding: const EdgeInsets.all(16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          // publish button
          Container(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 34),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: kLine, width: 1)),
            ),
            child: ListenableBuilder(
              listenable: Listenable.merge([_titleCtrl, _projectCtrl, _summaryCtrl]),
              builder: (_, __) => DmBtn(
                label: 'Publish task',
                full: true,
                icon: Icons.rocket_launch_rounded,
                disabled: !_canPublish,
                onPressed: widget.onPublish,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: kLabel()),
      const SizedBox(height: 9),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kLine, width: 1.5),
        ),
        child: TextField(
          controller: ctrl,
          style: kBody(15.5, color: kInk),
          decoration: InputDecoration(
            hintText: hint, hintStyle: kBody(15.5, color: kInk3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: InputBorder.none,
          ),
        ),
      ),
    ]);
  }
}
