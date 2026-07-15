import 'package:flutter/material.dart';

import '../../theme/landing_tokens.dart';
import 'landing_button.dart';
import 'landing_surface.dart';

class SocialProofStrip extends StatelessWidget {
  const SocialProofStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final verticalPadding = width >= LandingTokens.tabletBreakpoint
        ? LandingTokens.space24
        : LandingTokens.space16;

    return LandingSection(
      padding: LandingTokens.pagePaddingFor(
        width,
      ).copyWith(top: verticalPadding, bottom: verticalPadding),
      child: LandingGlassPanel(
        padding: const EdgeInsets.symmetric(
          horizontal: LandingTokens.space24,
          vertical: LandingTokens.space20,
        ),
        borderRadius: LandingTokens.mediumRadius,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 760;
            final lead = Text(
              'Built for curious beginners and the educators who guide them.',
              textAlign: stacked ? TextAlign.center : TextAlign.left,
              style: LandingTokens.body(
                color: LandingTokens.cream,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            );
            final placeholders = const Wrap(
              alignment: WrapAlignment.center,
              spacing: LandingTokens.space8,
              runSpacing: LandingTokens.space8,
              children: [
                _PlaceholderMark(label: '[INSTITUTION LOGO]'),
                _PlaceholderMark(label: '[PARTNER LOGO]'),
                _PlaceholderMark(label: '[COMMUNITY LOGO]'),
              ],
            );

            return stacked
                ? Column(
                    children: [
                      lead,
                      const SizedBox(height: LandingTokens.space16),
                      placeholders,
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: lead),
                      const SizedBox(width: LandingTokens.space24),
                      Flexible(child: placeholders),
                    ],
                  );
          },
        ),
      ),
    );
  }
}

class _PlaceholderMark extends StatelessWidget {
  final String label;

  const _PlaceholderMark({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LandingTokens.space12,
        vertical: LandingTokens.space8,
      ),
      decoration: BoxDecoration(
        color: LandingTokens.cream.withValues(alpha: 0.05),
        borderRadius: LandingTokens.pillRadius,
        border: Border.all(color: LandingTokens.outline),
      ),
      child: Text(
        label,
        style: LandingTokens.label(
          color: LandingTokens.creamMuted,
          fontSize: 10,
        ),
      ),
    );
  }
}

class LearningModulesSection extends StatelessWidget {
  const LearningModulesSection({super.key});

  static const List<LandingModule> _modules = <LandingModule>[
    LandingModule(
      number: '01',
      title: 'Sequential Logic',
      description:
          'Guide a bot across a grid by turning a plan into precise, ordered steps.',
      icon: Icons.grid_4x4_rounded,
      accent: LandingTokens.gameGreen,
      preview: 'move.right();\nmove.down();',
      outcomes: <String>['Understand sequence', 'Spot logic gaps'],
    ),
    LandingModule(
      number: '02',
      title: 'Intro to SQL',
      description:
          'Use real query thinking to ask a dataset exactly the question you mean.',
      icon: Icons.data_object_rounded,
      accent: LandingTokens.gameYellow,
      preview: 'SELECT name\nFROM users;',
      outcomes: <String>['Think declaratively', 'Query with intent'],
    ),
    LandingModule(
      number: '03',
      title: 'Aerospace Logic',
      description:
          'Prepare and launch a mission by learning why the order of commands matters.',
      icon: Icons.rocket_launch_rounded,
      accent: LandingTokens.gamePink,
      preview: 'sys.preflight();\nengine.start();',
      outcomes: <String>['Model state', 'Debug sequences'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LandingSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'Choose your next mission',
            title: 'Three playful paths.\nOne strong coding foundation.',
            body:
                'Start with the kind of problem that feels exciting, then build transferable thinking through short, focused challenges.',
          ),
          const SizedBox(height: LandingTokens.space40),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = LandingTokens.moduleColumnsFor(
                constraints.maxWidth,
              );
              final gap = LandingTokens.space20;
              final cardWidth =
                  (constraints.maxWidth - (gap * (columns - 1))) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: _modules
                    .map(
                      (module) => SizedBox(
                        width: cardWidth,
                        child: ModuleCard(module: module),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

class LandingModule {
  final String number;
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final String preview;
  final List<String> outcomes;

  const LandingModule({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.preview,
    required this.outcomes,
  });
}

/// Reusable product module card that can later receive a CTA or destination
/// without changing the landing layout.
class ModuleCard extends StatelessWidget {
  final LandingModule module;

  const ModuleCard({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '${module.title} learning module',
      child: LandingGlassPanel(
        padding: const EdgeInsets.all(LandingTokens.space24),
        highEmphasis: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: module.accent.withValues(alpha: 0.18),
                    borderRadius: LandingTokens.smallRadius,
                    border: Border.all(
                      color: module.accent.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Icon(module.icon, color: module.accent, size: 25),
                ),
                const Spacer(),
                Text(
                  module.number,
                  style: LandingTokens.display(
                    fontSize: 28,
                    color: module.accent.withValues(alpha: 0.86),
                  ),
                ),
              ],
            ),
            const SizedBox(height: LandingTokens.space24),
            Text(module.title, style: LandingTokens.sectionTitle(fontSize: 28)),
            const SizedBox(height: LandingTokens.space12),
            Text(module.description, style: LandingTokens.body(fontSize: 16)),
            const SizedBox(height: LandingTokens.space20),
            _CodePreview(code: module.preview, accent: module.accent),
            const SizedBox(height: LandingTokens.space20),
            ...module.outcomes.map(
              (outcome) => Padding(
                padding: const EdgeInsets.only(bottom: LandingTokens.space8),
                child: _OutcomeLine(label: outcome, accent: module.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodePreview extends StatelessWidget {
  final String code;
  final Color accent;

  const _CodePreview({required this.code, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LandingTokens.space16),
      decoration: BoxDecoration(
        color: LandingTokens.ink.withValues(alpha: 0.72),
        borderRadius: LandingTokens.smallRadius,
        border: Border.all(color: LandingTokens.cream.withValues(alpha: 0.1)),
      ),
      child: Text(
        code,
        style: TextStyle(
          color: accent,
          fontFamily: 'monospace',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
      ),
    );
  }
}

class _OutcomeLine extends StatelessWidget {
  final String label;
  final Color accent;

  const _OutcomeLine({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_circle_rounded, color: accent, size: 17),
        const SizedBox(width: LandingTokens.space8),
        Flexible(
          child: Text(
            label,
            style: LandingTokens.body(
              fontSize: 13,
              color: LandingTokens.cream,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  static const List<_LearningStep> _steps = <_LearningStep>[
    _LearningStep(
      number: '01',
      title: 'Pick a mission',
      body:
          'Choose a short coding challenge that matches what you want to practise.',
      icon: Icons.explore_rounded,
      accent: LandingTokens.gameYellow,
    ),
    _LearningStep(
      number: '02',
      title: 'Write and run',
      body:
          'Turn an idea into code, then watch your choices change the mission outcome.',
      icon: Icons.code_rounded,
      accent: LandingTokens.gameBlue,
    ),
    _LearningStep(
      number: '03',
      title: 'Learn from feedback',
      body:
          'When you stall, get a Socratic prompt that helps you discover the next move.',
      icon: Icons.auto_awesome_rounded,
      accent: LandingTokens.gameGreen,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return LandingSection(
      child: Column(
        children: [
          const SectionHeading(
            eyebrow: 'A clear learning loop',
            title: 'Momentum beats memorisation.',
            body:
                'Every mission gives learners one meaningful next action, so practice turns into confidence instead of frustration.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LandingTokens.space40),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked =
                  constraints.maxWidth < LandingTokens.desktopBreakpoint;
              if (stacked) {
                return Column(
                  children: _steps
                      .map(
                        (step) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: LandingTokens.space16,
                          ),
                          child: _StepCard(step: step, horizontal: true),
                        ),
                      )
                      .toList(growable: false),
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < _steps.length; index++) ...[
                    Expanded(child: _StepCard(step: _steps[index])),
                    if (index != _steps.length - 1) const _JourneyConnector(),
                  ],
                ],
              );
            },
          ),
          if (width < LandingTokens.tabletBreakpoint)
            const SizedBox(height: LandingTokens.space8),
        ],
      ),
    );
  }
}

class _LearningStep {
  final String number;
  final String title;
  final String body;
  final IconData icon;
  final Color accent;

  const _LearningStep({
    required this.number,
    required this.title,
    required this.body,
    required this.icon,
    required this.accent,
  });
}

class _StepCard extends StatelessWidget {
  final _LearningStep step;
  final bool horizontal;

  const _StepCard({required this.step, this.horizontal = false});

  @override
  Widget build(BuildContext context) {
    final icon = Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: step.accent.withValues(alpha: 0.17),
        shape: BoxShape.circle,
        border: Border.all(color: step.accent.withValues(alpha: 0.55)),
      ),
      child: Icon(step.icon, color: step.accent, size: 26),
    );
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          step.number,
          style: LandingTokens.label(color: step.accent, fontSize: 11),
        ),
        const SizedBox(height: LandingTokens.space12),
        Text(step.title, style: LandingTokens.sectionTitle(fontSize: 24)),
        const SizedBox(height: LandingTokens.space8),
        Text(step.body, style: LandingTokens.body(fontSize: 16)),
      ],
    );

    return LandingGlassPanel(
      padding: const EdgeInsets.all(LandingTokens.space24),
      borderRadius: LandingTokens.mediumRadius,
      child: horizontal
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon,
                const SizedBox(width: LandingTokens.space20),
                Expanded(child: content),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon,
                const SizedBox(height: LandingTokens.space24),
                content,
              ],
            ),
    );
  }
}

class _JourneyConnector extends StatelessWidget {
  const _JourneyConnector();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: Center(
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: LandingTokens.cream.withValues(alpha: 0.35),
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: LandingTokens.gameYellow,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class AiHintFeatureSection extends StatelessWidget {
  const AiHintFeatureSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LandingSection(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop =
              constraints.maxWidth >= LandingTokens.desktopBreakpoint;
          final copy = Column(
            crossAxisAlignment: isDesktop
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              SectionHeading(
                eyebrow: 'A tutor that respects your thinking',
                title: 'Hints that point forward\nwithout giving it away.',
                body:
                    'NgeCode Juh! reads the idea you are building and responds with one short question or observation—enough to unblock your next attempt.',
                textAlign: isDesktop ? TextAlign.left : TextAlign.center,
              ),
              const SizedBox(height: LandingTokens.space24),
              const _HintPromise(
                icon: Icons.lightbulb_outline_rounded,
                label: 'Guides with questions, not solutions',
              ),
              const SizedBox(height: LandingTokens.space12),
              const _HintPromise(
                icon: Icons.psychology_alt_outlined,
                label: 'Focused on the most useful next step',
              ),
              const SizedBox(height: LandingTokens.space12),
              const _HintPromise(
                icon: Icons.sync_rounded,
                label: 'Falls back gracefully when offline',
              ),
            ],
          );

          return isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 10, child: copy),
                    const SizedBox(width: LandingTokens.space64),
                    const Expanded(flex: 11, child: AiHintPreview()),
                  ],
                )
              : Column(
                  children: [
                    copy,
                    const SizedBox(height: LandingTokens.space40),
                    const AiHintPreview(),
                  ],
                );
        },
      ),
    );
  }
}

class _HintPromise extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HintPromise({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: LandingTokens.gameGreen, size: 20),
        const SizedBox(width: LandingTokens.space12),
        Flexible(
          child: Text(
            label,
            style: LandingTokens.body(
              fontSize: 16,
              color: LandingTokens.cream,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Composable code-and-hint visual. This is deliberately not a real editor;
/// it keeps the landing screen fast and lets a Figma/Canva component replace
/// the visual when approved assets are available.
class AiHintPreview extends StatelessWidget {
  const AiHintPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Sample code editor and AI Socratic hint',
      child: ExcludeSemantics(
        child: LandingGlassPanel(
          padding: const EdgeInsets.all(LandingTokens.space16),
          highEmphasis: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _PreviewToolbar(),
              const SizedBox(height: LandingTokens.space16),
              const _EditorMockup(),
              const SizedBox(height: LandingTokens.space16),
              const _SocraticHintCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewToolbar extends StatelessWidget {
  const _PreviewToolbar();

  @override
  Widget build(BuildContext context) {
    final progress = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: LandingTokens.gameGreen.withValues(alpha: 0.14),
        borderRadius: LandingTokens.pillRadius,
      ),
      child: Text(
        'IN PROGRESS',
        style: LandingTokens.label(color: LandingTokens.gameGreen, fontSize: 9),
      ),
    );

    final title = Row(
      children: [
        const Icon(
          Icons.code_rounded,
          color: LandingTokens.gameYellow,
          size: 20,
        ),
        const SizedBox(width: LandingTokens.space8),
        Expanded(
          child: Text(
            'MISSION 03 · LAUNCH SEQUENCE',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LandingTokens.label(fontSize: 10),
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 340) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: LandingTokens.space8),
              progress,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: title),
            const SizedBox(width: LandingTokens.space8),
            progress,
          ],
        );
      },
    );
  }
}

class _EditorMockup extends StatelessWidget {
  const _EditorMockup();

  @override
  Widget build(BuildContext context) {
    const lines = <_EditorLine>[
      _EditorLine('1', 'engine.start();', LandingTokens.gamePink),
      _EditorLine('2', 'throttle(70);', LandingTokens.gameYellow),
      _EditorLine('3', 'sys.preflight();', LandingTokens.creamMuted),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: LandingTokens.space12),
      decoration: BoxDecoration(
        color: LandingTokens.ink,
        borderRadius: LandingTokens.smallRadius,
        border: Border.all(color: LandingTokens.cream.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: lines
            .map(
              (line) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LandingTokens.space16,
                  vertical: LandingTokens.space4,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        line.number,
                        style: const TextStyle(
                          color: Color(0xFF8D8797),
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        line.code,
                        style: TextStyle(
                          color: line.color,
                          fontFamily: 'monospace',
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _EditorLine {
  final String number;
  final String code;
  final Color color;

  const _EditorLine(this.number, this.code, this.color);
}

class _SocraticHintCard extends StatelessWidget {
  const _SocraticHintCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LandingTokens.space16),
      decoration: BoxDecoration(
        color: LandingTokens.gameGreen.withValues(alpha: 0.12),
        borderRadius: LandingTokens.mediumRadius,
        border: Border.all(
          color: LandingTokens.gameGreen.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: LandingTokens.gameGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: LandingTokens.ink,
              size: 18,
            ),
          ),
          const SizedBox(width: LandingTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A thought to try',
                  style: LandingTokens.label(
                    color: LandingTokens.gameGreen,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: LandingTokens.space4),
                Text(
                  'Which safety step should happen before the engine can start?',
                  style: LandingTokens.body(
                    color: LandingTokens.cream,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OutcomesSection extends StatelessWidget {
  const OutcomesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return LandingSection(
      child: Column(
        children: [
          const SectionHeading(
            eyebrow: 'Designed for real learner voices',
            title: 'Progress you can explain, not just measure.',
            body:
                'Use this area for verified learner outcomes and approved feedback once research or pilot data is available.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LandingTokens.space40),
          LandingGlassPanel(
            padding: EdgeInsets.all(
              width >= LandingTokens.tabletBreakpoint
                  ? LandingTokens.space40
                  : LandingTokens.space24,
            ),
            borderRadius: LandingTokens.largeRadius,
            child: Column(
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  color: LandingTokens.gameYellow,
                  size: 42,
                ),
                const SizedBox(height: LandingTokens.space12),
                Text(
                  '“[Learner testimonial placeholder — replace this with approved, verified student feedback.]”',
                  textAlign: TextAlign.center,
                  style: LandingTokens.display(
                    fontSize: width >= LandingTokens.tabletBreakpoint ? 30 : 25,
                  ),
                ),
                const SizedBox(height: LandingTokens.space20),
                Text(
                  '[Student name] · [Institution / programme]',
                  textAlign: TextAlign.center,
                  style: LandingTokens.body(
                    fontSize: 14,
                    color: LandingTokens.creamMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FinalCallToAction extends StatelessWidget {
  final VoidCallback onStartPlaying;
  final VoidCallback onSignUp;

  const FinalCallToAction({
    super.key,
    required this.onStartPlaying,
    required this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return LandingSection(
      padding: LandingTokens.pagePaddingFor(
        width,
      ).copyWith(top: LandingTokens.space48, bottom: LandingTokens.space48),
      child: Container(
        padding: EdgeInsets.all(
          width >= LandingTokens.tabletBreakpoint
              ? LandingTokens.space64
              : LandingTokens.space32,
        ),
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
          border: Border.all(
            color: LandingTokens.cream.withValues(alpha: 0.32),
          ),
          boxShadow: LandingTokens.heroArtShadow,
        ),
        child: Column(
          children: [
            Text(
              'Your next coding\nmission is waiting.',
              textAlign: TextAlign.center,
              style: LandingTokens.display(
                fontSize: width >= LandingTokens.tabletBreakpoint ? 50 : 38,
              ),
            ),
            const SizedBox(height: LandingTokens.space16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 570),
              child: Text(
                'Start a mission now, or create an account to make your progress yours.',
                textAlign: TextAlign.center,
                style: LandingTokens.body(
                  fontSize: 17,
                  color: LandingTokens.cream,
                ),
              ),
            ),
            const SizedBox(height: LandingTokens.space24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: LandingTokens.space12,
              runSpacing: LandingTokens.space12,
              children: [
                GradientButton(
                  label: 'Start Playing',
                  onPressed: onStartPlaying,
                  icon: Icons.play_arrow_rounded,
                ),
                CinematicOutlineButton(
                  label: 'Create account',
                  onPressed: onSignUp,
                  icon: Icons.person_add_alt_1_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LandingFooter extends StatelessWidget {
  final VoidCallback onFeaturesTap;
  final VoidCallback onLearningTap;
  final VoidCallback onHowItWorksTap;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  const LandingFooter({
    super.key,
    required this.onFeaturesTap,
    required this.onLearningTap,
    required this.onHowItWorksTap,
    required this.onSignIn,
    required this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return LandingSection(
      padding: LandingTokens.pagePaddingFor(
        width,
      ).copyWith(top: LandingTokens.space24, bottom: LandingTokens.space32),
      child: Column(
        children: [
          const Divider(color: LandingTokens.outline, height: 1),
          const SizedBox(height: LandingTokens.space20),
          LayoutBuilder(
            builder: (context, constraints) {
              // Five touch-friendly footer links need more room than their
              // labels alone; stack before the links can ever squeeze the
              // brand line or overflow at tablet widths.
              final stacked = constraints.maxWidth < 980;
              final brand = Text(
                'NgeCode Juh! · Learn by exploring.',
                textAlign: stacked ? TextAlign.center : TextAlign.left,
                style: LandingTokens.body(
                  fontSize: 13,
                  color: LandingTokens.creamMuted,
                  fontWeight: FontWeight.w600,
                ),
              );
              final links = Wrap(
                alignment: WrapAlignment.center,
                spacing: LandingTokens.space4,
                runSpacing: LandingTokens.space4,
                children: [
                  _FooterLink(label: 'Features', onPressed: onFeaturesTap),
                  _FooterLink(
                    label: 'Learning paths',
                    onPressed: onLearningTap,
                  ),
                  _FooterLink(
                    label: 'How it works',
                    onPressed: onHowItWorksTap,
                  ),
                  _FooterLink(label: 'Sign in', onPressed: onSignIn),
                  _FooterLink(label: 'Create account', onPressed: onSignUp),
                ],
              );

              return stacked
                  ? Column(
                      children: [
                        brand,
                        const SizedBox(height: LandingTokens.space12),
                        links,
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: brand),
                        const SizedBox(width: LandingTokens.space24),
                        links,
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _FooterLink({required this.label, required this.onPressed});

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
          color: LandingTokens.cream,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
