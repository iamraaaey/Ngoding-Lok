import 'package:flutter/material.dart';
import '../theme/doodle.dart';

/// Animated splash / boot screen shown once on app start.
/// Plays a terminal-style loading sequence, then calls [onComplete].
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
    '> initializing NgeCode Juh!...',
    '> loading curriculum modules...',
    '> calibrating AI socratic tutor...',
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
        backgroundColor: DoodlePalette.dark,
        body: AnimatedDoodleDotBackground(
          child: LayoutBuilder(
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
                    // ── Logo ──────────────────────────────────────────────
                    FadeTransition(
                      opacity: _logoCtrl,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.6),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack)),
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: DoodlePalette.purple,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black, width: 3),
                                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(5, 5))],
                              ),
                              child: const Icon(Icons.terminal, color: Colors.white, size: 32),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [Colors.white, DoodlePalette.green],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: const Text(
                                      'NgeCode Juh!',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 34,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'Explore. Debug. Master the Code.',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
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

                    // ── Terminal box ──────────────────────────────────────
                    FadeTransition(
                      opacity: CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.45, 1.0)),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1117),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black, width: 3),
                          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Traffic lights
                            Row(
                              children: [
                                _dot(DoodlePalette.red),
                                const SizedBox(width: 6),
                                _dot(DoodlePalette.yellow),
                                const SizedBox(width: 6),
                                _dot(DoodlePalette.green),
                                const Spacer(),
                                const Text(
                                  'ngecode_juh — terminal',
                                  style: TextStyle(
                                    color: Color(0xFF58A6FF),
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
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
                                builder: (context, _) => Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    _cursorCtrl.value > 0.5 ? '█' : ' ',
                                    style: const TextStyle(
                                      color: DoodlePalette.green,
                                      fontFamily: 'monospace',
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Progress bar ──────────────────────────────────────
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
                                  const Text(
                                    'Loading app resources',
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${(p * 100).toInt()}%',
                                    style: const TextStyle(
                                      color: DoodlePalette.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  height: 6,
                                  color: Colors.white10,
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: p,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [DoodlePalette.blue, DoodlePalette.green],
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: DoodlePalette.green.withValues(alpha: 0.55),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
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
        ),
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2)),
      );
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
            style: TextStyle(
              color: widget.isSuccess ? DoodlePalette.green : Colors.white70,
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
