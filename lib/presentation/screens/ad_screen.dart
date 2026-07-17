import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/landing_tokens.dart';
import '../widgets/landing/landing_button.dart';
import '../widgets/landing/landing_surface.dart';

/// Simulated sponsor-break screen, shown only where a real rewarded ad
/// network is unavailable (desktop, or web builds without AdSense
/// configured). Real inventory comes from AdMob on Android/iOS and the
/// AdSense Ad Placement API on web — see RootOrchestrator._requestHintAd.
///
/// Terminal noir chrome: carbon panel, iridescent strip, mono status copy,
/// ember progress. Knows nothing about hints, XP, or navigation targets —
/// [onComplete] decides what happens next. [isRewarded] controls the
/// countdown length and button copy (5s "Unlock Hint" vs 3s "Continue").
class AdScreen extends StatefulWidget {
  final bool isRewarded;
  final VoidCallback onComplete;
  final VoidCallback? onCancel;

  const AdScreen({
    super.key,
    required this.isRewarded,
    required this.onComplete,
    this.onCancel,
  });

  @override
  State<AdScreen> createState() => _AdScreenState();
}

class _AdScreenState extends State<AdScreen> {
  late final int _totalSeconds = widget.isRewarded ? 5 : 3;
  late int _secondsLeft = _totalSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _tick(Timer timer) {
    if (_secondsLeft <= 1) {
      timer.cancel();
      setState(() => _secondsLeft = 0);
    } else {
      setState(() => _secondsLeft -= 1);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double get _progress => (_totalSeconds - _secondsLeft) / _totalSeconds;

  @override
  Widget build(BuildContext context) {
    final canContinue = _secondsLeft == 0;

    return Scaffold(
      backgroundColor: LandingTokens.voidBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CinematicBackdrop(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: LandingTokens.carbon,
                      borderRadius: LandingTokens.mediumRadius,
                      border: Border.all(color: LandingTokens.hairlineStrong),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x99000000),
                          blurRadius: 40,
                          offset: Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(
                          height: 3,
                          child: AnimatedIridescence(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _header(),
                              const SizedBox(height: 18),
                              Text(
                                widget.isRewarded
                                    ? 'UNLOCKING YOUR HINT'
                                    : 'SPONSOR BREAK',
                                style: LandingTokens.display(
                                  fontSize: 22,
                                ).copyWith(height: 1.12),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.isRewarded
                                    ? 'Watch this short sponsor session to '
                                          'unlock a Socratic hint for the '
                                          'current mission.'
                                    : 'A short sponsor break keeps Ngoding '
                                          'Lok free for every cadet.',
                                style: LandingTokens.body(fontSize: 13.5),
                              ),
                              const SizedBox(height: 16),
                              _adSlot(),
                              const SizedBox(height: 16),
                              _progressBar(context, canContinue),
                              if (canContinue) ...[
                                const SizedBox(height: 14),
                                _completedStatus(),
                              ],
                              const SizedBox(height: 20),
                              GradientButton(
                                label: canContinue
                                    ? (widget.isRewarded
                                          ? 'Unlock Hint'
                                          : 'Continue')
                                    : 'Stand by — $_secondsLeft',
                                icon: canContinue
                                    ? Icons.arrow_forward_rounded
                                    : Icons.hourglass_bottom_rounded,
                                onPressed: canContinue
                                    ? widget.onComplete
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        const PulsingDot(size: 5, color: LandingTokens.ember),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.isRewarded ? '// SPONSORED SESSION' : '// ADVERTISEMENT',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LandingTokens.label(
              fontSize: 10,
              color: LandingTokens.ember,
            ),
          ),
        ),
        if (widget.onCancel != null) ...[
          const SizedBox(width: 12),
          _CloseButton(onPressed: widget.onCancel!),
        ],
      ],
    );
  }

  /// Placeholder inventory slot rendered by the local preview. Real ads
  /// (AdMob / AdSense) present their own full-screen overlay instead.
  Widget _adSlot() {
    return Container(
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        color: LandingTokens.voidBlack,
        borderRadius: LandingTokens.smallRadius,
        border: Border.all(color: LandingTokens.hairlineStrong),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: LandingTokens.smallRadius,
                border: Border.all(color: LandingTokens.hairlineStrong),
              ),
              child: Text(
                'AD',
                style: LandingTokens.label(
                  fontSize: 8.5,
                  color: LandingTokens.textFaint,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.ondemand_video_rounded,
                  color: LandingTokens.textFaint,
                  size: 22,
                ),
                const SizedBox(height: 8),
                Text(
                  'SPONSOR MESSAGE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LandingTokens.label(
                    fontSize: 9.5,
                    color: LandingTokens.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'LOCAL PREVIEW',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LandingTokens.label(
                    fontSize: 8,
                    color: LandingTokens.textFaint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressBar(BuildContext context, bool canContinue) {
    final motion = LandingTokens.motionFor(
      context,
      const Duration(milliseconds: 950),
    );
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 6,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: LandingTokens.voidBlack,
              borderRadius: LandingTokens.smallRadius,
              border: Border.all(color: LandingTokens.hairline),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: _progress),
              duration: motion,
              curve: Curves.linear,
              builder: (context, value, _) => Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  child: const ColoredBox(color: LandingTokens.ember),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          canContinue ? 'DONE' : 'T-${_secondsLeft}S',
          style: LandingTokens.mono(
            fontSize: 12,
            color: canContinue
                ? LandingTokens.signal
                : LandingTokens.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _completedStatus() {
    return Row(
      children: [
        Container(width: 8, height: 8, color: LandingTokens.signal),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.isRewarded ? 'HINT UNLOCKED' : 'SPONSOR BREAK COMPLETE',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LandingTokens.label(
              fontSize: 9.5,
              color: LandingTokens.signal,
            ),
          ),
        ),
      ],
    );
  }
}

/// Square hairline close box, matching the game header's icon buttons.
class _CloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Cancel and return',
      child: Tooltip(
        message: 'Cancel and return',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: LandingTokens.smallRadius,
                border: Border.all(color: LandingTokens.hairlineStrong),
              ),
              child: const Icon(
                Icons.close,
                color: LandingTokens.textPrimary,
                size: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
