import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/landing_tokens.dart';

/// The page-wide atmosphere behind the landing content: a near-black field
/// with faint vertical grid hairlines, sparse "+" survey marks, and one slow
/// drifting ember glow. Built from vector primitives so no image asset is
/// required.
class CinematicBackdrop extends StatefulWidget {
  const CinematicBackdrop({super.key});

  @override
  State<CinematicBackdrop> createState() => _CinematicBackdropState();
}

class _CinematicBackdropState extends State<CinematicBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 26),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (LandingTokens.reducedMotion(context)) {
      _drift.stop();
      _drift.value = 0.35;
    } else if (!_drift.isAnimating) {
      _drift.repeat();
    }
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: LandingTokens.voidBlack),
          AnimatedBuilder(
            animation: _drift,
            builder: (context, _) {
              final t = _drift.value * 2 * math.pi;
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      0.65 + 0.25 * math.cos(t),
                      -0.7 + 0.18 * math.sin(t),
                    ),
                    radius: 1.15,
                    colors: const <Color>[
                      Color(0x14FF5C01),
                      Color(0x00070707),
                    ],
                  ),
                ),
              );
            },
          ),
          const RepaintBoundary(
            child: CustomPaint(painter: _BlueprintPainter()),
          ),
        ],
      ),
    );
  }
}

class _BlueprintPainter extends CustomPainter {
  const _BlueprintPainter();

  static const List<Offset> _marks = <Offset>[
    Offset(0.08, 0.06),
    Offset(0.3, 0.14),
    Offset(0.62, 0.05),
    Offset(0.9, 0.12),
    Offset(0.16, 0.34),
    Offset(0.48, 0.28),
    Offset(0.82, 0.4),
    Offset(0.07, 0.58),
    Offset(0.38, 0.52),
    Offset(0.68, 0.66),
    Offset(0.93, 0.6),
    Offset(0.22, 0.8),
    Offset(0.55, 0.88),
    Offset(0.84, 0.82),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Vertical hairlines every quarter of the content field, like the
    // section rules in the reference shot.
    final linePaint = Paint()
      ..color = const Color(0x0AFFFFFF)
      ..strokeWidth = 1;
    for (final fraction in const <double>[0.25, 0.5, 0.75]) {
      final x = size.width * fraction;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    // Sparse "+" survey marks.
    final markPaint = Paint()
      ..color = const Color(0x17FFFFFF)
      ..strokeWidth = 1;
    for (final mark in _marks) {
      final center = Offset(mark.dx * size.width, mark.dy * size.height);
      canvas.drawLine(
        center - const Offset(4, 0),
        center + const Offset(4, 0),
        markPaint,
      );
      canvas.drawLine(
        center - const Offset(0, 4),
        center + const Offset(0, 4),
        markPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BlueprintPainter oldDelegate) => false;
}

/// The standard raised surface: carbon fill, hairline border, near-sharp
/// corners. Replaces the old glass panel while keeping its call sites.
class LandingGlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? color;
  final bool highEmphasis;

  const LandingGlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(LandingTokens.space24),
    this.borderRadius = LandingTokens.mediumRadius,
    this.color,
    this.highEmphasis = false,
  });

  @override
  Widget build(BuildContext context) {
    final panelColor =
        color ?? (highEmphasis ? LandingTokens.panel : LandingTokens.carbon);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: borderRadius,
        border: Border.all(color: LandingTokens.hairline),
        boxShadow: LandingTokens.cardShadow,
      ),
      child: child,
    );
  }
}

/// Constrains every section to the same responsive page grid.
class LandingSection extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const LandingSection({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: LandingTokens.contentMaxWidth,
        ),
        child: Padding(
          padding:
              padding ??
              LandingTokens.pagePaddingFor(width).copyWith(
                top: LandingTokens.sectionVerticalPaddingFor(width),
                bottom: LandingTokens.sectionVerticalPaddingFor(width),
              ),
          child: child,
        ),
      ),
    );
  }
}

/// Monospace "// EYEBROW — 00N" line above a heavy display title.
class SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? body;
  final TextAlign textAlign;
  final double? titleSize;
  final String? index;

  const SectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.body,
    this.textAlign = TextAlign.left,
    this.titleSize,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final aligned = textAlign == TextAlign.center
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final defaultSize = width >= LandingTokens.desktopBreakpoint ? 44.0 : 32.0;

    return Column(
      crossAxisAlignment: aligned,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                '// ${eyebrow.toUpperCase()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LandingTokens.label(color: LandingTokens.ember),
              ),
            ),
            if (index != null) ...[
              const SizedBox(width: LandingTokens.space12),
              Text(
                '— $index',
                style: LandingTokens.label(color: LandingTokens.textFaint),
              ),
            ],
          ],
        ),
        const SizedBox(height: LandingTokens.space16),
        Semantics(
          header: true,
          child: Text(
            title.toUpperCase(),
            textAlign: textAlign,
            style: LandingTokens.sectionTitle(
              fontSize: titleSize ?? defaultSize,
            ),
          ),
        ),
        if (body != null) ...[
          const SizedBox(height: LandingTokens.space16),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: LandingTokens.readingMaxWidth,
            ),
            child: Text(
              body!,
              textAlign: textAlign,
              style: LandingTokens.body(fontSize: 16),
            ),
          ),
        ],
      ],
    );
  }
}

/// Thin full-width rule that draws the page's horizontal grid.
class HairlineDivider extends StatelessWidget {
  final Color color;

  const HairlineDivider({super.key, this.color = LandingTokens.hairline});

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: color);
  }
}

/// A blinking terminal cursor block. Renders as a steady block when the
/// platform asks for reduced motion.
class BlinkingCursor extends StatefulWidget {
  final Color color;
  final double height;
  final double width;

  const BlinkingCursor({
    super.key,
    this.color = LandingTokens.ember,
    this.height = 14,
    this.width = 8,
  });

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (LandingTokens.reducedMotion(context)) {
      _blink.stop();
      _blink.value = 0;
    } else if (!_blink.isAnimating) {
      _blink.repeat();
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _blink,
      builder: (context, _) {
        return Opacity(
          opacity: _blink.value < 0.5 ? 1 : 0,
          child: Container(
            width: widget.width,
            height: widget.height,
            color: widget.color,
          ),
        );
      },
    );
  }
}

/// Small status dot with a soft expanding pulse ring.
class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulsingDot({
    super.key,
    this.color = LandingTokens.signal,
    this.size = 7,
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (LandingTokens.reducedMotion(context)) {
      _pulse.stop();
      _pulse.value = 0;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ringMax = widget.size * 2.6;
    return SizedBox(
      width: ringMax,
      height: ringMax,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          final t = Curves.easeOut.transform(_pulse.value);
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.size + (ringMax - widget.size) * t,
                height: widget.size + (ringMax - widget.size) * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withValues(alpha: (1 - t) * 0.55),
                  ),
                ),
              ),
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Fades and slides its child in the first time it scrolls into view.
class ScrollReveal extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double offsetY;

  const ScrollReveal({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 620),
    this.delay = Duration.zero,
    this.offsetY = 26,
  });

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final CurvedAnimation _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  ScrollPosition? _position;
  bool _revealed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (LandingTokens.reducedMotion(context)) {
      _controller.duration = Duration.zero;
    }
    final position = Scrollable.maybeOf(context)?.position;
    if (!identical(position, _position)) {
      _position?.removeListener(_checkVisibility);
      _position = position;
      _position?.addListener(_checkVisibility);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  void _checkVisibility() {
    if (_revealed || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return;
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final top = box.localToGlobal(Offset.zero).dy;
    if (top < viewportHeight * 0.9) {
      _revealed = true;
      _position?.removeListener(_checkVisibility);
      if (widget.delay == Duration.zero) {
        _controller.forward();
      } else {
        Future<void>.delayed(widget.delay, () {
          if (mounted) _controller.forward();
        });
      }
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_checkVisibility);
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _animation.value) * widget.offsetY),
            child: child,
          ),
        );
      },
    );
  }
}

/// A surface filled with the slowly rotating iridescent gradient — the one
/// rainbow element of the page, mirroring the robot screen in the reference.
class AnimatedIridescence extends StatefulWidget {
  final Widget? child;
  final BorderRadius borderRadius;

  const AnimatedIridescence({
    super.key,
    this.child,
    this.borderRadius = LandingTokens.mediumRadius,
  });

  @override
  State<AnimatedIridescence> createState() => _AnimatedIridescenceState();
}

class _AnimatedIridescenceState extends State<AnimatedIridescence>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (LandingTokens.reducedMotion(context)) {
      _sweep.stop();
      _sweep.value = 0.15;
    } else if (!_sweep.isAnimating) {
      _sweep.repeat();
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sweep,
      child: widget.child,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              colors: LandingTokens.iridescence,
              transform: GradientRotation(_sweep.value * 2 * math.pi),
            ),
          ),
          child: child,
        );
      },
    );
  }
}
