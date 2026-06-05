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
  List<SkillTagDto> _allSkills = [];
  bool _skillsLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
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

  Future<void> _enterEditSkills() async {
    setState(() { _editingSkills = true; _skillsLoading = true; });
    final res = await ApiClient.getAllSkills();
    if (!mounted) return;
    if (res.statusCode == 200) {
      final list = (jsonDecode(res.body) as List<dynamic>)
          .map((s) => SkillTagDto.fromJson(s as Map<String, dynamic>))
          .toList();
      setState(() { _allSkills = list; _skillsLoading = false; });
    } else {
      setState(() => _skillsLoading = false);
    }
  }

  Future<void> _toggleSkill(SkillTagDto skill) async {
    final has = _user!.skills.any((s) => s.id == skill.id);
    final res = has
        ? await ApiClient.removeSkillFromUser(skill.id)
        : await ApiClient.addSkillToUser(skill.id);
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
            // skills section
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text('SKILLS', style: kLabel())),
                  GestureDetector(
                    onTap: _editingSkills
                        ? () => setState(() { _editingSkills = false; _allSkills = []; })
                        : _enterEditSkills,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _editingSkills ? kAccentSoft : kSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _editingSkills ? kAccent : kLine),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(_editingSkills ? Icons.check : Icons.edit,
                            size: 13,
                            color: _editingSkills ? kAccentInk : kInk3),
                        const SizedBox(width: 4),
                        Text(_editingSkills ? 'Done' : 'Edit',
                            style: kBody(12,
                                color: _editingSkills ? kAccentInk : kInk3,
                                weight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ]),
                const SizedBox(height: 11),

                if (_editingSkills) ...[
                  if (_skillsLoading)
                    const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(color: kAccent, strokeWidth: 2),
                    ))
                  else
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _allSkills.map((skill) {
                        final selected = user.skills.any((s) => s.id == skill.id);
                        return GestureDetector(
                          onTap: () => _toggleSkill(skill),
                          child: DmTag(skill.name,
                              tone: selected ? DmTagTone.accent : DmTagTone.outline),
                        );
                      }).toList(),
                    ),
                ] else ...[
                  if (user.skills.isEmpty)
                    Text('No skills added yet', style: kBody(14, color: kInk3))
                  else
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: user.skills
                          .map((s) => DmTag(s.name, tone: DmTagTone.accent))
                          .toList(),
                    ),
                ],
              ]),
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
              onPressed: () => context.push('/applications', extra: 0),
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
