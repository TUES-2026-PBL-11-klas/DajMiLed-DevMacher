import 'package:flutter/material.dart';
import '../theme.dart';
import '../data.dart';
import '../widgets/dm_widgets.dart';

class MatchesScreen extends StatefulWidget {
  final List<MatchChat> matches;
  final List<DiscoverItem> applications;
  final ValueChanged<MatchChat> onOpenChat;
  const MatchesScreen({super.key, required this.matches, required this.applications, required this.onOpenChat});

  @override State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  bool _showChats = true;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Matches', style: kHeading(28)),
          const SizedBox(height: 14),
          Row(children: [
            _Tab(label: 'Chats', active: _showChats, onTap: () => setState(() => _showChats = true)),
            const SizedBox(width: 8),
            _Tab(label: 'Applied · ${widget.applications.length}', active: !_showChats,
              onTap: () => setState(() => _showChats = false)),
          ]),
        ]),
      ),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: _showChats ? _buildChats() : _buildApplied(),
        ),
      ),
    ]);
  }

  List<Widget> _buildChats() {
    return widget.matches.map((m) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () => widget.onOpenChat(m),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: const Color(0xFF0F1A16).withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            Stack(clipBehavior: Clip.none, children: [
              DmAvatar(data: m.avatar, size: 52),
              if (m.unread > 0)
                Positioned(top: -2, right: -2,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 19),
                    height: 19,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: kAccent, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text('${m.unread}', style: kMono(11, color: Colors.white).copyWith(fontWeight: FontWeight.w700)),
                  )),
            ]),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(m.name, style: kBody(15.5, color: kInk, weight: FontWeight.w700))),
                Text(m.time, style: kMono(11.5, color: kInk3)),
              ]),
              const SizedBox(height: 2),
              Text(m.context, style: kMono(11, color: kAccentInk)),
              const SizedBox(height: 3),
              Text(m.preview,
                style: kBody(13.5, color: m.unread > 0 ? kInk : kInk2,
                  weight: m.unread > 0 ? FontWeight.w600 : FontWeight.w400),
                overflow: TextOverflow.ellipsis, maxLines: 1),
            ])),
          ]),
        ),
      ),
    )).toList();
  }

  List<Widget> _buildApplied() {
    if (widget.applications.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 24),
          child: Text('No applications yet. Swipe right on a task to apply.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.5, color: kInk3, height: 1.5)),
        ),
      ];
    }
    return widget.applications.map((a) {
      final t = a is Task ? a : null;
      final p = a is Person ? a : null;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kLine, width: 1),
          ),
          child: Row(children: [
            DmAvatar(data: a.avatar, size: 44),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t != null ? t.title : p!.name,
                style: kBody(14.5, color: kInk, weight: FontWeight.w700),
                overflow: TextOverflow.ellipsis, maxLines: 1),
              Text(t != null ? t.project : p!.role, style: kBody(12.5, color: kInk2)),
            ])),
            DmTag('Sent', tone: DmTagTone.accent, small: true),
          ]),
        ),
      );
    }).toList();
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: active ? kInk : kSurface2,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label, style: kBody(14, color: active ? Colors.white : kInk2, weight: FontWeight.w600)),
      ),
    );
  }
}
