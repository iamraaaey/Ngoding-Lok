import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shared neo-brutalist "doodle" palette/components used across the landing
/// page and the in-app screens, so the whole product reads as one design
/// system rather than a marketing page bolted onto a plain Material app.
class DoodlePalette {
  DoodlePalette._();

  // Base surfaces darkened to the landing page's near-black "terminal noir"
  // field so in-app screens read as the same product as the marketing page.
  static const dark = Color(0xFF0A0A0A);
  static const yellow = Color(0xFFFFD166);
  static const red = Color(0xFFEF476F);
  static const green = Color(0xFF06D6A0);
  static const blue = Color(0xFF118AB2);
  static const orange = Color(0xFFFF5C01);
  static const purple = Color(0xFF9D4EDD);
  static const white = Color(0xFFFAFAFA);
  static const cream = Color(0xFFFFFBEB);
}

/// Surface with a thick black border and hard drop-shadow.
class DoodleCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double shadowOffset;

  const DoodleCard({
    super.key,
    required this.child,
    this.color = DoodlePalette.white,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(18),
    this.shadowOffset = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(shadowOffset, shadowOffset),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Button with a hard drop-shadow that "presses in" on tap. Passing `null`
/// for [onPressed] renders it disabled (dimmed, no press feedback).
class DoodleButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool dense;
  final bool isLoading;

  const DoodleButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
    this.icon,
    this.dense = false,
    this.isLoading = false,
  });

  @override
  State<DoodleButton> createState() => _DoodleButtonState();
}

class _DoodleButtonState extends State<DoodleButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final shadow = _pressed && _enabled ? 2.0 : 5.0;
    return GestureDetector(
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.onPressed,
      child: Opacity(
        opacity: _enabled ? 1 : 0.6,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          padding: EdgeInsets.symmetric(
            horizontal: widget.dense ? 10 : 32,
            vertical: widget.dense ? 12 : 18,
          ),
          transform: Matrix4.translationValues(
            _pressed && _enabled ? 3 : 0,
            _pressed && _enabled ? 3 : 0,
            0,
          ),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(widget.dense ? 12 : 16),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: [
              BoxShadow(color: Colors.black, offset: Offset(shadow, shadow)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  widget.label.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    fontSize: widget.dense ? 13 : 17,
                  ),
                ),
              ),
              if (widget.isLoading) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: widget.dense ? 12 : 16,
                  height: widget.dense ? 12 : 16,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                ),
              ] else if (widget.icon != null) ...[
                const SizedBox(width: 8),
                Icon(
                  widget.icon,
                  color: Colors.black,
                  size: widget.dense ? 16 : 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Small rounded tag/badge, e.g. "PHASE 1 & 2" or "CLEARED".
class DoodlePill extends StatelessWidget {
  final String text;
  final Color background;
  final Color textColor;
  final double rotation;

  const DoodlePill({
    super.key,
    required this.text,
    this.background = DoodlePalette.yellow,
    this.textColor = Colors.black,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

/// Colored square badge with a centered icon, used for logos/module icons.
class DoodleIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final double size;
  final double iconSize;
  final double borderRadius;

  const DoodleIconBadge({
    super.key,
    required this.icon,
    this.color = DoodlePalette.purple,
    this.iconColor = Colors.white,
    this.size = 44,
    this.iconSize = 22,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Icon(icon, color: iconColor, size: iconSize),
    );
  }
}

/// Wraps [child] with the dark dotted-grid background used behind every
/// screen, matching the landing page's texture.
class DoodleDotBackground extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const DoodleDotBackground({
    super.key,
    required this.child,
    this.backgroundColor = DoodlePalette.dark,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: Stack(
        children: [
          const Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: DoodleDotGridPainter()),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class DoodleDotGridPainter extends CustomPainter {
  const DoodleDotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.08);
    const spacing = 20.0;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DoodleDotGridPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────
//  ANIMATED COMPONENTS
// ─────────────────────────────────────────────────────────────

/// Dot-grid background whose dots gently twinkle over time.
class AnimatedDoodleDotBackground extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;

  const AnimatedDoodleDotBackground({
    super.key,
    required this.child,
    this.backgroundColor = DoodlePalette.dark,
  });

  @override
  State<AnimatedDoodleDotBackground> createState() =>
      _AnimatedDoodleDotBackgroundState();
}

class _AnimatedDoodleDotBackgroundState
    extends State<AnimatedDoodleDotBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.backgroundColor,
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, _) =>
                    CustomPaint(painter: _TwinklingDotPainter(_ctrl.value)),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _TwinklingDotPainter extends CustomPainter {
  final double t;
  const _TwinklingDotPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 20.0;
    final paint = Paint();
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        final phase = (x * 0.31 + y * 0.73) % (2 * math.pi);
        final alpha = 0.04 + 0.05 * math.sin(t * 2 * math.pi + phase);
        paint.color = Colors.white.withValues(alpha: alpha.clamp(0.02, 0.12));
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TwinklingDotPainter old) => old.t != t;
}

/// Gently bobs its [child] up and down indefinitely.
class FloatingWidget extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration period;

  const FloatingWidget({
    super.key,
    required this.child,
    this.amplitude = 8.0,
    this.period = const Duration(seconds: 3),
  });

  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _curved;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.period)
      ..repeat(reverse: true);
    _curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curved,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, (_curved.value - 0.5) * widget.amplitude * 2),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Pulsing colored glow behind its [child] for emphasis on key CTAs.
class PulsingGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double borderRadius;

  const PulsingGlow({
    super.key,
    required this.child,
    this.glowColor = DoodlePalette.green,
    this.borderRadius = 20,
  });

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: widget.glowColor.withValues(
                alpha: 0.10 + _ctrl.value * 0.25,
              ),
              blurRadius: 14 + _ctrl.value * 22,
              spreadRadius: _ctrl.value * 4,
            ),
          ],
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Fade + slide entrance animation. Use [yOffset] > 0 to slide up,
/// < 0 to slide down. Driven by an external [animation] (0 → 1).
class DoodleFadeSlide extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final double yOffset;

  const DoodleFadeSlide({
    super.key,
    required this.child,
    required this.animation,
    this.yOffset = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) {
        final v = animation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, yOffset * (1 - v)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
