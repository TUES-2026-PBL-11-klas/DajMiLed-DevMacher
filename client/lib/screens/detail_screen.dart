import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../theme.dart';
import '../data.dart';
import '../widgets/dm_widgets.dart';

class DetailScreen extends StatelessWidget {
  final DiscoverItem item;
  final bool applied;
  final VoidCallback onBack;
  final VoidCallback onApply;
  const DetailScreen({super.key, required this.item, required this.applied,
    required this.onBack, required this.onApply});

  @override
  Widget build(BuildContext context) {
    final isTask = item is Task;
    final t = isTask ? item as Task : null;
    final p = isTask ? null : item as Person;

    return Scaffold(
      backgroundColor: kBg,
      body: Stack(children: [
        // scrollable content
        CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 230,
              child: Stack(children: [
                Positioned.fill(child: DmPlaceholderArt(item.avatar)),
                Positioned(
                  top: 56, left: 16,
                  child: SafeArea(child: DmNavBtn(onPressed: onBack)),
                ),
                Positioned(
                  top: 56, right: 16,
                  child: SafeArea(child: DmMatchRing(isTask ? t!.match : 88, dark: true)),
                ),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                decoration: const BoxDecoration(
                  color: kBg,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 120),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // tags
                  Wrap(spacing: 8, children: [
                    if (isTask) DmTag(t!.category, tone: DmTagTone.accent, small: true),
                    DmTag(isTask ? t!.posted : p!.location, small: true),
                  ]),
                  const SizedBox(height: 12),
                  // title
                  Text(
                    isTask ? t!.title : '${p!.name}, ${p.age}',
                    style: kHeading(25),
                  ),
                  const SizedBox(height: 8),
                  // owner row
                  Row(children: [
                    DmAvatar(data: isTask ? t!.ownerAvatar : item.avatar, size: 34),
                    const SizedBox(width: 10),
                    Text(
                      isTask ? '${t!.owner} · ${t.project}' : p!.role,
                      style: kBody(14.5, color: kInk2, weight: FontWeight.w600),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  // stats
                  Row(children: [
                    DmStatCard(
                      icon: LucideIcons.clock,
                      top: isTask ? t!.commitment : p!.availability,
                      bot: isTask ? 'commitment' : 'available',
                    ),
                    const SizedBox(width: 10),
                    DmStatCard(
                      icon: isTask ? LucideIcons.briefcase : LucideIcons.star,
                      top: isTask ? t!.length.split(' · ')[0] : p!.stats['rating']!,
                      bot: isTask ? 'duration' : 'rating',
                    ),
                    const SizedBox(width: 10),
                    DmStatCard(
                      icon: isTask ? LucideIcons.user : LucideIcons.layers,
                      top: isTask ? '${t!.applicants}' : p!.stats['projects']!,
                      bot: isTask ? 'applied' : 'projects',
                    ),
                  ]),
                  const SizedBox(height: 22),
                  // about
                  DmSection(
                    title: isTask ? 'About the task' : 'About',
                    child: Text(isTask ? t!.summary : p!.bio, style: kBody(15)),
                  ),
                  // skills
                  DmSection(
                    title: 'Skills',
                    child: Wrap(spacing: 8, runSpacing: 8,
                      children: item.skills.map((s) => DmTag(s, tone: DmTagTone.accent)).toList()),
                  ),
                  // details / highlights
                  if (isTask)
                    DmSection(
                      title: 'What you\'ll do',
                      child: Column(children: t!.details.asMap().entries.map((e) =>
                        Padding(
                          padding: const EdgeInsets.only(bottom: 11),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(
                              width: 22, height: 22, margin: const EdgeInsets.only(top: 1),
                              decoration: const BoxDecoration(color: kAccentSoft, shape: BoxShape.circle),
                              child: const Icon(Icons.check, color: kAccentInk, size: 13),
                            ),
                            const SizedBox(width: 11),
                            Expanded(child: Text(e.value, style: kBody(14.5, color: kInk))),
                          ]),
                        ),
                      ).toList()),
                    )
                  else
                    DmSection(
                      title: 'Highlights',
                      child: Column(children: (p!.highlights).map((h) =>
                        Container(
                          margin: const EdgeInsets.only(bottom: 9),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: kLine, width: 1),
                          ),
                          child: Row(children: [
                            Text(h.split(' ')[0], style: const TextStyle(fontSize: 15)),
                            const SizedBox(width: 10),
                            Expanded(child: Text(h.split(' ').skip(1).join(' '),
                              style: kBody(14, color: kInk, weight: FontWeight.w500))),
                          ]),
                        ),
                      ).toList()),
                    ),
                ]),
              ),
            ),
          ),
        ]),
        // sticky apply button
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, kBg],
                stops: [0.0, 0.24],
              ),
            ),
            child: SafeArea(
              top: false,
              child: DmBtn(
                label: applied
                    ? 'Application sent'
                    : (isTask ? 'Apply to this task' : 'Connect with ${p!.name.split(' ')[0]}'),
                full: true,
                icon: applied ? Icons.check : LucideIcons.send,
                disabled: applied,
                onPressed: onApply,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
