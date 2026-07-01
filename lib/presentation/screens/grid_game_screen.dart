import 'package:flutter/material.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/curriculum/module_config.dart';
import '../../core/interpreter/lexer.dart';
import '../../core/interpreter/parser.dart';
import '../../core/session/hint_service.dart';
import '../../core/state/game_state.dart';
import '../../core/timer/game_timer_controller.dart';
import '../theme/doodle.dart';
import '../widgets/code_editor.dart';
import '../widgets/console_log.dart';
import '../widgets/game_canvas.dart';
import '../widgets/game_header.dart';
import '../widgets/hint_banner.dart';

/// Logic-grid gameplay screen: wires the code editor input through the
/// lexer/parser pipeline and drives the execution queue against the game
/// canvas and console log, one tick at a time. The interpreter pipeline
/// (Lexer/Parser/GameState/GameCanvas/CodeEditor) is unchanged from the
/// original single-module app — only the surrounding chrome (header,
/// timer, hint, win-flow) is new.
class GridGameScreen extends StatefulWidget {
  final CurriculumModule module;
  final void Function({required VoidCallback onGranted}) onRequestHintAd;
  final Future<void> Function({required int linesUsed, required int executionMs}) onWin;
  final VoidCallback onBack;

  const GridGameScreen({
    super.key,
    required this.module,
    required this.onRequestHintAd,
    required this.onWin,
    required this.onBack,
  });

  @override
  State<GridGameScreen> createState() => _GridGameScreenState();
}

class _GridGameScreenState extends State<GridGameScreen> {
  late final TextEditingController _codeController =
      TextEditingController(text: widget.module.initialCode);
  final Lexer _lexer = Lexer();
  final List<String> _consoleLogs = [];
  final GameTimerController _timerController = GameTimerController();
  final HintService _hintService = HintService();

  late GameState _state;
  bool _hasHint = false;
  bool _isFetchingHint = false;
  String? _dynamicHintMessage;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    final config = widget.module.config as LogicGridConfig;
    _state = GameState(
      playerX: config.playerX,
      playerY: config.playerY,
      targetX: config.targetX,
      targetY: config.targetY,
      gridSize: config.gridSize,
    );
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
    );
  }

  Future<void> _loadDynamicHint() async {
    final result = await _hintService.fetchSocraticHint(
      moduleType: 'logic_grid',
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
    _log('Starting execution loop...');

    final tokens = _lexer.tokenize(_codeController.text);
    final parser = Parser(gridSize: _state.gridSize);
    final steps = parser.run(
      tokens,
      startX: (widget.module.config as LogicGridConfig).playerX,
      startY: (widget.module.config as LogicGridConfig).playerY,
      targetX: _state.targetX,
      targetY: _state.targetY,
    );

    for (final step in steps) {
      setState(() => _state = _state.copyWith(activeLineIndex: step.line - 1));
      await Future.delayed(const Duration(milliseconds: 600));

      switch (step.result) {
        case ExecutionResultType.moved:
          setState(() => _state = _state.copyWith(playerX: step.x, playerY: step.y));
          _log('Line ${step.line}: Moved to (${step.x}, ${step.y})');
          break;
        case ExecutionResultType.goalReached:
          setState(() => _state = _state.copyWith(
                playerX: step.x,
                playerY: step.y,
                goalReached: true,
              ));
          _log('Success! Goal reached successfully.');
          break;
        case ExecutionResultType.outOfBounds:
        case ExecutionResultType.syntaxError:
          _log('Line ${step.line}: Error - ${step.detail}');
          break;
      }
    }

    setState(() => _state = _state.copyWith(isExecuting: false, activeLineIndex: -1));

    if (_state.goalReached) {
      _timerController.stop();
      setState(() => _isSyncing = true);
      final validLines =
          _codeController.text.split('\n').where((l) => l.trim().isNotEmpty).length;
      await widget.onWin(
        linesUsed: validLines,
        executionMs: _timerController.elapsedSeconds.value * 1000,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoodlePalette.dark,
      body: DoodleDotBackground(
        child: Column(
          children: [
            GameHeader(
              title: widget.module.title,
              icon: Icons.videogame_asset,
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
            Expanded(
              flex: 3,
              child: GameCanvas(state: _state),
            ),
            Expanded(
              flex: 2,
              child: CodeEditor(
                controller: _codeController,
                activeLineIndex: _state.activeLineIndex,
              ),
            ),
            ConsoleLog(logs: _consoleLogs),
          ],
        ),
      ),
    );
  }
}
