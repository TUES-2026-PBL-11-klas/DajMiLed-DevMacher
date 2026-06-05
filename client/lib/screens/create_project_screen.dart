import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api.dart';
import '../theme.dart';
import '../widgets/dm_widgets.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});
  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final List<_TaskDraft> _tasks = [];
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _addTask() {
    setState(() => _tasks.add(_TaskDraft()));
  }

  void _removeTask(int i) {
    setState(() => _tasks.removeAt(i));
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Project title is required.');
      return;
    }
    setState(() { _submitting = true; _error = null; });

    // 1. Create project
    final projectRes = await ApiClient.createProject(title, _descCtrl.text.trim());
    if (!mounted) return;
    if (projectRes.statusCode != 201) {
      setState(() {
        _submitting = false;
        _error = 'Failed to create project. Please try again.';
      });
      return;
    }
    final project = ProjectDto.fromJson(
        jsonDecode(projectRes.body) as Map<String, dynamic>);

    // 2. Create each task
    for (final draft in _tasks) {
      final taskTitle = draft.titleCtrl.text.trim();
      if (taskTitle.isEmpty) continue;

      final taskRes = await ApiClient.createTask(
          project.id, taskTitle, draft.descCtrl.text.trim());
      if (!mounted) return;
      if (taskRes.statusCode != 201) continue;

      final task = ProjectTaskDto.fromJson(
          jsonDecode(taskRes.body) as Map<String, dynamic>);

      // 3. Add skills to task
      for (final skill in draft.skills) {
        await ApiClient.addSkillToTask(project.id, task.id, skill.id);
        if (!mounted) return;
      }
    }

    if (mounted) context.pushReplacement('/projects/${project.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        leading: DmNavBtn(onPressed: () => context.pop()),
        title: Text('New Project', style: kHeading(18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          // Project details
          _SectionHeader('Project Details'),
          const SizedBox(height: 12),
          _Field(label: 'Title', controller: _titleCtrl, hint: 'e.g. DevMatch Mobile App'),
          const SizedBox(height: 14),
          _Field(label: 'Description', controller: _descCtrl,
              hint: 'What is this project about?', maxLines: 3),

          const SizedBox(height: 28),
          _SectionHeader('Tasks'),
          const SizedBox(height: 12),

          // Task cards
          ...List.generate(_tasks.length, (i) => _TaskCard(
            draft: _tasks[i],
            index: i,
            onRemove: () => _removeTask(i),
          )),

          // Add task button
          GestureDetector(
            onTap: _addTask,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kLine, style: BorderStyle.solid),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.add, color: kAccent, size: 20),
                const SizedBox(width: 6),
                Text('Add task', style: kBody(15, color: kAccentInk, weight: FontWeight.w600)),
              ]),
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: kBody(14, color: Colors.red.shade600)),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: DmBtn(
            label: _submitting ? 'Publishing…' : 'Publish Project',
            full: true,
            disabled: _submitting,
            icon: Icons.rocket_launch_outlined,
            onPressed: _submit,
          ),
        ),
      ),
    );
  }
}

// ── Task draft card ───────────────────────────────────────────────
class _TaskCard extends StatefulWidget {
  final _TaskDraft draft;
  final int index;
  final VoidCallback onRemove;
  const _TaskCard({required this.draft, required this.index, required this.onRemove});
  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  final _searchCtrl = TextEditingController();
  List<SkillTagDto> _suggestions = [];
  String _query = '';
  bool _creating = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    setState(() { _query = q.trim(); _suggestions = []; });
    if (q.trim().isEmpty) return;
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final res = await ApiClient.searchSkills(q.trim());
      if (!mounted) return;
      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body) as List<dynamic>)
            .map((s) => SkillTagDto.fromJson(s as Map<String, dynamic>))
            .toList();
        setState(() => _suggestions = list
            .where((s) => !widget.draft.skills.any((a) => a.id == s.id))
            .toList());
      }
    });
  }

  void _addSkill(SkillTagDto skill) {
    setState(() {
      widget.draft.skills.add(skill);
      _suggestions = [];
      _query = '';
      _searchCtrl.clear();
    });
  }

  Future<void> _createAndAddSkill(String name) async {
    setState(() => _creating = true);
    final res = await ApiClient.createSkill(name);
    if (!mounted) return;
    if (res.statusCode == 201) {
      final skill = SkillTagDto.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
      _addSkill(skill);
    }
    setState(() => _creating = false);
  }

  void _removeSkill(SkillTagDto skill) {
    setState(() => widget.draft.skills.removeWhere((s) => s.id == skill.id));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kLine),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Task ${widget.index + 1}', style: kLabel()),
          const Spacer(),
          GestureDetector(
            onTap: widget.onRemove,
            child: Icon(Icons.close, size: 18, color: Colors.red.shade400),
          ),
        ]),
        const SizedBox(height: 10),
        _Field(label: 'Title', controller: widget.draft.titleCtrl,
            hint: 'e.g. Design onboarding screens'),
        const SizedBox(height: 10),
        _Field(label: 'Description', controller: widget.draft.descCtrl,
            hint: 'What does this task involve?', maxLines: 2),
        const SizedBox(height: 12),

        // Selected skills
        if (widget.draft.skills.isNotEmpty) ...[
          Wrap(spacing: 6, runSpacing: 6,
            children: widget.draft.skills.map((s) => GestureDetector(
              onTap: () => _removeSkill(s),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                DmTag(s.name, tone: DmTagTone.accent, small: true),
                const SizedBox(width: 3),
                Icon(Icons.close, size: 12, color: kAccentInk),
              ]),
            )).toList()),
          const SizedBox(height: 10),
        ],

        // Skill search
        TextField(
          controller: _searchCtrl,
          onChanged: _onSearchChanged,
          style: kBody(14, color: kInk),
          decoration: InputDecoration(
            hintText: 'Search skills…',
            hintStyle: kBody(14, color: kInk3),
            prefixIcon: const Icon(Icons.search, color: kInk3, size: 18),
            filled: true, fillColor: kSurface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kLine)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kLine)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kAccent, width: 2)),
          ),
        ),

        // Suggestions dropdown
        if (_query.isNotEmpty && (_suggestions.isNotEmpty || !_creating))
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kLine),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(15),
                  blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(children: [
              // existing matches
              ..._suggestions.take(5).map((s) => InkWell(
                onTap: () => _addSkill(s),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(children: [
                    Expanded(child: Text(s.name,
                        style: kBody(14, color: kInk, weight: FontWeight.w500))),
                    const Icon(Icons.add, size: 16, color: kAccent),
                  ]),
                ),
              )),
              // create option when no exact match exists
              if (_suggestions.every((s) =>
                  s.name.toLowerCase() != _query.toLowerCase()))
                InkWell(
                  onTap: _creating ? null : () => _createAndAddSkill(_query),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(children: [
                      const Icon(Icons.add_circle_outline, size: 16, color: kAccent),
                      const SizedBox(width: 8),
                      Expanded(child: Text(
                        _creating ? 'Creating…' : 'Create "$_query"',
                        style: kBody(14, color: kAccentInk, weight: FontWeight.w600),
                      )),
                    ]),
                  ),
                ),
            ]),
          ),
      ]),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────
class _TaskDraft {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final List<SkillTagDto> skills = [];
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: kLabel());
}

class _Field extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final int maxLines;
  const _Field({required this.label, required this.controller,
      required this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: kLabel()),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        maxLines: maxLines,
        style: kBody(15, color: kInk, weight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: kBody(15, color: kInk3),
          filled: true, fillColor: kSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kLine, width: 1.5)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kLine, width: 1.5)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kAccent, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    ]);
  }
}
