import 'package:flutter/material.dart';

import '../../theme/landing_tokens.dart';

/// A high-emphasis CTA that keeps a gradient surface while retaining the
/// focus, keyboard, and semantics behavior of a Material button.
class GradientButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final horizontalPadding = compact ? 18.0 : 24.0;
    final verticalPadding = compact ? 14.0 : 18.0;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel ?? label,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LandingTokens.primaryActionGradient,
          borderRadius: LandingTokens.pillRadius,
          boxShadow: LandingTokens.actionShadow,
        ),
        child: icon == null
            ? FilledButton(
                onPressed: onPressed,
                style: _style(
                  horizontalPadding: horizontalPadding,
                  verticalPadding: verticalPadding,
                ),
                child: _label(),
              )
            : FilledButton.icon(
                onPressed: onPressed,
                style: _style(
                  horizontalPadding: horizontalPadding,
                  verticalPadding: verticalPadding,
                ),
                icon: Icon(icon, size: compact ? 17 : 19),
                label: _label(),
              ),
      ),
    );
  }

  ButtonStyle _style({
    required double horizontalPadding,
    required double verticalPadding,
  }) {
    return ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
      foregroundColor: const WidgetStatePropertyAll<Color>(LandingTokens.ink),
      overlayColor: WidgetStatePropertyAll<Color>(
        LandingTokens.ink.withValues(alpha: 0.12),
      ),
      elevation: const WidgetStatePropertyAll<double>(0),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
      ),
      minimumSize: const WidgetStatePropertyAll<Size>(Size(48, 48)),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: LandingTokens.pillRadius),
      ),
      side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
        if (states.contains(WidgetState.focused)) {
          return const BorderSide(color: LandingTokens.focusRing, width: 3);
        }
        return const BorderSide(color: Colors.transparent, width: 2);
      }),
    );
  }

  Widget _label() {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: LandingTokens.label(
        color: LandingTokens.ink,
        fontSize: compact ? 12 : 14,
      ).copyWith(letterSpacing: 0.2),
    );
  }
}

/// A low-emphasis CTA for secondary paths and navigation. Its focused border
/// is intentionally high-contrast so desktop keyboard users never lose track
/// of their position.
class CinematicOutlineButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final horizontalPadding = compact ? 16.0 : 22.0;
    final verticalPadding = compact ? 12.0 : 17.0;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel ?? label,
      child: icon == null
          ? OutlinedButton(
              onPressed: onPressed,
              style: _style(
                horizontalPadding: horizontalPadding,
                verticalPadding: verticalPadding,
              ),
              child: _label(),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              style: _style(
                horizontalPadding: horizontalPadding,
                verticalPadding: verticalPadding,
              ),
              icon: Icon(icon, size: compact ? 17 : 19),
              label: _label(),
            ),
    );
  }

  ButtonStyle _style({
    required double horizontalPadding,
    required double verticalPadding,
  }) {
    return ButtonStyle(
      foregroundColor: const WidgetStatePropertyAll<Color>(LandingTokens.cream),
      overlayColor: WidgetStatePropertyAll<Color>(
        LandingTokens.cream.withValues(alpha: 0.1),
      ),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
      ),
      minimumSize: const WidgetStatePropertyAll<Size>(Size(48, 48)),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: LandingTokens.pillRadius),
      ),
      side: WidgetStateProperty.resolveWith<BorderSide>((states) {
        if (states.contains(WidgetState.focused)) {
          return const BorderSide(color: LandingTokens.focusRing, width: 3);
        }
        if (states.contains(WidgetState.hovered)) {
          return const BorderSide(color: LandingTokens.cream, width: 1.5);
        }
        return const BorderSide(color: LandingTokens.outline, width: 1);
      }),
    );
  }

  Widget _label() {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: LandingTokens.label(
        fontSize: compact ? 12 : 14,
      ).copyWith(letterSpacing: 0.2),
    );
  }
}
