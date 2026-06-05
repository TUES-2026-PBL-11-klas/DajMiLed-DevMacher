import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api.dart';
import '../theme.dart';
import '../widgets/dm_widgets.dart';

class ApplicantProfileScreen extends StatefulWidget {
  final int userId;
  const ApplicantProfileScreen({super.key, required this.userId});
  @override
  State<ApplicantProfileScreen> createState() => _ApplicantProfileScreenState();
}

class _ApplicantProfileScreenState extends State<ApplicantProfileScreen> {
  UserDto? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiClient.getUserById(widget.userId);
    if (!mounted) return;
    if (res.statusCode == 200) {
      setState(() {
        _user = UserDto.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        leading: DmNavBtn(onPressed: () => context.pop()),
        title: Text(_user?.fullName ?? 'Profile', style: kHeading(18)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kAccent))
          : _user == null
              ? Center(child: Text('Failed to load profile', style: kBody(15, color: kInk3)))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final user = _user!;
    final avatar = AvatarData(kAccentSoft, kAccentInk,
        user.initials.isNotEmpty ? user.initials : '?');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kAccentSoft, kBg],
              stops: [0.0, 0.8],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            DmAvatar(data: avatar, size: 64),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user.fullName, style: kHeading(20)),
                if (user.username != null && user.username!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('@${user.username}', style: kBody(13.5, color: kInk3)),
                ],
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(user.bio!, style: kBody(14, color: kInk2)),
                ],
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 20),

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

        if (user.skills.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('SKILLS', style: kLabel()),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.skills
                .map((s) => DmTag(s.name, tone: DmTagTone.accent))
                .toList(),
          ),
        ],
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
