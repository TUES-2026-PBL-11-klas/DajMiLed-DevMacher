import 'dart:convert';
import 'package:flutter/material.dart';
import '../api.dart';
import '../theme.dart';
import '../widgets/dm_widgets.dart';
import 'company_card.dart';

class CompanySwipe extends StatefulWidget {
  const CompanySwipe({super.key});
  @override
  State<CompanySwipe> createState() => _CompanySwipeState();
}

class _CompanySwipeState extends State<CompanySwipe>
    with SingleTickerProviderStateMixin {
  List<SwipeTask> _tasks = [];
  final Set<int> _appliedTaskIds = {};
  bool _loading = true;
  int _i = 0;
  Offset _drag = Offset.zero;
  late AnimationController _fly;
  Offset _flyEnd = Offset.zero;

  static const _threshold = 80.0;

  @override
  void initState() {
    super.initState();
    _fly = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300))
      ..addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _fly.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      ApiClient.getRelevantTasks(),
      ApiClient.getMyApplications(),
    ]);
    if (!mounted) return;

    final matchedRes = results[0];
    final appsRes = results[1];

    if (matchedRes.statusCode != 200) {
      setState(() => _loading = false);
      return;
    }

    final Set<int> applied = {};
    if (appsRes.statusCode == 200) {
      for (final a in jsonDecode(appsRes.body) as List<dynamic>) {
        applied.add((a as Map<String, dynamic>)['taskId'] as int);
      }
    }

    final matched = (jsonDecode(matchedRes.body) as List<dynamic>)
        .map((t) => MatchedTaskDto.fromJson(t as Map<String, dynamic>))
        .toList();

    final tasks = matched
        .where((t) => !applied.contains(t.taskId))
        .map((t) => SwipeTask(
              projectId: t.projectId,
              taskId: t.taskId,
              projectTitle: t.projectTitle,
              ownerName: t.ownerName,
              taskTitle: t.title,
              description: t.description,
              skills: t.requiredSkills.map((s) => s.name).toList(),
              color: colorFromTitle(t.projectTitle),
            ))
        .toList();

    setState(() {
      _tasks = tasks;
      _appliedTaskIds.addAll(applied);
      _loading = false;
    });
  }

  bool get _done => _tasks.isEmpty || _i >= _tasks.length;
  SwipeTask get _top => _tasks[_i];
  SwipeTask? get _next =>
      _i + 1 < _tasks.length ? _tasks[_i + 1] : null;

  Offset get _pos {
    if (!_fly.isAnimating) return _drag;
    return Offset.lerp(_drag, _flyEnd, Curves.easeIn.transform(_fly.value))!;
  }

  void _onUpdate(DragUpdateDetails d) {
    if (!_fly.isAnimating) setState(() => _drag += d.delta);
  }

  void _onEnd(DragEndDetails d) {
    if (_fly.isAnimating) return;
    if (_drag.dx.abs() > _threshold ||
        d.velocity.pixelsPerSecond.dx.abs() > 300) {
      _swipe(_drag.dx > 0);
    } else {
      setState(() => _drag = Offset.zero);
    }
  }

  void _swipe(bool apply) {
    final task = _top;
    _flyEnd = Offset(apply ? 600 : -600, _drag.dy);
    _fly.forward(from: 0).then((_) {
      if (mounted) setState(() { _i++; _drag = Offset.zero; });
      _fly.reset();
    });
    if (apply) {
      ApiClient.apply(task.projectId, task.taskId);
      _appliedTaskIds.add(task.taskId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: kAccent));
    }

    if (_done) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.done_all, size: 56, color: kAccent),
            const SizedBox(height: 16),
            Text("You're all caught up!", style: kHeading(22)),
            const SizedBox(height: 8),
            Text('No more tasks to review right now.',
              style: kBody(15, color: kInk3), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            DmBtn(
              label: 'Refresh',
              variant: DmBtnVariant.outline,
              icon: Icons.refresh,
              onPressed: () => setState(() { _i = 0; _loading = true; _tasks = []; _load(); }),
            ),
          ]),
        ),
      );
    }

    final pos = _pos;
    final progress = (pos.dx.abs() / _threshold).clamp(0.0, 1.0);
    final applyAmt = (pos.dx / _threshold).clamp(0.0, 1.0);
    final skipAmt = (-pos.dx / _threshold).clamp(0.0, 1.0);

    return Stack(fit: StackFit.expand, children: [
      if (_next != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - progress)),
            child: Transform.scale(
              scale: 0.93 + progress * 0.07,
              child: CompanyCard(task: _next!),
            ),
          ),
        ),
      GestureDetector(
        onPanUpdate: _onUpdate,
        onPanEnd: _onEnd,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.identity()
              ..translateByDouble(pos.dx, pos.dy, 0, 1)
              ..rotateZ(pos.dx / 400),
            child: _CardWithOverlay(
                task: _top, applyAmt: applyAmt, skipAmt: skipAmt),
          ),
        ),
      ),
    ]);
  }
}

class _CardWithOverlay extends StatelessWidget {
  const _CardWithOverlay(
      {required this.task, required this.applyAmt, required this.skipAmt});
  final SwipeTask task;
  final double applyAmt, skipAmt;

  Widget _stamp(Color c, String label, Alignment align, double opacity, double angle) =>
      Positioned.fill(
        child: Opacity(
          opacity: opacity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c, width: 3),
            ),
            child: Align(
              alignment: align,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Transform.rotate(
                  angle: angle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: c, width: 2.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(label,
                      style: TextStyle(
                          color: c, fontWeight: FontWeight.w900,
                          fontSize: 20, letterSpacing: 2)),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Stack(children: [
    CompanyCard(task: task),
    if (applyAmt > 0) _stamp(kAccent, 'APPLY', Alignment.topLeft, applyAmt, -0.3),
    if (skipAmt > 0) _stamp(Colors.red, 'SKIP', Alignment.topRight, skipAmt, 0.3),
  ]);
}
