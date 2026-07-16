import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/landing_tokens.dart';
import 'landing_button.dart';
import 'landing_surface.dart';

/// Full-bleed scrolling ticker between hairlines — the moving strip that
/// replaces the old static social-proof row.
class SocialProofStrip extends StatefulWidget {
  const SocialProofStrip({super.key});

  @override
  State<SocialProofStrip> createState() => _SocialProofStripState();
}

class _SocialProofStripState extends State<SocialProofStrip>
    with SingleTickerProviderStateMixin {
  static const List<String> _items = <String>[
    'SEQUENTIAL LOGIC',
    'INTRO TO SQL',
    'AEROSPACE LOGIC',
    'CYBERSECURITY LAB',
    'CODE GOLF',
    'AI SOCRATIC HINTS',
    'LEADERBOARDS',
  ];

  late final AnimationController _scroll = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 22),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (LandingTokens.reducedMotion(context)) {
      _scroll.stop();
      _scroll.value = 0;
    } else if (!_scroll.isAnimating) {
      _scroll.repeat();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sequence = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _items.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: LandingTokens.space24,
            ),
            child: Text(
              _items[i],
              style: LandingTokens.label(
                fontSize: 11,
                color: i.isEven
                    ? LandingTokens.textMuted
                    : LandingTokens.textFaint,
              ),
            ),
          ),
          Text(
            '//',
            style: LandingTokens.label(
              fontSize: 11,
              color: LandingTokens.ember,
            ),
          ),
        ],
      ],
    );

    return Semantics(
      label: 'Modules: ${_items.join(', ')}',
      child: ExcludeSemantics(
        child: Column(
          children: [
            const HairlineDivider(),
            SizedBox(
              height: 46,
              width: double.infinity,
              child: ClipRect(
                child: OverflowBox(
                  maxWidth: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: AnimatedBuilder(
                    animation: _scroll,
                    builder: (context, child) {
                      return FractionalTranslation(
                        translation: Offset(-_scroll.value * 0.5, 0),
                        child: child,
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [sequence, sequence],
                    ),
                  ),
                ),
              ),
            ),
            const HairlineDivider(),
          ],
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
      accent: LandingTokens.ember,
      preview: 'move.right();\nmove.down();',
      outcomes: <String>['Understand sequence', 'Spot logic gaps'],
    ),
    LandingModule(
      number: '02',
      title: 'Intro to SQL',
      description:
          'Use real query thinking to ask a dataset exactly the question you mean.',
      icon: Icons.data_object_rounded,
      accent: LandingTokens.signal,
      preview: 'SELECT name\nFROM users;',
      outcomes: <String>['Think declaratively', 'Query with intent'],
    ),
    LandingModule(
      number: '03',
      title: 'Aerospace Logic',
      description:
          'Prepare and launch a mission by learning why the order of commands matters.',
      icon: Icons.rocket_launch_rounded,
      accent: LandingTokens.circuit,
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
            eyebrow: 'Learning paths',
            index: '001',
            title: 'Three missions.\nOne coding brain.',
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
                children: [
                  for (var i = 0; i < _modules.length; i++)
                    SizedBox(
                      width: cardWidth,
                      child: ScrollReveal(
                        delay: Duration(milliseconds: 90 * i),
                        child: ModuleCard(module: _modules[i]),
                      ),
                    ),
                ],
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

/// Hairline module card that lifts and warms its border on hover.
class ModuleCard extends StatefulWidget {
  final LandingModule module;

  const ModuleCard({super.key, required this.module});

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final module = widget.module;
    final motion = LandingTokens.motionFor(
      context,
      LandingTokens.motionStandard,
    );

    return Semantics(
      container: true,
      label: '${module.title} learning module',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: motion,
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
          padding: const EdgeInsets.all(LandingTokens.space24),
          decoration: BoxDecoration(
            color: _hovered ? LandingTokens.panel : LandingTokens.carbon,
            borderRadius: LandingTokens.mediumRadius,
            border: Border.all(
              color: _hovered
                  ? module.accent.withValues(alpha: 0.65)
                  : LandingTokens.hairline,
            ),
            boxShadow: LandingTokens.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '/${module.number}',
                    style: LandingTokens.mono(
                      fontSize: 26,
                      color: _hovered
                          ? module.accent
                          : LandingTokens.textFaint,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    module.icon,
                    color: module.accent.withValues(alpha: 0.9),
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: LandingTokens.space20),
              Text(
                module.title.toUpperCase(),
                style: LandingTokens.sectionTitle(fontSize: 22),
              ),
              const SizedBox(height: LandingTokens.space12),
              Text(module.description, style: LandingTokens.body(fontSize: 14)),
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
        color: LandingTokens.voidBlack,
        borderRadius: LandingTokens.smallRadius,
        border: Border.all(color: LandingTokens.hairline),
      ),
      child: Text(code, style: LandingTokens.mono(fontSize: 12, color: accent)),
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
        Text('+', style: LandingTokens.mono(fontSize: 13, color: accent)),
        const SizedBox(width: LandingTokens.space8),
        Flexible(
          child: Text(
            label.toUpperCase(),
            style: LandingTokens.label(
              fontSize: 10,
              color: LandingTokens.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

/// The learning loop as an indexed ledger: hairline rows that highlight on
/// hover, replacing the old card triptych.
class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  static const List<_LearningStep> _steps = <_LearningStep>[
    _LearningStep(
      number: '01',
      title: 'Pick a mission',
      body:
          'Choose a short coding challenge that matches what you want to practise.',
    ),
    _LearningStep(
      number: '02',
      title: 'Write and run',
      body:
          'Turn an idea into code, then watch your choices change the mission outcome.',
    ),
    _LearningStep(
      number: '03',
      title: 'Learn from feedback',
      body:
          'When you stall, get a Socratic prompt that helps you discover the next move.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LandingSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'How it works',
            index: '002',
            title: 'Momentum beats\nmemorisation.',
            body:
                'Every mission gives learners one meaningful next action, so practice turns into confidence instead of frustration.',
          ),
          const SizedBox(height: LandingTokens.space40),
          for (var i = 0; i < _steps.length; i++)
            ScrollReveal(
              delay: Duration(milliseconds: 90 * i),
              child: _StepRow(step: _steps[i], isLast: i == _steps.length - 1),
            ),
        ],
      ),
    );
  }
}

class _LearningStep {
  final String number;
  final String title;
  final String body;

  const _LearningStep({
    required this.number,
    required this.title,
    required this.body,
  });
}

class _StepRow extends StatefulWidget {
  final _LearningStep step;
  final bool isLast;

  const _StepRow({required this.step, required this.isLast});

  @override
  State<_StepRow> createState() => _StepRowState();
}

class _StepRowState extends State<_StepRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final motion = LandingTokens.motionFor(
      context,
      LandingTokens.motionStandard,
    );
    final step = widget.step;
    final stacked =
        MediaQuery.sizeOf(context).width < LandingTokens.tabletBreakpoint;

    final number = AnimatedDefaultTextStyle(
      duration: motion,
      style: LandingTokens.mono(
        fontSize: stacked ? 22 : 30,
        color: _hovered ? LandingTokens.ember : LandingTokens.textFaint,
        fontWeight: FontWeight.w700,
      ),
      child: Text('/${step.number}'),
    );

    final title = Text(
      step.title.toUpperCase(),
      style: LandingTokens.sectionTitle(fontSize: stacked ? 20 : 26),
    );

    final body = Text(step.body, style: LandingTokens.body(fontSize: 14));

    final arrow = AnimatedSlide(
      duration: motion,
      offset: _hovered ? const Offset(0.25, 0) : Offset.zero,
      child: Icon(
        Icons.arrow_forward_rounded,
        size: 18,
        color: _hovered ? LandingTokens.ember : LandingTokens.textFaint,
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: motion,
        color: _hovered ? LandingTokens.carbon : Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HairlineDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: LandingTokens.space24,
                horizontal: LandingTokens.space8,
              ),
              child: stacked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            number,
                            const Spacer(),
                            arrow,
                          ],
                        ),
                        const SizedBox(height: LandingTokens.space12),
                        title,
                        const SizedBox(height: LandingTokens.space8),
                        body,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 90, child: number),
                        Expanded(flex: 5, child: title),
                        const SizedBox(width: LandingTokens.space24),
                        Expanded(flex: 6, child: body),
                        const SizedBox(width: LandingTokens.space24),
                        arrow,
                      ],
                    ),
            ),
            if (widget.isLast) const HairlineDivider(),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeading(
                eyebrow: 'AI tutor',
                index: '003',
                title: 'Hints that point\nforward, not answers.',
                body:
                    'Ngoding Lok reads the idea you are building and responds with one short question or observation — enough to unblock your next attempt.',
              ),
              const SizedBox(height: LandingTokens.space24),
              const _HintPromise(label: 'Guides with questions, not solutions'),
              const SizedBox(height: LandingTokens.space12),
              const _HintPromise(label: 'Focused on the most useful next step'),
              const SizedBox(height: LandingTokens.space12),
              const _HintPromise(label: 'Falls back gracefully when offline'),
            ],
          );

          return isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 10, child: copy),
                    const SizedBox(width: LandingTokens.space64),
                    const Expanded(
                      flex: 11,
                      child: ScrollReveal(child: AiHintPreview()),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    copy,
                    const SizedBox(height: LandingTokens.space40),
                    const ScrollReveal(child: AiHintPreview()),
                  ],
                );
        },
      ),
    );
  }
}

class _HintPromise extends StatelessWidget {
  final String label;

  const _HintPromise({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '>',
          style: LandingTokens.mono(fontSize: 14, color: LandingTokens.signal),
        ),
        const SizedBox(width: LandingTokens.space12),
        Flexible(
          child: Text(
            label.toUpperCase(),
            style: LandingTokens.label(
              fontSize: 11,
              color: LandingTokens.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Fake terminal window: mission code with a live cursor, and the Socratic
/// hint printed below like a system message.
class AiHintPreview extends StatelessWidget {
  const AiHintPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Sample code editor and AI Socratic hint',
      child: ExcludeSemantics(
        child: Container(
          decoration: BoxDecoration(
            color: LandingTokens.carbon,
            borderRadius: LandingTokens.mediumRadius,
            border: Border.all(color: LandingTokens.hairline),
            boxShadow: LandingTokens.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _PreviewToolbar(),
              const HairlineDivider(),
              const Padding(
                padding: EdgeInsets.all(LandingTokens.space16),
                child: _EditorMockup(),
              ),
              const HairlineDivider(),
              Padding(
                padding: const EdgeInsets.all(LandingTokens.space16),
                child: _SocraticHintCard(),
              ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LandingTokens.space16,
        vertical: LandingTokens.space12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'MISSION_03 :: LAUNCH_SEQUENCE.NGE',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LandingTokens.label(
                fontSize: 9.5,
                color: LandingTokens.textMuted,
              ),
            ),
          ),
          const SizedBox(width: LandingTokens.space8),
          const PulsingDot(color: LandingTokens.ember, size: 5),
          const SizedBox(width: 6),
          Text(
            'RUNNING',
            style: LandingTokens.label(fontSize: 9, color: LandingTokens.ember),
          ),
        ],
      ),
    );
  }
}

class _EditorMockup extends StatelessWidget {
  const _EditorMockup();

  @override
  Widget build(BuildContext context) {
    const lines = <(String, String, Color)>[
      ('1', 'engine.start();', LandingTokens.textPrimary),
      ('2', 'throttle(70);', LandingTokens.circuit),
      ('3', 'sys.preflight();  // too late?', LandingTokens.ember),
    ];

    return Column(
      children: [
        for (final (number, code, color) in lines)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: LandingTokens.space4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 26,
                  child: Text(
                    number,
                    style: LandingTokens.mono(
                      fontSize: 12,
                      color: LandingTokens.textFaint,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    code,
                    style: LandingTokens.mono(fontSize: 12, color: color),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: LandingTokens.space4),
          child: Row(
            children: [
              SizedBox(
                width: 26,
                child: Text(
                  '4',
                  style: LandingTokens.mono(
                    fontSize: 12,
                    color: LandingTokens.textFaint,
                  ),
                ),
              ),
              const BlinkingCursor(
                color: LandingTokens.textPrimary,
                width: 7,
                height: 13,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SocraticHintCard extends StatelessWidget {
  const _SocraticHintCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LandingTokens.space16),
      decoration: BoxDecoration(
        color: LandingTokens.signal.withValues(alpha: 0.06),
        borderRadius: LandingTokens.smallRadius,
        border: Border.all(color: LandingTokens.signal.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PulsingDot(size: 5),
              const SizedBox(width: LandingTokens.space8),
              Flexible(
                child: Text(
                  'AI TUTOR — A THOUGHT TO TRY',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LandingTokens.label(
                    fontSize: 9.5,
                    color: LandingTokens.signal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: LandingTokens.space8),
          Text(
            'Which safety step should happen before the engine can start?',
            style: LandingTokens.mono(
              fontSize: 13,
              color: LandingTokens.textPrimary,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'Field reports',
            index: '004',
            title: 'Progress you can explain,\nnot just measure.',
          ),
          const SizedBox(height: LandingTokens.space40),
          ScrollReveal(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(
                width >= LandingTokens.tabletBreakpoint
                    ? LandingTokens.space48
                    : LandingTokens.space24,
              ),
              decoration: BoxDecoration(
                color: LandingTokens.carbon,
                borderRadius: LandingTokens.mediumRadius,
                border: Border.all(color: LandingTokens.hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '/*',
                    style: LandingTokens.mono(
                      fontSize: 22,
                      color: LandingTokens.ember,
                    ),
                  ),
                  const SizedBox(height: LandingTokens.space12),
                  Text(
                    '[Learner testimonial placeholder — replace this with '
                    'approved, verified student feedback.]',
                    style: LandingTokens.display(
                      fontSize: width >= LandingTokens.tabletBreakpoint
                          ? 26
                          : 20,
                      fontWeight: FontWeight.w600,
                    ).copyWith(height: 1.3),
                  ),
                  const SizedBox(height: LandingTokens.space16),
                  Text(
                    '— [STUDENT NAME] · [INSTITUTION / PROGRAMME]',
                    style: LandingTokens.label(
                      fontSize: 10,
                      color: LandingTokens.textFaint,
                    ),
                  ),
                  const SizedBox(height: LandingTokens.space12),
                  Text(
                    '*/',
                    style: LandingTokens.mono(
                      fontSize: 22,
                      color: LandingTokens.ember,
                    ),
                  ),
                ],
              ),
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
    final wordSize = math.min(
      LandingTokens.heroDisplaySizeFor(width),
      width >= LandingTokens.tabletBreakpoint ? 64.0 : 40.0,
    );

    return LandingSection(
      child: ScrollReveal(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: width >= LandingTokens.tabletBreakpoint
                ? LandingTokens.space64
                : LandingTokens.space24,
            vertical: width >= LandingTokens.tabletBreakpoint
                ? LandingTokens.space80
                : LandingTokens.space48,
          ),
          decoration: BoxDecoration(
            color: LandingTokens.carbon,
            borderRadius: LandingTokens.mediumRadius,
            border: Border.all(color: LandingTokens.hairlineStrong),
          ),
          child: Column(
            children: [
              Text(
                '// READY PLAYER ONE?',
                style: LandingTokens.label(color: LandingTokens.textMuted),
              ),
              const SizedBox(height: LandingTokens.space24),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: wordSize * 0.18,
                runSpacing: wordSize * 0.18,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: wordSize * 0.18,
                      vertical: wordSize * 0.1,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: LandingTokens.smallRadius,
                      border: Border.all(
                        color: LandingTokens.textPrimary,
                        width: 1.4,
                      ),
                    ),
                    child: Text(
                      'PRESS',
                      style: LandingTokens.display(fontSize: wordSize),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: wordSize * 0.18,
                      vertical: wordSize * 0.1,
                    ),
                    decoration: const BoxDecoration(
                      color: LandingTokens.ember,
                      borderRadius: LandingTokens.smallRadius,
                    ),
                    child: Text(
                      'START',
                      style: LandingTokens.display(
                        fontSize: wordSize,
                        color: const Color(0xFF0A0500),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: LandingTokens.space24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Text(
                  'Start a mission now, or create an account to make your progress yours.',
                  textAlign: TextAlign.center,
                  style: LandingTokens.body(fontSize: 15),
                ),
              ),
              const SizedBox(height: LandingTokens.space32),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: LandingTokens.space12,
                runSpacing: LandingTokens.space12,
                children: [
                  GradientButton(
                    label: 'Start Playing',
                    onPressed: onStartPlaying,
                  ),
                  CinematicOutlineButton(
                    label: 'Create Account',
                    onPressed: onSignUp,
                  ),
                ],
              ),
            ],
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HairlineDivider(),
        LandingSection(
          padding: LandingTokens.pagePaddingFor(
            width,
          ).copyWith(top: LandingTokens.space40, bottom: LandingTokens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ghost wordmark, the oversized dim brand of the reference
              // footer treatments.
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'NGODING LOK',
                  style: LandingTokens.display(
                    fontSize: 160,
                    color: LandingTokens.textPrimary.withValues(alpha: 0.05),
                  ),
                ),
              ),
              const SizedBox(height: LandingTokens.space24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 980;
                  final brand = Text(
                    'NGODING LOK — LEARN BY EXPLORING.',
                    textAlign: stacked ? TextAlign.center : TextAlign.left,
                    style: LandingTokens.label(
                      fontSize: 10,
                      color: LandingTokens.textFaint,
                    ),
                  );
                  final links = Wrap(
                    alignment: WrapAlignment.center,
                    spacing: LandingTokens.space4,
                    runSpacing: LandingTokens.space4,
                    children: [
                      _FooterLink(label: 'Features', onPressed: onFeaturesTap),
                      _FooterLink(
                        label: 'Learning Paths',
                        onPressed: onLearningTap,
                      ),
                      _FooterLink(
                        label: 'How It Works',
                        onPressed: onHowItWorksTap,
                      ),
                      _FooterLink(label: 'Sign In', onPressed: onSignIn),
                      _FooterLink(label: 'Create Account', onPressed: onSignUp),
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
              const SizedBox(height: LandingTokens.space20),
              const HairlineDivider(),
              const SizedBox(height: LandingTokens.space16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '© 2026 NGODING LOK — BUILT FOR CURIOUS MINDS',
                      style: LandingTokens.label(
                        fontSize: 9,
                        color: LandingTokens.textFaint,
                      ),
                    ),
                  ),
                  Text(
                    'KUCHING // EARTH',
                    style: LandingTokens.label(
                      fontSize: 9,
                      color: LandingTokens.textFaint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _FooterLink({required this.label, required this.onPressed});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
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
            fontSize: 10,
            color: _hovered ? LandingTokens.ember : LandingTokens.textMuted,
          ),
          child: Text(widget.label.toUpperCase()),
        ),
      ),
    );
  }
}
