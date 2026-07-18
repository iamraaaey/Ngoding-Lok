import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_theme.dart';
import 'core/session/app_preferences.dart';
import 'firebase_options.dart';
import 'presentation/screens/root_orchestrator.dart';

Future<void> main() async {
  // Render any startup failure on-screen instead of a blank white page. In a
  // release web build a thrown error during boot or first build otherwise
  // leaves an empty canvas with only a minified console trace.
  ErrorWidget.builder = (details) => _StartupErrorScreen(
    details.exceptionAsString(),
    details.stack?.toString(),
  );

  var bootCompleted = false;
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (error, stack) {
        // A Firebase failure should not blank the whole app; log and continue
        // so the UI still renders.
        debugPrint('Firebase.initializeApp failed: $error\n$stack');
      }
      runApp(const NgeCodeJuhApp());
      bootCompleted = true;
    },
    (error, stack) {
      debugPrint('Uncaught error: $error\n$stack');
      // Only replace the UI when boot itself failed. A stray async error
      // after a successful start (a failed share, an ad SDK hiccup) must not
      // tear down a running session with the full-screen error page.
      if (!bootCompleted) {
        runApp(_StartupErrorApp(error.toString(), stack.toString()));
      }
    },
  );
}

/// Scrolling still works everywhere (mouse wheel, touch, trackpad) — this
/// only hides the draggable scrollbar rail that Flutter shows by default on
/// web/desktop, so short and tall screens render identically instead of the
/// rail appearing only on whichever ones are currently tall enough to scroll.
class _NoScrollbarBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}

class NgeCodeJuhApp extends StatefulWidget {
  const NgeCodeJuhApp({super.key});

  @override
  State<NgeCodeJuhApp> createState() => _NgeCodeJuhAppState();
}

class _NgeCodeJuhAppState extends State<NgeCodeJuhApp> {
  // App-wide preferences, flipped from Settings and persisted locally.
  bool _darkMode = true;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final darkMode = await AppPreferences.loadDarkMode();
    final soundEnabled = await AppPreferences.loadSoundEnabled();
    if (!mounted) return;
    setState(() {
      _darkMode = darkMode ?? _darkMode;
      _soundEnabled = soundEnabled ?? _soundEnabled;
    });
  }

  void _setDarkMode(bool value) {
    setState(() => _darkMode = value);
    unawaited(AppPreferences.saveDarkMode(value));
  }

  void _setSoundEnabled(bool value) {
    setState(() => _soundEnabled = value);
    unawaited(AppPreferences.saveSoundEnabled(value));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ngoding Lok',
      debugShowCheckedModeBanner: false,
      scrollBehavior: _NoScrollbarBehavior(),
      theme: appLightTheme,
      darkTheme: appTheme,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: RootOrchestrator(
        darkMode: _darkMode,
        soundEnabled: _soundEnabled,
        onSetDarkMode: _setDarkMode,
        onSetSound: _setSoundEnabled,
      ),
    );
  }
}

/// Full-screen wrapper shown when the app fails to boot, so a startup crash is
/// visible and copyable instead of a blank page.
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp(this.message, this.stack);

  final String message;
  final String? stack;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: _StartupErrorScreen(message, stack),
  );
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen(this.message, this.stack);

  final String message;
  final String? stack;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: const Color(0xFF0A0A0B),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Startup error',
                  style: TextStyle(
                    color: Color(0xFFFF5C01),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(height: 16),
                SelectableText(
                  stack ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
