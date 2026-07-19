import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/social/certificate_link.dart';
import '../../data/models/module_certificate.dart';
import '../theme/landing_tokens.dart';
import '../widgets/landing/landing_button.dart';

const Color _certificatePaper = Color(0xFFF7F5EF);
const Color _certificateInk = Color(0xFF101112);
const Color _certificateInkMuted = Color(0xFF5C5B55);
const Color _certificateSignalInk = Color(0xFF087A54);

/// The live, responsive presentation of a verified credential.
///
/// Desktop uses a dark Ngoding Lok rail beside an ivory certificate sheet.
/// On smaller screens the rail becomes a compact masthead, preserving the
/// certificate hierarchy without shrinking the credential into illegibility.
class CertificateDisplayEnhanced extends StatefulWidget {
  final ModuleCertificate certificate;
  final VoidCallback onShare;
  final VoidCallback? onDownload;
  final bool downloading;
  final VoidCallback onBack;

  const CertificateDisplayEnhanced({
    super.key,
    required this.certificate,
    required this.onShare,
    this.onDownload,
    this.downloading = false,
    required this.onBack,
  });

  @override
  State<CertificateDisplayEnhanced> createState() =>
      _CertificateDisplayEnhancedState();
}

class _CertificateDisplayEnhancedState extends State<CertificateDisplayEnhanced>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 520),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final entrance = disableAnimations
        ? const AlwaysStoppedAnimation<double>(1)
        : CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScaleTransition(
          alignment: Alignment.topCenter,
          scale: Tween<double>(begin: 0.99, end: 1).animate(entrance),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 720;
              final railWidth = (constraints.maxWidth * 0.3)
                  .clamp(216.0, 308.0)
                  .toDouble();

              return Container(
                key: const Key('certificate-artwork-canvas'),
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: LandingTokens.carbon,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: LandingTokens.ember.withValues(alpha: 0.62),
                    width: 1.25,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x99000000),
                      blurRadius: 32,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    if (isDesktop)
                      Padding(
                        padding: EdgeInsets.only(left: railWidth),
                        child: _CertificateCredentialCanvas(
                          certificate: widget.certificate,
                          desktop: true,
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _CertificateSideRail(
                            certificate: widget.certificate,
                            compact: true,
                          ),
                          _CertificateCredentialCanvas(
                            certificate: widget.certificate,
                            desktop: false,
                          ),
                        ],
                      ),
                    if (isDesktop)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: railWidth,
                        child: _CertificateSideRail(
                          certificate: widget.certificate,
                          compact: false,
                        ),
                      ),
                    if (isDesktop)
                      Positioned(
                        left: railWidth - 56,
                        top: 166,
                        child: const IgnorePointer(
                          child: _CertificateAchievementSeal(size: 112),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        _CertificateActionBar(
          onBack: widget.onBack,
          onShare: widget.onShare,
          onDownload: widget.onDownload,
          downloading: widget.downloading,
        ),
      ],
    );
  }
}

class _CertificateSideRail extends StatelessWidget {
  final ModuleCertificate certificate;
  final bool compact;

  const _CertificateSideRail({
    required this.certificate,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _MobileCertificateMasthead(certificate: certificate);
    }

    return CustomPaint(
      painter: const _CertificateRailPainter(),
      child: Container(
        color: LandingTokens.carbon,
        padding: const EdgeInsets.fromLTRB(28, 30, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _RailBrand(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 44, height: 3, color: LandingTokens.ember),
                const SizedBox(height: 16),
                Text(
                  'COMPLETION',
                  style: LandingTokens.label(
                    fontSize: 10,
                    color: LandingTokens.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'CREDENTIAL',
                  style: LandingTokens.label(
                    fontSize: 10,
                    color: LandingTokens.signal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'A verifiable record of focused practice, issued from the Ngoding Lok learning floor.',
                  style: LandingTokens.body(
                    fontSize: 12,
                    color: LandingTokens.textMuted,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.14),
                ),
                const SizedBox(height: 14),
                Text(
                  certificate.trackLabel.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: LandingTokens.label(
                    fontSize: 9,
                    color: LandingTokens.circuit,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'PUBLIC CREDENTIAL // 01',
                  style: LandingTokens.mono(
                    fontSize: 9,
                    color: LandingTokens.textMuted,
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

class _RailBrand extends StatelessWidget {
  const _RailBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LandingTokens.ember,
            border: Border.all(color: LandingTokens.emberBright),
            borderRadius: BorderRadius.circular(3),
            boxShadow: LandingTokens.emberGlow,
          ),
          child: const Icon(
            Icons.terminal_rounded,
            color: _certificateInk,
            size: 22,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'NGODING',
          style: LandingTokens.display(
            fontSize: 28,
            color: LandingTokens.textPrimary,
            fontWeight: FontWeight.w900,
          ).copyWith(letterSpacing: -1.1),
        ),
        Text(
          'LOK',
          style: LandingTokens.display(
            fontSize: 28,
            color: LandingTokens.textPrimary,
            fontWeight: FontWeight.w900,
          ).copyWith(letterSpacing: -1.1),
        ),
        const SizedBox(height: 8),
        Text(
          'LEARN // BUILD // SHIP',
          style: LandingTokens.label(
            fontSize: 8,
            color: LandingTokens.signal,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _MobileCertificateMasthead extends StatelessWidget {
  final ModuleCertificate certificate;

  const _MobileCertificateMasthead({required this.certificate});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _CertificateRailPainter(compact: true),
      child: Container(
        color: LandingTokens.carbon,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 17),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: LandingTokens.ember,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Icon(
                Icons.terminal_rounded,
                color: _certificateInk,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NGODING LOK',
                    style: LandingTokens.label(
                      fontSize: 10,
                      color: LandingTokens.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    certificate.trackLabel.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LandingTokens.mono(
                      fontSize: 9,
                      color: LandingTokens.circuit,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const _VerifiedMark(),
          ],
        ),
      ),
    );
  }
}

class _VerifiedMark extends StatelessWidget {
  const _VerifiedMark();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Verified credential',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: LandingTokens.signal.withValues(alpha: 0.11),
          border: Border.all(
            color: LandingTokens.signal.withValues(alpha: 0.6),
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.verified_rounded,
              color: LandingTokens.signal,
              size: 13,
            ),
            const SizedBox(width: 4),
            Text(
              'VERIFIED',
              style: LandingTokens.label(
                fontSize: 7,
                color: LandingTokens.signal,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertificateCredentialCanvas extends StatelessWidget {
  final ModuleCertificate certificate;
  final bool desktop;

  const _CertificateCredentialCanvas({
    required this.certificate,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = desktop
        ? const BorderRadius.only(topRight: Radius.circular(132))
        : const BorderRadius.only(
            topLeft: Radius.circular(44),
            topRight: Radius.circular(44),
          );

    return Container(
      constraints: desktop ? const BoxConstraints(minHeight: 570) : null,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _certificatePaper,
        borderRadius: borderRadius,
      ),
      child: CustomPaint(
        painter: _CertificatePaperPainter(desktop: desktop),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 500;
            final horizontal = desktop
                ? (narrow ? 34.0 : 52.0)
                : (narrow ? 20.0 : 30.0);
            final sealSpace = desktop ? (narrow ? 72.0 : 100.0) : 0.0;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                horizontal + sealSpace,
                desktop ? 34 : 28,
                horizontal,
                desktop ? 30 : 28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CredentialHeader(desktop: desktop),
                  SizedBox(height: desktop ? 28 : 24),
                  _CertificateTitleBlock(
                    certificate: certificate,
                    desktop: desktop,
                  ),
                  SizedBox(height: desktop ? 26 : 23),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: _certificateInk.withValues(alpha: 0.17),
                  ),
                  SizedBox(height: desktop ? 24 : 22),
                  _RecipientBlock(certificate: certificate, desktop: desktop),
                  SizedBox(height: desktop ? 22 : 21),
                  _ModuleBlock(certificate: certificate, desktop: desktop),
                  SizedBox(height: desktop ? 28 : 26),
                  _CertificateIssueFooter(
                    certificate: certificate,
                    compact: !desktop || narrow,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CredentialHeader extends StatelessWidget {
  final bool desktop;

  const _CredentialHeader({required this.desktop});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: desktop ? 38 : 32,
          height: 3,
          color: LandingTokens.ember,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'VERIFIED COMPLETION CREDENTIAL',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LandingTokens.label(
              fontSize: desktop ? 9 : 8,
              color: _certificateInkMuted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Icon(
          Icons.verified_rounded,
          color: LandingTokens.signal,
          size: 18,
        ),
      ],
    );
  }
}

class _CertificateTitleBlock extends StatelessWidget {
  final ModuleCertificate certificate;
  final bool desktop;

  const _CertificateTitleBlock({
    required this.certificate,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final titleSize = desktop ? 40.0 : 30.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final useInlineSeal = !desktop;
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Certificate',
              style: LandingTokens.display(
                fontSize: titleSize,
                color: LandingTokens.ember,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'of achievement',
              style: LandingTokens.display(
                fontSize: titleSize,
                color: _certificateInk,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              certificate.trackLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _certificateInk,
                fontSize: desktop ? 17 : 14,
                fontWeight: FontWeight.w700,
                height: 1.18,
              ),
            ),
          ],
        );

        if (!useInlineSeal) return title;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: _CertificateAchievementSeal(size: 70),
            ),
            const SizedBox(width: 14),
            Expanded(child: title),
          ],
        );
      },
    );
  }
}

class _RecipientBlock extends StatelessWidget {
  final ModuleCertificate certificate;
  final bool desktop;

  const _RecipientBlock({required this.certificate, required this.desktop});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THIS CREDENTIAL IS AWARDED TO',
          style: LandingTokens.label(
            fontSize: desktop ? 9 : 8,
            color: _certificateInkMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            certificate.learnerName,
            style: LandingTokens.display(
              fontSize: desktop ? 38 : 30,
              color: _certificateInk,
              fontWeight: FontWeight.w900,
            ).copyWith(letterSpacing: desktop ? -1.3 : -0.9),
          ),
        ),
        const SizedBox(height: 9),
        Container(
          width: double.infinity,
          height: 1,
          color: LandingTokens.signal.withValues(alpha: 0.58),
        ),
      ],
    );
  }
}

class _ModuleBlock extends StatelessWidget {
  final ModuleCertificate certificate;
  final bool desktop;

  const _ModuleBlock({required this.certificate, required this.desktop});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FOR SUCCESSFULLY COMPLETING',
          style: LandingTokens.label(
            fontSize: desktop ? 9 : 8,
            color: _certificateInkMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          certificate.moduleTitle,
          maxLines: desktop ? 2 : 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _certificateInk,
            fontSize: desktop ? 20 : 17,
            fontWeight: FontWeight.w800,
            height: 1.18,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          certificate.moduleDescription,
          maxLines: desktop ? 2 : 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _certificateInkMuted,
            fontSize: desktop ? 12 : 11,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _CertificateIssueFooter extends StatelessWidget {
  final ModuleCertificate certificate;
  final bool compact;

  const _CertificateIssueFooter({
    required this.certificate,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final details = _CertificateIssueDetails(certificate: certificate);
    final qr = CertificateVerificationQr(
      certificateId: certificate.certificateId,
      compact: compact,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = compact || constraints.maxWidth < 470;
        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              details,
              const SizedBox(height: 20),
              Align(alignment: Alignment.centerRight, child: qr),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: details),
            const SizedBox(width: 28),
            qr,
          ],
        );
      },
    );
  }
}

class _CertificateIssueDetails extends StatelessWidget {
  final ModuleCertificate certificate;

  const _CertificateIssueDetails({required this.certificate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 186,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NGODING LOK',
                style: TextStyle(
                  color: _certificateInk,
                  fontFamily: 'cursive',
                  fontSize: 26,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                height: 1,
                color: _certificateInk.withValues(alpha: 0.42),
              ),
              const SizedBox(height: 6),
              Text(
                'ISSUING STUDIO',
                style: LandingTokens.label(
                  fontSize: 7,
                  color: _certificateInkMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        Wrap(
          spacing: 26,
          runSpacing: 12,
          children: [
            _CredentialFact(
              label: 'ISSUED',
              value: _formatCertificateDate(certificate.issuedAt),
            ),
            _CredentialFact(
              label: 'MODULE SCORE',
              value: '${certificate.score} XP',
              valueColor: _certificateSignalInk,
            ),
            _CredentialFact(
              label: 'CREDENTIAL ID',
              value: _certificateIdPreview(certificate.certificateId),
            ),
          ],
        ),
      ],
    );
  }
}

class _CredentialFact extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _CredentialFact({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: LandingTokens.label(
              fontSize: 7,
              color: _certificateInkMuted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LandingTokens.mono(
              fontSize: 10,
              color: valueColor ?? _certificateInk,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// A scanner-ready QR code containing the public verification URL, not merely
/// an internal certificate identifier.
class CertificateVerificationQr extends StatelessWidget {
  final String certificateId;
  final bool compact;

  const CertificateVerificationQr({
    super.key,
    required this.certificateId,
    this.compact = false,
  });

  String get verificationUrl => CertificateLink.certificateUrl(certificateId);

  @override
  Widget build(BuildContext context) {
    final side = compact ? 108.0 : 124.0;
    return Semantics(
      label: 'Certificate verification QR code',
      image: true,
      container: true,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: side,
            height: side,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _certificateInk, width: 1.25),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: LandingTokens.ember.withValues(alpha: 0.2),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: QrImageView(
              key: const Key('certificate-verification-qr'),
              data: verificationUrl,
              version: QrVersions.auto,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
              size: side - 16,
              padding: EdgeInsets.zero,
              gapless: true,
              backgroundColor: Colors.white,
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              semanticsLabel: 'Certificate verification QR code',
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'SCAN TO VERIFY',
            style: LandingTokens.label(
              fontSize: 7,
              color: _certificateInkMuted,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificateAchievementSeal extends StatelessWidget {
  final double size;

  const _CertificateAchievementSeal({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.1,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          CustomPaint(
            size: Size(size, size * 1.1),
            painter: const _CertificateSealPainter(),
          ),
          Positioned(
            top: size * 0.27,
            child: Icon(
              Icons.terminal_rounded,
              color: _certificateInk,
              size: size * 0.36,
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificateActionBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback? onDownload;
  final bool downloading;

  const _CertificateActionBar({
    required this.onBack,
    required this.onShare,
    required this.onDownload,
    required this.downloading,
  });

  @override
  Widget build(BuildContext context) {
    final back = _CertificateActionButton(
      label: 'Back to certificates',
      icon: Icons.arrow_back,
      onPressed: onBack,
    );
    final download = _CertificateActionButton(
      label: downloading ? 'Preparing PDF...' : 'Download PDF',
      icon: downloading ? Icons.sync : Icons.picture_as_pdf_outlined,
      primary: true,
      onPressed: downloading ? null : onDownload,
    );
    final share = _CertificateActionButton(
      label: 'Share on LinkedIn',
      icon: Icons.work_outline,
      onPressed: onShare,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 680) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              back,
              const SizedBox(height: 8),
              download,
              const SizedBox(height: 8),
              share,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: back),
            const SizedBox(width: 8),
            Expanded(child: download),
            const SizedBox(width: 8),
            Expanded(child: share),
          ],
        );
      },
    );
  }
}

class _CertificateActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback? onPressed;

  const _CertificateActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    if (primary) {
      return GradientButton(
        label: label,
        icon: icon,
        compact: true,
        onPressed: onPressed,
      );
    }
    return CinematicOutlineButton(
      label: label,
      icon: icon,
      compact: true,
      onPressed: onPressed,
    );
  }
}

class _CertificateRailPainter extends CustomPainter {
  final bool compact;

  const _CertificateRailPainter({this.compact = false});

  @override
  void paint(Canvas canvas, Size size) {
    final diagonal = Paint()
      ..color = LandingTokens.ember.withValues(alpha: compact ? 0.12 : 0.09)
      ..style = PaintingStyle.fill;
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width * 0.95, 0)
        ..lineTo(size.width * 0.18, size.height)
        ..lineTo(0, size.height),
      diagonal,
    );

    final trace = Paint()
      ..color = LandingTokens.circuit.withValues(alpha: compact ? 0.22 : 0.17)
      ..strokeWidth = 1;
    final y = compact ? size.height - 10 : size.height - 34;
    canvas.drawLine(Offset(0, y), Offset(size.width * 0.56, y), trace);
    canvas.drawLine(
      Offset(size.width * 0.56, y),
      Offset(size.width * 0.56, compact ? y - 16 : y - 46),
      trace,
    );
    canvas.drawCircle(
      Offset(size.width * 0.56, compact ? y - 16 : y - 46),
      2.5,
      Paint()..color = LandingTokens.signal.withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(covariant _CertificateRailPainter oldDelegate) =>
      oldDelegate.compact != compact;
}

class _CertificatePaperPainter extends CustomPainter {
  final bool desktop;

  const _CertificatePaperPainter({required this.desktop});

  @override
  void paint(Canvas canvas, Size size) {
    final wash = Paint()
      ..color = LandingTokens.ember.withValues(alpha: 0.045)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width + 18, -18), desktop ? 176 : 118, wash);

    final cyanLine = Paint()
      ..color = LandingTokens.circuit.withValues(alpha: 0.38)
      ..strokeWidth = 1.2;
    final emberLine = Paint()
      ..color = LandingTokens.ember.withValues(alpha: 0.42)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(size.width - (desktop ? 128 : 90), 28),
      Offset(size.width - 28, 28),
      cyanLine,
    );
    canvas.drawLine(
      Offset(size.width - 28, 28),
      Offset(size.width - 28, desktop ? 86 : 68),
      emberLine,
    );
    canvas.drawCircle(
      Offset(size.width - 28, desktop ? 86 : 68),
      2.5,
      Paint()..color = LandingTokens.ember,
    );

    final lowerMark = Paint()
      ..color = _certificateInk.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(24, size.height - 24),
      Offset(desktop ? 98 : 72, size.height - 24),
      lowerMark,
    );
  }

  @override
  bool shouldRepaint(covariant _CertificatePaperPainter oldDelegate) =>
      oldDelegate.desktop != desktop;
}

class _CertificateSealPainter extends CustomPainter {
  const _CertificateSealPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width;
    final ribbon = Paint()
      ..color = LandingTokens.ember
      ..style = PaintingStyle.fill;
    final ribbonDark = Paint()
      ..color = LandingTokens.ember.withValues(alpha: 0.72)
      ..style = PaintingStyle.fill;
    final outer = Paint()
      ..color = LandingTokens.signal
      ..style = PaintingStyle.fill;
    final inner = Paint()
      ..color = _certificatePaper
      ..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = _certificateInk
      ..style = PaintingStyle.stroke
      ..strokeWidth = scale * 0.026;

    canvas.drawPath(
      Path()
        ..moveTo(scale * 0.24, scale * 0.61)
        ..lineTo(scale * 0.24, scale * 1.02)
        ..lineTo(scale * 0.5, scale * 0.86)
        ..lineTo(scale * 0.76, scale * 1.02)
        ..lineTo(scale * 0.76, scale * 0.61)
        ..close(),
      ribbon,
    );
    canvas.drawPath(
      Path()
        ..moveTo(scale * 0.5, scale * 0.7)
        ..lineTo(scale * 0.76, scale * 0.61)
        ..lineTo(scale * 0.76, scale * 1.02)
        ..lineTo(scale * 0.5, scale * 0.86)
        ..close(),
      ribbonDark,
    );

    final center = Offset(scale * 0.5, scale * 0.43);
    canvas.drawCircle(center, scale * 0.41, outer);
    canvas.drawCircle(center, scale * 0.31, inner);
    canvas.drawCircle(center, scale * 0.41, outline);
  }

  @override
  bool shouldRepaint(covariant _CertificateSealPainter oldDelegate) => false;
}

String _formatCertificateDate(DateTime date) {
  const months = <String>[
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  return <String>[
    date.day.toString().padLeft(2, '0'),
    months[date.month - 1],
    date.year.toString(),
  ].join(' ');
}

String _certificateIdPreview(String certificateId) {
  if (certificateId.length <= 22) return certificateId;
  return '${certificateId.substring(0, 13)}...'
      '${certificateId.substring(certificateId.length - 6)}';
}
