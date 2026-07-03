import 'package:flutter/material.dart';
import '../theme/doodle.dart';

/// Marketing landing page shown before the app's auth/dashboard flow.
/// Every call to action funnels into [onGetStarted], which the orchestrator
/// wires to advance past this screen into the real app.
class LandingScreen extends StatefulWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onSignUp;

  const LandingScreen({super.key, required this.onGetStarted, required this.onSignUp});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  final _featuresKey = GlobalKey();
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Animation<double> _interval(double begin, double end) => CurvedAnimation(
        parent: _entrance,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      );

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoodlePalette.dark,
      body: AnimatedDoodleDotBackground(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 110),
                  DoodleFadeSlide(
                    animation: _interval(0.05, 0.55),
                    yOffset: 32,
                    child: _HeroSection(onStartPlaying: widget.onGetStarted),
                  ),
                  DoodleFadeSlide(
                    animation: _interval(0.25, 0.70),
                    yOffset: 28,
                    child: _FeaturesSection(key: _featuresKey),
                  ),
                  DoodleFadeSlide(
                    animation: _interval(0.40, 0.85),
                    yOffset: 28,
                    child: const _CurriculumSection(),
                  ),
                  _Footer(onPlay: widget.onGetStarted),
                ],
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: DoodleFadeSlide(
                animation: _interval(0.0, 0.35),
                yOffset: -20,
                child: _NavBar(
                  onFeaturesTap: () => _scrollTo(_featuresKey),
                  onLogIn: widget.onGetStarted,
                  onSignUp: widget.onSignUp,
                  onPlayNow: widget.onGetStarted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final VoidCallback onFeaturesTap;
  final VoidCallback onLogIn;
  final VoidCallback onSignUp;
  final VoidCallback onPlayNow;

  const _NavBar({
    required this.onFeaturesTap,
    required this.onLogIn,
    required this.onSignUp,
    required this.onPlayNow,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: DoodleCard(
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // "NgeCode Juh!" is longer than the original "CodeQuest" wordmark,
              // so this needs a wider breakpoint than a typical navbar to avoid
              // overflow once Features/Log In/Sign Up join the row.
              final isWide = constraints.maxWidth > 860;
              final isCompact = constraints.maxWidth < 420;
              return Row(
                children: [
                  // Wrapping the logo group in the sole Expanded (rather than
                  // giving the text its own Flexible alongside a Spacer) means
                  // it claims all leftover width instead of splitting it evenly
                  // with an empty spacer, so the wordmark only truncates when
                  // there's genuinely no room left.
                  Expanded(
                    child: Row(
                      children: [
                        DoodleIconBadge(icon: Icons.terminal, color: DoodlePalette.purple, size: isCompact ? 36 : 44),
                        SizedBox(width: isCompact ? 8 : 12),
                        Flexible(
                          child: Text(
                            'NgeCode Juh!',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(color: Colors.black, fontSize: isCompact ? 16 : 22, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isWide) ...[
                    _NavLink('Features', onFeaturesTap),
                    const SizedBox(width: 24),
                    TextButton(
                      onPressed: onLogIn,
                      child: const Text('Log In', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: onSignUp,
                      child: const Text('Sign Up', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 12),
                  ],
                  DoodleButton(label: 'Play Now', color: DoodlePalette.green, onPressed: onPlayNow, dense: true),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 15)),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final VoidCallback onStartPlaying;

  const _HeroSection({required this.onStartPlaying});

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 60),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;

          final text = Column(
            crossAxisAlignment: isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              const DoodlePill(text: 'AI-Driven Socratic Feedback', rotation: -0.035),
              const SizedBox(height: 28),
              _StrokeHeading(isWide: isWide),
              const SizedBox(height: 24),
              Text(
                "An adaptive, gamified platform for computing education. Ditch the boring "
                "compiler errors—get smart hints from an AI tutor when you're stuck.",
                textAlign: isWide ? TextAlign.left : TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w700, height: 1.4),
              ),
              const SizedBox(height: 36),
              PulsingGlow(
                glowColor: DoodlePalette.orange,
                borderRadius: 16,
                child: DoodleButton(
                  label: 'Start Playing',
                  color: DoodlePalette.orange,
                  onPressed: onStartPlaying,
                  icon: Icons.sports_esports,
                ),
              ),
            ],
          );

          final visual = FloatingWidget(child: const _HeroMockup());

          return Padding(
            padding: const EdgeInsets.only(top: 40),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: text),
                      const SizedBox(width: 60),
                      Expanded(child: visual),
                    ],
                  )
                : Column(children: [text, const SizedBox(height: 48), visual]),
          );
        },
      ),
    );
  }
}

class _StrokeHeading extends StatelessWidget {
  final bool isWide;

  const _StrokeHeading({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final fontSize = isWide ? 64.0 : 42.0;
    final style = TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, height: 1.05, color: Colors.white);

    return Column(
      crossAxisAlignment: isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text('Explore.', style: style),
        Stack(
          children: [
            Text(
              'Debug.',
              style: style.copyWith(foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 6
                ..color = Colors.black),
            ),
            Text('Debug.', style: style.copyWith(color: DoodlePalette.green)),
          ],
        ),
        Text('Master the Code.', style: style),
      ],
    );
  }
}

class _HeroMockup extends StatelessWidget {
  const _HeroMockup();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.02,
      child: DoodleCard(
        padding: EdgeInsets.zero,
        borderRadius: 28,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: DoodlePalette.purple,
                border: Border(bottom: BorderSide(color: Colors.black, width: 3)),
              ),
              child: Row(
                children: [
                  _trafficDot(DoodlePalette.red),
                  const SizedBox(width: 6),
                  _trafficDot(DoodlePalette.yellow),
                  const SizedBox(width: 6),
                  _trafficDot(DoodlePalette.green),
                  const Spacer(),
                  const Text(
                    'LEVEL_1_LOOPS',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.2, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              color: DoodlePalette.cream,
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 420;
                  const code = _CodePanel();
                  const grid = _GridPanel();
                  if (isWide) {
                    return const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Expanded(child: code), SizedBox(width: 16), Expanded(child: grid)],
                    );
                  }
                  return const Column(children: [code, SizedBox(height: 16), grid]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _trafficDot(Color color) => Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2)),
      );
}

class _CodePanel extends StatelessWidget {
  const _CodePanel();

  @override
  Widget build(BuildContext context) {
    const mono = TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.black, width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('/* Navigate the grid */', style: mono.copyWith(color: Colors.grey, fontWeight: FontWeight.normal)),
          const SizedBox(height: 6),
          Text.rich(TextSpan(children: [
            TextSpan(text: 'while ', style: mono.copyWith(color: DoodlePalette.purple)),
            const TextSpan(text: '(!goal) {', style: mono),
          ])),
          Padding(padding: const EdgeInsets.only(left: 16), child: Text('moveForward();', style: mono.copyWith(color: DoodlePalette.blue))),
          Padding(padding: const EdgeInsets.only(left: 16), child: Text('if (wallAhead) {', style: mono.copyWith(color: DoodlePalette.blue))),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              'turnLeft;',
              style: mono.copyWith(color: DoodlePalette.red, decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.wavy),
            ),
          ),
          Padding(padding: const EdgeInsets.only(left: 16), child: Text('}', style: mono)),
          const Text('}', style: mono),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: DoodlePalette.yellow, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black, width: 2)),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.smart_toy, size: 16, color: Colors.black),
                SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black),
                      children: [
                        TextSpan(text: 'Wait! Did you forget parentheses on '),
                        TextSpan(text: 'turnLeft()', style: TextStyle(fontFamily: 'monospace', backgroundColor: Colors.white)),
                        TextSpan(text: '?'),
                      ],
                    ),
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

class _GridPanel extends StatelessWidget {
  const _GridPanel();

  @override
  Widget build(BuildContext context) {
    const walls = {5, 6, 12};
    const trophyIndex = 2;
    const playerIndex = 9;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: DoodlePalette.green, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.black, width: 2)),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 16,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 6, mainAxisSpacing: 6),
          itemBuilder: (context, index) {
            if (walls.contains(index)) {
              return Container(decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)));
            }
            final tile = Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black, width: 2),
              ),
              alignment: Alignment.center,
              child: index == trophyIndex
                  ? const Text('🏆', style: TextStyle(fontSize: 16))
                  : index == playerIndex
                      ? Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(color: DoodlePalette.red, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2)),
                        )
                      : null,
            );
            return tile;
          },
        ),
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DoodlePalette.white,
      child: _SectionContainer(
        child: Column(
          children: [
            const DoodlePill(text: 'Core Mechanics', background: Colors.black, textColor: Colors.white, rotation: 0.035),
            const SizedBox(height: 20),
            const Text('Not your average compiler.',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 40, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            const Text(
              'Built for modern learning with responsive frontends and intelligent serverless backends.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 760;
                final cards = [
                  _FeatureCard(
                    color: DoodlePalette.red,
                    tag: 'Phase 1 & 2',
                    title: 'Lightweight Client Engine',
                    description: 'Responsive 2D visual grid. Instant code parsing & deterministic execution.',
                    icon: Icons.sports_esports,
                    titleColor: Colors.white,
                  ),
                  _FeatureCard(
                    color: DoodlePalette.yellow,
                    tag: 'Phase 4',
                    title: 'AI Socratic Tutors',
                    description: 'No explicit answers. Progressive, indirect guidance via telemetry to resolve structural flaws.',
                    icon: Icons.smart_toy,
                    titleColor: Colors.black,
                  ),
                  _FeatureCard(
                    color: DoodlePalette.green,
                    tag: 'Architecture',
                    title: 'Decoupled Backend',
                    description: 'RESTful API streaming modular course blueprints. Updates without app reinstalls.',
                    icon: Icons.dns,
                    titleColor: Colors.black,
                  ),
                  _FeatureCard(
                    color: DoodlePalette.purple,
                    tag: 'Phase 3',
                    title: 'Competitive Scalability',
                    description: 'Offline-first caching & low-latency database syncing for high-volume leaderboards.',
                    icon: Icons.leaderboard,
                    titleColor: Colors.white,
                  ),
                ];
                if (isWide) {
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 1.7,
                    children: cards,
                  );
                }
                return Column(
                  children: [for (final c in cards) Padding(padding: const EdgeInsets.only(bottom: 24), child: SizedBox(height: 220, child: c))],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final Color color;
  final String tag;
  final String title;
  final String description;
  final IconData icon;
  final Color titleColor;

  const _FeatureCard({
    required this.color,
    required this.tag,
    required this.title,
    required this.description,
    required this.icon,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return DoodleCard(
      color: color,
      borderRadius: 24,
      child: Stack(
        children: [
          Positioned(right: -10, bottom: -10, child: Icon(icon, size: 110, color: Colors.black.withValues(alpha: 0.15))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black, width: 2)),
                    child: Text(tag.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                  const SizedBox(height: 14),
                  Text(title, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: titleColor)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12, right: 40),
                child: Text(description, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: titleColor, height: 1.25)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurriculumSection extends StatelessWidget {
  const _CurriculumSection();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DoodlePalette.blue,
      child: _SectionContainer(
        child: DoodleCard(
          borderRadius: 40,
          padding: const EdgeInsets.all(32),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 760;
              final text = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DoodlePill(text: 'Scope & Audience', background: DoodlePalette.orange, rotation: -0.05),
                  const SizedBox(height: 18),
                  const Text('Targeting the Fundamentals.', style: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  const Text(
                    'Designed for K-12 and early undergrads struggling with structural logic. '
                    'We replace cognitive friction with guided discovery.',
                    style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.w700, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: const [
                      _ChipItem(icon: Icons.low_priority, label: 'Sequential Logic', color: Color(0xFFFFF3CD)),
                      _ChipItem(icon: Icons.loop, label: 'Loops (For/While)', color: Color(0xFFFCDDE4)),
                      _ChipItem(icon: Icons.alt_route, label: 'Conditionals (If/Else)', color: Color(0xFFD8F5E9)),
                      _ChipItem(icon: Icons.bug_report, label: 'Syntax Debugging', color: Color(0xFFEBDCF9)),
                    ],
                  ),
                ],
              );

              const visual = _CurriculumVisual();

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 6, child: text),
                    const SizedBox(width: 48),
                    Expanded(flex: 5, child: visual),
                  ],
                );
              }
              return Column(children: [text, const SizedBox(height: 32), visual]);
            },
          ),
        ),
      ),
    );
  }
}

class _ChipItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ChipItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.black, width: 2)),
      child: Row(children: [
        Icon(icon, color: Colors.black, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black))),
      ]),
    );
  }
}

class _CurriculumVisual extends StatelessWidget {
  const _CurriculumVisual();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        children: [
          Positioned.fill(
            child: Transform.rotate(
              angle: 0.1,
              child: Container(
                decoration: BoxDecoration(color: DoodlePalette.red, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black, width: 3)),
              ),
            ),
          ),
          Positioned.fill(
            child: Transform.rotate(
              angle: -0.05,
              child: Container(
                decoration: BoxDecoration(color: DoodlePalette.green, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black, width: 3)),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black, width: 3)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Mobile & Web Ready', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _iconTile(Icons.smartphone),
                    const SizedBox(width: 16),
                    _iconTile(Icons.laptop_mac),
                  ]),
                  const SizedBox(height: 16),
                  const Text('Unified codebase. Deploy anywhere.', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconTile(IconData icon) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.black, width: 2)),
        child: Icon(icon, size: 32, color: Colors.black),
      );
}

class _Footer extends StatelessWidget {
  final VoidCallback onPlay;

  const _Footer({required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DoodlePalette.white,
      child: _SectionContainer(
        padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Ready to ', style: TextStyle(color: Colors.black, fontSize: 44, fontWeight: FontWeight.w800)),
                Transform.rotate(
                  angle: 0.035,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration:
                        BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black, width: 3)),
                    child: const Text('Code?', style: TextStyle(color: DoodlePalette.purple, fontSize: 44, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            DoodleButton(label: 'Play NgeCode Juh Free', color: DoodlePalette.green, onPressed: onPlay),
            const SizedBox(height: 48),
            const Divider(color: Colors.black, thickness: 3),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 16,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const DoodleIconBadge(icon: Icons.terminal, color: DoodlePalette.red, size: 36, iconSize: 18, borderRadius: 10),
                  const SizedBox(width: 10),
                  const Text('NgeCode Juh!', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w800)),
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  _socialIcon(Icons.code),
                  const SizedBox(width: 12),
                  _socialIcon(Icons.forum),
                ]),
              ],
            ),
            const SizedBox(height: 24),
            const Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 24,
              runSpacing: 8,
              children: [
                Text('© 2026 NgeCode Juh! Platform. Final Year Project.', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 13)),
                Text('Designed for UNIMAS SE Program by Raynold Anak Kabai.', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2)),
        child: Icon(icon, size: 18, color: Colors.black),
      );
}

/// Centers content within a max width and applies consistent section
/// padding, mirroring the reference design's `max-w-7xl` container.
class _SectionContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SectionContainer({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1200), child: child),
      ),
    );
  }
}
