import 'package:flutter/material.dart';
import '../theme/landing_tokens.dart';
import '../widgets/landing/landing_surface.dart';

/// Animated splash / boot screen shown once on app start, in the terminal
/// noir language of the landing page. Plays a terminal-style loading
/// sequence, then calls [onComplete].
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _progressCtrl;
  late final AnimationController _exitCtrl;
  late final AnimationController _cursorCtrl;

  int _visibleLines = 0;

  static const _lines = [
    '> initializing ngoding lok...',
    '> loading curriculum modules...',
    '> calibrating ai socratic tutor...',
    '> ready. let the quest begin! ✓',
  ];

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _exitCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _cursorCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 550))
      ..repeat(reverse: true);

    _logoCtrl.forward();

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _progressCtrl.forward();
    });

    for (int i = 0; i < _lines.length; i++) {
      Future.delayed(Duration(milliseconds: 350 + i * 520), () {
        if (mounted) setState(() => _visibleLines = i + 1);
      });
    }

    // Total lines finish ~350 + 3*520 = 1910ms; exit at 3000ms
    Future.delayed(const Duration(milliseconds: 3100), () async {
      if (!mounted) return;
      await _exitCtrl.forward();
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _progressCtrl.dispose();
    _exitCtrl.dispose();
    _cursorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _exitCtrl,
      builder: (_, child) => Opacity(opacity: (1 - _exitCtrl.value).clamp(0.0, 1.0), child: child),
      child: Scaffold(
        backgroundColor: LandingTokens.voidBlack,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const CinematicBackdrop(),
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Logo ──────────────────────────────────────
                            FadeTransition(
                              opacity: _logoCtrl,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, -0.6),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutCubic)),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: const BoxDecoration(
                                        color: LandingTokens.ember,
                                        borderRadius: LandingTokens.mediumRadius,
                                      ),
                                      child: const Icon(Icons.terminal, color: Color(0xFF0A0500), size: 30),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  'NGODING LOK',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: LandingTokens.display(fontSize: 30),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              AnimatedBuilder(
                                                animation: _cursorCtrl,
                                                builder: (context, _) => Opacity(
                                                  opacity: _cursorCtrl.value > 0.5 ? 1 : 0,
                                                  child: Container(
                                                    width: 12,
                                                    height: 24,
                                                    color: LandingTokens.ember,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '// EXPLORE. DEBUG. MASTER THE CODE.',
                                            overflow: TextOverflow.ellipsis,
                                            style: LandingTokens.label(
                                              fontSize: 9.5,
                                              color: LandingTokens.textFaint,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // ── Terminal box ──────────────────────────────
                            FadeTransition(
                              opacity: CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.45, 1.0)),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: LandingTokens.carbon,
                                  borderRadius: LandingTokens.mediumRadius,
                                  border: Border.all(color: LandingTokens.hairline),
                                  boxShadow: LandingTokens.cardShadow,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Row(
                                        children: [
                                          _dot(LandingTokens.hairlineStrong),
                                          const SizedBox(width: 5),
                                          _dot(LandingTokens.hairlineStrong),
                                          const SizedBox(width: 5),
                                          _dot(LandingTokens.ember),
                                          const Spacer(),
                                          Text(
                                            'NGODING_LOK — TERMINAL',
                                            style: LandingTokens.label(
                                              fontSize: 9,
                                              color: LandingTokens.textFaint,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const HairlineDivider(),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Animated code lines
                                          for (int i = 0; i < _lines.length; i++)
                                            if (i < _visibleLines)
                                              _TerminalLine(
                                                key: ValueKey(i),
                                                text: _lines[i],
                                                isSuccess: i == _lines.length - 1,
                                              ),
                                          // Blinking cursor while typing
                                          if (_visibleLines < _lines.length)
                                            AnimatedBuilder(
                                              animation: _cursorCtrl,
                                              builder: (context, _) => Opacity(
                                                opacity: _cursorCtrl.value > 0.5 ? 1 : 0,
                                                child: Container(
                                                  width: 8,
                                                  height: 15,
                                                  color: LandingTokens.signal,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // ── Progress bar ──────────────────────────────
                            FadeTransition(
                              opacity: CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.5, 1.0)),
                              child: AnimatedBuilder(
                                animation: _progressCtrl,
                                builder: (context, _) {
                                  final p = CurvedAnimation(
                                    parent: _progressCtrl,
                                    curve: Curves.easeInOut,
                                  ).value;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'LOADING APP RESOURCES',
                                            style: LandingTokens.label(
                                              fontSize: 9.5,
                                              color: LandingTokens.textFaint,
                                            ),
                                          ),
                                          Text(
                                            '${(p * 100).toInt()}%',
                                            style: LandingTokens.mono(
                                              fontSize: 12,
                                              color: LandingTokens.ember,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: LandingTokens.panel,
                                          border: Border.all(color: LandingTokens.hairline),
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: FractionallySizedBox(
                                          widthFactor: p,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: LandingTokens.ember,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: LandingTokens.ember.withValues(alpha: 0.5),
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color color) => Container(width: 8, height: 8, color: color);
}

/// Single animated terminal line that fades + slides in on mount.
class _TerminalLine extends StatefulWidget {
  final String text;
  final bool isSuccess;

  const _TerminalLine({super.key, required this.text, this.isSuccess = false});

  @override
  State<_TerminalLine> createState() => _TerminalLineState();
}

class _TerminalLineState extends State<_TerminalLine> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.03, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Text(
            widget.text,
            style: LandingTokens.mono(
              fontSize: 13,
              color: widget.isSuccess ? LandingTokens.signal : LandingTokens.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
