import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/curriculum/curriculum.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/session/user_session.dart';
import '../../core/social/certificate_link.dart';
import '../../data/models/module_certificate.dart';
import '../../data/repositories/user_repository.dart';
import '../theme/landing_tokens.dart';
import '../theme/noir_skin.dart';
import '../widgets/landing/landing_button.dart';
import '../widgets/landing/landing_surface.dart';
import '../widgets/noir_dialog.dart';

/// Lists certificates for modules that the current user has actually
/// completed. A signed-in session can issue a public credential; a local demo
/// session can still preview which modules are ready.
class CertificatesScreen extends StatefulWidget {
  final UserSession user;
  final String? uid;
  final UserRepository repository;
  final VoidCallback onBack;

  const CertificatesScreen({
    super.key,
    required this.user,
    required this.uid,
    required this.repository,
    required this.onBack,
  });

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  ModuleCertificate? _certificate;
  Map<String, ModuleCertificate> _issuedCertificates = const {};
  CurriculumModule? _selectedModule;
  String? _error;
  bool _busy = false;
  bool _loadingCertificates = false;

  @override
  void initState() {
    super.initState();
    _loadIssuedCertificates();
  }

  @override
  void didUpdateWidget(covariant CertificatesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid ||
        oldWidget.user.completedModuleIds != widget.user.completedModuleIds) {
      _loadIssuedCertificates();
    }
  }

  Future<void> _loadIssuedCertificates() async {
    final uid = widget.uid;
    if (uid == null) return;
    setState(() {
      _loadingCertificates = true;
      _error = null;
    });
    try {
      final completedIds = _completedModules.map((module) => module.id).toList();
      if (completedIds.isEmpty) {
        if (mounted) setState(() => _issuedCertificates = {});
        return;
      }

      final certificates = await widget.repository.fetchCertificatesForUser(
        uid: uid,
        moduleIds: completedIds,
      );
      if (mounted) {
        setState(() {
          _issuedCertificates = certificates;
          debugPrint('Loaded ${certificates.length} certificates from database');
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Failed to load certificates: ${error.toString().split('\n').first}');
      }
      debugPrint('Certificate list sync failed: $error');
    } finally {
      if (mounted) setState(() => _loadingCertificates = false);
    }
  }

  List<CurriculumModule> get _completedModules => [
    for (final module in Curriculum.sortedModules)
      if (widget.user.completedModuleIds.contains(module.id)) module,
  ];

  Future<void> _issue(CurriculumModule module) async {
    final uid = widget.uid;
    if (uid == null) {
      setState(() => _error = 'Sign in to issue a verified certificate.');
      return;
    }

    // Check if already issued
    ModuleCertificate? existing;
    for (final certificate in _issuedCertificates.values) {
      if (certificate.moduleId == module.id) {
        existing = certificate;
        break;
      }
    }
    if (existing != null) {
      setState(() => _certificate = existing);
      return;
    }

    // Validate module was completed
    if (!widget.user.completedModuleIds.contains(module.id)) {
      setState(() => _error = 'Complete ${module.title} before issuing its certificate.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _selectedModule = module;
    });
    try {
      debugPrint('Issuing certificate for module ${module.id} with uid=$uid');
      final certificate = await widget.repository.ensureModuleCertificate(
        uid: uid,
        user: widget.user,
        module: module,
      );
      if (mounted) {
        debugPrint('Certificate issued successfully: ${certificate.certificateId}');
        setState(() {
          _issuedCertificates = {
            ..._issuedCertificates,
            certificate.certificateId: certificate,
          };
          _certificate = certificate;
        });
      }
    } on CertificateException catch (error) {
      debugPrint('Certificate exception: ${error.message}');
      if (mounted) setState(() => _error = error.message);
    } catch (error) {
      debugPrint('Certificate issuance error: $error');
      final errorMsg = error.toString();
      final shortError = errorMsg.split('\n').first;
      if (mounted) {
        setState(() => _error = 'Certificate sync failed. Try again.\n$shortError');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareOnLinkedIn(ModuleCertificate certificate) async {
    final launched = await launchUrl(
      CertificateLink.linkedinShareUrl(certificate.certificateId),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      showNoirSnack(
        context,
        'LinkedIn could not be opened on this device.',
        success: false,
      );
    }
  }

  void _showList() {
    setState(() {
      _certificate = null;
      _selectedModule = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final skin = NoirSkin.of(context);
    final certificate = _certificate;

    return Scaffold(
      backgroundColor: skin.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (skin.isDark) const CinematicBackdrop(),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NoirHeader(
                        title: certificate == null
                            ? 'Certificates'
                            : 'Certificate',
                        eyebrow: certificate == null
                            ? 'Verified achievements'
                            : 'Public credential',
                        skin: skin,
                        onBack: certificate == null ? widget.onBack : _showList,
                      ),
                      const SizedBox(height: 16),
                      if (certificate != null)
                        CertificateArtwork(
                          certificate: certificate,
                          onShare: () => _shareOnLinkedIn(certificate),
                          onBack: _showList,
                        )
                      else
                        _CertificateList(
                          skin: skin,
                          modules: _completedModules,
                          uidAvailable: widget.uid != null,
                          busy: _busy,
                          loadingCertificates: _loadingCertificates,
                          issuedCertificates: _issuedCertificates,
                          selectedModuleId: _selectedModule?.id,
                          error: _error,
                          onIssue: _issue,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificateList extends StatelessWidget {
  final NoirSkin skin;
  final List<CurriculumModule> modules;
  final bool uidAvailable;
  final bool busy;
  final bool loadingCertificates;
  final Map<String, ModuleCertificate> issuedCertificates;
  final String? selectedModuleId;
  final String? error;
  final ValueChanged<CurriculumModule> onIssue;

  const _CertificateList({
    required this.skin,
    required this.modules,
    required this.uidAvailable,
    required this.busy,
    required this.loadingCertificates,
    required this.issuedCertificates,
    required this.selectedModuleId,
    required this.error,
    required this.onIssue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NoirPanel(
          skin: skin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified, color: LandingTokens.signal),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '// EARNED CREDENTIALS',
                      style: LandingTokens.label(
                        fontSize: 10,
                        color: LandingTokens.signal,
                      ),
                    ),
                  ),
                  Text(
                    '${modules.length} COMPLETE',
                    style: LandingTokens.label(fontSize: 9, color: skin.faint),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Complete a module, then issue its verified credential. Every credential has a public link that works when shared on LinkedIn.',
                style: TextStyle(color: skin.sub, height: 1.45),
              ),
              if (loadingCertificates) ...[
                const SizedBox(height: 8),
                Text(
                  'Checking issued credentials…',
                  style: LandingTokens.label(fontSize: 9, color: skin.faint),
                ),
              ],
              if (!uidAvailable) ...[
                const SizedBox(height: 10),
                Text(
                  'Demo sessions can preview completed modules. Sign in to issue a public credential.',
                  style: TextStyle(color: LandingTokens.ember, height: 1.35),
                ),
              ],
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(
                  error!,
                  style: TextStyle(color: LandingTokens.ember, height: 1.35),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (modules.isEmpty)
          NoirPanel(
            skin: skin,
            child: Text(
              'Finish your first module to unlock a certificate.',
              style: TextStyle(color: skin.sub),
            ),
          )
        else
          for (final module in modules) ...[
            _CompletedModuleCard(
              skin: skin,
              module: module,
              issued: issuedCertificates.values.any(
                (certificate) => certificate.moduleId == module.id,
              ),
              busy: busy && selectedModuleId == module.id,
              enabled: uidAvailable && !busy,
              onIssue: () => onIssue(module),
            ),
            if (module != modules.last) const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _CompletedModuleCard extends StatelessWidget {
  final NoirSkin skin;
  final CurriculumModule module;
  final bool issued;
  final bool busy;
  final bool enabled;
  final VoidCallback onIssue;

  const _CompletedModuleCard({
    required this.skin,
    required this.module,
    required this.issued,
    required this.busy,
    required this.enabled,
    required this.onIssue,
  });

  @override
  Widget build(BuildContext context) {
    return NoirPanel(
      skin: skin,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: LandingTokens.signal.withValues(alpha: 0.12),
              borderRadius: LandingTokens.smallRadius,
              border: Border.all(
                color: LandingTokens.signal.withValues(alpha: 0.4),
              ),
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: LandingTokens.signal,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.track.label.toUpperCase(),
                  style: LandingTokens.label(
                    fontSize: 9,
                    color: LandingTokens.ember,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  module.title,
                  style: TextStyle(
                    color: skin.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'COMPLETED · ${module.xpReward} XP MODULE',
                  style: LandingTokens.label(fontSize: 9, color: skin.faint),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GradientButton(
            label: busy
                ? 'Issuing...'
                : issued
                ? 'View Credential'
                : 'Earn Certificate',
            icon: busy
                ? Icons.sync
                : issued
                ? Icons.open_in_new
                : Icons.verified,
            compact: true,
            onPressed: enabled ? onIssue : null,
          ),
        ],
      ),
    );
  }
}

/// Certificate artwork recreated from the supplied reference, but generated
/// from real module and learner data rather than a static image.
class CertificateArtwork extends StatelessWidget {
  final ModuleCertificate certificate;
  final VoidCallback onShare;
  final VoidCallback onBack;

  const CertificateArtwork({
    super.key,
    required this.certificate,
    required this.onShare,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD5DCE2)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 28,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _CertificateHeader(certificate: certificate),
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFFF6B00),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: const Text(
                      'THIS CERTIFICATE IS PRESENTED TO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF087F9D),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 20,
                    ),
                    child: Text(
                      certificate.learnerName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(34, 26, 34, 18),
                    child: Column(
                      children: [
                        Text(
                          'for completing ${certificate.moduleTitle}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF34383B),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          certificate.moduleDescription,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF60676C),
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 10,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE5242A),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            'NGODING LOK · ${certificate.trackLabel.toUpperCase()}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _CertificateMeta(
                                label: 'ISSUED',
                                value: _certificateDate(certificate.issuedAt),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFFFF3DF),
                                      border: Border.all(
                                        color: const Color(0xFFE9A93A),
                                        width: 4,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.verified,
                                      color: Color(0xFF087F9D),
                                      size: 36,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'ONLINE VERIFIED',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF087F9D),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: _CertificateMeta(
                                label: 'MODULE SCORE',
                                value: '${certificate.score} XP',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Certificate ID: ${certificate.certificateId}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF7A8288),
                            fontFamily: 'monospace',
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Verify this credential online at ngoding-lok.web.app',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF087F9D),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            CinematicOutlineButton(
              label: 'Back to certificates',
              icon: Icons.arrow_back,
              compact: true,
              onPressed: onBack,
            ),
            GradientButton(
              label: 'Share on LinkedIn',
              icon: Icons.work,
              compact: true,
              onPressed: onShare,
            ),
          ],
        ),
      ],
    );
  }
}

class _CertificateHeader extends StatelessWidget {
  final ModuleCertificate certificate;

  const _CertificateHeader({required this.certificate});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: CustomPaint(
        painter: const _CertificateBlueprintPainter(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(color: const Color(0xFFB7DCE7)),
                ),
                child: const Text(
                  'NGODING LOK  ·  LEARN BY BUILDING',
                  style: TextStyle(
                    color: Color(0xFF087F9D),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'CERTIFIED',
                style: TextStyle(
                  color: Color(0xFF087F9D),
                  fontSize: 38,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 3.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(height: 2, width: 180, color: const Color(0xFFFF6B00)),
              const SizedBox(height: 7),
              Text(
                certificate.trackLabel.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF3F6875),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                certificate.moduleTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF245766),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CertificateMeta extends StatelessWidget {
  final String label;
  final String value;

  const _CertificateMeta({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF777E82),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF2D3539),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CertificateBlueprintPainter extends CustomPainter {
  const _CertificateBlueprintPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFFCDEDF5);
    canvas.drawRect(Offset.zero & size, background);

    final line = Paint()
      ..color = const Color(0x6686C9D8)
      ..strokeWidth = 1;
    final accent = Paint()
      ..color = const Color(0x5585B8C6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var i = -2; i < 12; i++) {
      final x = i * 100.0;
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), line);
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), line);
    }
    for (var i = 0; i < 7; i++) {
      final center = Offset(size.width * (0.12 + i * 0.15), 42 + (i % 3) * 58);
      canvas.drawCircle(center, 19, accent);
      canvas.drawLine(
        center + const Offset(-30, 0),
        center + const Offset(30, 0),
        accent,
      );
      canvas.drawLine(
        center + const Offset(0, -30),
        center + const Offset(0, 30),
        accent,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CertificateBlueprintPainter oldDelegate) =>
      false;
}

/// Public, unauthenticated certificate page loaded from a LinkedIn share.
class PublicCertificateScreen extends StatefulWidget {
  final String certificateId;
  final UserRepository repository;
  final VoidCallback onBack;

  const PublicCertificateScreen({
    super.key,
    required this.certificateId,
    required this.repository,
    required this.onBack,
  });

  @override
  State<PublicCertificateScreen> createState() =>
      _PublicCertificateScreenState();
}

class _PublicCertificateScreenState extends State<PublicCertificateScreen> {
  ModuleCertificate? _certificate;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final certificate = await widget.repository.fetchPublicCertificate(
        widget.certificateId,
      );
      if (!mounted) return;
      setState(() {
        _certificate = certificate;
        _error = certificate == null
            ? 'This certificate could not be verified.'
            : null;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Certificate verification is unavailable.');
      }
    }
  }

  Future<void> _share() async {
    final launched = await launchUrl(
      CertificateLink.linkedinShareUrl(widget.certificateId),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      showNoirSnack(context, 'LinkedIn could not be opened.', success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final skin = NoirSkin.of(context);
    final certificate = _certificate;
    return Scaffold(
      backgroundColor: skin.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (skin.isDark) const CinematicBackdrop(),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      NoirHeader(
                        title: 'Certificate Verification',
                        eyebrow: 'Public verification record',
                        skin: skin,
                        onBack: widget.onBack,
                      ),
                      const SizedBox(height: 16),
                      if (certificate != null)
                        CertificateArtwork(
                          certificate: certificate,
                          onShare: _share,
                          onBack: widget.onBack,
                        )
                      else if (_error == null)
                        const Padding(
                          padding: EdgeInsets.all(48),
                          child: CircularProgressIndicator(),
                        )
                      else
                        NoirPanel(
                          skin: skin,
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: skin.sub),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _certificateDate(DateTime date) {
  const months = [
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
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}
