import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'presentation/screens/root_orchestrator.dart';

void main() => runApp(const NgeCodeJuhApp());

class NgeCodeJuhApp extends StatelessWidget {
  const NgeCodeJuhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NgeCode Juh!',
      theme: appTheme,
      home: const RootOrchestrator(),
    );
  }
}
