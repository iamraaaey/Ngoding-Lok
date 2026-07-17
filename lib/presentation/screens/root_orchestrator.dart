import 'package:flutter/material.dart';
import '../../core/curriculum/curriculum.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/curriculum/language_track.dart';
import '../../core/curriculum/module_type.dart';
import '../../core/ads/adsense_rewarded.dart';
import '../../core/ads/rewarded_ad_service.dart';
import '../../core/session/api_service.dart';
import '../../core/session/app_route.dart';
import '../../core/session/google_auth_service.dart';
import '../../core/session/leaderboard.dart';
import '../../core/session/user_session.dart';
import '../../core/session/session_persistence.dart';
import 'arduino_simulator_screen.dart';
import 'auth_screen.dart';
import 'code_golf_screen.dart';
import 'cybersecurity_room_screen.dart';
import 'dashboard_screen.dart';
import 'forgot_password_screen.dart';
import 'grid_game_screen.dart';
import 'home_dashboard_screen.dart';
import 'landing_screen.dart';
import 'league_map_screen.dart';
import 'profile_screen.dart';
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
  UserSession? _user;
  CurriculumModule? _activeModule;

  late final RewardedAdService _rewardedAdService;

  /// Streak the player starts a fresh session with. There's no day-tracking
  /// backend in this prototype, so this stands in for a returning player's
  /// run rather than being computed from real login dates.
  static const int _seededStreak = 3;

  @override
  void initState() {
    super.initState();
    _rewardedAdService = RewardedAdService()..initialize();
    _loadPersistedSession();
  }

  @override
  void dispose() {
    _rewardedAdService.dispose();
    super.dispose();
  }

  Future<void> _loadPersistedSession() async {
    final session = await SessionPersistence.loadSession();
    if (session != null && mounted) {
      setState(() {
        _user = session;
        _route = AppRoute.home;
        _splashDone = true;
      });
    }
  }

  void _updateUser(UserSession? user) {
    setState(() {
      _user = user;
    });
    if (user != null) {
      SessionPersistence.saveSession(user);
    } else {
      SessionPersistence.clearSession();
    }
  }

  void _login(String email, {String? name, String? photoUrl}) {
    final session = UserSession(
      email: email,
      name: name,
      photoUrl: photoUrl,
      streak: _seededStreak,
    );
    _updateUser(session);
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

  /// Runs the fake XP-sync API, updates the session, then automatically
  /// launches the next module in the track (if any) directly without displaying ads.
  Future<void> _handleModuleWin({
    required int linesUsed,
    required int executionMs,
  }) async {
    final module = _activeModule!;
    final result = await ApiService.syncLevelComplete(
      baseXp: module.xpReward,
      linesUsed: linesUsed,
      executionMs: executionMs,
    );

    final updated = _user!.withModuleCompleted(module.id, result.finalScore);
    _updateUser(updated);

    final trackModules = Curriculum.modulesForTrack(module.track);
    final index = trackModules.indexOf(module);
    final nextModule = (index >= 0 && index < trackModules.length - 1)
        ? trackModules[index + 1]
        : null;

    setState(() {
      if (nextModule != null) {
        _activeModule = nextModule;
        _route = AppRoute.game;
      } else {
        _activeModule = null;
        _route = AppRoute.home;
      }
    });
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
        );

      case AppRoute.home:
        return HomeDashboardScreen(
          user: _user!,
          nextModule: _nextModule,
          onResume: _launchModule,
          onOpenMap: () => setState(() => _route = AppRoute.leagueMap),
          onOpenCodeGolf: () => setState(() => _route = AppRoute.codeGolf),
          onOpenProfile: () => setState(() => _route = AppRoute.profile),
          onOpenSettings: () => setState(() => _route = AppRoute.settings),
          onLogout: _logout,
        );

      case AppRoute.codeGolf:
        return CodeGolfScreen(
          user: _user!,
          onBack: () => setState(() => _route = AppRoute.home),
        );

      case AppRoute.profile:
        return ProfileScreen(
          user: _user!,
          onPurchaseStreakFreeze: _purchaseStreakFreeze,
          onBack: () => setState(() => _route = AppRoute.home),
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
        );

      case AppRoute.dashboard:
        return DashboardScreen(
          user: _user!,
          leaderboard: Leaderboard.withUser(_user!),
          onLogout: _logout,
          onLaunchModule: _launchModule,
          onBack: () => setState(() => _route = AppRoute.home),
        );

      case AppRoute.game:
        return _buildGameScreen(_activeModule!);
    }
  }
}
