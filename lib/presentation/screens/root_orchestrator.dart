import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/curriculum/curriculum.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/curriculum/language_track.dart';
import '../../core/curriculum/module_type.dart';
import '../../core/ads/adsense_rewarded.dart';
import '../../core/ads/rewarded_ad_service.dart';
import '../../core/session/api_service.dart';
import '../../core/session/app_route.dart';
import '../../core/session/email_auth_service.dart';
import '../../core/session/google_auth_service.dart';
import '../../core/session/user_session.dart';
import '../../core/session/module_performance.dart';
import '../../core/session/session_persistence.dart';
import '../../core/social/certificate_link.dart';
import '../../core/social/referral_link.dart';
import '../../data/repositories/user_repository.dart';
import 'arduino_simulator_screen.dart';
import 'auth_screen.dart';
import 'code_golf_screen.dart';
import 'certificates_screen.dart';
import 'cybersecurity_room_screen.dart';
import 'dashboard_screen.dart';
import 'forgot_password_screen.dart';
import 'friends_screen.dart';
import 'grid_game_screen.dart';
import 'home_dashboard_screen.dart';
import 'landing_screen.dart';
import 'league_map_screen.dart';
import 'profile_screen.dart';
import 'performance_report_screen.dart';
import 'rocket_game_screen.dart';
import 'settings_screen.dart';
import 'signup_screen.dart';
import 'splash_screen.dart';
import 'sql_game_screen.dart';

/// Single state-machine owner for the whole app, mirroring the prototype's
/// `App` component: one `_route` enum + shared `_user`/`_activeModule`/
/// ad-flow state that every screen reads/mutates through. There's no
/// meaningful back-stack here (the ad screen "returns" to wherever
/// `onComplete` decides, not to nav history), so a `Navigator` would just
/// fight this shape rather than fit it.
class RootOrchestrator extends StatefulWidget {
  /// App-wide theme + sound preferences, owned by [NgeCodeJuhApp] so the theme
  /// switch can rebuild the whole [MaterialApp]. Threaded down to the Settings
  /// screen, which flips them via the callbacks.
  final bool darkMode;
  final bool soundEnabled;
  final ValueChanged<bool> onSetDarkMode;
  final ValueChanged<bool> onSetSound;

  const RootOrchestrator({
    super.key,
    required this.darkMode,
    required this.soundEnabled,
    required this.onSetDarkMode,
    required this.onSetSound,
  });

  @override
  State<RootOrchestrator> createState() => _RootOrchestratorState();
}

class _RootOrchestratorState extends State<RootOrchestrator> {
  bool _splashDone = false;
  AppRoute _route = AppRoute.landing;
  String? _publicCertificateId;
  UserSession? _user;
  CurriculumModule? _activeModule;
  LanguageTrack _leagueMapTrack = LanguageTrack.python;

  late final RewardedAdService _rewardedAdService;
  late final UserRepository _userRepository;
  StreamSubscription<UserSession?>? _userSyncSubscription;

  @override
  void initState() {
    super.initState();
    _publicCertificateId = CertificateLink.certificateIdFromLaunchUrl();
    if (_publicCertificateId != null) _route = AppRoute.publicCertificate;
    _userRepository = UserRepository();
    _rewardedAdService = RewardedAdService()..initialize();
    _loadPersistedSession();
  }

  @override
  void dispose() {
    _userSyncSubscription?.cancel();
    _rewardedAdService.dispose();
    super.dispose();
  }

  Future<void> _loadPersistedSession() async {
    if (_publicCertificateId != null) return;
    final currentUser = _firebaseUser;
    final cachedSession = await SessionPersistence.loadSession();

    // A local cache is not an account. Old demo sessions must never reopen the
    // learning hub without a live Firebase identity.
    if (currentUser == null) {
      await SessionPersistence.clearSession();
      return;
    }

    var restored =
        cachedSession ??
        UserSession(
          email: currentUser.email ?? currentUser.uid,
          name: currentUser.displayName,
          photoUrl: currentUser.photoURL,
        );
    try {
      restored = await _userRepository.syncUserSession(
        currentUser.uid,
        restored,
      );
      restored = await _userRepository.recordActivity(currentUser.uid);
    } catch (error) {
      // Keep the authenticated UI usable during a transient Firestore outage;
      // the real Firebase identity still remains the gate.
      debugPrint('Firestore restore failed: $error');
      restored = restored.withActivity();
    }
    if (!mounted) return;
    _startUserSync(currentUser.uid);
    setState(() {
      _user = restored;
      _route = AppRoute.home;
      _splashDone = true;
    });
    await SessionPersistence.saveSession(restored);
    unawaited(_maybeRedeemPendingReferral(currentUser.uid, restored));
  }

  /// Completes an invite-link referral (`?ref=CODE` on the hosted web app)
  /// once the invitee is signed in and their Firestore profile exists.
  /// Best-effort: failures surface as a snack and never block navigation.
  Future<void> _maybeRedeemPendingReferral(
    String uid,
    UserSession session,
  ) async {
    if (session.referralRewardClaimed) {
      ReferralLink.consumePendingCode();
      return;
    }
    final code = ReferralLink.consumePendingCode();
    if (code == null || code == _userRepository.referralCodeForUid(uid)) {
      return;
    }
    try {
      final updated = await _userRepository.redeemReferralCode(uid, code);
      _updateUser(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Referral applied — you and your friend each earned +50 XP.',
          ),
        ),
      );
    } on ReferralException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      debugPrint('Referral auto-redeem failed: $error');
    }
  }

  User? get _firebaseUser {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  void _startUserSync(String uid) {
    _userSyncSubscription?.cancel();
    _userSyncSubscription = _userRepository.streamUserFromFirestore(uid).listen(
      (remoteUser) {
        if (!mounted || remoteUser == null) return;
        setState(() => _user = remoteUser);
        SessionPersistence.saveSession(remoteUser);
      },
      onError: (Object error) =>
          debugPrint('Firestore user stream failed: $error'),
    );
  }

  void _updateUser(UserSession? user, {bool syncRemote = true}) {
    setState(() {
      _user = user;
    });
    if (user != null) {
      SessionPersistence.saveSession(user);
      // Sync to Firestore if user is authenticated
      final currentUser = _firebaseUser;
      if (currentUser != null && syncRemote) {
        _userRepository
            .saveUserToFirestore(user, currentUser.uid)
            .catchError(
              (e) => debugPrint('Failed to sync user to Firestore: $e'),
            );
      }
    } else {
      SessionPersistence.clearSession();
    }
  }

  void _login(String email, {String? name, String? photoUrl}) async {
    final currentUser = _firebaseUser;
    if (currentUser == null) {
      if (mounted) {
        setState(() => _route = AppRoute.auth);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Create or sign in to your account first.'),
          ),
        );
      }
      return;
    }

    var session = UserSession(
      email: email,
      name: name,
      photoUrl: photoUrl,
    ).withActivity();

    try {
      final mergedSession = await _userRepository.syncUserSession(
        currentUser.uid,
        session,
      );
      UserSession activeSession;
      try {
        activeSession = await _userRepository.recordActivity(currentUser.uid);
      } catch (error) {
        debugPrint('Activity sync failed during sign-in: $error');
        activeSession = mergedSession;
      }
      _updateUser(activeSession, syncRemote: false);
      _startUserSync(currentUser.uid);
      unawaited(_maybeRedeemPendingReferral(currentUser.uid, activeSession));
    } catch (error) {
      debugPrint('Firestore sync failed after authenticated sign-in: $error');
      _updateUser(session, syncRemote: true);
    }

    if (!mounted) return;
    setState(() {
      _route = AppRoute.home;
    });
  }

  /// The next puzzle to resume: the first uncleared lesson in the public
  /// track order, then in that track's explicit lesson order.
  CurriculumModule? get _nextModule {
    for (final track in LanguageTrack.values) {
      for (final module in Curriculum.modulesForTrack(track)) {
        if (!_user!.completedModuleIds.contains(module.id)) return module;
      }
    }
    return null;
  }

  void _logout() {
    _userSyncSubscription?.cancel();
    _userSyncSubscription = null;
    GoogleAuthService.signOut(); // fire-and-forget; no-op for email sessions
    _updateUser(null);
    setState(() {
      _route = AppRoute.auth;
    });
  }

  void _launchModule(CurriculumModule module) {
    setState(() {
      _activeModule = module;
      _route = AppRoute.game;
    });
  }

  /// Returns from a game (win or quit) to the Home hub, so the player lands
  /// back on an up-to-date view of their XP, streak, league, and next puzzle.
  void _returnToHub() {
    setState(() {
      _activeModule = null;
      _route = AppRoute.home;
    });
  }

  /// Spends XP to buy a Streak Freeze from the Profile screen. Returns false
  /// (leaving state untouched) when the player can't afford it, so the screen
  /// can surface the right message.
  bool _purchaseStreakFreeze() {
    const cost = ProfileScreen.streakFreezeCost;
    if (_user!.xp < cost) return false;
    final updated = _user!.copyWith(
      xp: _user!.xp - cost,
      streakFreezes: _user!.streakFreezes + 1,
    );
    _updateUser(updated);
    return true;
  }

  /// Gates every hint behind a real rewarded ad wherever a network is
  /// available: AdMob on Android/iOS, the AdSense Ad Placement API on web.
  /// Every hint is gated by a real rewarded placement. Native builds use the
  /// AdMob full-screen overlay; web builds use the AdSense H5 Games placement.
  /// There is deliberately no simulated sponsor card in the production flow.
  void _requestHintAd({
    required VoidCallback onGranted,
    VoidCallback? onCancelled,
  }) {
    if (RewardedAdService.isSupported) {
      _rewardedAdService.showRewardedAd(
        onLoading: () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Preparing your rewarded hint...')),
          );
        },
        onRewarded: onGranted,
        onUnavailable: (message) {
          onCancelled?.call();
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
      );
      return;
    }

    _requestWebRewardedAd(onGranted, onCancelled);
  }

  Future<void> _requestWebRewardedAd(
    VoidCallback onGranted,
    VoidCallback? onCancelled,
  ) async {
    // Debug mode: skip ads and go straight to hint when in development.
    const bool kDebugHintFlow = bool.fromEnvironment(
      'DEBUG_HINT_FLOW',
      defaultValue: false,
    );
    if (kDebugHintFlow) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('[DEBUG] Ad skipped, requesting hint...')),
      );
      onGranted();
      return;
    }

    if (!AdSenseRewarded.isConfigured) {
      _showAdUnavailable(
        'Live rewarded ads are not configured for this build.',
        onCancelled,
      );
      return;
    }

    final available = await AdSenseRewarded.waitUntilAvailable();
    if (!mounted) return;
    if (!available) {
      _showAdUnavailable(
        'No live rewarded ad is available right now.',
        onCancelled,
      );
      return;
    }

    AdSenseRewarded.showRewardedAd(
      onRewarded: onGranted,
      onDismissed: onCancelled,
      onUnavailable: (message) => _showAdUnavailable(message, onCancelled),
    );
  }

  void _showAdUnavailable(String message, VoidCallback? onCancelled) {
    onCancelled?.call();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Runs the fake XP-sync API and updates the session. Cybersecurity rooms
  /// return to their League Map tab; the other tracks keep auto-progression.
  Future<void> _handleModuleWin({
    required int linesUsed,
    required int executionMs,
    String? sourceCode,
  }) async {
    final module = _activeModule!;
    final result = await ApiService.syncLevelComplete(
      baseXp: module.xpReward,
      linesUsed: linesUsed,
      executionMs: executionMs,
      moduleId: module.id,
    );

    final currentUser = _firebaseUser;
    UserSession updated;
    if (currentUser != null) {
      try {
        updated = await _userRepository.recordModuleCompletion(
          uid: currentUser.uid,
          user: _user!,
          module: module,
          score: result.finalScore,
          linesUsed: linesUsed,
          executionMs: executionMs,
          source: sourceCode ?? '',
        );
        _updateUser(updated, syncRemote: false);
      } catch (error) {
        debugPrint('Module completion sync failed: $error');
        updated = _recordLocalCompletion(
          _user!,
          module,
          result.finalScore,
          linesUsed,
          executionMs,
        );
        _updateUser(updated);
      }
    } else {
      updated = _recordLocalCompletion(
        _user!,
        module,
        result.finalScore,
        linesUsed,
        executionMs,
      );
      _updateUser(updated);
    }

    setState(() {
      if (module.track == LanguageTrack.cybersecurity) {
        _activeModule = null;
        _leagueMapTrack = LanguageTrack.cybersecurity;
        _route = AppRoute.leagueMap;
      } else {
        final trackModules = Curriculum.modulesForTrack(module.track);
        final index = trackModules.indexOf(module);
        final nextModule = (index >= 0 && index < trackModules.length - 1)
            ? trackModules[index + 1]
            : null;
        if (nextModule != null) {
          _activeModule = nextModule;
          _route = AppRoute.game;
        } else {
          _activeModule = null;
          _route = AppRoute.home;
        }
      }
    });
  }

  UserSession _recordLocalCompletion(
    UserSession user,
    CurriculumModule module,
    int score,
    int linesUsed,
    int executionMs,
  ) {
    final currentScore = user.moduleScores[module.id];
    final bestScore = currentScore == null || score > currentScore
        ? score
        : currentScore;
    final performance = user.modulePerformance[module.id];
    final better =
        performance == null ||
        score > performance.score ||
        (score == performance.score && executionMs < performance.executionMs);
    final now = DateTime.now();
    final nextPerformance = better
        ? ModulePerformance(
            score: bestScore,
            linesUsed: linesUsed,
            executionMs: executionMs,
            accuracy: (score / module.xpReward).clamp(0.0, 1.0),
            attempts: (performance?.attempts ?? 0) + 1,
            firstCompletedAt: performance?.firstCompletedAt ?? now,
            lastCompletedAt: now,
          )
        : performance.copyWith(
            score: bestScore,
            attempts: performance.attempts + 1,
            lastCompletedAt: now,
          );
    final next = user.withActivity();
    return next.copyWith(
      xp:
          user.xp +
          (currentScore == null
              ? score
              : (score - currentScore).clamp(0, score).toInt()),
      completedModuleIds: [
        ...user.completedModuleIds,
        if (!user.completedModuleIds.contains(module.id)) module.id,
      ],
      moduleScores: {...user.moduleScores, module.id: bestScore},
      modulePerformance: {
        ...user.modulePerformance,
        module.id: nextPerformance,
      },
    );
  }

  Widget _buildGameScreen(CurriculumModule module) {
    switch (module.type) {
      case ModuleType.logicGrid:
        return GridGameScreen(
          module: module,
          onRequestHintAd: _requestHintAd,
          onWin: _handleModuleWin,
          onBack: _returnToHub,
        );
      case ModuleType.sqlTerminal:
        return SqlGameScreen(
          module: module,
          onRequestHintAd: _requestHintAd,
          onWin: _handleModuleWin,
          onBack: _returnToHub,
        );
      case ModuleType.rocketFlight:
        return RocketGameScreen(
          module: module,
          onRequestHintAd: _requestHintAd,
          onWin: _handleModuleWin,
          onBack: _returnToHub,
        );
      case ModuleType.cybersecurityRoom:
        return CybersecurityRoomScreen(
          module: module,
          onWin: _handleModuleWin,
          onBack: _returnToHub,
          savedProgress: _user!.cyberRoomProgress[module.id],
          onProgressChanged: (progress) =>
              _updateUser(_user!.withCyberRoomProgress(module.id, progress)),
          onBadgeAwarded: (badge) => _updateUser(_user!.withBadge(badge)),
        );
      case ModuleType.arduinoSimulator:
        return ArduinoSimulatorScreen(module: module, onBack: _returnToHub);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show animated splash once on first launch.
    if (!_splashDone) {
      return SplashScreen(onComplete: () => setState(() => _splashDone = true));
    }

    // Wrap every route in a smooth fade+scale transition.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      transitionBuilder: (child, animation) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.965, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(key: ValueKey(_route), child: _buildRoute(_route)),
    );
  }

  Widget _buildRoute(AppRoute route) {
    final publicRoute =
        route == AppRoute.landing ||
        route == AppRoute.auth ||
        route == AppRoute.signup ||
        route == AppRoute.forgotPassword ||
        route == AppRoute.publicCertificate;
    if (_user == null && !publicRoute) {
      return AuthScreen(
        onLogin: _login,
        onBack: () => setState(() => _route = AppRoute.landing),
        onCreateAccount: () => setState(() => _route = AppRoute.signup),
        onForgotPassword: () =>
            setState(() => _route = AppRoute.forgotPassword),
      );
    }
    switch (route) {
      case AppRoute.landing:
        return LandingScreen(
          onGetStarted: () => setState(() => _route = AppRoute.auth),
          onSignUp: () => setState(() => _route = AppRoute.signup),
        );

      case AppRoute.auth:
        return AuthScreen(
          onLogin: _login,
          onBack: () => setState(() => _route = AppRoute.landing),
          onCreateAccount: () => setState(() => _route = AppRoute.signup),
          onForgotPassword: () =>
              setState(() => _route = AppRoute.forgotPassword),
        );

      case AppRoute.signup:
        return SignUpScreen(
          onRegister: _login,
          onBackToLogin: () => setState(() => _route = AppRoute.auth),
        );

      case AppRoute.forgotPassword:
        return ForgotPasswordScreen(
          onBackToLogin: () => setState(() => _route = AppRoute.auth),
          onSendResetLink: EmailAuthService.sendPasswordResetLink,
        );

      case AppRoute.home:
        return HomeDashboardScreen(
          user: _user!,
          nextModule: _nextModule,
          onResume: _launchModule,
          onOpenMap: () => setState(() {
            _leagueMapTrack = LanguageTrack.python;
            _route = AppRoute.leagueMap;
          }),
          onOpenCodeGolf: () => setState(() => _route = AppRoute.codeGolf),
          onOpenProfile: () => setState(() => _route = AppRoute.profile),
          onOpenFriends: () => setState(() => _route = AppRoute.friends),
          onOpenCertificates: () =>
              setState(() => _route = AppRoute.certificates),
          onOpenReport: () =>
              setState(() => _route = AppRoute.performanceReport),
          onOpenSettings: () => setState(() => _route = AppRoute.settings),
          onLogout: _logout,
        );

      case AppRoute.codeGolf:
        return CodeGolfScreen(
          user: _user!,
          uid: _firebaseUser?.uid,
          repository: _userRepository,
          onBack: () => setState(() => _route = AppRoute.home),
        );

      case AppRoute.profile:
        return ProfileScreen(
          user: _user!,
          uid: _firebaseUser?.uid,
          repository: _userRepository,
          onPurchaseStreakFreeze: _purchaseStreakFreeze,
          onOpenFriends: () => setState(() => _route = AppRoute.friends),
          onOpenCertificates: () =>
              setState(() => _route = AppRoute.certificates),
          onBack: () => setState(() => _route = AppRoute.home),
        );

      case AppRoute.friends:
        return FriendsScreen(
          user: _user!,
          uid: _firebaseUser?.uid,
          repository: _userRepository,
          onUserUpdated: _updateUser,
          onBack: () => setState(() => _route = AppRoute.home),
        );

      case AppRoute.certificates:
        return CertificatesScreen(
          user: _user!,
          uid: _firebaseUser?.uid,
          repository: _userRepository,
          onBack: () => setState(() => _route = AppRoute.home),
        );

      case AppRoute.publicCertificate:
        return PublicCertificateScreen(
          certificateId: _publicCertificateId!,
          repository: _userRepository,
          onBack: () => setState(() => _route = AppRoute.landing),
        );

      case AppRoute.settings:
        return SettingsScreen(
          user: _user!,
          darkMode: widget.darkMode,
          soundEnabled: widget.soundEnabled,
          onSetDarkMode: widget.onSetDarkMode,
          onSetSound: widget.onSetSound,
          onLogout: _logout,
          onBack: () => setState(() => _route = AppRoute.home),
        );

      case AppRoute.leagueMap:
        return LeagueMapScreen(
          user: _user!,
          onLaunch: _launchModule,
          onBack: () => setState(() => _route = AppRoute.home),
          initialTrack: _leagueMapTrack,
        );

      case AppRoute.dashboard:
        return DashboardScreen(
          user: _user!,
          uid: _firebaseUser?.uid,
          repository: _userRepository,
          onLogout: _logout,
          onLaunchModule: _launchModule,
          onBack: () => setState(() => _route = AppRoute.home),
        );

      case AppRoute.performanceReport:
        return PerformanceReportScreen(
          user: _user!,
          uid: _firebaseUser?.uid,
          repository: _userRepository,
          onBack: () => setState(() => _route = AppRoute.home),
        );

      case AppRoute.game:
        return _buildGameScreen(_activeModule!);
    }
  }
}
