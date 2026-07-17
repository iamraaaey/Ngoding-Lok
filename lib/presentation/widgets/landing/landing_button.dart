import 'package:flutter/material.dart';

import '../../theme/landing_tokens.dart';

/// The high-emphasis CTA: a solid ember block with a mono uppercase label
/// and an arrow that nudges forward on hover. Square corners on purpose —
/// this theme's buttons are boxes, not pills.
class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool compact;
  final String? semanticLabel;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.compact = false,
    this.semanticLabel,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final motion = LandingTokens.motionFor(context, LandingTokens.motionFast);
    final icon = widget.icon ?? Icons.arrow_forward_rounded;

    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      label: widget.semanticLabel ?? widget.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: motion,
          decoration: BoxDecoration(
            borderRadius: LandingTokens.smallRadius,
            boxShadow: _hovered ? LandingTokens.emberGlow : null,
          ),
          child: FilledButton(
            onPressed: widget.onPressed,
            style: _style(),
            child: LayoutBuilder(
              builder: (context, constraints) => Row(
                mainAxisSize: constraints.hasBoundedWidth
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      widget.label.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LandingTokens.label(
                        color: const Color(0xFF0A0500),
                        fontSize: widget.compact ? 11 : 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: widget.compact ? 8 : 10),
                  AnimatedSlide(
                    duration: motion,
                    offset: _hovered ? const Offset(0.18, 0) : Offset.zero,
                    child: Icon(
                      icon,
                      size: widget.compact ? 15 : 17,
                      color: const Color(0xFF0A0500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _style() {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed)) {
          return LandingTokens.emberBright;
        }
        return LandingTokens.ember;
      }),
      foregroundColor: const WidgetStatePropertyAll<Color>(Color(0xFF0A0500)),
      overlayColor: WidgetStatePropertyAll<Color>(
        Colors.black.withValues(alpha: 0.08),
      ),
      elevation: const WidgetStatePropertyAll<double>(0),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(
          horizontal: widget.compact ? 16 : 24,
          vertical: widget.compact ? 12 : 18,
        ),
      ),
      minimumSize: const WidgetStatePropertyAll<Size>(Size(48, 48)),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: LandingTokens.smallRadius),
      ),
      side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
        if (states.contains(WidgetState.focused)) {
          return const BorderSide(color: LandingTokens.focusRing, width: 2);
        }
        return BorderSide.none;
      }),
    );
  }
}

/// The low-emphasis CTA: hairline box, mono label wrapped in brackets. The
/// border and text warm up to ember on hover.
class CinematicOutlineButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool compact;
  final String? semanticLabel;

  const CinematicOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.compact = false,
    this.semanticLabel,
  });

  @override
  State<CinematicOutlineButton> createState() => _CinematicOutlineButtonState();
}

class _CinematicOutlineButtonState extends State<CinematicOutlineButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final motion = LandingTokens.motionFor(context, LandingTokens.motionFast);
    final color = _hovered ? LandingTokens.ember : LandingTokens.textPrimary;

    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      label: widget.semanticLabel ?? widget.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: OutlinedButton(
          onPressed: widget.onPressed,
          style: _style(),
          child: LayoutBuilder(
            builder: (context, constraints) => Row(
              mainAxisSize: constraints.hasBoundedWidth
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: AnimatedDefaultTextStyle(
                    duration: motion,
                    style: LandingTokens.label(
                      color: color,
                      fontSize: widget.compact ? 11 : 12,
                      fontWeight: FontWeight.w700,
                    ),
                    child: Text(
                      '[ ${widget.label.toUpperCase()} ]',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (widget.icon != null) ...[
                  SizedBox(width: widget.compact ? 8 : 10),
                  Icon(
                    widget.icon,
                    size: widget.compact ? 15 : 17,
                    color: color,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _style() {
    return ButtonStyle(
      foregroundColor: const WidgetStatePropertyAll<Color>(
        LandingTokens.textPrimary,
      ),
      overlayColor: WidgetStatePropertyAll<Color>(
        LandingTokens.ember.withValues(alpha: 0.08),
      ),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(
          horizontal: widget.compact ? 14 : 22,
          vertical: widget.compact ? 12 : 18,
        ),
      ),
      minimumSize: const WidgetStatePropertyAll<Size>(Size(48, 48)),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: LandingTokens.smallRadius),
      ),
      side: WidgetStateProperty.resolveWith<BorderSide>((states) {
        if (states.contains(WidgetState.focused)) {
          return const BorderSide(color: LandingTokens.focusRing, width: 2);
        }
        if (states.contains(WidgetState.hovered)) {
          return const BorderSide(color: LandingTokens.ember, width: 1);
        }
        return const BorderSide(color: LandingTokens.hairlineStrong, width: 1);
      }),
    );
  }
}
