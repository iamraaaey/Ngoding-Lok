import 'package:flutter/material.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/curriculum/module_config.dart';
import '../../core/interpreter/rocket_lexer.dart';
import '../../core/interpreter/rocket_parser.dart';
import '../../core/session/hint_service.dart';
import '../../core/state/rocket_state.dart';
import '../../core/timer/game_timer_controller.dart';
import '../theme/landing_tokens.dart';
import '../widgets/altitude_gauge.dart';
import '../widgets/code_editor.dart';
import '../widgets/console_log.dart';
import '../widgets/game_header.dart';
import '../widgets/hint_banner.dart';
import '../widgets/landing/landing_surface.dart';

/// Rocket-flight gameplay screen: tokenizes/parses the launch script and
/// steps through the resulting [RocketStep] queue against [RocketState],
/// mirroring [GridGameScreen]'s execution-loop shape.
class RocketGameScreen extends StatefulWidget {
  final CurriculumModule module;
  final void Function({
    required VoidCallback onGranted,
    VoidCallback? onCancelled,
  })
  onRequestHintAd;
  final Future<void> Function({
    required int linesUsed,
    required int executionMs,
    String? sourceCode,
  })
  onWin;
  final VoidCallback onBack;

  const RocketGameScreen({
    super.key,
    required this.module,
    required this.onRequestHintAd,
    required this.onWin,
    required this.onBack,
  });

  @override
  State<RocketGameScreen> createState() => _RocketGameScreenState();
}

class _RocketGameScreenState extends State<RocketGameScreen> {
  late final TextEditingController _codeController = TextEditingController(
    text: widget.module.initialCode,
  );
  final RocketLexer _lexer = RocketLexer();
  final List<String> _consoleLogs = [];
  final GameTimerController _timerController = GameTimerController();
  final HintService _hintService = HintService();

  late RocketState _state;
  bool _isSyncing = false;
  bool _hasHint = false;
  bool _isFetchingHint = false;
  String? _dynamicHintMessage;

  @override
  void initState() {
    super.initState();
    final config = widget.module.config as RocketFlightConfig;
    _state = RocketState(targetAltitude: config.targetAltitude);
    _timerController.start();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  void _log(String message) => setState(() => _consoleLogs.add(message));

  void _onGetHint() {
    _timerController.stop();
    widget.onRequestHintAd(
      onGranted: () {
        setState(() {
          _hasHint = true;
          _isFetchingHint = true;
        });
        _timerController.start();
        _loadDynamicHint();
      },
      onCancelled: () => _timerController.start(),
    );
  }

  Future<void> _loadDynamicHint() async {
    final result = await _hintService.fetchSocraticHint(
      moduleType: 'rocket_flight',
      levelObjective: widget.module.description,
      currentCode: _codeController.text,
    );
    if (!mounted) return;
    setState(() {
      _dynamicHintMessage = result?.hintMessage;
      _isFetchingHint = false;
    });
  }

  Future<void> _executeCode() async {
    if (_state.isExecuting) return;

    setState(() {
      _consoleLogs.clear();
      _state = _state.reset().copyWith(isExecuting: true);
    });
    _log('Initiating Launch Sequence...');

    final tokens = _lexer.tokenize(_codeController.text);
    final parser = RocketParser(targetAltitude: _state.targetAltitude);
    final steps = parser.run(tokens);

    for (final step in steps) {
      setState(() => _state = _state.copyWith(activeLineIndex: step.line - 1));
      await Future.delayed(const Duration(milliseconds: 500));

      switch (step.result) {
        case RocketResultType.preflightOk:
          setState(() => _state = _state.copyWith(preflightDone: true));
          _log('Preflight checks passed.');
          break;
        case RocketResultType.engineStarted:
          setState(() => _state = _state.copyWith(engineStarted: true));
          _log('Main engines ignited.');
          break;
        case RocketResultType.throttled:
          setState(() => _state = _state.copyWith(altitude: step.altitude));
          _log('Line ${step.line}: Thrust applied. Altitude ${step.altitude}m');
          break;
        case RocketResultType.exploded:
          setState(
            () => _state = _state.copyWith(
              exploded: true,
              altitude: step.altitude,
            ),
          );
          _log('CATASTROPHIC FAILURE: ${step.detail}');
          break;
        case RocketResultType.invalidThrottle:
        case RocketResultType.syntaxError:
          _log('Line ${step.line}: Error - ${step.detail}');
          break;
        case RocketResultType.goalReached:
          setState(
            () => _state = _state.copyWith(
              altitude: step.altitude,
              goalReached: true,
            ),
          );
          _log('ORBIT REACHED. Mission Success!');
          break;
      }
    }

    setState(
      () => _state = _state.copyWith(isExecuting: false, activeLineIndex: -1),
    );

    if (_state.goalReached) {
      _timerController.stop();
      setState(() => _isSyncing = true);
      final validLines = _codeController.text
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .length;
      await widget.onWin(
        linesUsed: validLines,
        executionMs: _timerController.elapsedSeconds.value * 1000,
        sourceCode: _codeController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LandingTokens.voidBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CinematicBackdrop(),
          SafeArea(
            child: Column(
              children: [
                GameHeader(
                  title: widget.module.title,
                  icon: Icons.rocket_launch,
                  timerController: _timerController,
                  hasHint: _hasHint,
                  isExecuting: _state.isExecuting,
                  isSyncing: _isSyncing,
                  onBack: widget.onBack,
                  onGetHint: _hasHint ? null : _onGetHint,
                  onRun: _executeCode,
                ),
                if (_hasHint)
                  HintBanner(
                    hint: _dynamicHintMessage ?? widget.module.hint,
                    isLoading: _isFetchingHint,
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: AltitudeGauge(state: _state),
                ),
                Expanded(
                  child: CodeEditor(
                    controller: _codeController,
                    activeLineIndex: _state.activeLineIndex,
                  ),
                ),
                ConsoleLog(logs: _consoleLogs),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
