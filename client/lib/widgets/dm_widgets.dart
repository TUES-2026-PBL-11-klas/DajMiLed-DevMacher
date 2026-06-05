import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../theme.dart';
import '../data.dart';

// ── Logo ─────────────────────────────────────────────────────────
class DmLogo extends StatelessWidget {
  final double size;
  const DmLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: kAccent,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [BoxShadow(color: kAccent.withValues(alpha: 0.4), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Icon(LucideIcons.code2, color: Colors.white, size: size * 0.52),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────
class DmAvatar extends StatelessWidget {
  final AvatarData data;
  final double size;
  final bool ring;
  const DmAvatar({super.key, required this.data, this.size = 48, this.ring = false});

  @override
  Widget build(BuildContext context) {
    Widget circle = Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: data.bg,
        shape: BoxShape.circle,
        boxShadow: ring ? [
          BoxShadow(color: Colors.white, spreadRadius: 3),
          BoxShadow(color: data.fg.withValues(alpha: 0.22), spreadRadius: 5),
        ] : null,
      ),
      alignment: Alignment.center,
      child: Text(data.initials,
        style: TextStyle(
          fontFamily: 'monospace', fontWeight: FontWeight.w700,
          fontSize: size * 0.34, color: data.fg, letterSpacing: -0.5)),
    );
    return circle;
  }
}

// ── Tag / Chip ────────────────────────────────────────────────────
enum DmTagTone { def, accent, outline, light }

class DmTag extends StatelessWidget {
  final String text;
  final DmTagTone tone;
  final bool small;
  const DmTag(this.text, {super.key, this.tone = DmTagTone.def, this.small = false});

  @override
  Widget build(BuildContext context) {
    Color bg, fg, bd;
    switch (tone) {
      case DmTagTone.accent: bg = kAccentSoft; fg = kAccentInk; bd = Colors.transparent;
      case DmTagTone.outline: bg = Colors.transparent; fg = kInk2; bd = kLine;
      case DmTagTone.light: bg = Colors.white.withValues(alpha: 0.16); fg = Colors.white; bd = Colors.transparent;
      default: bg = kSurface2; fg = kInk2; bd = Colors.transparent;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 9 : 12, vertical: small ? 4 : 6),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bd, width: 1.5),
      ),
      child: Text(text,
        style: TextStyle(fontFamily: 'monospace', fontSize: small ? 12 : 13,
          fontWeight: FontWeight.w500, color: fg)),
    );
  }
}

// ── Button ────────────────────────────────────────────────────────
enum DmBtnVariant { primary, dark, ghost, outline }

class DmBtn extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final DmBtnVariant variant;
  final bool full, disabled;
  final IconData? icon;
  final double? fontSize;
  const DmBtn({super.key, required this.label, this.onPressed, this.variant = DmBtnVariant.primary,
    this.full = false, this.disabled = false, this.icon, this.fontSize});

  @override
  State<DmBtn> createState() => _DmBtnState();
}

class _DmBtnState extends State<DmBtn> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    Border? border;
    List<BoxShadow> shadow = [];
    switch (widget.variant) {
      case DmBtnVariant.dark: bg = kInk; fg = Colors.white;
      case DmBtnVariant.ghost: bg = kSurface2; fg = kInk;
      case DmBtnVariant.outline:
        bg = Colors.white; fg = kInk;
        border = Border.all(color: kLine, width: 1.5);
      default:
        bg = widget.disabled ? kAccent.withValues(alpha: 0.4) : kAccent;
        fg = Colors.white;
        if (!widget.disabled) shadow = [BoxShadow(color: kAccent.withValues(alpha: 0.45), blurRadius: 20, offset: const Offset(0, 8))];
    }
    return GestureDetector(
      onTapDown: widget.disabled ? null : (_) => setState(() => _scale = 0.97),
      onTapUp: widget.disabled ? null : (_) { setState(() => _scale = 1.0); widget.onPressed?.call(); },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Opacity(
          opacity: widget.disabled ? 0.45 : 1.0,
          child: Container(
            width: widget.full ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
            decoration: BoxDecoration(
              color: bg, borderRadius: BorderRadius.circular(16),
              border: border, boxShadow: shadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: widget.full ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[Icon(widget.icon, color: fg, size: 18), const SizedBox(width: 9)],
                Text(widget.label,
                  style: TextStyle(color: fg, fontSize: widget.fontSize ?? 16,
                    fontWeight: FontWeight.w600, letterSpacing: -0.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Match ring badge ──────────────────────────────────────────────
class DmMatchRing extends StatelessWidget {
  final int value;
  final bool dark;
  const DmMatchRing(this.value, {super.key, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final bg = dark ? Colors.white.withValues(alpha: 0.18) : kAccentSoft;
    final fg = dark ? Colors.white : kAccentInk;
    final dot = dark ? Colors.white : kAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$value% match', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600, fontSize: 13, color: fg)),
      ]),
    );
  }
}

// ── Placeholder art (card header) ─────────────────────────────────
class DmPlaceholderArt extends StatelessWidget {
  final AvatarData data;
  const DmPlaceholderArt(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: data.bg,
      child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _HatchPainter(data.fg))),
        Center(
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 8))],
            ),
            alignment: Alignment.center,
            child: Text(data.initials,
              style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w800,
                fontSize: 26, color: data.fg)),
          ),
        ),
      ]),
    );
  }
}

class _HatchPainter extends CustomPainter {
  final Color color;
  _HatchPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (double i = -size.height; i < size.width + size.height; i += 24) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }
  @override bool shouldRepaint(_) => false;
}

// ── Stat card ─────────────────────────────────────────────────────
class DmStatCard extends StatelessWidget {
  final IconData icon;
  final String top, bot;
  const DmStatCard({super.key, required this.icon, required this.top, required this.bot});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kLine, width: 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: kAccent, size: 18),
          const SizedBox(height: 6),
          Text(top, style: kBody(14.5, color: kInk, weight: FontWeight.w700),
            overflow: TextOverflow.ellipsis, maxLines: 1),
          const SizedBox(height: 2),
          Text(bot.toUpperCase(), style: kMono(10.5, color: kInk3)),
        ]),
      ),
    );
  }
}

// ── Section ───────────────────────────────────────────────────────
class DmSection extends StatelessWidget {
  final String title;
  final Widget child;
  const DmSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: Text(title.toUpperCase(), style: kLabel()),
        ),
        child,
      ]),
    );
  }
}

// ── Nav back button ───────────────────────────────────────────────
class DmNavBtn extends StatelessWidget {
  final VoidCallback onPressed;
  const DmNavBtn({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white, shape: BoxShape.circle,
          border: Border.all(color: kLine, width: 1.5),
        ),
        child: const Icon(LucideIcons.arrowLeft, size: 20, color: kInk),
      ),
    );
  }
}

// ── Progress bar ──────────────────────────────────────────────────
class DmProgress extends StatelessWidget {
  final int step, total;
  const DmProgress({super.key, required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) => Expanded(
        flex: i == step ? 2 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          height: 6,
          margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
          decoration: BoxDecoration(
            color: i <= step ? kAccent : kSurface2,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      )),
    );
  }
}

// ── Toast ─────────────────────────────────────────────────────────
class DmToast extends StatelessWidget {
  final String text;
  final IconData icon;
  const DmToast({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: kInk, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: kInk.withValues(alpha: 0.3), blurRadius: 36, offset: const Offset(0, 16))],
      ),
      child: Row(children: [
        Container(
          width: 26, height: 26,
          decoration: const BoxDecoration(color: kAccent, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 15),
        ),
        const SizedBox(width: 11),
        Expanded(child: Text(text, style: kBody(14.5, color: Colors.white, weight: FontWeight.w500))),
      ]),
    );
  }
}

// ── Action button (circular) ──────────────────────────────────────
class DmActionBtn extends StatefulWidget {
  final IconData icon;
  final Color iconColor, bgColor, borderColor;
  final double size;
  final VoidCallback? onPressed;
  final bool disabled;
  final List<BoxShadow> shadow;

  const DmActionBtn({super.key, required this.icon, required this.iconColor,
    required this.bgColor, required this.borderColor, this.size = 48,
    this.onPressed, this.disabled = false, this.shadow = const []});

  @override
  State<DmActionBtn> createState() => _DmActionBtnState();
}

class _DmActionBtnState extends State<DmActionBtn> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.disabled ? null : (_) => setState(() => _scale = 0.9),
      onTapUp: widget.disabled ? null : (_) { setState(() => _scale = 1.0); widget.onPressed?.call(); },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Opacity(
          opacity: widget.disabled ? 0.4 : 1.0,
          child: Container(
            width: widget.size, height: widget.size,
            decoration: BoxDecoration(
              color: widget.bgColor, shape: BoxShape.circle,
              border: Border.all(color: widget.borderColor, width: 1.5),
              boxShadow: widget.shadow,
            ),
            child: Icon(widget.icon, color: widget.iconColor, size: widget.size * 0.42),
          ),
        ),
      ),
    );
  }
}

// ── Chat bubble ───────────────────────────────────────────────────
class DmBubble extends StatelessWidget {
  final bool me;
  final Widget child;
  const DmBubble({super.key, required this.me, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: me ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: me ? kAccent : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(me ? 18 : 5),
            bottomRight: Radius.circular(me ? 5 : 18),
          ),
          border: me ? null : Border.all(color: kLine),
          boxShadow: me
              ? [BoxShadow(color: kAccent.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))]
              : [BoxShadow(color: kInk.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: DefaultTextStyle(
          style: kBody(14.5, color: me ? Colors.white : kInk, weight: me ? FontWeight.w600 : FontWeight.w500),
          child: child,
        ),
      ),
    );
  }
}
