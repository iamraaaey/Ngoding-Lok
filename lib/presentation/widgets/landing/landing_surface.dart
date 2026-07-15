import 'package:flutter/material.dart';

import '../../theme/landing_tokens.dart';

/// The page-wide, original atmosphere behind the landing content. It is made
/// from gradients and vector primitives so exported Figma/Canva art can later
/// replace or layer over it without coupling the layout to an image asset.
class CinematicBackdrop extends StatelessWidget {
  const CinematicBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(gradient: LandingTokens.pageGradient),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(gradient: LandingTokens.heroGlow),
          ),
          Positioned(
            top: -150,
            right: -180,
            child: _GlowOrb(
              diameter: 420,
              color: LandingTokens.sunlight.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            top: 520,
            left: -240,
            child: _GlowOrb(
              diameter: 520,
              color: LandingTokens.gameBlue.withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            bottom: -260,
            right: -120,
            child: _GlowOrb(
              diameter: 540,
              color: LandingTokens.gamePink.withValues(alpha: 0.1),
            ),
          ),
          const RepaintBoundary(
            child: CustomPaint(painter: _AtmospherePainter()),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double diameter;
  final Color color;

  const _GlowOrb({required this.diameter, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 110, spreadRadius: 42)],
      ),
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  const _AtmospherePainter();

  static const List<Offset> _stars = <Offset>[
    Offset(0.06, 0.04),
    Offset(0.13, 0.15),
    Offset(0.22, 0.07),
    Offset(0.31, 0.2),
    Offset(0.4, 0.09),
    Offset(0.48, 0.17),
    Offset(0.58, 0.05),
    Offset(0.67, 0.21),
    Offset(0.76, 0.11),
    Offset(0.88, 0.18),
    Offset(0.94, 0.06),
    Offset(0.08, 0.38),
    Offset(0.2, 0.47),
    Offset(0.35, 0.4),
    Offset(0.52, 0.46),
    Offset(0.7, 0.37),
    Offset(0.86, 0.48),
    Offset(0.1, 0.66),
    Offset(0.29, 0.59),
    Offset(0.45, 0.74),
    Offset(0.63, 0.63),
    Offset(0.78, 0.72),
    Offset(0.93, 0.61),
    Offset(0.16, 0.9),
    Offset(0.41, 0.88),
    Offset(0.67, 0.93),
    Offset(0.88, 0.86),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()
      ..color = LandingTokens.cream.withValues(alpha: 0.2);
    for (var index = 0; index < _stars.length; index++) {
      final star = _stars[index];
      final radius = index.isEven ? 1.2 : 0.7;
      canvas.drawCircle(
        Offset(star.dx * size.width, star.dy * size.height),
        radius,
        starPaint,
      );
    }

    final linePaint = Paint()
      ..color = LandingTokens.cream.withValues(alpha: 0.045)
      ..strokeWidth = 1;
    const grid = 72.0;
    for (var x = -size.height; x < size.width + size.height; x += grid) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) => false;
}

/// The translucent surface used for feature cards, code previews, and callout
/// panels. It keeps the landing-specific depth language independent of the
/// rest of the app's neo-brutalist screens.
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
    this.borderRadius = LandingTokens.largeRadius,
    this.color,
    this.highEmphasis = false,
  });

  @override
  Widget build(BuildContext context) {
    final panelColor =
        color ??
        (highEmphasis ? LandingTokens.surfaceStrong : LandingTokens.surface);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: borderRadius,
        border: Border.all(color: LandingTokens.outline),
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

class SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? body;
  final TextAlign textAlign;
  final double? titleSize;

  const SectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.body,
    this.textAlign = TextAlign.left,
    this.titleSize,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final aligned = textAlign == TextAlign.center
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final defaultSize = width >= LandingTokens.desktopBreakpoint ? 46.0 : 36.0;

    return Column(
      crossAxisAlignment: aligned,
      children: [
        _Eyebrow(label: eyebrow),
        const SizedBox(height: LandingTokens.space16),
        Semantics(
          header: true,
          child: Text(
            title,
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
              style: LandingTokens.body(fontSize: 17),
            ),
          ),
        ],
      ],
    );
  }
}

class _Eyebrow extends StatelessWidget {
  final String label;

  const _Eyebrow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LandingTokens.space12,
        vertical: LandingTokens.space8,
      ),
      decoration: BoxDecoration(
        color: LandingTokens.surfaceLight,
        borderRadius: LandingTokens.pillRadius,
        border: Border.all(color: LandingTokens.outline),
      ),
      child: Text(
        label.toUpperCase(),
        style: LandingTokens.label(
          color: LandingTokens.gameYellow,
          fontSize: 11,
        ),
      ),
    );
  }
}
