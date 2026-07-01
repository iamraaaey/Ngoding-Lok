import 'dart:async';
import 'package:flutter/foundation.dart';

/// Owns a 1-second periodic ticker and exposes elapsed seconds via a
/// [ValueNotifier] so widgets can listen with [ValueListenableBuilder]
/// without the owning State needing to `setState` on every tick. This is
/// the plain-Dart stand-in for the prototype's `useGameTimer` hook (Flutter
/// has no hooks): screens create one in `initState`, `start()`/`stop()` it
/// around gameplay and ad interruptions, and `dispose()` it in `dispose()`.
class GameTimerController {
  final ValueNotifier<int> elapsedSeconds = ValueNotifier<int>(0);
  Timer? _timer;

  bool get isRunning => _timer != null;

  void start() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value += 1;
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void reset() {
    stop();
    elapsedSeconds.value = 0;
  }

  void dispose() {
    stop();
    elapsedSeconds.dispose();
  }

  static String format(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
