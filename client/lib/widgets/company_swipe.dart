import 'package:flutter/material.dart';
import 'company_card.dart';

class CompanySwipe extends StatefulWidget {
  const CompanySwipe({super.key});
  @override
  State<CompanySwipe> createState() => _CompanySwipeState();
}

class _CompanySwipeState extends State<CompanySwipe>
    with SingleTickerProviderStateMixin {
  int _i = 0;
  Offset _drag = Offset.zero;
  late AnimationController _fly;
  Offset _flyEnd = Offset.zero;

  static const _threshold = 80.0;

  @override
  void initState() {
    super.initState();
    _fly = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() { _fly.dispose(); super.dispose(); }

  Company get _top => companies[_i % companies.length];
  Company get _next => companies[(_i + 1) % companies.length];

  Offset get _pos {
    if (!_fly.isAnimating) return _drag;
    return Offset.lerp(_drag, _flyEnd, Curves.easeIn.transform(_fly.value))!;
  }

  void _onUpdate(DragUpdateDetails d) {
    if (!_fly.isAnimating) setState(() => _drag += d.delta);
  }

  void _onEnd(DragEndDetails d) {
    if (_fly.isAnimating) return;
    if (_drag.dx.abs() > _threshold || d.velocity.pixelsPerSecond.dx.abs() > 300) {
      _swipe(_drag.dx > 0);
    } else {
      setState(() => _drag = Offset.zero);
    }
  }

  void _swipe(bool apply) {
    _flyEnd = Offset(apply ? 600 : -600, _drag.dy);
    _fly.forward(from: 0).then((_) {
      if (mounted) setState(() { _i++; _drag = Offset.zero; });
      _fly.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pos = _pos;
    final progress = (pos.dx.abs() / _threshold).clamp(0.0, 1.0);
    final applyAmt = (pos.dx / _threshold).clamp(0.0, 1.0);
    final skipAmt = (-pos.dx / _threshold).clamp(0.0, 1.0);

    return Stack(fit: StackFit.expand, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - progress)),
          child: Transform.scale(
            scale: 0.93 + progress * 0.07,
            child: CompanyCard(company: _next),
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
            child: _CardWithOverlay(company: _top, applyAmt: applyAmt, skipAmt: skipAmt),
          ),
        ),
      ),
    ]);
  }
}

class _CardWithOverlay extends StatelessWidget {
  const _CardWithOverlay(
      {required this.company, required this.applyAmt, required this.skipAmt});
  final Company company; final double applyAmt, skipAmt;

  Widget _stamp(Color c, String label, Alignment align, double opacity, double angle) =>
      Positioned.fill(child: Opacity(opacity: opacity, child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: c, width: 3)),
        child: Align(alignment: align, child: Padding(padding: const EdgeInsets.all(16),
          child: Transform.rotate(angle: angle, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(border: Border.all(color: c, width: 2.5), borderRadius: BorderRadius.circular(6)),
            child: Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 2)),
          )))),
      )));

  @override
  Widget build(BuildContext context) => Stack(children: [
    CompanyCard(company: company),
    if (applyAmt > 0) _stamp(Colors.green, 'APPLY', Alignment.topLeft, applyAmt, -0.3),
    if (skipAmt > 0) _stamp(Colors.red, 'SKIP', Alignment.topRight, skipAmt, 0.3),
  ]);
}
