import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'presentation/screens/root_orchestrator.dart';

void main() => runApp(const NgeCodeJuhApp());

/// Scrolling still works everywhere (mouse wheel, touch, trackpad) — this
/// only hides the draggable scrollbar rail that Flutter shows by default on
/// web/desktop, so short and tall screens render identically instead of the
/// rail appearing only on whichever ones are currently tall enough to scroll.
class _NoScrollbarBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) => child;
}

class NgeCodeJuhApp extends StatefulWidget {
  const NgeCodeJuhApp({super.key});

  @override
  State<NgeCodeJuhApp> createState() => _NgeCodeJuhAppState();
}

class _NgeCodeJuhAppState extends State<NgeCodeJuhApp> {
  // App-wide preferences, flipped from the Settings screen. Session-only (no
  // persistence), matching the rest of this prototype's in-memory state.
  bool _darkMode = true;
  bool _soundEnabled = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NgeCode Juh!',
      debugShowCheckedModeBanner: false,
      scrollBehavior: _NoScrollbarBehavior(),
      theme: appLightTheme,
      darkTheme: appTheme,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: RootOrchestrator(
        darkMode: _darkMode,
        soundEnabled: _soundEnabled,
        onSetDarkMode: (v) => setState(() => _darkMode = v),
        onSetSound: (v) => setState(() => _soundEnabled = v),
      ),
    );
  }
}
