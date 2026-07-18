import 'package:flutter/material.dart';
import '../theme/landing_tokens.dart';

/// Enhanced hint banner with smooth animations, responsive design, and improved UX.
/// Shows AI tutor's Socratic hint with loading state and interactive feedback.
class HintBanner extends StatefulWidget {
  final String hint;
  final bool isLoading;

  const HintBanner({super.key, required this.hint, this.isLoading = false});

  @override
  State<HintBanner> createState() => _HintBannerState();
}

class _HintBannerState extends State<HintBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(HintBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading && !widget.isLoading) {
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isCompact = MediaQuery.of(context).size.width < 400;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: double.infinity,
              color: LandingTokens.voidBlack,
              padding: EdgeInsets.fromLTRB(
                isCompact ? 8 : 12,
                12,
                isCompact ? 8 : 12,
                0,
              ),
              child: _HintCard(
                hint: widget.hint,
                isLoading: widget.isLoading,
                isMobile: isMobile,
                isCompact: isCompact,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HintCard extends StatelessWidget {
  final String hint;
  final bool isLoading;
  final bool isMobile;
  final bool isCompact;

  const _HintCard({
    required this.hint,
    required this.isLoading,
    required this.isMobile,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 16,
        vertical: isCompact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: LandingTokens.signal.withValues(alpha: 0.07),
        borderRadius: LandingTokens.mediumRadius,
        border: Border.all(
          color: LandingTokens.signal.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: LandingTokens.signal.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isCompact
          ? _CompactLayout(
              hint: hint,
              isLoading: isLoading,
            )
          : _FullLayout(
              hint: hint,
              isLoading: isLoading,
              isMobile: isMobile,
            ),
    );
  }
}

class _FullLayout extends StatelessWidget {
  final String hint;
  final bool isLoading;
  final bool isMobile;

  const _FullLayout({
    required this.hint,
    required this.isLoading,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LoadingIndicator(isLoading: isLoading),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isLoading ? 'Generating hint...' : 'Hint',
                style: LandingTokens.mono(
                  fontSize: isMobile ? 11 : 12,
                  color: LandingTokens.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isLoading
                    ? '> searching your code for insights...'
                    : '> $hint',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: isMobile ? 12 : 13,
                  color: LandingTokens.textPrimary,
                  height: 1.4,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactLayout extends StatelessWidget {
  final String hint;
  final bool isLoading;

  const _CompactLayout({
    required this.hint,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _LoadingIndicator(isLoading: isLoading),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            isLoading
                ? '> generating...'
                : '> $hint',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 11,
              color: LandingTokens.textPrimary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _LoadingIndicator extends StatefulWidget {
  final bool isLoading;

  const _LoadingIndicator({required this.isLoading});

  @override
  State<_LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return RotationTransition(
        turns: _spinController,
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: LandingTokens.signal.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LandingTokens.signal.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      );
    }

    return Icon(
      Icons.smart_toy,
      color: LandingTokens.signal,
      size: 16,
    );
  }
}
