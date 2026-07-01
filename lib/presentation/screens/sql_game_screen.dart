import 'package:flutter/material.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/curriculum/module_config.dart';
import '../../core/interpreter/sql_checker.dart';
import '../../core/session/hint_service.dart';
import '../../core/timer/game_timer_controller.dart';
import '../theme/doodle.dart';
import '../widgets/code_editor.dart';
import '../widgets/console_log.dart';
import '../widgets/game_header.dart';
import '../widgets/hint_banner.dart';

/// SQL-terminal gameplay screen. Unlike the Grid/Rocket engines this
/// module has no stepped simulation: [SqlChecker] returns a single verdict
/// for the whole query, so this screen just animates through a canned
/// server-log response on success rather than looping execution steps.
class SqlGameScreen extends StatefulWidget {
  final CurriculumModule module;
  final void Function({required VoidCallback onGranted}) onRequestHintAd;
  final Future<void> Function({required int linesUsed, required int executionMs}) onWin;
  final VoidCallback onBack;

  const SqlGameScreen({
    super.key,
    required this.module,
    required this.onRequestHintAd,
    required this.onWin,
    required this.onBack,
  });

  @override
  State<SqlGameScreen> createState() => _SqlGameScreenState();
}

class _SqlGameScreenState extends State<SqlGameScreen> {
  late final TextEditingController _codeController =
      TextEditingController(text: widget.module.initialCode);
  final SqlChecker _checker = SqlChecker();
  final List<String> _consoleLogs = [];
  final GameTimerController _timerController = GameTimerController();
  final HintService _hintService = HintService();

  bool _isExecuting = false;
  bool _isSyncing = false;
  bool _hasHint = false;
  bool _isFetchingHint = false;
  String? _dynamicHintMessage;

  @override
  void initState() {
    super.initState();
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
      moduleType: 'sql_terminal',
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
    if (_isExecuting) return;

    final config = widget.module.config as SqlTerminalConfig;
    setState(() {
      _isExecuting = true;
      _consoleLogs.clear();
    });
    _log('> ${_codeController.text.replaceAll('\n', ' ')}');

    await Future.delayed(const Duration(milliseconds: 800));
    final result = _checker.check(_codeController.text, config);

    if (result.type == SqlCheckResultType.success) {
      _log('Executing Query...');
      for (final line in result.serverLog) {
        await Future.delayed(const Duration(milliseconds: 400));
        _log(line);
      }
      _timerController.stop();
      setState(() {
        _isExecuting = false;
        _isSyncing = true;
      });
      final validLines =
          _codeController.text.split('\n').where((l) => l.trim().isNotEmpty).length;
      await widget.onWin(
        linesUsed: validLines,
        executionMs: _timerController.elapsedSeconds.value * 1000,
      );
    } else {
      _log('Error: ${result.detail}');
      setState(() => _isExecuting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.module.config as SqlTerminalConfig;
    return Scaffold(
      backgroundColor: DoodlePalette.dark,
      body: DoodleDotBackground(
        child: Column(
          children: [
            GameHeader(
              title: widget.module.title,
              icon: Icons.storage,
              timerController: _timerController,
              hasHint: _hasHint,
              isExecuting: _isExecuting,
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
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DoodlePalette.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(5, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(config.instruction, style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Table: ${config.table}',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: DoodlePalette.purple, fontWeight: FontWeight.w700)),
                  Text('Columns: ${config.schema.join(', ')}',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: DoodlePalette.purple, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Expanded(
              child: CodeEditor(controller: _codeController),
            ),
            ConsoleLog(logs: _consoleLogs),
          ],
        ),
      ),
    );
  }
}
