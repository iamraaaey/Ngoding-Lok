import 'package:flutter/material.dart';

import '../theme/landing_tokens.dart';
import '../widgets/landing/landing_hero.dart';
import '../widgets/landing/landing_nav_bar.dart';
import '../widgets/landing/landing_sections.dart';
import '../widgets/landing/landing_surface.dart';

/// Conversion-focused marketing home for NgeCode Juh!.
///
/// This screen deliberately owns no direct routing: [RootOrchestrator] injects
/// the existing auth and sign-up callbacks so the landing page remains a
/// presentation layer rather than a second navigation system.
class LandingScreen extends StatefulWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onSignUp;

  const LandingScreen({
    super.key,
    required this.onGetStarted,
    required this.onSignUp,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _featuresKey = GlobalKey();
  final _learningPathsKey = GlobalKey();
  final _howItWorksKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final targetContext = key.currentContext;
    if (targetContext == null) return;

    Scrollable.ensureVisible(
      targetContext,
      alignment: 0.08,
      duration: LandingTokens.motionFor(
        context,
        const Duration(milliseconds: 520),
      ),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LandingTokens.midnight,
      body: Stack(
        children: [
          const Positioned.fill(child: CinematicBackdrop()),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LandingReveal(
                  child: HeroSection(
                    onStartPlaying: widget.onGetStarted,
                    onExploreModules: () => _scrollTo(_learningPathsKey),
                  ),
                ),
                const SocialProofStrip(),
                KeyedSubtree(
                  key: _learningPathsKey,
                  child: const _LandingReveal(
                    duration: Duration(milliseconds: 560),
                    child: LearningModulesSection(),
                  ),
                ),
                KeyedSubtree(
                  key: _howItWorksKey,
                  child: const HowItWorksSection(),
                ),
                KeyedSubtree(
                  key: _featuresKey,
                  child: const AiHintFeatureSection(),
                ),
                const OutcomesSection(),
                FinalCallToAction(
                  onStartPlaying: widget.onGetStarted,
                  onSignUp: widget.onSignUp,
                ),
                LandingFooter(
                  onFeaturesTap: () => _scrollTo(_featuresKey),
                  onLearningTap: () => _scrollTo(_learningPathsKey),
                  onHowItWorksTap: () => _scrollTo(_howItWorksKey),
                  onSignIn: widget.onGetStarted,
                  onSignUp: widget.onSignUp,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: LandingNavBar(
                onFeaturesTap: () => _scrollTo(_featuresKey),
                onLearningTap: () => _scrollTo(_learningPathsKey),
                onHowItWorksTap: () => _scrollTo(_howItWorksKey),
                onSignIn: widget.onGetStarted,
                onPlayNow: widget.onGetStarted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single calm entrance transition. The system's reduced-motion preference
/// resolves it to zero duration, while all page interactions remain usable
/// before, during, and after the visual transition.
class _LandingReveal extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const _LandingReveal({
    required this.child,
    this.duration = const Duration(milliseconds: 640),
  });

  @override
  Widget build(BuildContext context) {
    final resolvedDuration = LandingTokens.motionFor(context, duration);
    final initialValue = resolvedDuration == Duration.zero ? 1.0 : 0.0;

    return TweenAnimationBuilder<double>(
      duration: resolvedDuration,
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: initialValue, end: 1),
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 18),
            child: child,
          ),
        );
      },
    );
  }
}
