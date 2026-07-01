import 'package:flutter/material.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/curriculum/module_type.dart';
import '../../core/session/api_service.dart';
import '../../core/session/app_route.dart';
import '../../core/session/leaderboard.dart';
import '../../core/session/user_session.dart';
import 'ad_screen.dart';
import 'auth_screen.dart';
import 'dashboard_screen.dart';
import 'grid_game_screen.dart';
import 'landing_screen.dart';
import 'rocket_game_screen.dart';
import 'splash_screen.dart';
import 'sql_game_screen.dart';

/// Single state-machine owner for the whole app, mirroring the prototype's
/// `App` component: one `_route` enum + shared `_user`/`_activeModule`/
/// ad-flow state that every screen reads/mutates through. There's no
/// meaningful back-stack here (the ad screen "returns" to wherever
/// `onComplete` decides, not to nav history), so a `Navigator` would just
/// fight this shape rather than fit it.
class RootOrchestrator extends StatefulWidget {
  const RootOrchestrator({super.key});

  @override
  State<RootOrchestrator> createState() => _RootOrchestratorState();
}

class _RootOrchestratorState extends State<RootOrchestrator> {
  bool _splashDone = false;
  AppRoute _route = AppRoute.landing;
  UserSession? _user;
  CurriculumModule? _activeModule;

  bool _adIsRewarded = false;
  VoidCallback? _onAdComplete;

  void _login(String email) {
    setState(() {
      _user = UserSession(email: email);
      _route = AppRoute.dashboard;
    });
  }

  void _logout() {
    setState(() {
      _user = null;
      _route = AppRoute.auth;
    });
  }

  void _launchModule(CurriculumModule module) {
    setState(() {
      _activeModule = module;
      _route = AppRoute.game;
    });
  }

  void _backToDashboard() {
    setState(() {
      _activeModule = null;
      _route = AppRoute.dashboard;
    });
  }

  /// Pauses the active game screen (which stays mounted under a Stack
  /// overlay, see [build]) and shows the rewarded-ad screen. On completion,
  /// grants the hint and returns to the game route.
  void _requestHintAd({required VoidCallback onGranted}) {
    setState(() {
      _adIsRewarded = true;
      _onAdComplete = () {
        onGranted();
        setState(() => _route = AppRoute.game);
      };
      _route = AppRoute.ad;
    });
  }

  /// Runs the fake XP-sync API, updates the session, then shows the
  /// non-rewarded interstitial ad before returning to the dashboard.
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

    setState(() => _user = _user!.withModuleCompleted(module.id, result.finalScore));
    setState(() {
      _adIsRewarded = false;
      _onAdComplete = _backToDashboard;
      _route = AppRoute.ad;
    });
  }

  Widget _buildGameScreen(CurriculumModule module) {
    switch (module.type) {
      case ModuleType.logicGrid:
        return GridGameScreen(
          module: module,
          onRequestHintAd: _requestHintAd,
          onWin: _handleModuleWin,
          onBack: _backToDashboard,
        );
      case ModuleType.sqlTerminal:
        return SqlGameScreen(
          module: module,
          onRequestHintAd: _requestHintAd,
          onWin: _handleModuleWin,
          onBack: _backToDashboard,
        );
      case ModuleType.rocketFlight:
        return RocketGameScreen(
          module: module,
          onRequestHintAd: _requestHintAd,
          onWin: _handleModuleWin,
          onBack: _backToDashboard,
        );
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
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.965, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(_route),
        child: _buildCurrentRoute(),
      ),
    );
  }

  Widget _buildCurrentRoute() {
    switch (_route) {
      case AppRoute.landing:
        return LandingScreen(onGetStarted: () => setState(() => _route = AppRoute.auth));

      case AppRoute.auth:
        return AuthScreen(
          onLogin: _login,
          onBack: () => setState(() => _route = AppRoute.landing),
        );

      case AppRoute.dashboard:
        return DashboardScreen(
          user: _user!,
          leaderboard: Leaderboard.withUser(_user!),
          onLogout: _logout,
          onLaunchModule: _launchModule,
        );

      case AppRoute.game:
        return _buildGameScreen(_activeModule!);

      case AppRoute.ad:
        // The game screen is kept mounted underneath the ad overlay for
        // the hint-ad flow so its in-progress code/timer/hint state
        // survives the interruption. The win-flow interstitial also
        // routes through here, but its onComplete discards _activeModule
        // and returns to the dashboard, so there's nothing to preserve.
        return Stack(
          children: [
            if (_activeModule != null) _buildGameScreen(_activeModule!),
            AdScreen(isRewarded: _adIsRewarded, onComplete: _onAdComplete!),
          ],
        );
    }
  }
}
