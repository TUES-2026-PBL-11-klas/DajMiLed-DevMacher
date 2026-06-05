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

  void _showEditProfile() {
    final user = _user!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _EditProfileSheet(
        user: user,
        onSaved: (updated) {
          if (mounted) setState(() => _user = updated);
        },
      ),
    );
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
    final avatar = AvatarData(kAccentSoft, kAccentInk,
        user.initials.isNotEmpty ? user.initials : '?');

    return SingleChildScrollView(
      child: Column(children: [
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
              GestureDetector(
                onTap: _showEditProfile,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kLine),
                  ),
                  child: const Icon(Icons.edit_outlined, size: 18, color: kInk3),
                ),
              ),
            ]),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // education / links info
            if (user.education != null && user.education!.isNotEmpty) ...[
              _InfoRow(icon: Icons.school_outlined, label: user.education!),
              const SizedBox(height: 10),
            ],
            if (user.githubLink != null && user.githubLink!.isNotEmpty) ...[
              _InfoRow(icon: Icons.code, label: user.githubLink!),
              const SizedBox(height: 10),
            ],
            if (user.discordTag != null && user.discordTag!.isNotEmpty) ...[
              _InfoRow(icon: Icons.discord, label: user.discordTag!),
              const SizedBox(height: 10),
            ],
            if (user.education != null || user.githubLink != null || user.discordTag != null)
              const SizedBox(height: 14),

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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: kInk3),
      ),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: kBody(14.5, color: kInk2))),
    ]);
  }
}

class _EditProfileSheet extends StatefulWidget {
  final UserDto user;
  final void Function(UserDto updated) onSaved;
  const _EditProfileSheet({required this.user, required this.onSaved});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _username;
  late final TextEditingController _bio;
  late final TextEditingController _discord;
  late final TextEditingController _github;
  late final TextEditingController _education;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _username = TextEditingController(text: u.username ?? '');
    _bio = TextEditingController(text: u.bio ?? '');
    _discord = TextEditingController(text: u.discordTag ?? '');
    _github = TextEditingController(text: u.githubLink ?? '');
    _education = TextEditingController(text: u.education ?? '');
  }

  @override
  void dispose() {
    _username.dispose();
    _bio.dispose();
    _discord.dispose();
    _github.dispose();
    _education.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final username = _username.text.trim();
    if (username.isNotEmpty && username.length < 3) {
      setState(() => _error = 'Username must be at least 3 characters.');
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      final res = await ApiClient.updateProfile(
        username: username,
        bio: _bio.text.trim(),
        discordTag: _discord.text.trim(),
        githubLink: _github.text.trim(),
        education: _education.text.trim(),
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        final updated = UserDto.fromJson(
            jsonDecode(res.body) as Map<String, dynamic>);
        widget.onSaved(updated);
        Navigator.of(context).pop();
      } else {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final msg = body['message'] as String? ??
            (body['fieldErrors'] as Map?)?.values.first as String? ??
            'Failed to save. Please try again.';
        setState(() { _saving = false; _error = msg; });
      }
    } catch (_) {
      if (mounted) setState(() { _saving = false; _error = 'Network error. Is the server running?'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('Edit profile', style: kHeading(20))),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.close, color: kInk3),
            ),
          ]),
          const SizedBox(height: 24),

          _Field(label: 'Username', controller: _username, hint: 'your_handle'),
          const SizedBox(height: 16),
          _Field(label: 'Bio', controller: _bio, hint: 'I build things…', maxLines: 3),
          const SizedBox(height: 16),
          _Field(label: 'Education', controller: _education, hint: 'CS @ University'),
          const SizedBox(height: 16),
          _Field(label: 'GitHub link', controller: _github, hint: 'github.com/you'),
          const SizedBox(height: 16),
          _Field(label: 'Discord tag', controller: _discord, hint: 'username#1234'),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: kBody(13.5, color: Colors.red.shade600)),
          ],

          const SizedBox(height: 24),
          DmBtn(
            label: _saving ? 'Saving…' : 'Save changes',
            full: true,
            disabled: _saving,
            onPressed: _save,
          ),
        ]),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _Field({required this.label, required this.controller,
      required this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: kBody(13, color: kInk3, weight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        maxLines: maxLines,
        style: kBody(15, color: kInk),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: kBody(15, color: kInk3),
          filled: true,
          fillColor: kSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kLine, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kLine, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kAccent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    ]);
  }
}
