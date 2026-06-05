import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../theme.dart';
import '../data.dart';
import '../widgets/dm_widgets.dart';

class ProfileScreen extends StatelessWidget {
  final UserProfile profile;
  final List<DiscoverItem> applications;
  final List<MatchChat> matches;
  const ProfileScreen({super.key, required this.profile, required this.applications, required this.matches});

  @override
  Widget build(BuildContext context) {
    final goals = profile.goals.map((id) => kGoals.firstWhere((g) => g.id == id, orElse: () => kGoals[0])).toList();
    final avail = profile.avail.isNotEmpty
        ? kAvail.firstWhere((a) => a.id == profile.avail, orElse: () => kAvail[1])
        : null;
    return SingleChildScrollView(
      child: Column(children: [
        // gradient header
        Container(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [kAccentSoft, kBg],
              stops: [0.0, 0.7],
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(LucideIcons.pencil, color: kInk2, size: 18),
              ),
            ]),
            Row(children: [
              DmAvatar(data: avatarYou, size: 78),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(profile.name.isNotEmpty ? profile.name : 'You', style: kHeading(24)),
                const SizedBox(height: 2),
                Text(profile.role.isNotEmpty ? profile.role : 'Developer',
                  style: kBody(14.5, color: kInk2, weight: FontWeight.w600)),
                if (profile.headline.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(profile.headline, style: kBody(13.5, color: kInk3)),
                ],
              ])),
            ]),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 30),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // stats
            Row(children: [
              DmStatCard(icon: LucideIcons.send, top: '${applications.length}', bot: 'applied'),
              const SizedBox(width: 10),
              DmStatCard(icon: LucideIcons.heart, top: '${matches.length}', bot: 'matches'),
              const SizedBox(width: 10),
              DmStatCard(icon: LucideIcons.clock,
                top: avail != null ? avail.label.split(' ')[0] : '—', bot: 'per week'),
            ]),
            const SizedBox(height: 24),
            // skills
            DmSection(
              title: 'Skills',
              child: profile.skills.isEmpty
                  ? Text('No skills yet', style: kBody(14, color: kInk3))
                  : Wrap(spacing: 8, runSpacing: 8,
                      children: profile.skills.map((s) => DmTag(s, tone: DmTagTone.accent)).toList()),
            ),
            // goals
            DmSection(
              title: 'Looking for',
              child: goals.isEmpty
                  ? Text('Not set', style: kBody(14, color: kInk3))
                  : Column(children: goals.map((g) => Container(
                      margin: const EdgeInsets.only(bottom: 9),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                      decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kLine, width: 1),
                      ),
                      child: Row(children: [
                        Text(g.emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 12),
                        Text(g.label, style: kBody(14.5, color: kInk, weight: FontWeight.w500)),
                      ]),
                    )).toList()),
            ),
            // availability
            DmSection(
              title: 'Availability',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                decoration: BoxDecoration(color: kAccentSoft, borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  const Icon(LucideIcons.clock, color: kAccentInk, size: 22),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(avail?.label ?? 'Not set', style: kBody(15.5, color: kAccentInk, weight: FontWeight.w700)),
                    if (avail != null) Text(avail.sub, style: kMono(12, color: kAccentInk).copyWith(color: kAccentInk.withValues(alpha: 0.7))),
                  ]),
                ]),
              ),
            ),
            DmBtn(label: 'Edit profile', full: true, variant: DmBtnVariant.outline,
              icon: LucideIcons.pencil, onPressed: () {}),
          ]),
        ),
      ]),
    );
  }
}
