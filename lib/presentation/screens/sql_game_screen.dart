import 'package:flutter/material.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/curriculum/module_config.dart';
import '../../core/curriculum/sql_case_catalog.dart';
import '../../core/interpreter/sql_checker.dart';
import '../../core/session/hint_service.dart';
import '../../core/timer/game_timer_controller.dart';
import '../theme/landing_tokens.dart';
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
  final void Function({
    required VoidCallback onGranted,
    VoidCallback? onCancelled,
  })
  onRequestHintAd;
  final Future<void> Function({
    required int linesUsed,
    required int executionMs,
  })
  onWin;
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
  late final TextEditingController _codeController = TextEditingController(
    text: widget.module.initialCode,
  );
  final SqlChecker _checker = SqlChecker();
  final List<String> _consoleLogs = [];
  final GameTimerController _timerController = GameTimerController();
  final HintService _hintService = HintService();

  bool _isExecuting = false;
  bool _isSyncing = false;
  bool _hasHint = false;
  bool _isFetchingHint = false;
  String? _dynamicHintMessage;
  int _activeTab = 0;
  final TextEditingController _findingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _timerController.start();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _findingController.dispose();
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
      final validLines = _codeController.text
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .length;
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
    final caseFile = SqlCaseCatalog.forModule(widget.module);
    return Scaffold(
      backgroundColor: LandingTokens.voidBlack,
      body: SafeArea(
        child: ColoredBox(
          color: LandingTokens.voidBlack,
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
              _CaseTabs(
                active: _activeTab,
                onChanged: (tab) => setState(() => _activeTab = tab),
              ),
              if (_hasHint)
                HintBanner(
                  hint: _dynamicHintMessage ?? widget.module.hint,
                  isLoading: _isFetchingHint,
                ),
              Expanded(
                child: IndexedStack(
                  index: _activeTab,
                  children: [
                    _briefView(caseFile),
                    _workspaceView(config),
                    _schemaView(config),
                    _submitView(caseFile),
                  ],
                ),
              ),
              /* Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: LandingTokens.carbon,
                borderRadius: LandingTokens.mediumRadius,
                border: Border.all(color: LandingTokens.hairline),
                boxShadow: LandingTokens.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CASE #${caseFile.number}: ${caseFile.title}',
                    style: const TextStyle(
                      color: LandingTokens.ember,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    caseFile.brief,
                    style: const TextStyle(
                      color: LandingTokens.textPrimary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'OBJECTIVES',
                    style: TextStyle(
                      color: LandingTokens.signal,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  for (final objective in caseFile.objectives)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        '• $objective',
                        style: const TextStyle(
                          color: LandingTokens.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    config.instruction,
                    style: const TextStyle(
                      color: LandingTokens.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Table: ${config.table}',
                    style: LandingTokens.mono(
                      fontSize: 12,
                      color: LandingTokens.circuit,
                    ),
                  ),
                  Text(
                    'Columns: ${config.schema.join(', ')}',
                    style: LandingTokens.mono(
                      fontSize: 12,
                      color: LandingTokens.circuit,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: CodeEditor(controller: _codeController)),
            ConsoleLog(logs: _consoleLogs), */
            ],
          ),
        ),
      ),
    );
  }

  Widget _briefView(SqlCase caseFile) => SingleChildScrollView(
    padding: const EdgeInsets.all(14),
    child: _casePanel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CASE #${caseFile.number}: ${caseFile.title}',
            style: const TextStyle(
              color: LandingTokens.ember,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            caseFile.brief,
            style: const TextStyle(
              color: LandingTokens.textPrimary,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'OBJECTIVES',
            style: TextStyle(
              color: LandingTokens.signal,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < caseFile.objectives.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                '${i + 1}.  ${caseFile.objectives[i]}',
                style: const TextStyle(
                  color: LandingTokens.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _workspaceView(SqlTerminalConfig config) => Column(
    children: [
      Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        padding: const EdgeInsets.all(14),
        color: LandingTokens.carbon,
        child: Text(
          config.instruction,
          style: const TextStyle(
            color: LandingTokens.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      Expanded(child: CodeEditor(controller: _codeController)),
      ConsoleLog(logs: _consoleLogs),
    ],
  );

  Widget _schemaView(SqlTerminalConfig config) => SingleChildScrollView(
    padding: const EdgeInsets.all(14),
    child: _casePanel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DATABASE SCHEMA',
            style: TextStyle(
              color: LandingTokens.ember,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          _schemaTable(config.table, config.schema),
          const SizedBox(height: 14),
          const Text(
            'Use this schema to plan joins, filters, and aggregations before running your query.',
            style: TextStyle(color: LandingTokens.textMuted, fontSize: 13),
          ),
        ],
      ),
    ),
  );

  Widget _schemaTable(String table, List<String> columns) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: LandingTokens.hairline),
      borderRadius: LandingTokens.smallRadius,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: LandingTokens.ember.withValues(alpha: .18),
          padding: const EdgeInsets.all(12),
          child: Text(
            table,
            style: LandingTokens.mono(
              color: LandingTokens.ember,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        for (final column in columns)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              column,
              style: LandingTokens.mono(color: LandingTokens.textPrimary),
            ),
          ),
      ],
    ),
  );

  Widget _submitView(SqlCase caseFile) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: _casePanel(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SUBMIT YOUR FINDINGS',
              style: const TextStyle(
                color: LandingTokens.ember,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Submit the suspect or result you discovered for ${caseFile.title}.',
              style: const TextStyle(
                color: LandingTokens.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'YOUR ANSWER',
              style: TextStyle(
                color: LandingTokens.ember,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _findingController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter your answer...',
                hintStyle: TextStyle(color: LandingTokens.textMuted),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _executeCode,
                icon: const Icon(Icons.send),
                label: const Text('Submit Solution'),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _casePanel(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: LandingTokens.carbon,
      borderRadius: LandingTokens.mediumRadius,
      border: Border.all(color: LandingTokens.hairline),
      boxShadow: LandingTokens.cardShadow,
    ),
    child: child,
  );
}

class _CaseTabs extends StatelessWidget {
  final int active;
  final ValueChanged<int> onChanged;
  const _CaseTabs({required this.active, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: LandingTokens.hairline)),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: compact ? 4 : 8,
          runSpacing: 4,
          children: [
            _tab(0, Icons.menu_book, 'Case Brief', compact),
            _tab(1, Icons.code, 'SQL Workspace', compact),
            _tab(2, Icons.storage, 'Schema', compact),
            _tab(3, Icons.send, 'Submit', compact),
          ],
        );
      },
    ),
  );

  Widget _tab(int index, IconData icon, String label, bool compact) {
    final color = active == index
        ? LandingTokens.ember
        : LandingTokens.textMuted;
    if (compact) {
      return Tooltip(
        message: label,
        child: TextButton(
          onPressed: () => onChanged(index),
          child: Icon(icon, color: color, size: 18),
        ),
      );
    }
    return TextButton.icon(
      onPressed: () => onChanged(index),
      icon: Icon(icon, color: color, size: 17),
      label: Text(label, style: TextStyle(color: color)),
    );
  }
}
