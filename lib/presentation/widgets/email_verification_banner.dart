import 'package:flutter/material.dart';
import '../../core/session/email_auth_service.dart';
import '../theme/landing_tokens.dart';
import '../theme/noir_skin.dart';

/// Banner widget displayed when user is logged in but email is not verified.
/// Prompts user to verify their email and provides resend/refresh options.
class EmailVerificationBanner extends StatefulWidget {
  final VoidCallback onVerified;
  final String userEmail;

  const EmailVerificationBanner({
    super.key,
    required this.onVerified,
    required this.userEmail,
  });

  @override
  State<EmailVerificationBanner> createState() =>
      _EmailVerificationBannerState();
}

class _EmailVerificationBannerState extends State<EmailVerificationBanner>
    with SingleTickerProviderStateMixin {
  bool _isVerified = false;
  bool _isLoading = false;
  bool _canResend = true;
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkVerification();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkVerification() async {
    try {
      final isVerified = await EmailAuthService.reloadEmailVerification();
      if (mounted) {
        setState(() => _isVerified = isVerified);
        if (isVerified) {
          await _fadeController.reverse();
          widget.onVerified();
        }
      }
    } catch (e) {
      debugPrint('Error checking email verification: $e');
    }
  }

  Future<void> _resendVerification() async {
    if (!_canResend || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      await EmailAuthService.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification email sent to ${widget.userEmail}'),
            backgroundColor: LandingTokens.signal,
          ),
        );
        // Disable resend for 60 seconds
        setState(() => _canResend = false);
        await Future.delayed(const Duration(seconds: 60));
        if (mounted) setState(() => _canResend = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isVerified) return const SizedBox.shrink();

    final skin = NoirSkin.of(context);

    return FadeTransition(
      opacity: _fadeController.drive(Tween(begin: 1.0, end: 0.0)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          border: Border(
            left: BorderSide(color: LandingTokens.ember, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mail_outline, color: LandingTokens.ember, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email Verification Required',
                        style: TextStyle(
                          color: skin.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Check your inbox for a verification link sent to ${widget.userEmail}',
                        style: TextStyle(color: skin.sub, fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : (_canResend ? _resendVerification : null),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _canResend ? LandingTokens.ember : skin.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: LandingTokens.smallRadius,
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(skin.text),
                              ),
                            )
                          : Text(
                              _canResend ? 'Resend Email' : 'Wait to resend...',
                              style: TextStyle(
                                color: _canResend
                                    ? LandingTokens.ember
                                    : skin.sub,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _checkVerification,
                      style: FilledButton.styleFrom(
                        backgroundColor: LandingTokens.ember,
                        shape: RoundedRectangleBorder(
                          borderRadius: LandingTokens.smallRadius,
                        ),
                      ),
                      child: Text(
                        'Refresh Status',
                        style: TextStyle(
                          color: const Color(0xFF0A0500),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
