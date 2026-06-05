import 'package:flutter/material.dart';
import '../theme.dart';
import '../data.dart';
import '../widgets/dm_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  final void Function(String role, String headline, List<String> skills, List<String> goals, String avail) onDone;
  final VoidCallback onBack;
  const OnboardingScreen({super.key, required this.onDone, required this.onBack});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  String _role = '';
  String _headline = '';
  final List<String> _skills = [];
  final List<String> _goals = [];
  String _avail = '';

  static const _total = 4;

  bool get _canContinue {
    switch (_step) {
      case 0: return _role.isNotEmpty;
      case 1: return _skills.isNotEmpty;
      case 2: return _goals.isNotEmpty;
      case 3: return _avail.isNotEmpty;
    }
    return false;
  }

  void _next() {
    if (_step < _total - 1) {
      setState(() => _step++);
    } else {
      widget.onDone(_role, _headline, _skills, _goals, _avail);
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = ['What\'s your main role?', 'What are your skills?',
                       'What are you here for?', 'How much time do you have?'];
    final subs = ['Pick the hat you wear most. You can add more later.',
                  'Add the tags that describe what you build. Matching runs on these.',
                  'Choose all that apply.',
                  'Be honest — it sets expectations with teams.'];

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(children: [
          // progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
            child: Row(children: [
              DmNavBtn(onPressed: _step == 0 ? widget.onBack : () => setState(() => _step--)),
              const SizedBox(width: 14),
              Expanded(child: DmProgress(step: _step, total: _total)),
              const SizedBox(width: 14),
              Text('${_step + 1}/$_total', style: kMono(13, color: kInk3).copyWith(fontWeight: FontWeight.w600)),
            ]),
          ),
          // content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween(begin: const Offset(0.08, 0), end: Offset.zero).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: KeyedSubtree(
                key: ValueKey(_step),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(26, 26, 26, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(questions[_step], style: kHeading(27)),
                    const SizedBox(height: 8),
                    Text(subs[_step], style: kBody(15)),
                    const SizedBox(height: 24),
                    _buildStep(),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ),
          ),
          // continue button
          Container(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 40),
            child: DmBtn(
              label: _step == _total - 1 ? 'Finish & start matching' : 'Continue',
              full: true,
              icon: _step == _total - 1 ? Icons.check : Icons.arrow_forward_rounded,
              disabled: !_canContinue,
              onPressed: _next,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _RolePicker(role: _role, headline: _headline,
          onRole: (r) => setState(() => _role = r),
          onHeadline: (h) => setState(() => _headline = h));
      case 1: return _SkillPicker(selected: _skills,
          onToggle: (s) => setState(() => _skills.contains(s) ? _skills.remove(s) : _skills.add(s)));
      case 2: return _GoalPicker(selected: _goals,
          onToggle: (g) => setState(() => _goals.contains(g) ? _goals.remove(g) : _goals.add(g)));
      case 3: return _AvailPicker(selected: _avail,
          onSelect: (a) => setState(() => _avail = a));
    }
    return const SizedBox();
  }
}

// ── Role picker ──────────────────────────────────────────────────
class _RolePicker extends StatefulWidget {
  final String role, headline;
  final ValueChanged<String> onRole, onHeadline;
  const _RolePicker({required this.role, required this.headline, required this.onRole, required this.onHeadline});

  @override
  State<_RolePicker> createState() => _RolePickerState();
}

class _RolePickerState extends State<_RolePicker> {
  late final TextEditingController _headCtrl;
  @override void initState() { super.initState(); _headCtrl = TextEditingController(text: widget.headline); }
  @override void dispose() { _headCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Wrap(spacing: 9, runSpacing: 9, children: kRoles.map((r) {
        final on = widget.role == r;
        return GestureDetector(
          onTap: () => widget.onRole(r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
            decoration: BoxDecoration(
              color: on ? kAccentSoft : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: on ? kAccent : kLine, width: 1.5),
            ),
            child: Text(r, style: kBody(14.5, color: on ? kAccentInk : kInk, weight: FontWeight.w600)),
          ),
        );
      }).toList()),
      const SizedBox(height: 14),
      _inputField(_headCtrl, 'Add a one-line headline (optional)', onChanged: widget.onHeadline),
    ]);
  }
}

// ── Skill picker ─────────────────────────────────────────────────
class _SkillPicker extends StatefulWidget {
  final List<String> selected;
  final ValueChanged<String> onToggle;
  const _SkillPicker({required this.selected, required this.onToggle});

  @override State<_SkillPicker> createState() => _SkillPickerState();
}

class _SkillPickerState extends State<_SkillPicker> {
  String _query = '';
  late final TextEditingController _ctrl;
  @override void initState() { super.initState(); _ctrl = TextEditingController(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final filtered = kAllSkills.where((s) => s.toLowerCase().contains(_query.toLowerCase())).toList();
    final unselected = filtered.where((s) => !widget.selected.contains(s)).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // search
      Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: kLine, width: 1.5)),
        child: TextField(
          controller: _ctrl,
          onChanged: (v) => setState(() => _query = v),
          style: kBody(15, color: kInk),
          decoration: InputDecoration(
            hintText: 'Search skills…', hintStyle: kBody(15, color: kInk3),
            contentPadding: const EdgeInsets.fromLTRB(42, 13, 16, 13),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: kInk3, size: 18),
          ),
        ),
      ),
      if (widget.selected.isNotEmpty) ...[
        const SizedBox(height: 14),
        Wrap(spacing: 7, runSpacing: 7, children: widget.selected.map((s) =>
          GestureDetector(
            onTap: () => widget.onToggle(s),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 7, 10, 7),
              decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(s, style: kMono(13, color: Colors.white)),
                const SizedBox(width: 6),
                const Icon(Icons.close, color: Colors.white, size: 13),
              ]),
            ),
          ),
        ).toList()),
      ],
      const SizedBox(height: 14),
      Wrap(spacing: 7, runSpacing: 7, children: unselected.take(18).map((s) =>
        GestureDetector(
          onTap: () => widget.onToggle(s),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(999),
              border: Border.all(color: kLine, width: 1.5),
            ),
            child: Text('+ $s', style: kMono(13, color: kInk2)),
          ),
        ),
      ).toList()),
    ]);
  }
}

// ── Goal picker ──────────────────────────────────────────────────
class _GoalPicker extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<String> onToggle;
  const _GoalPicker({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Column(children: kGoals.map((g) {
      final on = selected.contains(g.id);
      return GestureDetector(
        onTap: () => onToggle(g.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: on ? kAccentSoft : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: on ? kAccent : kLine, width: 1.5),
          ),
          child: Row(children: [
            Text(g.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(child: Text(g.label, style: kBody(15, color: kInk, weight: FontWeight.w600))),
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: on ? kAccent : Colors.white, shape: BoxShape.circle,
                border: Border.all(color: on ? kAccent : kLine, width: 2),
              ),
              child: on ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
            ),
          ]),
        ),
      );
    }).toList());
  }
}

// ── Avail picker ─────────────────────────────────────────────────
class _AvailPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _AvailPicker({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.8,
      children: kAvail.map((a) {
        final on = selected == a.id;
        return GestureDetector(
          onTap: () => onSelect(a.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: on ? kAccentSoft : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: on ? kAccent : kLine, width: 1.5),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.label, style: kBody(15, color: on ? kAccentInk : kInk, weight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(a.sub, style: kMono(12)),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

Widget _inputField(TextEditingController ctrl, String hint, {ValueChanged<String>? onChanged}) {
  return Container(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: kLine, width: 1.5)),
    child: TextField(
      controller: ctrl,
      onChanged: onChanged,
      style: TextStyle(fontSize: 15, color: kInk),
      decoration: InputDecoration(
        hintText: hint, hintStyle: TextStyle(fontSize: 15, color: kInk3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: InputBorder.none,
      ),
    ),
  );
}
