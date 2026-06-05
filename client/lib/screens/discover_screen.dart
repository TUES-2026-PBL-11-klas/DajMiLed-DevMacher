import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../theme.dart';
import '../data.dart';
import '../widgets/dm_widgets.dart';

class DiscoverScreen extends StatefulWidget {
  final String mode;
  final ValueChanged<String> onModeChange;
  final ValueChanged<DiscoverItem> onApply;
  final ValueChanged<DiscoverItem> onOpen;
  final void Function(String text, IconData icon) onToast;

  const DiscoverScreen({super.key, required this.mode, required this.onModeChange,
    required this.onApply, required this.onOpen, required this.onToast});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _taskIdx = 0, _peopleIdx = 0;
  DiscoverItem? _confirm;

  List<DiscoverItem> get _deck => widget.mode == 'tasks' ? kTasks : kPeople;
  int get _idx => widget.mode == 'tasks' ? _taskIdx : _peopleIdx;
  set _idx(int v) {
    if (widget.mode == 'tasks') { _taskIdx = v; } else { _peopleIdx = v; }
  }

  void _doLeft() => setState(() => _idx = _idx + 1);

  void _doApply(DiscoverItem item) {
    setState(() => _idx = _idx + 1);
    widget.onApply(item);
  }

  void _doRight(DiscoverItem item) {
    widget.onToast('Saved to your interested list', LucideIcons.heart);
    setState(() => _idx = _idx + 1);
  }

  @override
  Widget build(BuildContext context) {
    final deck = _deck;
    final item = _idx < deck.length ? deck[_idx] : null;
    final visible = _idx < deck.length ? deck.skip(_idx).take(3).toList() : <DiscoverItem>[];

    return Stack(children: [
      Positioned.fill(child: Column(children: [
      // header
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Column(children: [
          Row(children: [
            const DmLogo(size: 30),
            const SizedBox(width: 9),
            Text('Discover', style: kHeading(20)),
            const Spacer(),
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                border: Border.all(color: kLine, width: 1.5)),
              child: const Icon(LucideIcons.sliders, color: kInk2, size: 20),
            ),
          ]),
          const SizedBox(height: 14),
          _ModeToggle(mode: widget.mode, onChanged: widget.onModeChange),
        ]),
      ),
      // deck
      Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: item == null
              ? _EmptyDeck(onReset: () => setState(() => _idx = 0), mode: widget.mode)
              : Stack(children: [
                  // back cards
                  for (int i = visible.length - 1; i >= 1; i--)
                    Positioned.fill(
                      child: Transform(
                        transform: Matrix4.identity()
                          ..translateByDouble(0.0, i * 12.0, 0.0, 1.0)
                          ..scaleByDouble(1 - i * 0.04, 1 - i * 0.04, 1.0, 1.0),
                        alignment: Alignment.topCenter,
                        child: Opacity(
                          opacity: i == 2 ? 0.5 : 1,
                          child: _CardAccent(item: visible[i]),
                        ),
                      ),
                    ),
                  // top card (draggable)
                  Positioned.fill(
                    child: _DraggableCard(
                      key: ValueKey(item.id),
                      item: item,
                      onLeft: _doLeft,
                      onRight: () => _doRight(item),
                      onConfirm: () => setState(() => _confirm = item),
                      onOpen: () => widget.onOpen(item),
                    ),
                  ),
                ]),
        ),
      ),
      // action bar
      if (item != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
          child: Row(children: [
            DmActionBtn(
              icon: LucideIcons.x, iconColor: const Color(0xFF8A97A0),
              bgColor: Colors.white, borderColor: kLine, size: 52,
              onPressed: _doLeft,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: DmBtn(
                label: 'Apply now', full: true,
                icon: LucideIcons.check,
                onPressed: () => setState(() => _confirm = item),
              ),
            ),
            const SizedBox(width: 14),
            DmActionBtn(
              icon: LucideIcons.heart, iconColor: kAccentInk,
              bgColor: kAccentSoft, borderColor: kAccentSoft, size: 52,
              onPressed: () => _doRight(item),
            ),
          ]),
        ),
    ])),
      // confirm sheet overlay
      if (_confirm != null)
        Positioned.fill(
          child: _ConfirmSheet(
            item: _confirm!,
            onCancel: () => setState(() => _confirm = null),
            onSend: (it) { setState(() => _confirm = null); _doApply(it); },
          ),
        ),
    ]);
  }
}

// ── Card accent style ─────────────────────────────────────────────
class _CardAccent extends StatelessWidget {
  final DiscoverItem item;
  const _CardAccent({required this.item});

  @override
  Widget build(BuildContext context) {
    final isTask = item is Task;
    final t = item is Task ? item as Task : null;
    final p = item is Person ? item as Person : null;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F1A16).withValues(alpha: 0.18), blurRadius: 44, offset: const Offset(0, 18)),
          BoxShadow(color: const Color(0xFF0F1A16).withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // image area
        ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(26), topRight: Radius.circular(26)),
          child: SizedBox(
            height: 168,
            child: Stack(children: [
              Positioned.fill(child: DmPlaceholderArt(item.avatar)),
              Positioned(top: 14, left: 14,
                child: DmTag(isTask ? t!.category : p!.location, tone: DmTagTone.light, small: true)),
              Positioned(top: 14, right: 14,
                child: DmMatchRing(isTask ? t!.match : 88, dark: true)),
            ]),
          ),
        ),
        // content
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              isTask ? t!.title : '${p!.name}, ${p.age}',
              style: kHeading(21),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              isTask ? '${t!.project} · ${t.owner}' : p!.role,
              style: kBody(14, color: kInk2, weight: FontWeight.w500),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Wrap(spacing: 7, runSpacing: 7,
            children: item.skills.map((s) => DmTag(s, tone: DmTagTone.accent, small: true)).toList()),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Text(
            isTask ? t!.summary : p!.bio,
            style: kBody(14, color: kInk2),
            maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    );
  }
}

// ── Draggable top card ─────────────────────────────────────────────
class _DraggableCard extends StatefulWidget {
  final DiscoverItem item;
  final VoidCallback onLeft, onRight, onConfirm, onOpen;
  const _DraggableCard({super.key, required this.item, required this.onLeft,
    required this.onRight, required this.onConfirm, required this.onOpen});

  @override State<_DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<_DraggableCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _anim;
  Offset _offset = Offset.zero;
  bool _dragging = false;
  bool _moved = false;
  VoidCallback? _onEnd;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    _anim = Tween(begin: Offset.zero, end: Offset.zero).animate(_ctrl);
    _anim.addListener(() => setState(() => _offset = _anim.value));
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) _onEnd?.call();
    });
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _animateTo(Offset to, {Curve curve = Curves.easeOut, VoidCallback? onEnd}) {
    _onEnd = onEnd;
    _anim = Tween(begin: _offset, end: to).animate(CurvedAnimation(parent: _ctrl, curve: curve));
    _anim.addListener(() => setState(() => _offset = _anim.value));
    _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final rot = _offset.dx / 22.0 * math.pi / 180.0;
    final rightOp = (_offset.dx / 90.0).clamp(0.0, 1.0);
    final leftOp = (-_offset.dx / 90.0).clamp(0.0, 1.0);
    final isTask = widget.item is Task;

    return GestureDetector(
      onPanStart: (d) {
        if (_ctrl.isAnimating) return;
        _dragging = true; _moved = false;
      },
      onPanUpdate: (d) {
        if (!_dragging) return;
        if (d.delta.dx.abs() > 2) _moved = true;
        setState(() => _offset += Offset(d.delta.dx, d.delta.dy * 0.4));
      },
      onPanEnd: (d) {
        if (!_dragging) return;
        _dragging = false;
        if (_offset.dx > 95) {
          _animateTo(const Offset(700, -40), curve: Curves.easeIn,
            onEnd: widget.onRight);
        } else if (_offset.dx < -95) {
          _animateTo(const Offset(-700, -40), curve: Curves.easeIn,
            onEnd: widget.onLeft);
        } else {
          _animateTo(Offset.zero, curve: Curves.elasticOut);
          if (!_moved) widget.onOpen();
        }
      },
      child: Transform(
        transform: Matrix4.identity()
          ..translateByDouble(_offset.dx, _offset.dy, 0.0, 1.0)
          ..rotateZ(rot),
        alignment: Alignment.center,
        child: Stack(children: [
          _CardAccent(item: widget.item),
          // APPLY stamp
          if (rightOp > 0)
            Positioned(top: 26, left: 22,
              child: Opacity(opacity: rightOp,
                child: Transform.rotate(angle: -14 * math.pi / 180,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: kAccent, width: 3),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    child: Text(isTask ? 'APPLY' : 'INTERESTED',
                      style: kMono(22, color: kAccent).copyWith(fontWeight: FontWeight.w700)),
                  ),
                ))),
          // SKIP stamp
          if (leftOp > 0)
            Positioned(top: 26, right: 22,
              child: Opacity(opacity: leftOp,
                child: Transform.rotate(angle: 14 * math.pi / 180,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF8A97A0), width: 3),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    child: Text('SKIP',
                      style: kMono(22, color: const Color(0xFF8A97A0)).copyWith(fontWeight: FontWeight.w700)),
                  ),
                ))),
        ]),
      ),
    );
  }
}

// ── Mode toggle ───────────────────────────────────────────────────
class _ModeToggle extends StatelessWidget {
  final String mode;
  final ValueChanged<String> onChanged;
  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          _tab('tasks', 'Find tasks', LucideIcons.briefcase),
          _tab('people', 'Find people', LucideIcons.user),
        ]),
      ),
    ]);
  }

  Widget _tab(String key, String label, IconData icon) {
    final on = mode == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: on ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: on ? [BoxShadow(color: const Color(0xFF0F1A16).withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))] : [],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 18, color: on ? kAccent : kInk3),
            const SizedBox(width: 8),
            Text(label, style: kBody(14.5, color: on ? kInk : kInk3, weight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

// ── Empty deck ────────────────────────────────────────────────────
class _EmptyDeck extends StatelessWidget {
  final VoidCallback onReset;
  final String mode;
  const _EmptyDeck({required this.onReset, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 76, height: 76,
            decoration: BoxDecoration(color: kAccentSoft, borderRadius: BorderRadius.circular(24)),
            child: const Icon(LucideIcons.sparkles, color: kAccent, size: 38),
          ),
          const SizedBox(height: 14),
          Text('You\'re all caught up', style: kHeading(21), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'No more ${mode == 'tasks' ? 'open tasks' : 'people'} matching your skills right now.',
            style: kBody(15), textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          DmBtn(label: 'Review again', variant: DmBtnVariant.ghost,
            icon: LucideIcons.arrowLeft, onPressed: onReset),
        ]),
      ),
    );
  }
}

// ── Confirm sheet ─────────────────────────────────────────────────
class _ConfirmSheet extends StatefulWidget {
  final DiscoverItem item;
  final VoidCallback onCancel;
  final ValueChanged<DiscoverItem> onSend;
  const _ConfirmSheet({required this.item, required this.onCancel, required this.onSend});

  @override State<_ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends State<_ConfirmSheet> {
  final _noteCtrl = TextEditingController();
  @override void dispose() { _noteCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isTask = widget.item is Task;
    final t = isTask ? widget.item as Task : null;
    final p = isTask ? null : widget.item as Person;
    return Container(
      color: Colors.black.withValues(alpha: 0.42),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: const BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: kLine, borderRadius: BorderRadius.circular(999))),
            Row(children: [
              DmAvatar(data: widget.item.avatar, size: 50),
              const SizedBox(width: 13),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  isTask ? 'Apply to ${t!.project}' : 'Reach out to ${p!.name.split(' ')[0]}',
                  style: kBody(17, color: kInk, weight: FontWeight.w800),
                ),
                Text(isTask ? t!.title : p!.role, style: kBody(13.5)),
              ])),
            ]),
            const SizedBox(height: 16),
            Text('ADD A NOTE (OPTIONAL)', style: kLabel()),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kLine, width: 1.5)),
              child: TextField(
                controller: _noteCtrl,
                maxLines: 3, minLines: 3,
                style: kBody(14.5, color: kInk),
                decoration: InputDecoration(
                  hintText: isTask ? 'Why you\'re a great fit…' : 'Say hi and what you\'d build together…',
                  hintStyle: kBody(14.5, color: kInk3),
                  contentPadding: const EdgeInsets.all(15),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: DmBtn(label: 'Cancel', variant: DmBtnVariant.outline, onPressed: widget.onCancel)),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: DmBtn(label: 'Send application',
                icon: LucideIcons.send, onPressed: () => widget.onSend(widget.item))),
            ]),
          ]),
        ),
      ),
    );
  }
}
