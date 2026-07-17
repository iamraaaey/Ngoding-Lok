import 'dart:math' as math;

import 'package:flutter/gestures.dart';
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

class _BrandLockup extends StatefulWidget {
  final bool iconOnly;

  const _BrandLockup({this.iconOnly = false});

  @override
  State<_BrandLockup> createState() => _BrandLockupState();
}

class _BrandLockupState extends State<_BrandLockup> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final motion = LandingTokens.motionFor(
      context,
      LandingTokens.motionStandard,
    );
    // Keep the underscore cursor proportional to the wordmark under
    // accessibility text scaling so it stays on the baseline.
    final textScale = MediaQuery.textScalerOf(context).scale(13) / 13;

    return Semantics(
      header: true,
      label: 'Ngoding Lok',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _AnimatedBrandMark(),
            if (!widget.iconOnly) ...[
              const SizedBox(width: LandingTokens.space12),
              // Tracking widens slightly on hover, like a terminal waking up.
              AnimatedDefaultTextStyle(
                duration: motion,
                curve: Curves.easeOutCubic,
                style: LandingTokens.label(
                  fontSize: 13,
                  color: LandingTokens.textPrimary,
                  fontWeight: FontWeight.w700,
                ).copyWith(letterSpacing: _hovered ? 3.1 : 2.2),
                child: const Text(
                  'NGODING LOK',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Blinking prompt underscore, sitting on the wordmark baseline.
              const SizedBox(width: 4),
              Padding(
                padding: EdgeInsets.only(top: 9 * textScale),
                child: BlinkingCursor(
                  width: 7 * textScale,
                  height: 2.5 * textScale,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Gives the terminal mark a "live session" feel: a breathing ember glow,
/// a CRT scan sweep, and a blinking prompt cursor. The mark also watches the
/// mouse anywhere on the page — tilting toward it like an eye, with its
/// prompt cursor drifting the same way — and is magnetically pulled (with a
/// hotter glow) when the cursor comes near. All motion is disabled for
/// reduced-motion users.
class _AnimatedBrandMark extends StatefulWidget {
  const _AnimatedBrandMark();

  @override
  State<_AnimatedBrandMark> createState() => _AnimatedBrandMarkState();
}

class _AnimatedBrandMarkState extends State<_AnimatedBrandMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _motionEnabled = true;

  /// Last known mouse position in global logical coordinates, or null when
  /// the cursor has left the window. The pointer handler only records this;
  /// the geometry and easing work happens once per frame in the builder.
  Offset? _pointerPosition;

  /// Where the mark currently leans (a vector toward the cursor, magnitude
  /// capped at 1) and how strongly the cursor attracts it (0 far → 1 on the
  /// mark). Both ease toward their per-frame targets so the mark follows
  /// with a springy lag.
  Offset _currentLean = Offset.zero;
  double _currentPull = 0;
  Duration? _lastElapsed;

  /// Distance (px) at which the cursor starts to magnetically attract the
  /// mark and heat up its glow.
  static const double _pullRadius = 240;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    // Global route so the mark can watch the mouse across the whole page,
    // not just inside its own 30px bounds.
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handleGlobalPointer);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final motionEnabled = !LandingTokens.reducedMotion(context);
    if (_motionEnabled == motionEnabled && _controller.isAnimating) return;

    _motionEnabled = motionEnabled;
    if (_motionEnabled) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
      _pointerPosition = null;
      _currentLean = Offset.zero;
      _currentPull = 0;
      _lastElapsed = null;
    }
  }

  @override
  void dispose() {
    GestureBinding.instance.pointerRouter.removeGlobalRoute(
      _handleGlobalPointer,
    );
    _controller.dispose();
    super.dispose();
  }

  /// Runs for every mouse event in the window, so it only records the
  /// position; geometry happens once per frame in the builder. No setState:
  /// the repeating ambient animation already repaints the mark every frame.
  void _handleGlobalPointer(PointerEvent event) {
    if (!_motionEnabled || event.kind != PointerDeviceKind.mouse) return;
    if (event is PointerRemovedEvent) {
      _pointerPosition = null;
      return;
    }
    if (event is! PointerHoverEvent && event is! PointerMoveEvent) return;

    // The web engine never sends a remove for a mouse — leaving the window
    // arrives as one final hover at the window edge. Treat edge positions
    // as the cursor having left so the mark relaxes instead of freezing
    // mid-lean. (Desktop embedders do send the remove above.)
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;
    if (view != null) {
      final bounds = view.physicalSize / view.devicePixelRatio;
      if (event.position.dx <= 1.5 ||
          event.position.dy <= 1.5 ||
          event.position.dx >= bounds.width - 1.5 ||
          event.position.dy >= bounds.height - 1.5) {
        _pointerPosition = null;
        return;
      }
    }
    _pointerPosition = event.position;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: const Icon(
        Icons.terminal_rounded,
        color: Color(0xFF0A0500),
        size: 18,
      ),
      builder: (context, child) {
        // Resolve the pointer into lean/pull targets once per frame. The
        // mark is pinned in the nav bar, so its center is stable; last
        // frame's geometry is accurate enough for a 30px ornament.
        var targetLean = Offset.zero;
        var targetPull = 0.0;
        final pointer = _pointerPosition;
        final box = context.findRenderObject() as RenderBox?;
        if (pointer != null &&
            box != null &&
            box.attached &&
            box.hasSize) {
          final center = box.localToGlobal(box.size.center(Offset.zero));
          final delta = pointer - center;
          final distance = delta.distance;
          // Full lean beyond 90px, proportional inside — never overshoots.
          targetLean = distance == 0
              ? Offset.zero
              : delta / math.max(distance, 90);
          targetPull = (1 - distance / _pullRadius).clamp(0.0, 1.0);
        }

        // Ease toward the targets with the step scaled by elapsed frame
        // time, so the springy lag feels the same at 60Hz, 120Hz, or under
        // jank. This builder runs every frame while ambient motion is on,
        // which gives the follow effect its spring without an extra ticker.
        final elapsed = _controller.lastElapsedDuration;
        var frames = 1.0;
        if (elapsed != null && _lastElapsed != null) {
          frames = ((elapsed - _lastElapsed!).inMicroseconds / 16667.0).clamp(
            0.0,
            6.0,
          );
        }
        _lastElapsed = elapsed;
        final ease = 1 - math.pow(0.86, frames).toDouble();
        _currentLean = Offset.lerp(_currentLean, targetLean, ease)!;
        _currentPull += (targetPull - _currentPull) * ease;

        final phase = _motionEnabled ? _controller.value * math.pi * 2 : 0.0;
        final pulse = (math.sin(phase) + 1) / 2;
        final cursorOpacity = _motionEnabled
            ? (math.sin(phase * 1.5) > 0 ? 1.0 : 0.25)
            : 1.0;

        // Perspective tilt toward the cursor, strongest when it is close.
        final tiltStrength = 0.16 + _currentPull * 0.22;
        final tilt = Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateX(-_currentLean.dy * tiltStrength)
          ..rotateY(_currentLean.dx * tiltStrength);

        return Transform.translate(
          // Ambient bob plus the magnetic pull toward a nearby cursor.
          offset:
              Offset(0, -pulse * 1.2) + _currentLean * (_currentPull * 3.5),
          child: Transform.scale(
            scale: 1 + pulse * 0.035 + _currentPull * 0.06,
            child: Transform(
              transform: tilt,
              alignment: Alignment.center,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    LandingTokens.ember,
                    LandingTokens.emberBright,
                    math.max(pulse, _currentPull),
                  ),
                  borderRadius: LandingTokens.smallRadius,
                  boxShadow: [
                    BoxShadow(
                      color: LandingTokens.ember.withValues(
                        alpha: 0.18 + pulse * 0.18 + _currentPull * 0.28,
                      ),
                      blurRadius: 8 + pulse * 8 + _currentPull * 10,
                      spreadRadius: pulse * 0.5 + _currentPull * 1.5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: LandingTokens.smallRadius,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      child!,
                      // CRT scan sweep drifting down the mark.
                      if (_motionEnabled)
                        Positioned(
                          top: _controller.value * 42 - 6,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 6,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: <Color>[
                                  Color(0x00FFFFFF),
                                  Color(0x2EFFFFFF),
                                  Color(0x00FFFFFF),
                                ],
                              ),
                            ),
                          ),
                        ),
                      // The prompt cursor doubles as a pupil, drifting
                      // toward the mouse.
                      Positioned(
                        right: 6 - _currentLean.dx * 2,
                        bottom: 7 - _currentLean.dy * 2,
                        child: Opacity(
                          opacity: cursorOpacity,
                          child: Container(
                            width: 3,
                            height: 1.5,
                            color: const Color(0xFF0A0500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
          child: Text('${_hovered ? '/' : ''}${widget.label.toUpperCase()}'),
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
        icon: const Icon(Icons.menu_rounded, color: LandingTokens.textPrimary),
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
