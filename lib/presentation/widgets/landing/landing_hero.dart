import 'package:flutter/material.dart';

import '../../theme/landing_tokens.dart';
import 'landing_button.dart';
import 'landing_surface.dart';

/// The conversion-focused first section. The illustration is intentionally
/// composed in Flutter so a final Figma/Canva export can replace it later
/// without any copied reference artwork.
class HeroSection extends StatelessWidget {
  final VoidCallback onStartPlaying;
  final VoidCallback onExploreModules;

  const HeroSection({
    super.key,
    required this.onStartPlaying,
    required this.onExploreModules,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = LandingTokens.isDesktop(width);
    final textAlign = isDesktop ? TextAlign.left : TextAlign.center;
    final crossAxisAlignment = isDesktop
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;

    final copy = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        const _HeroEyebrow(),
        const SizedBox(height: LandingTokens.space20),
        Semantics(
          header: true,
          child: Text(
            'Explore. Debug.\nMaster the Code.',
            textAlign: textAlign,
            style: LandingTokens.display(
              fontSize: LandingTokens.heroDisplaySizeFor(width),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: LandingTokens.space24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 570),
          child: Text(
            'Build real programming intuition through interactive missions, then get a '
            'helpful nudge from an AI tutor when you need it—not the answer.',
            textAlign: textAlign,
            style: LandingTokens.body(fontSize: 18, color: LandingTokens.cream),
          ),
        ),
        const SizedBox(height: LandingTokens.space32),
        Wrap(
          alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
          spacing: LandingTokens.space12,
          runSpacing: LandingTokens.space12,
          children: [
            GradientButton(
              label: 'Start Playing',
              semanticLabel: 'Start playing NgeCode Juh',
              onPressed: onStartPlaying,
              icon: Icons.play_arrow_rounded,
            ),
            CinematicOutlineButton(
              label: 'Explore Modules',
              onPressed: onExploreModules,
              icon: Icons.arrow_downward_rounded,
            ),
          ],
        ),
        const SizedBox(height: LandingTokens.space24),
        const _TrustLine(),
      ],
    );

    final illustration = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: LandingTokens.heroArtMaxWidth),
      child: CodingAdventureIllustration(),
    );

    return LandingSection(
      padding: LandingTokens.pagePaddingFor(width).copyWith(
        top: width >= LandingTokens.tabletBreakpoint ? 156 : 126,
        bottom: width >= LandingTokens.tabletBreakpoint
            ? LandingTokens.space80
            : LandingTokens.space64,
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 11, child: copy),
                const SizedBox(width: LandingTokens.space64),
                Expanded(flex: 10, child: illustration),
              ],
            )
          : Column(
              children: [
                copy,
                const SizedBox(height: LandingTokens.space48),
                illustration,
              ],
            ),
    );
  }
}

class _HeroEyebrow extends StatelessWidget {
  const _HeroEyebrow();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 290),
      padding: const EdgeInsets.symmetric(
        horizontal: LandingTokens.space12,
        vertical: LandingTokens.space8,
      ),
      decoration: BoxDecoration(
        color: LandingTokens.gameGreen.withValues(alpha: 0.12),
        borderRadius: LandingTokens.pillRadius,
        border: Border.all(
          color: LandingTokens.gameGreen.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: LandingTokens.gameGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: LandingTokens.space8),
          Expanded(
            child: Text(
              'AI-Driven Socratic Feedback',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: LandingTokens.label(
                color: LandingTokens.cream,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustLine extends StatelessWidget {
  const _TrustLine();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Placeholder for verified learner count and institution support',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_outlined,
            color: LandingTokens.gameYellow,
            size: 18,
          ),
          const SizedBox(width: LandingTokens.space8),
          Flexible(
            child: Text(
              '[Learner count] learners exploring coding with [institution partners]',
              style: LandingTokens.body(
                fontSize: 13,
                color: LandingTokens.creamMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Original visual composition for the hero. Replace this widget with a final
/// `Image.asset(LandingAssets.heroCodingAdventure)` only after the approved
/// Figma/Canva export has been supplied and declared in pubspec.yaml.
class CodingAdventureIllustration extends StatelessWidget {
  const CodingAdventureIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label:
          'Illustration of a code mission with a puzzle grid, code snippets, a rocket, and an AI hint',
      child: ExcludeSemantics(
        child: AspectRatio(
          aspectRatio: 1.04,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  LandingTokens.indigo,
                  LandingTokens.violet,
                  LandingTokens.sunrise,
                ],
              ),
              borderRadius: LandingTokens.largeRadius,
              border: Border.all(color: LandingTokens.outline),
              boxShadow: LandingTokens.heroArtShadow,
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -78,
                  right: -56,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: LandingTokens.sunlight.withValues(alpha: 0.84),
                      boxShadow: [
                        BoxShadow(
                          color: LandingTokens.sunlight.withValues(alpha: 0.5),
                          blurRadius: 60,
                          spreadRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ),
                const Positioned.fill(child: _AdventureLandscape()),
                const Positioned(top: 36, left: 28, child: _FloatingCodeCard()),
                const Positioned(
                  left: 30,
                  bottom: 38,
                  child: _MissionGridCard(),
                ),
                const Positioned(
                  right: 28,
                  bottom: 40,
                  child: _RocketMission(),
                ),
                const Positioned(right: 24, top: 140, child: _AiHintBubble()),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          LandingTokens.midnight.withValues(alpha: 0),
                          LandingTokens.midnight.withValues(alpha: 0.45),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdventureLandscape extends StatelessWidget {
  const _AdventureLandscape();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 164,
          left: -32,
          right: -32,
          child: Transform.rotate(
            angle: -0.08,
            child: Container(
              height: 146,
              decoration: BoxDecoration(
                color: LandingTokens.cream.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.all(
                  Radius.elliptical(230, 80),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: -70,
          right: -70,
          bottom: -98,
          child: Container(
            height: 270,
            decoration: const BoxDecoration(
              color: LandingTokens.midnight,
              borderRadius: BorderRadius.all(Radius.elliptical(340, 150)),
            ),
          ),
        ),
        Positioned(
          left: -60,
          right: 92,
          bottom: -110,
          child: Container(
            height: 240,
            decoration: BoxDecoration(
              color: LandingTokens.gameBlue.withValues(alpha: 0.62),
              borderRadius: const BorderRadius.all(Radius.elliptical(300, 145)),
            ),
          ),
        ),
      ],
    );
  }
}

class _FloatingCodeCard extends StatelessWidget {
  const _FloatingCodeCard();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.045,
      child: Container(
        width: 196,
        padding: const EdgeInsets.all(LandingTokens.space16),
        decoration: BoxDecoration(
          color: LandingTokens.ink.withValues(alpha: 0.8),
          borderRadius: LandingTokens.mediumRadius,
          border: Border.all(
            color: LandingTokens.cream.withValues(alpha: 0.26),
          ),
          boxShadow: LandingTokens.cardShadow,
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WindowDots(),
            SizedBox(height: LandingTokens.space12),
            _CodeLine(width: 86, color: LandingTokens.gamePink),
            SizedBox(height: LandingTokens.space8),
            _CodeLine(width: 132, color: LandingTokens.gameYellow),
            SizedBox(height: LandingTokens.space8),
            _CodeLine(width: 102, color: LandingTokens.gameGreen),
          ],
        ),
      ),
    );
  }
}

class _WindowDots extends StatelessWidget {
  const _WindowDots();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dot(color: LandingTokens.gamePink),
        SizedBox(width: 5),
        _Dot(color: LandingTokens.gameYellow),
        SizedBox(width: 5),
        _Dot(color: LandingTokens.gameGreen),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _CodeLine extends StatelessWidget {
  final double width;
  final Color color;

  const _CodeLine({required this.width, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 7,
      decoration: BoxDecoration(
        color: color,
        borderRadius: LandingTokens.pillRadius,
      ),
    );
  }
}

class _MissionGridCard extends StatelessWidget {
  const _MissionGridCard();

  @override
  Widget build(BuildContext context) {
    return LandingGlassPanel(
      padding: const EdgeInsets.all(LandingTokens.space12),
      borderRadius: LandingTokens.mediumRadius,
      color: LandingTokens.cream.withValues(alpha: 0.94),
      child: SizedBox(
        width: 166,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MISSION 01',
              style: LandingTokens.label(
                color: LandingTokens.ink,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: LandingTokens.space8),
            Row(
              children: List<Widget>.generate(4, (index) {
                return Padding(
                  padding: EdgeInsets.only(right: index == 3 ? 0 : 5),
                  child: _GridSquare(
                    color: index == 2
                        ? LandingTokens.gameGreen
                        : LandingTokens.ink.withValues(alpha: 0.12),
                    icon: index == 0 ? Icons.smart_toy_outlined : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 5),
            Row(
              children: List<Widget>.generate(4, (index) {
                return Padding(
                  padding: EdgeInsets.only(right: index == 3 ? 0 : 5),
                  child: _GridSquare(
                    color: index == 3
                        ? LandingTokens.gameYellow
                        : LandingTokens.ink.withValues(alpha: 0.12),
                    icon: index == 3 ? Icons.flag_outlined : null,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridSquare extends StatelessWidget {
  final Color color;
  final IconData? icon;

  const _GridSquare({required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
      ),
      child: icon == null
          ? null
          : Icon(icon, size: 14, color: LandingTokens.ink),
    );
  }
}

class _RocketMission extends StatelessWidget {
  const _RocketMission();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: LandingTokens.gamePink,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: LandingTokens.gamePink.withValues(alpha: 0.5),
                  blurRadius: 28,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              color: LandingTokens.cream,
              size: 32,
            ),
          ),
          const SizedBox(height: LandingTokens.space8),
          Text('MISSION 03', style: LandingTokens.label(fontSize: 10)),
        ],
      ),
    );
  }
}

class _AiHintBubble extends StatelessWidget {
  const _AiHintBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 154,
      padding: const EdgeInsets.all(LandingTokens.space12),
      decoration: BoxDecoration(
        color: LandingTokens.gameGreen.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(LandingTokens.radiusMedium),
          topRight: Radius.circular(LandingTokens.radiusMedium),
          bottomLeft: Radius.circular(LandingTokens.radiusMedium),
          bottomRight: Radius.circular(5),
        ),
        boxShadow: LandingTokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: LandingTokens.ink,
            size: 18,
          ),
          const SizedBox(height: LandingTokens.space8),
          Text(
            'What needs to happen before launch?',
            style: LandingTokens.body(
              color: LandingTokens.ink,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ).copyWith(height: 1.25),
          ),
        ],
      ),
    );
  }
}
