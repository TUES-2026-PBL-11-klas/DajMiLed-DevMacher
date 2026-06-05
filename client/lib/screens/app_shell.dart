import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../theme.dart';
import '../data.dart';
import '../widgets/dm_widgets.dart';
import 'discover_screen.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';
import 'detail_screen.dart';
import 'chat_screen.dart';
import 'post_task_screen.dart';

enum _Tab { discover, matches, profile }
enum _OverlayType { detail, chat, post }

class _Overlay {
  final _OverlayType type;
  final DiscoverItem? item;
  final MatchChat? chat;
  _Overlay.detail(this.item) : type = _OverlayType.detail, chat = null;
  _Overlay.chat(this.chat) : type = _OverlayType.chat, item = null;
  _Overlay.post() : type = _OverlayType.post, item = null, chat = null;
}

class _Toast {
  final String text;
  final IconData icon;
  _Toast(this.text, this.icon);
}

class AppShell extends StatefulWidget {
  final UserProfile profile;
  const AppShell({super.key, required this.profile});

  @override State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  _Tab _tab = _Tab.discover;
  String _mode = 'tasks';
  _Overlay? _overlay;
  _Toast? _toast;
  DiscoverItem? _matchModalItem;
  final List<DiscoverItem> _applications = [];
  late List<MatchChat> _matches;
  late AnimationController _toastCtrl;
  late AnimationController _matchCtrl;

  @override
  void initState() {
    super.initState();
    _matches = buildInitialMatches();
    _toastCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _matchCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override void dispose() { _toastCtrl.dispose(); _matchCtrl.dispose(); super.dispose(); }

  bool _isApplied(DiscoverItem item) => _applications.any((a) => a.id == item.id);

  void _fireToast(String text, IconData icon) {
    setState(() => _toast = _Toast(text, icon));
    _toastCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  void _handleApply(DiscoverItem item) {
    if (!_isApplied(item)) setState(() => _applications.insert(0, item));
    if (isMatchItem(item)) {
      final m = makeMatchChat(item);
      setState(() {
        if (!_matches.any((x) => x.id == m.id)) _matches.insert(0, m);
      });
      Future.delayed(const Duration(milliseconds: 380), () {
        if (mounted) { setState(() => _matchModalItem = item); _matchCtrl.forward(from: 0); }
      });
    } else {
      _fireToast(item is Task ? 'Application sent ✦' : 'They\'ll see your profile', LucideIcons.send);
    }
  }

  int get _unread => _matches.fold(0, (n, m) => n + m.unread);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          // main column
          Column(children: [
            Expanded(child: _buildTab()),
            _BottomNav(
              tab: _tab,
              unread: _unread,
              onTab: (t) => setState(() { _tab = t; _overlay = null; }),
              onPost: () => setState(() => _overlay = _Overlay.post()),
            ),
          ]),
          // overlays
          if (_overlay != null) _buildOverlay(),
          // match modal
          if (_matchModalItem != null) _buildMatchModal(),
          // toast
          if (_toast != null)
            Positioned(
              left: 16, right: 16, bottom: 96,
              child: AnimatedBuilder(
                animation: _toastCtrl,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, (1 - _toastCtrl.value) * 20),
                  child: Opacity(opacity: _toastCtrl.value.clamp(0.0, 1.0), child: child),
                ),
                child: DmToast(text: _toast!.text, icon: _toast!.icon),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _buildTab() {
    switch (_tab) {
      case _Tab.discover:
        return DiscoverScreen(
          mode: _mode,
          onModeChange: (m) => setState(() => _mode = m),
          onApply: _handleApply,
          onOpen: (item) => setState(() => _overlay = _Overlay.detail(item)),
          onToast: _fireToast,
        );
      case _Tab.matches:
        return MatchesScreen(
          matches: _matches,
          applications: _applications,
          onOpenChat: (m) => setState(() => _overlay = _Overlay.chat(m)),
        );
      case _Tab.profile:
        return ProfileScreen(profile: widget.profile, applications: _applications, matches: _matches);
    }
  }

  Widget _buildOverlay() {
    final ov = _overlay!;
    Widget child;
    switch (ov.type) {
      case _OverlayType.detail:
        child = DetailScreen(
          item: ov.item!,
          applied: _isApplied(ov.item!),
          onBack: () => setState(() => _overlay = null),
          onApply: () => _handleApply(ov.item!),
        );
      case _OverlayType.chat:
        child = ChatScreen(
          match: ov.chat!,
          onBack: () => setState(() => _overlay = null),
        );
      case _OverlayType.post:
        child = PostTaskScreen(
          onBack: () => setState(() => _overlay = null),
          onPublish: () {
            setState(() => _overlay = null);
            _fireToast('Task published — candidates incoming', Icons.rocket_launch_rounded);
          },
        );
    }
    return Positioned.fill(child: child);
  }

  Widget _buildMatchModal() {
    final item = _matchModalItem!;
    final name = item is Task ? item.owner : (item as Person).name;
    final matchChat = _matches.firstWhere((m) => m.id == 'new_${item.id}',
        orElse: () => _matches.first);

    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            transform: GradientRotation(2.79), // ~160 degrees
            colors: [kAccentInk, kAccent],
          ),
        ),
        child: Stack(children: [
          // confetti particles
          ..._buildParticles(),
          // content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('● ● ●', style: kMono(14, color: Colors.white).copyWith(color: Colors.white70)),
              const SizedBox(height: 6),
              Text('It\'s a match!', style: kHeading(44, color: Colors.white)),
              const SizedBox(height: 8),
              Text(
                'You and ${name.split(' ')[0]} are interested in working together.',
                style: kBody(16, color: Colors.white.withValues(alpha: 0.87)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // avatars
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Transform.rotate(
                  angle: -7 * 3.14159 / 180,
                  child: DmAvatar(data: avatarYou, size: 92, ring: true),
                ),
                Container(
                  width: 44, height: 44, margin: const EdgeInsets.symmetric(horizontal: -8),
                  decoration: BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: const Icon(LucideIcons.heart, color: kAccent, size: 22),
                ),
                Transform.rotate(
                  angle: 7 * 3.14159 / 180,
                  child: DmAvatar(
                    data: item is Task ? item.ownerAvatar : item.avatar,
                    size: 92, ring: true,
                  ),
                ),
              ]),
              const SizedBox(height: 34),
              DmBtn(
                label: 'Send a message', full: true,
                variant: DmBtnVariant.dark, icon: LucideIcons.messageCircle,
                onPressed: () {
                  setState(() { _matchModalItem = null; _tab = _Tab.matches; _overlay = _Overlay.chat(matchChat); });
                },
              ),
              const SizedBox(height: 11),
              GestureDetector(
                onTap: () => setState(() => _matchModalItem = null),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text('Keep swiping',
                    style: kBody(15, color: Colors.white, weight: FontWeight.w600)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  List<Widget> _buildParticles() {
    const colors = [Colors.white, Color(0xFFFFE08A), Color(0xFFBFF3DC)];
    return List.generate(14, (i) {
      final left = ((i * 67) % 100) / 100.0;
      final top = ((i * 37) % 100) / 100.0;
      return Positioned(
        left: MediaQuery.of(context).size.width * left,
        top: MediaQuery.of(context).size.height * top,
        child: Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: colors[i % colors.length].withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      );
    });
  }
}

// ── Bottom nav ────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final _Tab tab;
  final int unread;
  final ValueChanged<_Tab> onTab;
  final VoidCallback onPost;
  const _BottomNav({required this.tab, required this.unread, required this.onTab, required this.onPost});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        border: const Border(top: BorderSide(color: kLine, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
      child: SafeArea(
        top: false,
        child: Row(children: [
          _navItem(_Tab.discover, LucideIcons.compass, 'Discover'),
          _navItem(_Tab.matches, LucideIcons.messageCircle, 'Matches', badge: unread),
          // center post button
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: onPost,
                child: Container(
                  width: 52, height: 52,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: kAccent, borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: kAccent.withValues(alpha: 0.5), blurRadius: 22, offset: const Offset(0, 10))],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 26),
                ),
              ),
            ),
          ),
          _navItem(_Tab.profile, LucideIcons.user, 'Profile'),
          // spacer for symmetry
          const Expanded(child: SizedBox()),
        ]),
      ),
    );
  }

  Widget _navItem(_Tab t, IconData icon, String label, {int badge = 0}) {
    final on = tab == t;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTab(t),
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Stack(clipBehavior: Clip.none, children: [
              Icon(icon, size: 25, color: on ? kAccent : kInk3),
              if (badge > 0)
                Positioned(top: -3, right: -6,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16),
                    height: 16, padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: kAccent, borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text('$badge', style: kMono(10, color: Colors.white)),
                  )),
            ]),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: on ? kAccentInk : kInk3)),
          ]),
        ),
      ),
    );
  }
}
