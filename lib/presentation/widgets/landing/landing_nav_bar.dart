import 'package:flutter/material.dart';

import '../../theme/landing_tokens.dart';
import 'landing_button.dart';

enum _NavDestination { features, learning, howItWorks, signIn }

/// A pinned, responsive marketing navigation. Desktop keeps all links visible;
/// compact widths move them into an accessible menu without dropping any path.
class LandingNavBar extends StatelessWidget {
  final VoidCallback onFeaturesTap;
  final VoidCallback onLearningTap;
  final VoidCallback onHowItWorksTap;
  final VoidCallback onSignIn;
  final VoidCallback onPlayNow;

  const LandingNavBar({
    super.key,
    required this.onFeaturesTap,
    required this.onLearningTap,
    required this.onHowItWorksTap,
    required this.onSignIn,
    required this.onPlayNow,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, outerConstraints) {
        // Use the actual layout width instead of MediaQuery so the navigation
        // also behaves correctly in a narrow embedded window or widget test.
        final width = outerConstraints.maxWidth;
        final showLinks = width >= 980;
        final compact = width < LandingTokens.tabletBreakpoint;
        final iconOnlyBrand = width < 520;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: LandingTokens.contentMaxWidth,
            ),
            child: Container(
              margin: LandingTokens.pagePaddingFor(
                width,
              ).copyWith(top: 10, bottom: 0),
              padding: EdgeInsets.symmetric(
                horizontal: compact
                    ? LandingTokens.space12
                    : LandingTokens.space16,
                vertical: LandingTokens.space8,
              ),
              decoration: BoxDecoration(
                color: LandingTokens.surfaceStrong.withValues(alpha: 0.92),
                borderRadius: LandingTokens.pillRadius,
                border: Border.all(color: LandingTokens.outline),
                boxShadow: LandingTokens.cardShadow,
              ),
              child: Row(
                children: [
                  _BrandLockup(iconOnly: iconOnlyBrand),
                  const Spacer(),
                  if (showLinks) ...[
                    _NavLink(label: 'Features', onPressed: onFeaturesTap),
                    _NavLink(label: 'Learning Paths', onPressed: onLearningTap),
                    _NavLink(label: 'How It Works', onPressed: onHowItWorksTap),
                    const SizedBox(width: LandingTokens.space8),
                  ] else ...[
                    _CompactNavigation(
                      onFeaturesTap: onFeaturesTap,
                      onLearningTap: onLearningTap,
                      onHowItWorksTap: onHowItWorksTap,
                      onSignIn: onSignIn,
                    ),
                    const SizedBox(width: LandingTokens.space4),
                  ],
                  if (showLinks) ...[
                    CinematicOutlineButton(
                      label: 'Sign in',
                      compact: true,
                      onPressed: onSignIn,
                    ),
                    const SizedBox(width: LandingTokens.space8),
                  ],
                  GradientButton(
                    label: compact ? 'Play' : 'PLAY NOW',
                    semanticLabel: 'Play NgeCode Juh now',
                    compact: true,
                    onPressed: onPlayNow,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BrandLockup extends StatelessWidget {
  final bool iconOnly;

  const _BrandLockup({this.iconOnly = false});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: 'NgeCode Juh',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              gradient: LandingTokens.primaryActionGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.terminal_rounded,
              color: LandingTokens.ink,
              size: 19,
            ),
          ),
          if (!iconOnly) ...[
            const SizedBox(width: LandingTokens.space8),
            Text(
              'NgeCode Juh!',
              overflow: TextOverflow.ellipsis,
              style: LandingTokens.label(
                fontSize: 15,
              ).copyWith(letterSpacing: -0.1),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _NavLink({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll<Color>(
          LandingTokens.cream,
        ),
        overlayColor: WidgetStatePropertyAll<Color>(
          LandingTokens.cream.withValues(alpha: 0.1),
        ),
        minimumSize: const WidgetStatePropertyAll<Size>(Size(48, 48)),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(horizontal: LandingTokens.space12),
        ),
        shape: const WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: LandingTokens.pillRadius),
        ),
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          return states.contains(WidgetState.focused)
              ? const BorderSide(color: LandingTokens.focusRing, width: 2)
              : BorderSide.none;
        }),
      ),
      child: Text(
        label,
        style: LandingTokens.body(
          fontSize: 14,
          color: LandingTokens.cream,
          fontWeight: FontWeight.w600,
        ).copyWith(height: 1),
      ),
    );
  }
}

class _CompactNavigation extends StatelessWidget {
  final VoidCallback onFeaturesTap;
  final VoidCallback onLearningTap;
  final VoidCallback onHowItWorksTap;
  final VoidCallback onSignIn;

  const _CompactNavigation({
    required this.onFeaturesTap,
    required this.onLearningTap,
    required this.onHowItWorksTap,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open landing page navigation',
      child: PopupMenuButton<_NavDestination>(
        tooltip: 'Open navigation',
        color: LandingTokens.surfaceStrong,
        elevation: 10,
        onSelected: _onSelected,
        itemBuilder: (context) => <PopupMenuEntry<_NavDestination>>[
          _item(
            _NavDestination.features,
            'Features',
            Icons.auto_awesome_outlined,
          ),
          _item(
            _NavDestination.learning,
            'Learning Paths',
            Icons.route_outlined,
          ),
          _item(
            _NavDestination.howItWorks,
            'How It Works',
            Icons.account_tree_outlined,
          ),
          _item(_NavDestination.signIn, 'Sign in', Icons.login_rounded),
        ],
        icon: const Icon(Icons.menu_rounded, color: LandingTokens.cream),
      ),
    );
  }

  PopupMenuItem<_NavDestination> _item(
    _NavDestination destination,
    String label,
    IconData icon,
  ) {
    return PopupMenuItem<_NavDestination>(
      value: destination,
      child: Row(
        children: [
          Icon(icon, color: LandingTokens.gameYellow, size: 18),
          const SizedBox(width: LandingTokens.space12),
          Text(
            label,
            style: LandingTokens.body(color: LandingTokens.cream, fontSize: 15),
          ),
        ],
      ),
    );
  }

  void _onSelected(_NavDestination destination) {
    switch (destination) {
      case _NavDestination.features:
        return onFeaturesTap();
      case _NavDestination.learning:
        return onLearningTap();
      case _NavDestination.howItWorks:
        return onHowItWorksTap();
      case _NavDestination.signIn:
        return onSignIn();
    }
  }
}
