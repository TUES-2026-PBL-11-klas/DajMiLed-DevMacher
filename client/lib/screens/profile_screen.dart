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
    final initials = user.initials;
    final avatar = avatarFromInitials(initials);

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
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle,
                  border: Border.all(color: kLine, width: 1.5),
                ),
                child: const Icon(Icons.edit_outlined, color: kInk2, size: 18),
              ),
            ]),
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
            if (user.skills.isNotEmpty) ...[
              DmSection(
                title: 'Skills',
                child: Wrap(spacing: 8, runSpacing: 8,
                  children: user.skills.map((s) => DmTag(s.name, tone: DmTagTone.accent)).toList()),
              ),
            ],

            // tags
            if (user.tags.isNotEmpty) ...[
              DmSection(
                title: 'Tags',
                child: Wrap(spacing: 8, runSpacing: 8,
                  children: user.tags.map((t) => DmTag(t.name, tone: DmTagTone.outline)).toList()),
              ),
            ],

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
