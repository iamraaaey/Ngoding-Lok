import 'package:flutter/material.dart';

import '../../theme/landing_tokens.dart';
import 'landing_button.dart';
import 'landing_surface.dart';

enum _NavDestination { features, learning, howItWorks, signIn }

/// Pinned full-width header in the reference style: a thin announcement
/// strip, then the main bar — logo, mono uppercase links, and a hot CTA —
/// all separated by hairlines. Compact widths collapse the links into a menu.
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
        final width = outerConstraints.maxWidth;
        final showLinks = width >= 980;
        final compact = width < LandingTokens.tabletBreakpoint;
        final iconOnlyBrand = width < 520;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: LandingTokens.voidBlack.withValues(alpha: 0.97),
            border: const Border(
              bottom: BorderSide(color: LandingTokens.hairline),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AnnouncementStrip(compact: compact),
              const HairlineDivider(),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: LandingTokens.contentMaxWidth,
                  ),
                  child: Padding(
                    padding: LandingTokens.pagePaddingFor(
                      width,
                    ).copyWith(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        _BrandLockup(iconOnly: iconOnlyBrand),
                        const Spacer(),
                        if (showLinks) ...[
                          _NavLink(label: 'Features', onPressed: onFeaturesTap),
                          _NavLink(
                            label: 'Learning Paths',
                            onPressed: onLearningTap,
                          ),
                          _NavLink(
                            label: 'How It Works',
                            onPressed: onHowItWorksTap,
                          ),
                          const SizedBox(width: LandingTokens.space16),
                          _NavLink(label: 'Sign In', onPressed: onSignIn),
                          const SizedBox(width: LandingTokens.space12),
                        ] else ...[
                          _CompactNavigation(
                            onFeaturesTap: onFeaturesTap,
                            onLearningTap: onLearningTap,
                            onHowItWorksTap: onHowItWorksTap,
                            onSignIn: onSignIn,
                          ),
                          const SizedBox(width: LandingTokens.space4),
                        ],
                        GradientButton(
                          label: compact ? 'Play' : 'Play Now',
                          semanticLabel: 'Play Ngoding Lok now',
                          compact: true,
                          onPressed: onPlayNow,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnnouncementStrip extends StatelessWidget {
  final bool compact;

  const _AnnouncementStrip({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: LandingTokens.space16,
        vertical: 7,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const PulsingDot(size: 5),
          const SizedBox(width: LandingTokens.space8),
          Flexible(
            child: Text(
              compact
                  ? 'NEW — CYBERSECURITY ROOM IS LIVE'
                  : 'NEW — THE CYBERSECURITY ROOM IS LIVE. BREACH YOUR FIRST FIREWALL TODAY',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LandingTokens.label(
                fontSize: 9.5,
                color: LandingTokens.textMuted,
              ),
            ),
          ),
        ],
      ),
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
      label: 'Ngoding Lok',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: LandingTokens.ember,
              borderRadius: LandingTokens.smallRadius,
            ),
            child: const Icon(
              Icons.terminal_rounded,
              color: Color(0xFF0A0500),
              size: 18,
            ),
          ),
          if (!iconOnly) ...[
            const SizedBox(width: LandingTokens.space12),
            Text(
              'NGODING LOK',
              overflow: TextOverflow.ellipsis,
              style: LandingTokens.label(
                fontSize: 13,
                color: LandingTokens.textPrimary,
                fontWeight: FontWeight.w700,
              ).copyWith(letterSpacing: 2.2),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _NavLink({required this.label, required this.onPressed});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final motion = LandingTokens.motionFor(context, LandingTokens.motionFast);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: TextButton(
        onPressed: widget.onPressed,
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll<Color>(
            LandingTokens.textPrimary,
          ),
          overlayColor: WidgetStatePropertyAll<Color>(
            LandingTokens.textPrimary.withValues(alpha: 0.06),
          ),
          minimumSize: const WidgetStatePropertyAll<Size>(Size(48, 48)),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: LandingTokens.space12),
          ),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: LandingTokens.smallRadius),
          ),
          side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
            return states.contains(WidgetState.focused)
                ? const BorderSide(color: LandingTokens.focusRing, width: 2)
                : BorderSide.none;
          }),
        ),
        child: AnimatedDefaultTextStyle(
          duration: motion,
          style: LandingTokens.label(
            fontSize: 11,
            color: _hovered ? LandingTokens.ember : LandingTokens.textMuted,
          ),
          child: Text(
            '${_hovered ? '/' : ''}${widget.label.toUpperCase()}',
          ),
        ),
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
        color: LandingTokens.panel,
        elevation: 10,
        shape: const RoundedRectangleBorder(
          borderRadius: LandingTokens.mediumRadius,
          side: BorderSide(color: LandingTokens.hairlineStrong),
        ),
        onSelected: _onSelected,
        itemBuilder: (context) => <PopupMenuEntry<_NavDestination>>[
          _item(_NavDestination.features, 'FEATURES'),
          _item(_NavDestination.learning, 'LEARNING PATHS'),
          _item(_NavDestination.howItWorks, 'HOW IT WORKS'),
          _item(_NavDestination.signIn, 'SIGN IN'),
        ],
        icon: const Icon(
          Icons.menu_rounded,
          color: LandingTokens.textPrimary,
        ),
      ),
    );
  }

  PopupMenuItem<_NavDestination> _item(
    _NavDestination destination,
    String label,
  ) {
    return PopupMenuItem<_NavDestination>(
      value: destination,
      child: Row(
        children: [
          Text('/', style: LandingTokens.label(color: LandingTokens.ember)),
          const SizedBox(width: LandingTokens.space12),
          Text(
            label,
            style: LandingTokens.label(
              color: LandingTokens.textPrimary,
              fontSize: 12,
            ),
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
