import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api.dart';
import '../auth.dart' as auth;
import '../theme.dart';
import '../widgets/dm_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserDto? _user;
  bool _loading = true;
  bool _editingSkills = false;
  final _skillSearchCtrl = TextEditingController();
  List<SkillTagDto> _suggestions = [];
  String _skillQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _skillSearchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final res = await ApiClient.get('/api/users/me');
    if (!mounted) return;
    if (res.statusCode == 401) { context.go('/login'); return; }
    if (res.statusCode == 200) {
      setState(() {
        _user = UserDto.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _onSkillSearchChanged(String q) {
    _debounce?.cancel();
    setState(() { _skillQuery = q.trim(); _suggestions = []; });
    if (q.trim().isEmpty) return;
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final res = await ApiClient.searchSkills(q.trim());
      if (!mounted) return;
      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body) as List<dynamic>)
            .map((s) => SkillTagDto.fromJson(s as Map<String, dynamic>))
            .toList();
        final current = _user?.skills ?? [];
        setState(() => _suggestions = list
            .where((s) => !current.any((c) => c.id == s.id))
            .toList());
      }
    });
  }

  Future<void> _addSkill(SkillTagDto skill) async {
    final res = await ApiClient.addSkillToUser(skill.id);
    if (!mounted) return;
    if (res.statusCode == 200) {
      final updated = UserDto.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      setState(() {
        _user = updated;
        _suggestions = [];
        _skillQuery = '';
        _skillSearchCtrl.clear();
      });
    }
  }

  Future<void> _createAndAddSkill(String name) async {
    final createRes = await ApiClient.createSkill(name);
    if (!mounted) return;
    if (createRes.statusCode == 201) {
      final skill = SkillTagDto.fromJson(
          jsonDecode(createRes.body) as Map<String, dynamic>);
      await _addSkill(skill);
    }
  }

  Future<void> _removeSkill(SkillTagDto skill) async {
    final res = await ApiClient.removeSkillFromUser(skill.id);
    if (!mounted) return;
    if (res.statusCode == 200) {
      setState(() {
        _user = UserDto.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      });
    }
  }

  Future<void> _signOut() async {
    await auth.logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: kAccent));
    if (_user == null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Failed to load profile', style: kBody(15, color: kInk3)),
        const SizedBox(height: 12),
        DmBtn(label: 'Retry', onPressed: _load, variant: DmBtnVariant.outline),
      ]));
    }
    final user = _user!;
    final avatar = avatarFromInitials(user.initials);

    return SingleChildScrollView(
      child: Column(children: [
        // gradient header
        Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [kAccentSoft, kBg],
              stops: [0.0, 0.75],
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 8),
            Row(children: [
              DmAvatar(data: avatar, size: 76),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user.fullName, style: kHeading(22)),
                const SizedBox(height: 2),
                Text(user.username != null ? '@${user.username}' : user.email,
                    style: kBody(14, color: kInk3)),
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(user.bio!, style: kBody(13.5, color: kInk3),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ])),
            ]),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // skills
            _SkillsSection(
              skills: user.skills,
              editing: _editingSkills,
              query: _skillQuery,
              suggestions: _suggestions,
              searchCtrl: _skillSearchCtrl,
              onToggleEdit: () {
                setState(() {
                  _editingSkills = !_editingSkills;
                  if (!_editingSkills) {
                    _skillQuery = '';
                    _suggestions = [];
                    _skillSearchCtrl.clear();
                  }
                });
              },
              onSearchChanged: _onSkillSearchChanged,
              onAdd: _addSkill,
              onCreate: _createAndAddSkill,
              onRemove: _removeSkill,
            ),

            // social links
            if (user.githubLink != null || user.discordTag != null)
              DmSection(
                title: 'Links',
                child: Column(children: [
                  if (user.githubLink != null)
                    _LinkRow(icon: Icons.code, label: user.githubLink!),
                  if (user.discordTag != null)
                    _LinkRow(icon: Icons.discord, label: user.discordTag!),
                ]),
              ),

            const SizedBox(height: 8),
            DmBtn(
              label: 'My Applications',
              full: true,
              variant: DmBtnVariant.outline,
              icon: Icons.send_outlined,
              onPressed: () => context.push('/applications'),
            ),
            const SizedBox(height: 10),
            DmBtn(
              label: 'Sign out',
              full: true,
              variant: DmBtnVariant.ghost,
              icon: Icons.logout,
              onPressed: _signOut,
            ),
          ]),
        ),
      ]),
    );
  }
}

class _SkillsSection extends StatelessWidget {
  final List<SkillTagDto> skills;
  final bool editing;
  final String query;
  final List<SkillTagDto> suggestions;
  final TextEditingController searchCtrl;
  final VoidCallback onToggleEdit;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<SkillTagDto> onAdd;
  final ValueChanged<String> onCreate;
  final ValueChanged<SkillTagDto> onRemove;

  const _SkillsSection({
    required this.skills,
    required this.editing,
    required this.query,
    required this.suggestions,
    required this.searchCtrl,
    required this.onToggleEdit,
    required this.onSearchChanged,
    required this.onAdd,
    required this.onCreate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // section header row
        Row(children: [
          Expanded(child: Text('SKILLS', style: kLabel())),
          GestureDetector(
            onTap: onToggleEdit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: editing ? kAccentSoft : kSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: editing ? kAccent : kLine),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(editing ? Icons.check : Icons.edit,
                    size: 13, color: editing ? kAccentInk : kInk3),
                const SizedBox(width: 4),
                Text(editing ? 'Done' : 'Edit',
                    style: kBody(12, color: editing ? kAccentInk : kInk3,
                        weight: FontWeight.w600)),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 11),

        // skill chips
        if (skills.isNotEmpty)
          Wrap(spacing: 8, runSpacing: 8,
            children: skills.map((s) => editing
                ? GestureDetector(
                    onTap: () => onRemove(s),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      DmTag(s.name, tone: DmTagTone.accent),
                      const SizedBox(width: 3),
                      const Icon(Icons.close, size: 13, color: kAccentInk),
                    ]),
                  )
                : DmTag(s.name, tone: DmTagTone.accent),
            ).toList()),

        if (skills.isEmpty && !editing)
          Text('No skills added yet', style: kBody(14, color: kInk3)),

        // skill search (edit mode only)
        if (editing) ...[
          const SizedBox(height: 12),
          TextField(
            controller: searchCtrl,
            onChanged: onSearchChanged,
            style: kBody(15, color: kInk),
            decoration: InputDecoration(
              hintText: 'Search or create skills…',
              hintStyle: kBody(15, color: kInk3),
              prefixIcon: const Icon(Icons.search, color: kInk3, size: 20),
              filled: true, fillColor: kSurface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kLine, width: 1.5)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kLine, width: 1.5)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kAccent, width: 2)),
            ),
          ),
          if (query.isNotEmpty)
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
                ...suggestions.take(5).map((s) => InkWell(
                  onTap: () => onAdd(s),
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
                if (suggestions.every((s) => s.name.toLowerCase() != query.toLowerCase()))
                  InkWell(
                    onTap: () => onCreate(query),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(children: [
                        const Icon(Icons.add_circle_outline, size: 16, color: kAccent),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Create "$query"',
                            style: kBody(14, color: kAccentInk, weight: FontWeight.w600))),
                      ]),
                    ),
                  ),
              ]),
            ),
        ],
      ]),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _LinkRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, size: 18, color: kInk3),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: kBody(14.5, color: kInk2))),
      ]),
    );
  }
}
