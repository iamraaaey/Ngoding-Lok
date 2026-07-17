import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/curriculum/curriculum.dart';
import 'package:ngecode_juh/core/session/leaderboard.dart';
import 'package:ngecode_juh/core/session/user_session.dart';
import 'package:ngecode_juh/presentation/screens/arduino_simulator_screen.dart';
import 'package:ngecode_juh/presentation/screens/auth_screen.dart';
import 'package:ngecode_juh/presentation/screens/code_golf_screen.dart';
import 'package:ngecode_juh/presentation/screens/cybersecurity_room_screen.dart';
import 'package:ngecode_juh/presentation/screens/dashboard_screen.dart';
import 'package:ngecode_juh/presentation/screens/forgot_password_screen.dart';
import 'package:ngecode_juh/presentation/screens/grid_game_screen.dart';
import 'package:ngecode_juh/presentation/screens/home_dashboard_screen.dart';
import 'package:ngecode_juh/presentation/screens/league_map_screen.dart';
import 'package:ngecode_juh/presentation/screens/landing_screen.dart';
import 'package:ngecode_juh/presentation/screens/profile_screen.dart';
import 'package:ngecode_juh/presentation/screens/rocket_game_screen.dart';
import 'package:ngecode_juh/presentation/screens/settings_screen.dart';
import 'package:ngecode_juh/presentation/screens/signup_screen.dart';
import 'package:ngecode_juh/presentation/screens/splash_screen.dart';
import 'package:ngecode_juh/presentation/screens/sql_game_screen.dart';

final _user = UserSession(email: 'detective@example.com', name: 'Detective');

Future<void> _pumpScreen(WidgetTester tester, Widget screen, Size size) async {
  await tester.binding.setSurfaceSize(size);
  await tester.pumpWidget(MaterialApp(home: screen));
  await tester.pump(const Duration(milliseconds: 250));
  final exception = tester.takeException();
  expect(
    exception,
    isNull,
    reason: '${screen.runtimeType} overflowed at ${size.width}x${size.height}',
  );
}

Widget _game(Widget child) => child;

void main() {
  final sizes = <Size>[
    const Size(320, 640),
    const Size(360, 800),
    const Size(768, 1024),
    const Size(1440, 900),
    const Size(1920, 1080),
  ];
  final screens = <String, Widget Function()>{
    'landing': () => LandingScreen(onGetStarted: () {}, onSignUp: () {}),
    'splash': () => SplashScreen(onComplete: () {}),
    'auth': () => AuthScreen(
      onLogin: (_, {name, photoUrl}) {},
      onBack: () {},
      onCreateAccount: () {},
      onForgotPassword: () {},
    ),
    'sign up': () => SignUpScreen(
      onRegister: (_, {name, photoUrl}) {},
      onBackToLogin: () {},
    ),
    'forgot password': () => ForgotPasswordScreen(
      onBackToLogin: () {},
      onSendResetLink: (_) async {},
    ),
    'home': () => HomeDashboardScreen(
      user: _user,
      nextModule: Curriculum.byId('m1'),
      onResume: (_) {},
      onOpenMap: () {},
      onOpenCodeGolf: () {},
      onOpenProfile: () {},
      onOpenSettings: () {},
      onLogout: () {},
    ),
    'dashboard': () => DashboardScreen(
      user: _user,
      leaderboard: Leaderboard.withUser(_user),
      onLogout: () {},
      onLaunchModule: (_) {},
      onBack: () {},
    ),
    'league map': () =>
        LeagueMapScreen(user: _user, onLaunch: (_) {}, onBack: () {}),
    'code golf': () => CodeGolfScreen(user: _user, onBack: () {}),
    'profile': () => ProfileScreen(
      user: _user,
      onPurchaseStreakFreeze: () => false,
      onBack: () {},
    ),
    'settings': () => SettingsScreen(
      user: _user,
      darkMode: true,
      soundEnabled: true,
      onSetDarkMode: (_) {},
      onSetSound: (_) {},
      onLogout: () {},
      onBack: () {},
    ),
    'grid game': () => _game(
      GridGameScreen(
        module: Curriculum.byId('m1'),
        onRequestHintAd: ({required onGranted, onCancelled}) {},
        onWin: ({required linesUsed, required executionMs}) async {},
        onBack: () {},
      ),
    ),
    'SQL game': () => _game(
      SqlGameScreen(
        module: Curriculum.byId('m2'),
        onRequestHintAd: ({required onGranted, onCancelled}) {},
        onWin: ({required linesUsed, required executionMs}) async {},
        onBack: () {},
      ),
    ),
    'rocket game': () => _game(
      RocketGameScreen(
        module: Curriculum.byId('m3'),
        onRequestHintAd: ({required onGranted, onCancelled}) {},
        onWin: ({required linesUsed, required executionMs}) async {},
        onBack: () {},
      ),
    ),
    'Arduino': () => ArduinoSimulatorScreen(
      module: Curriculum.byId('arduino-wokwi-starter'),
      onBack: () {},
    ),
    'cybersecurity room': () => CybersecurityRoomScreen(
      module: Curriculum.byId('cyber-warmup'),
      onWin: ({required linesUsed, required executionMs}) async {},
      onBack: () {},
      onProgressChanged: (_) {},
      onBadgeAwarded: (_) {},
    ),
  };

  testWidgets('primary screens render at phone, tablet, and desktop widths', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final entry in screens.entries) {
      for (final size in sizes) {
        await _pumpScreen(tester, entry.value(), size);
      }
    }
  });
}
