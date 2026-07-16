import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/landing_tokens.dart';
import 'landing_button.dart';
import 'landing_surface.dart';

/// The reference-style hero: a typing terminal prompt, two big boxed
/// headline words (white + ember), a floating bot with an iridescent screen,
/// and monospace metadata scattered along the grid.
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
    final crossAxisAlignment = isDesktop
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;

    final copy = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        const TerminalPromptCard(),
        const SizedBox(height: LandingTokens.space32),
        Text(
          '// UNLEASH THE POWER OF PLAY',
          style: LandingTokens.label(color: LandingTokens.textMuted),
        ),
        const SizedBox(height: LandingTokens.space16),
        Semantics(
          header: true,
          label: 'Ngoding Lok. Learn to code by playing.',
          child: ExcludeSemantics(
            child: BoxedHeadline(
              size: LandingTokens.heroDisplaySizeFor(width),
              center: !isDesktop,
            ),
          ),
        ),
        const SizedBox(height: LandingTokens.space24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'Your personal coding arcade — master real programming logic '
            'through missions, with an AI tutor that asks the right '
            'question instead of giving the answer.',
            textAlign: isDesktop ? TextAlign.left : TextAlign.center,
            style: LandingTokens.body(fontSize: 16),
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
              semanticLabel: 'Start playing Ngoding Lok',
              onPressed: onStartPlaying,
            ),
            CinematicOutlineButton(
              label: 'Explore Modules',
              onPressed: onExploreModules,
            ),
          ],
        ),
        const SizedBox(height: LandingTokens.space24),
        const _TrustLine(),
      ],
    );

    final visual = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: LandingTokens.heroArtMaxWidth),
      child: const BotVisual(),
    );

    return LandingSection(
      padding: LandingTokens.pagePaddingFor(width).copyWith(
        top: width >= LandingTokens.tabletBreakpoint ? 168 : 138,
        bottom: 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 11, child: copy),
                    const SizedBox(width: LandingTokens.space48),
                    Expanded(flex: 9, child: visual),
                    if (LandingTokens.isWide(width)) ...[
                      const SizedBox(width: LandingTokens.space40),
                      const MetaRail(),
                    ],
                  ],
                )
              : Column(
                  children: [
                    copy,
                    const SizedBox(height: LandingTokens.space48),
                    visual,
                  ],
                ),
          SizedBox(
            height: width >= LandingTokens.tabletBreakpoint
                ? LandingTokens.space80
                : LandingTokens.space48,
          ),
          const _HeroBaseline(),
        ],
      ),
    );
  }
}

/// "NGODING" in a white hairline box and "LOK" in an ember box, with a
/// blinking block cursor — the boxed-word treatment of the reference.
class BoxedHeadline extends StatelessWidget {
  final double size;
  final bool center;

  const BoxedHeadline({super.key, required this.size, this.center = false});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: center ? WrapAlignment.center : WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: size * 0.16,
      runSpacing: size * 0.18,
      children: [
        _BoxedWord(
          text: 'NGODING',
          size: size,
          color: LandingTokens.textPrimary,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BoxedWord(text: 'LOK', size: size, color: LandingTokens.ember),
            SizedBox(width: size * 0.18),
            BlinkingCursor(
              color: LandingTokens.ember,
              width: size * 0.14,
              height: size * 0.62,
            ),
          ],
        ),
      ],
    );
  }
}

class _BoxedWord extends StatelessWidget {
  final String text;
  final double size;
  final Color color;

  const _BoxedWord({
    required this.text,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.18,
        vertical: size * 0.1,
      ),
      decoration: BoxDecoration(
        color: LandingTokens.voidBlack.withValues(alpha: 0.6),
        borderRadius: LandingTokens.smallRadius,
        border: Border.all(color: color.withValues(alpha: 0.9), width: 1.4),
      ),
      child: Text(
        text,
        style: LandingTokens.display(fontSize: size, color: color),
      ),
    );
  }
}

/// Terminal card that keeps re-typing mission prompts, like the smart
/// contract prompt card in the reference.
class TerminalPromptCard extends StatefulWidget {
  const TerminalPromptCard({super.key});

  @override
  State<TerminalPromptCard> createState() => _TerminalPromptCardState();
}

class _TerminalPromptCardState extends State<TerminalPromptCard> {
  static const List<String> _prompts = <String>[
    'guide the bot across the grid using loops',
    'query the crew roster with pure SQL',
    'run the launch sequence in the right order',
    'breach the training firewall, legally',
  ];

  Timer? _timer;
  int _promptIndex = 0;
  int _charCount = 0;
  bool _deleting = false;
  int _holdTicks = 0;
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = LandingTokens.reducedMotion(context);
    if (reduced != _reduced || _timer == null) {
      _reduced = reduced;
      _timer?.cancel();
      if (reduced) {
        setState(() => _charCount = _prompts[_promptIndex].length);
      } else {
        _timer = Timer.periodic(const Duration(milliseconds: 55), _tick);
      }
    }
  }

  void _tick(Timer timer) {
    final prompt = _prompts[_promptIndex];
    setState(() {
      if (_holdTicks > 0) {
        _holdTicks--;
        return;
      }
      if (_deleting) {
        if (_charCount > 0) {
          _charCount--;
        } else {
          _deleting = false;
          _promptIndex = (_promptIndex + 1) % _prompts.length;
        }
      } else {
        if (_charCount < prompt.length) {
          _charCount++;
        } else {
          _holdTicks = 34;
          _deleting = true;
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prompt = _prompts[_promptIndex];
    final visible = prompt.substring(0, _charCount.clamp(0, prompt.length));

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(LandingTokens.space16),
      decoration: BoxDecoration(
        color: LandingTokens.carbon,
        borderRadius: LandingTokens.mediumRadius,
        border: Border.all(color: LandingTokens.hairline),
        boxShadow: LandingTokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                '~/MISSION.LOG',
                style: LandingTokens.label(
                  fontSize: 9,
                  color: LandingTokens.textFaint,
                ),
              ),
              const Spacer(),
              Container(width: 6, height: 6, color: LandingTokens.hairlineStrong),
              const SizedBox(width: 4),
              Container(width: 6, height: 6, color: LandingTokens.hairlineStrong),
              const SizedBox(width: 4),
              Container(width: 6, height: 6, color: LandingTokens.ember),
            ],
          ),
          const SizedBox(height: LandingTokens.space12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '> ',
                style: LandingTokens.mono(color: LandingTokens.signal),
              ),
              Expanded(
                child: Text(
                  visible,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: LandingTokens.mono(color: LandingTokens.textPrimary),
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(top: 3),
                child: BlinkingCursor(
                  color: LandingTokens.signal,
                  width: 7,
                  height: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The stand-in for the reference's 3D robot: a floating console bot whose
/// face is the page's single iridescent, slowly-sweeping rainbow surface.
class BotVisual extends StatefulWidget {
  const BotVisual({super.key});

  @override
  State<BotVisual> createState() => _BotVisualState();
}

class _BotVisualState extends State<BotVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (LandingTokens.reducedMotion(context)) {
      _float.stop();
      _float.value = 0.5;
    } else if (!_float.isAnimating) {
      _float.repeat();
    }
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label:
          'Illustration of the Ngoding bot with an iridescent screen, '
          'floating over a technical grid',
      child: ExcludeSemantics(
        child: AspectRatio(
          aspectRatio: 0.96,
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: _BracketFramePainter()),
              ),
              Positioned(
                top: 6,
                left: 14,
                child: Text(
                  'FIG. 01 — LOK-BOT',
                  style: LandingTokens.label(
                    fontSize: 9,
                    color: LandingTokens.textFaint,
                  ),
                ),
              ),
              Positioned(
                bottom: 6,
                right: 14,
                child: Row(
                  children: [
                    const PulsingDot(size: 5),
                    const SizedBox(width: 6),
                    Text(
                      'STATUS: ONLINE',
                      style: LandingTokens.label(
                        fontSize: 9,
                        color: LandingTokens.signal,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _float,
                  builder: (context, child) {
                    final t = math.sin(_float.value * 2 * math.pi);
                    return Transform.translate(
                      offset: Offset(0, t * 9),
                      child: child,
                    );
                  },
                  child: Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.74,
                      child: Transform.rotate(
                        angle: -0.05,
                        child: const _BotBody(),
                      ),
                    ),
                  ),
                ),
              ),
              const Positioned(left: 8, bottom: 34, child: _XpChip()),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotBody extends StatelessWidget {
  const _BotBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Antenna.
        Container(width: 2, height: 22, color: LandingTokens.hairlineStrong),
        const PulsingDot(color: LandingTokens.ember, size: 6),
        const SizedBox(height: 6),
        // Head: dark shell around the iridescent face.
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: LandingTokens.panelRaised,
            borderRadius: LandingTokens.largeRadius,
            border: Border.all(color: LandingTokens.hairlineStrong),
            boxShadow: LandingTokens.cardShadow,
          ),
          child: AspectRatio(
            aspectRatio: 1.35,
            child: ClipRRect(
              borderRadius: LandingTokens.mediumRadius,
              child: AnimatedIridescence(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Scanlines over the rainbow face.
                    const CustomPaint(painter: _ScanlinePainter()),
                    // Two friendly eyes.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _eye(),
                        const SizedBox(width: 26),
                        _eye(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Torso plate with a mono readout.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: LandingTokens.panel,
            borderRadius: LandingTokens.mediumRadius,
            border: Border.all(color: LandingTokens.hairline),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'while(alive)',
                  style: LandingTokens.mono(
                    fontSize: 11,
                    color: LandingTokens.textMuted,
                  ),
                ),
                Text(
                  ' { learn(); }',
                  style: LandingTokens.mono(
                    fontSize: 11,
                    color: LandingTokens.ember,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _eye() {
    return Container(
      width: 16,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xE60A0A0A),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  const _ScanlinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x3D000000)
      ..strokeWidth = 1.4;
    for (double y = 2; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) => false;
}

class _BracketFramePainter extends CustomPainter {
  const _BracketFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = LandingTokens.hairlineStrong
      ..strokeWidth = 1.4;
    const len = 22.0;
    // Four corner brackets, like a camera viewfinder.
    canvas.drawLine(const Offset(0, len), Offset.zero, paint);
    canvas.drawLine(Offset.zero, const Offset(len, 0), paint);
    canvas.drawLine(Offset(size.width - len, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);
    canvas.drawLine(Offset(0, size.height - len), Offset(0, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);
    canvas.drawLine(
      Offset(size.width, size.height - len),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - len, size.height),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BracketFramePainter oldDelegate) => false;
}

class _XpChip extends StatelessWidget {
  const _XpChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: LandingTokens.carbon,
        borderRadius: LandingTokens.smallRadius,
        border: Border.all(color: LandingTokens.hairline),
        boxShadow: LandingTokens.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'XP +120',
            style: LandingTokens.label(
              fontSize: 10,
              color: LandingTokens.signal,
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 12, color: LandingTokens.hairlineStrong),
          const SizedBox(width: 10),
          Text(
            'STREAK 07',
            style: LandingTokens.label(
              fontSize: 10,
              color: LandingTokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Right-edge metadata column; the highlighted entry cycles, echoing the
/// small technical index on the reference's right margin.
class MetaRail extends StatefulWidget {
  const MetaRail({super.key});

  @override
  State<MetaRail> createState() => _MetaRailState();
}

class _MetaRailState extends State<MetaRail> {
  static const List<String> _entries = <String>[
    'SEQUENTIAL LOGIC',
    'SQL QUERIES',
    'ROCKET SCIENCE',
    'CYBERSECURITY',
    'CODE GOLF',
  ];

  Timer? _timer;
  int _active = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer?.cancel();
    if (!LandingTokens.reducedMotion(context)) {
      _timer = Timer.periodic(const Duration(milliseconds: 1700), (_) {
        setState(() => _active = (_active + 1) % _entries.length);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = LandingTokens.motionFor(
      context,
      LandingTokens.motionStandard,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _entries.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: AnimatedDefaultTextStyle(
              duration: motion,
              style: LandingTokens.label(
                fontSize: 10,
                color: i == _active
                    ? LandingTokens.ember
                    : LandingTokens.textFaint,
              ),
              child: Text('${_entries[i]} /'),
            ),
          ),
      ],
    );
  }
}

class _TrustLine extends StatelessWidget {
  const _TrustLine();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const PulsingDot(size: 5),
        const SizedBox(width: LandingTokens.space8),
        Flexible(
          child: Text(
            'FREE TO PLAY — NO INSTALL, RUNS IN YOUR BROWSER',
            style: LandingTokens.label(
              fontSize: 9.5,
              color: LandingTokens.textFaint,
            ),
          ),
        ),
      ],
    );
  }
}

/// The hero's bottom rule: caption, coordinates, and a bobbing scroll cue.
class _HeroBaseline extends StatelessWidget {
  const _HeroBaseline();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HairlineDivider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: LandingTokens.space16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'YOUR PERSONAL CODING ARCADE, IN ALL ITS PIXEL '
                  '& LOGIC-RELATED GLORY.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: LandingTokens.label(
                    fontSize: 9.5,
                    color: LandingTokens.textFaint,
                  ),
                ),
              ),
              const SizedBox(width: LandingTokens.space16),
              Text(
                '01°33\'N 110°21\'E',
                style: LandingTokens.label(
                  fontSize: 9.5,
                  color: LandingTokens.textFaint,
                ),
              ),
              const SizedBox(width: LandingTokens.space16),
              const _ScrollCue(),
            ],
          ),
        ),
        const HairlineDivider(),
      ],
    );
  }
}

class _ScrollCue extends StatefulWidget {
  const _ScrollCue();

  @override
  State<_ScrollCue> createState() => _ScrollCueState();
}

class _ScrollCueState extends State<_ScrollCue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (LandingTokens.reducedMotion(context)) {
      _bob.stop();
      _bob.value = 0;
    } else if (!_bob.isAnimating) {
      _bob.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bob,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, Curves.easeInOut.transform(_bob.value) * 5),
          child: const Icon(
            Icons.arrow_downward_rounded,
            size: 16,
            color: LandingTokens.ember,
          ),
        );
      },
    );
  }
}
