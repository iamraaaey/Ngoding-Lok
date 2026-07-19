import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/curriculum/curriculum.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/session/user_session.dart';
import '../../core/social/certificate_link.dart';
import '../../core/social/certificate_pdf.dart';
import '../../data/models/module_certificate.dart';
import '../../data/repositories/user_repository.dart';
import '../theme/landing_tokens.dart';
import '../theme/noir_skin.dart';
import '../widgets/landing/landing_button.dart';
import '../widgets/landing/landing_surface.dart';
import '../widgets/noir_dialog.dart';
import 'certificate_display_enhanced.dart';

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
  bool _downloadingPdf = false;

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
      final completedIds = _completedModules
          .map((module) => module.id)
          .toList();
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
          debugPrint(
            'Loaded ${certificates.length} certificates from database',
          );
        });
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error =
              'Failed to load certificates: ${error.toString().split('\n').first}',
        );
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
      setState(
        () =>
            _error = 'Complete ${module.title} before issuing its certificate.',
      );
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
        debugPrint(
          'Certificate issued successfully: ${certificate.certificateId}',
        );
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
        setState(
          () => _error = 'Certificate sync failed. Try again.\n$shortError',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareOnLinkedIn(ModuleCertificate certificate) async {
    var launched = false;
    try {
      launched = await launchUrl(
        CertificateLink.linkedinShareUrl(certificate.certificateId),
        mode: LaunchMode.externalApplication,
      );
    } catch (error) {
      debugPrint('LinkedIn share failed: $error');
    }
    if (!launched && mounted) {
      showNoirSnack(
        context,
        'LinkedIn could not be opened on this device.',
        success: false,
      );
    }
  }

  Future<void> _downloadPdf(ModuleCertificate certificate) async {
    if (_downloadingPdf) return;
    setState(() => _downloadingPdf = true);
    try {
      final started = await CertificatePdf.download(certificate);
      if (mounted) {
        showNoirSnack(
          context,
          started
              ? 'Certificate PDF download started.'
              : 'Certificate PDF download was cancelled.',
          success: started,
        );
      }
    } catch (error) {
      debugPrint('Certificate PDF download failed: $error');
      if (mounted) {
        showNoirSnack(
          context,
          'Could not create the certificate PDF. Please try again.',
          success: false,
        );
      }
    } finally {
      if (mounted) setState(() => _downloadingPdf = false);
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
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NoirHeader(
                    title: certificate == null ? 'Certificates' : 'Certificate',
                    eyebrow: certificate == null
                        ? 'Verified achievements'
                        : 'Public credential',
                    skin: skin,
                    onBack: certificate == null ? widget.onBack : _showList,
                  ),
                  const SizedBox(height: 1),
                  if (certificate != null)
                    CertificateArtwork(
                      certificate: certificate,
                      onShare: () => _shareOnLinkedIn(certificate),
                      onDownload: () => _downloadPdf(certificate),
                      downloading: _downloadingPdf,
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
    final issuedCount = issuedCertificates.values
        .where(
          (certificate) =>
              modules.any((module) => module.id == certificate.moduleId),
        )
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NoirPanel(
          skin: skin,
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
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
                    '$issuedCount ISSUED',
                    style: LandingTokens.label(fontSize: 9, color: skin.faint),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Your verified work, ready to share, download, and validate from a public credential link.',
                style: TextStyle(color: skin.sub, height: 1.45),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stats = [
                    _CertificateStat(
                      label: 'COMPLETED',
                      value: '${modules.length}',
                      color: LandingTokens.signal,
                    ),
                    _CertificateStat(
                      label: 'ISSUED',
                      value: '$issuedCount',
                      color: LandingTokens.circuit,
                    ),
                    _CertificateStat(
                      label: 'READY',
                      value: '${modules.length - issuedCount}',
                      color: LandingTokens.ember,
                    ),
                  ];
                  if (constraints.maxWidth < 520) {
                    return Row(
                      children: [
                        for (final stat in stats)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: stat == stats.last ? 0 : 8,
                              ),
                              child: stat,
                            ),
                          ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      for (final stat in stats) ...[
                        SizedBox(width: 156, child: stat),
                        if (stat != stats.last) const SizedBox(width: 10),
                      ],
                    ],
                  );
                },
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
        const SizedBox(height: 1),
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
            if (module != modules.last) const SizedBox(height: 1),
          ],
      ],
    );
  }
}

class _CertificateStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CertificateStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final skin = NoirSkin.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.28)),
        borderRadius: LandingTokens.smallRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: LandingTokens.mono(
              fontSize: 18,
              color: skin.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: LandingTokens.label(fontSize: 8, color: color)),
        ],
      ),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 560) {
            return _MobileCertificateModuleContent(
              skin: skin,
              module: module,
              issued: issued,
              busy: busy,
              enabled: enabled,
              onIssue: onIssue,
            );
          }
          return Row(
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
                      style: LandingTokens.label(
                        fontSize: 9,
                        color: skin.faint,
                      ),
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
          );
        },
      ),
    );
  }
}

class _MobileCertificateModuleContent extends StatelessWidget {
  final NoirSkin skin;
  final CurriculumModule module;
  final bool issued;
  final bool busy;
  final bool enabled;
  final VoidCallback onIssue;

  const _MobileCertificateModuleContent({
    required this.skin,
    required this.module,
    required this.issued,
    required this.busy,
    required this.enabled,
    required this.onIssue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(width: 12),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: GradientButton(
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
        ),
      ],
    );
  }
}

/// The responsive terminal-noir certificate used by both the learner and
/// public verification views. Keeping this facade preserves the established
/// screen API while the artwork itself lives in its focused component.
class CertificateArtwork extends CertificateDisplayEnhanced {
  const CertificateArtwork({
    super.key,
    required super.certificate,
    required super.onShare,
    super.onDownload,
    super.downloading = false,
    required super.onBack,
  });
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
  bool _downloadingPdf = false;

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
    var launched = false;
    try {
      launched = await launchUrl(
        CertificateLink.linkedinShareUrl(widget.certificateId),
        mode: LaunchMode.externalApplication,
      );
    } catch (error) {
      debugPrint('LinkedIn share failed: $error');
    }
    if (!launched && mounted) {
      showNoirSnack(context, 'LinkedIn could not be opened.', success: false);
    }
  }

  Future<void> _downloadPdf(ModuleCertificate certificate) async {
    if (_downloadingPdf) return;
    setState(() => _downloadingPdf = true);
    try {
      final started = await CertificatePdf.download(certificate);
      if (mounted) {
        showNoirSnack(
          context,
          started
              ? 'Certificate PDF download started.'
              : 'Certificate PDF download was cancelled.',
          success: started,
        );
      }
    } catch (error) {
      debugPrint('Public certificate PDF download failed: $error');
      if (mounted) {
        showNoirSnack(
          context,
          'Could not create the certificate PDF. Please try again.',
          success: false,
        );
      }
    } finally {
      if (mounted) setState(() => _downloadingPdf = false);
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
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NoirHeader(
                    title: 'Certificate Verification',
                    eyebrow: 'Public verification record',
                    skin: skin,
                    onBack: widget.onBack,
                  ),
                  const SizedBox(height: 1),
                  if (certificate != null)
                    CertificateArtwork(
                      certificate: certificate,
                      onShare: _share,
                      onDownload: () => _downloadPdf(certificate),
                      downloading: _downloadingPdf,
                      onBack: widget.onBack,
                    )
                  else if (_error == null)
                    const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(child: CircularProgressIndicator()),
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
        ],
      ),
    );
  }
}
