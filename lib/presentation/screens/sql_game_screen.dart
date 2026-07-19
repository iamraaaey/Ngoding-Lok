import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/curriculum/module_config.dart';
import '../../core/curriculum/sql_case_catalog.dart';
import '../../core/interpreter/sql_checker.dart';
import '../../core/session/hint_service.dart';
import '../../core/timer/game_timer_controller.dart';
import '../theme/landing_tokens.dart';
import '../widgets/code_editor.dart';
import '../widgets/console_log.dart';
import '../widgets/hint_banner.dart';
import '../widgets/landing/landing_button.dart';
import '../widgets/landing/landing_surface.dart';

/// SQL case screen inspired by SQLNoir's case-study layout.
///
/// Case 001 is a local, deterministic investigation: queries reveal rows from
/// the three case tables and the final answer is checked in the Submit tab.
/// Other curriculum modules keep the original single-query completion flow.
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
    String? sourceCode,
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
  final TextEditingController _findingController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final SqlChecker _checker = SqlChecker();
  final List<String> _consoleLogs = [];
  final GameTimerController _timerController = GameTimerController();
  final HintService _hintService = HintService();

  late final SqlCase _caseFile = SqlCaseCatalog.forModule(widget.module);
  bool _isExecuting = false;
  bool _isSyncing = false;
  bool _hasHint = false;
  bool _isFetchingHint = false;
  bool _isDatabaseLoading = false;
  bool _sideBySide = false;
  String? _dynamicHintMessage;
  String? _queryError;
  String? _submissionMessage;
  bool _submissionCorrect = false;
  int _activeTab = 0;
  List<String> _resultColumns = const [];
  List<List<Object?>> _resultRows = const [];

  /// Schema tab: "Table" (collapsible cards) vs "Graph" (ERD) view, and which
  /// table dropdowns are currently collapsed (empty = all expanded).
  bool _schemaGraphMode = false;
  final Set<String> _collapsedSchemaTables = <String>{};

  bool get _isCaseStudy => _caseFile.solution != null;

  @override
  void initState() {
    super.initState();
    _timerController.start();
    _notesController.addListener(_persistNotes);
    _loadNotes();
    if (_isCaseStudy) {
      _isDatabaseLoading = true;
      Future<void>.delayed(const Duration(milliseconds: 280), () {
        if (mounted) setState(() => _isDatabaseLoading = false);
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _findingController.dispose();
    _notesController.removeListener(_persistNotes);
    _notesController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notes = prefs.getString(_notesKey);
      if (mounted && notes != null && _notesController.text.isEmpty) {
        _notesController.text = notes;
      }
    } catch (_) {
      // Local notes are a convenience; the investigation remains usable.
    }
  }

  Future<void> _persistNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_notesKey, _notesController.text);
    } catch (_) {
      // Ignore storage failures on unsupported platforms.
    }
  }

  String get _notesKey => 'sqlnoir-notes-${widget.module.id}';

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
    final config = widget.module.config as SqlTerminalConfig;
    final result = await _hintService.fetchSocraticHint(
      moduleType: 'sql_terminal',
      moduleId: widget.module.id,
      moduleTitle: widget.module.title,
      levelObjective: widget.module.description,
      moduleContext:
          'Query goal: ${config.instruction}\n'
          'Table: ${config.table}\n'
          'Schema: ${config.schema.join(', ')}',
      currentCode: _codeController.text,
    );
    if (!mounted) return;
    setState(() {
      _dynamicHintMessage = result?.hintMessage;
      _isFetchingHint = false;
    });
  }

  Future<void> _executeCode() async {
    if (_isExecuting || _isSyncing || _isDatabaseLoading) return;
    if (_isCaseStudy) {
      await _executeCaseQuery();
      return;
    }

    final config = widget.module.config as SqlTerminalConfig;
    setState(() {
      _isExecuting = true;
      _consoleLogs.clear();
      _queryError = null;
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
      await widget.onWin(
        linesUsed: _codeController.text
            .split('\n')
            .where((l) => l.trim().isNotEmpty)
            .length,
        executionMs: _timerController.elapsedSeconds.value * 1000,
        sourceCode: _codeController.text,
      );
    } else {
      _log('Error: ${result.detail}');
      setState(() => _isExecuting = false);
    }
  }

  Future<void> _executeCaseQuery() async {
    final query = _codeController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _queryError = 'Query is empty.';
        _resultColumns = const [];
        _resultRows = const [];
      });
      return;
    }

    setState(() {
      _isExecuting = true;
      _queryError = null;
      _consoleLogs.clear();
      _resultColumns = const [];
      _resultRows = const [];
    });
    _log('> ${query.replaceAll('\n', ' ')}');
    await Future.delayed(const Duration(milliseconds: 420));
    final result = _caseQuery(query);
    if (!mounted) return;
    setState(() {
      _isExecuting = false;
      _queryError = result.error;
      _resultColumns = result.columns;
      _resultRows = result.rows;
    });
    if (result.error == null) {
      _log('Query executed successfully.');
      _log('[${result.rows.length} ROWS RETURNED]');
    }
  }

  _SqlQueryResult _caseQuery(String query) {
    final normalized = query.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    if (!normalized.startsWith('select')) {
      return const _SqlQueryResult.error(
        'This case workspace is read-only. Start with a SELECT query.',
      );
    }

    if (normalized.contains('from crime_scene')) {
      if (normalized.contains('blue note lounge') ||
          !normalized.contains('where')) {
        return const _SqlQueryResult(
          ['id', 'date', 'type', 'description'],
          [
            [
              76,
              19851120,
              'theft',
              'A briefcase containing sensitive documents vanished. A witness reported a man in a trench coat with a scar on his left cheek fleeing the scene.',
            ],
          ],
        );
      }
      return const _SqlQueryResult(['id', 'date', 'type', 'description'], []);
    }

    if (normalized.contains('from suspects')) {
      final matchesClue =
          normalized.contains('trench coat') &&
          normalized.contains('left cheek');
      if (matchesClue || !normalized.contains('where')) {
        return const _SqlQueryResult(
          ['id', 'name'],
          [
            [3, 'Frankie Lombardi'],
            [183, 'Vincent Malone'],
          ],
        );
      }
      return const _SqlQueryResult(['id', 'name'], []);
    }

    if (normalized.contains('from interviews')) {
      return const _SqlQueryResult(
        ['suspect_id', 'transcript', 'name'],
        [
          [183, "I wasn't going to steal it, but I did.", 'Vincent Malone'],
        ],
      );
    }

    return const _SqlQueryResult(['result'], []);
  }

  Future<void> _submitFinding() async {
    if (!_isCaseStudy) {
      await _executeCode();
      return;
    }
    final answer = _findingController.text.trim();
    if (answer.isEmpty) {
      setState(() {
        _submissionCorrect = false;
        _submissionMessage =
            'Enter the specific name you found through your investigation.';
      });
      return;
    }
    final correct = answer.toLowerCase() == _caseFile.solution!.toLowerCase();
    setState(() {
      _submissionCorrect = correct;
      _submissionMessage = correct
          ? 'Case closed. Vincent Malone confessed to the theft.'
          : 'That name does not match the evidence. Recheck the interview transcript.';
    });
    if (!correct || _isSyncing) return;
    _timerController.stop();
    setState(() => _isSyncing = true);
    await widget.onWin(
      linesUsed: _codeController.text
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .length,
      executionMs: _timerController.elapsedSeconds.value * 1000,
      sourceCode: _codeController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.module.config as SqlTerminalConfig;
    return Scaffold(
      backgroundColor: _SqlNoir.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CinematicBackdrop(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                children: [
                  _SqlHeader(
                    caseFile: _caseFile,
                    module: widget.module,
                    timerController: _timerController,
                    hasHint: _hasHint,
                    isExecuting: _isExecuting,
                    isSyncing: _isSyncing,
                    sideBySide: _sideBySide,
                    onBack: widget.onBack,
                    onGetHint: _hasHint ? null : _onGetHint,
                    onRun: _executeCode,
                    onToggleSideBySide: () {
                      if (constraints.maxWidth < 900) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Side by Side is available on wider screens.',
                            ),
                          ),
                        );
                        return;
                      }
                      setState(() => _sideBySide = !_sideBySide);
                    },
                  ),
                  if (_hasHint)
                    HintBanner(
                      hint: _dynamicHintMessage ?? widget.module.hint,
                      isLoading: _isFetchingHint,
                    ),
                  Expanded(
                    child: _CaseShell(
                      activeTab: _activeTab,
                      onTabChanged: (tab) => setState(() => _activeTab = tab),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          constraints.maxWidth >= 900 ? 24 : 16,
                          16,
                          constraints.maxWidth >= 900 ? 24 : 16,
                          24,
                        ),
                        child: _isDatabaseLoading
                            ? const _LoadingState(label: 'Loading database...')
                            : _buildContent(config, constraints.maxWidth),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SqlTerminalConfig config, double width) {
    if (_sideBySide && width >= 900) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _briefView()),
          const SizedBox(width: 16),
          Expanded(child: _workspaceView(config)),
        ],
      );
    }

    return IndexedStack(
      index: _activeTab,
      children: [
        _briefView(),
        _workspaceView(config),
        _schemaView(config),
        _notesView(),
        _submitView(),
      ],
    );
  }

  Widget _briefView() => ListView(
    padding: EdgeInsets.zero,
    children: [
      _ReferencePanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PanelHeading(
              icon: Icons.description_outlined,
              label: 'Case #${_caseFile.number}: ${_caseFile.title}',
              size: 24,
            ),
            const SizedBox(height: 14),
            Text(_caseFile.brief, style: _SqlNoir.body),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _ReferencePanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PanelHeading(
              icon: Icons.track_changes,
              label: 'Objectives',
              size: 21,
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < _caseFile.objectives.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${index + 1}.', style: _SqlNoir.mono),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _caseFile.objectives[index],
                        style: _SqlNoir.body,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ],
  );

  Widget _workspaceView(SqlTerminalConfig config) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _ReferencePanel(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Text(
          _isCaseStudy
              ? 'Investigate the crime scene, suspects, and interviews with SQL.'
              : config.instruction,
          style: _SqlNoir.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      const SizedBox(height: 12),
      Expanded(child: CodeEditor(controller: _codeController)),
      const SizedBox(height: 12),
      SizedBox(
        height: _isCaseStudy ? 172 : 120,
        child: _isCaseStudy ? _queryResults() : ConsoleLog(logs: _consoleLogs),
      ),
    ],
  );

  Widget _queryResults() => Container(
    decoration: BoxDecoration(
      color: _SqlNoir.paper,
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: _SqlNoir.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: _SqlNoir.paleAmber,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            children: [
              Text(
                'Query Results',
                style: _SqlNoir.heading.copyWith(fontSize: 14),
              ),
              const Spacer(),
              if (_consoleLogs.isNotEmpty)
                Text(
                  _consoleLogs.last,
                  style: _SqlNoir.mono.copyWith(fontSize: 11),
                ),
            ],
          ),
        ),
        Expanded(
          child: _queryError != null
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_queryError!, style: _SqlNoir.error),
                )
              : _resultColumns.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Run a SELECT query to inspect the evidence.',
                    style: _SqlNoir.mutedBody,
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: WidgetStatePropertyAll(
                        _SqlNoir.paleAmber,
                      ),
                      dataRowMinHeight: 30,
                      dataRowMaxHeight: 44,
                      columnSpacing: 22,
                      columns: [
                        for (final column in _resultColumns)
                          DataColumn(
                            label: Text(column, style: _SqlNoir.tableHead),
                          ),
                      ],
                      rows: [
                        for (final row in _resultRows)
                          DataRow(
                            cells: [
                              for (final value in row)
                                DataCell(
                                  Text('$value', style: _SqlNoir.tableCell),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    ),
  );

  Widget _schemaView(SqlTerminalConfig config) {
    final tables = _caseFile.tables.isNotEmpty
        ? _caseFile.tables
        : [SqlCaseTable(config.table, config.schema)];
    final tableNames = tables.map((t) => t.name).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: _PanelHeading(
                icon: Icons.storage_outlined,
                label: 'Database Schema',
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            _SchemaViewToggle(
              graphMode: _schemaGraphMode,
              onChanged: (graph) => setState(() => _schemaGraphMode = graph),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: _schemaGraphMode
              ? _SchemaGraphView(tables: tables, tableNames: tableNames)
              : ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final table in tables) ...[
                      _SchemaTableCard(
                        table: table,
                        tableNames: tableNames,
                        expanded: !_collapsedSchemaTables.contains(table.name),
                        onToggle: () => setState(() {
                          if (!_collapsedSchemaTables.remove(table.name)) {
                            _collapsedSchemaTables.add(table.name);
                          }
                        }),
                      ),
                      const SizedBox(height: 14),
                    ],
                    Text(
                      'Tap a table to expand its columns. Switch to Graph view to '
                      'see how the tables relate through their keys.',
                      style: _SqlNoir.mutedBody,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _notesView() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _PanelHeading(
        icon: Icons.edit_note,
        label: 'Investigation Notes',
        size: 22,
      ),
      const SizedBox(height: 14),
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: _SqlNoir.paper,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: _SqlNoir.border),
            boxShadow: const [
              BoxShadow(color: Color(0x12000000), blurRadius: 8),
            ],
          ),
          child: TextField(
            controller: _notesController,
            expands: true,
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
            style: _SqlNoir.mono.copyWith(fontSize: 14, height: 2),
            decoration: InputDecoration(
              hintText: 'Take notes about your investigation here...',
              hintStyle: _SqlNoir.mono.copyWith(color: _SqlNoir.muted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      Text(
        'Your notes are automatically saved locally and will persist between sessions.',
        style: _SqlNoir.mutedBody.copyWith(fontStyle: FontStyle.italic),
      ),
    ],
  );

  Widget _submitView() => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: _ReferencePanel(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submit Your Findings',
                style: _SqlNoir.heading.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 12),
              Text(
                'Submit the suspect you discovered through your investigation to see if you cracked the case.',
                style: _SqlNoir.body,
              ),
              const SizedBox(height: 20),
              Text(
                'Your Answer',
                style: _SqlNoir.heading.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _findingController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submitFinding(),
                style: _SqlNoir.body.copyWith(color: _SqlNoir.ink),
                decoration: InputDecoration(
                  hintText: 'Enter your answer...',
                  hintStyle: _SqlNoir.body.copyWith(color: _SqlNoir.muted),
                  filled: true,
                  fillColor: _SqlNoir.paper,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide(color: _SqlNoir.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide(color: _SqlNoir.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(
                      color: _SqlNoir.accent,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the specific name you found through your investigation.',
                style: _SqlNoir.mutedBody,
              ),
              if (_submissionMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  _submissionMessage!,
                  style: _submissionCorrect ? _SqlNoir.success : _SqlNoir.error,
                ),
              ],
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: GradientButton(
                  label: 'Submit Solution',
                  icon: Icons.send_rounded,
                  compact: true,
                  onPressed: _isSyncing ? null : _submitFinding,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SqlHeader extends StatelessWidget {
  final SqlCase caseFile;
  final CurriculumModule module;
  final GameTimerController timerController;
  final bool hasHint, isExecuting, isSyncing, sideBySide;
  final VoidCallback onBack, onToggleSideBySide, onRun;
  final VoidCallback? onGetHint;

  const _SqlHeader({
    required this.caseFile,
    required this.module,
    required this.timerController,
    required this.hasHint,
    required this.isExecuting,
    required this.isSyncing,
    required this.sideBySide,
    required this.onBack,
    required this.onToggleSideBySide,
    required this.onRun,
    required this.onGetHint,
  });

  @override
  Widget build(BuildContext context) {
    final xp = caseFile.xp ?? module.xpReward;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 700;
              if (compact) {
                return Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 6,
                  children: [
                    _HeaderButton(
                      icon: Icons.arrow_back,
                      label: 'Back',
                      onPressed: onBack,
                    ),
                    _CaseBadge(number: caseFile.number, xp: xp, compact: true),
                  ],
                );
              }
              return Row(
                children: [
                  _HeaderButton(
                    icon: Icons.arrow_back,
                    label: 'Back to Cases',
                    onPressed: onBack,
                  ),
                  const Spacer(),
                  _HeaderButton(
                    icon: Icons.view_column_outlined,
                    label: 'Side by Side',
                    active: sideBySide,
                    onPressed: onToggleSideBySide,
                  ),
                  const SizedBox(width: 10),
                  _CaseBadge(number: caseFile.number, xp: xp),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 620;
              final actions = [
                _HeaderButton(
                  icon: Icons.lightbulb_outline,
                  label: 'Hint',
                  onPressed: onGetHint,
                  compact: true,
                ),
                const SizedBox(width: 8),
                _RunButton(
                  isExecuting: isExecuting,
                  isSyncing: isSyncing,
                  onPressed: onRun,
                ),
              ];
              if (compact) {
                return Column(
                  children: [
                    Row(
                      children: [
                        _HeaderMeta(
                          label: 'CASE #${caseFile.number}',
                          value: caseFile.title,
                        ),
                        const SizedBox(width: 8),
                        _TimerChip(timerController: timerController),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  _HeaderMeta(
                    label: 'CASE #${caseFile.number}',
                    value: caseFile.title,
                  ),
                  const Spacer(),
                  _TimerChip(timerController: timerController),
                  ...actions,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CaseShell extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTabChanged;
  final Widget child;

  const _CaseShell({
    required this.activeTab,
    required this.onTabChanged,
    required this.child,
  });

  static const _tabs = [
    (Icons.book_outlined, 'Case Brief'),
    (Icons.code, 'SQL Workspace'),
    (Icons.storage_outlined, 'Schema'),
    (Icons.edit_note, 'Notes'),
    (Icons.send_outlined, 'Submit'),
  ];

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: _SqlNoir.shell,
      borderRadius: LandingTokens.mediumRadius,
      border: Border.all(color: _SqlNoir.border),
      boxShadow: LandingTokens.cardShadow,
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: LandingTokens.hairline)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  _TabButton(
                    icon: _tabs[i].$1,
                    label: _tabs[i].$2,
                    active: activeTab == i,
                    onPressed: () => onTabChanged(i),
                  ),
              ],
            ),
          ),
        ),
        Expanded(child: child),
      ],
    ),
  );
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onPressed;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: active ? _SqlNoir.accent : Colors.transparent,
          width: 2,
        ),
      ),
    ),
    child: TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: active ? _SqlNoir.accent : _SqlNoir.bodyInk,
        backgroundColor: active
            ? _SqlNoir.accent.withValues(alpha: 0.08)
            : Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        textStyle: _SqlNoir.body.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _ReferencePanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _ReferencePanel({
    required this.child,
    this.padding = const EdgeInsets.all(22),
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: _SqlNoir.paper,
      borderRadius: LandingTokens.mediumRadius,
      border: Border.all(color: _SqlNoir.border),
      boxShadow: LandingTokens.cardShadow,
    ),
    child: child,
  );
}

class _PanelHeading extends StatelessWidget {
  final IconData icon;
  final String label;
  final double size;

  const _PanelHeading({
    required this.icon,
    required this.label,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: _SqlNoir.accent, size: size),
      const SizedBox(width: 10),
      Expanded(
        child: Text(label, style: _SqlNoir.heading.copyWith(fontSize: size)),
      ),
    ],
  );
}

// ── Schema browser ──────────────────────────────────────────────────────
// Node geometry shared between the graph layout and its node cards so the
// foreign-key connector lines terminate at the right card edges.
const double _kNodeWidth = 220;
const double _kNodeHeaderH = 40;
const double _kNodeRowH = 26;

/// One parsed schema column with inferred key metadata. Primary key = a column
/// named `id`; foreign key = a `<name>_id` column whose prefix matches another
/// table in the schema (e.g. `suspect_id` → `suspects`).
class _SchemaColumn {
  final String name;
  final String type;
  final bool isPrimaryKey;
  final String? references;

  const _SchemaColumn({
    required this.name,
    required this.type,
    required this.isPrimaryKey,
    this.references,
  });
}

List<_SchemaColumn> _parseSchemaColumns(
  SqlCaseTable table,
  List<String> tableNames,
) {
  final others = tableNames.where((n) => n != table.name).toList();
  return table.columns.map((raw) {
    final match = RegExp(
      r'^\s*([A-Za-z_]\w*)\s*(?:\(([^)]*)\))?',
    ).firstMatch(raw);
    final name = match?.group(1) ?? raw.trim();
    final type = (match?.group(2) ?? '').trim();
    final lower = name.toLowerCase();
    final isPrimaryKey = lower == 'id';
    String? references;
    if (!isPrimaryKey && lower.endsWith('_id')) {
      final prefix = lower.substring(0, lower.length - 3);
      for (final other in others) {
        final ol = other.toLowerCase();
        if (ol == prefix || ol == '${prefix}s' || ol == '${prefix}es') {
          references = other;
          break;
        }
      }
    }
    return _SchemaColumn(
      name: name,
      type: type,
      isPrimaryKey: isPrimaryKey,
      references: references,
    );
  }).toList();
}

/// Icon + tint for a column row, keyed by its role (PK / FK / plain).
(IconData, Color) _columnGlyph(_SchemaColumn column) {
  if (column.isPrimaryKey) return (Icons.vpn_key, _SqlNoir.accent);
  if (column.references != null) return (Icons.link, _SqlNoir.link);
  return (Icons.circle, _SqlNoir.muted);
}

/// Segmented "Table | Graph" control for the schema tab.
class _SchemaViewToggle extends StatelessWidget {
  final bool graphMode;
  final ValueChanged<bool> onChanged;

  const _SchemaViewToggle({required this.graphMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _SqlNoir.paleAmber,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _SqlNoir.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment(Icons.table_rows_outlined, 'Table', !graphMode, false),
          _segment(Icons.account_tree_outlined, 'Graph', graphMode, true),
        ],
      ),
    );
  }

  Widget _segment(IconData icon, String label, bool active, bool graph) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onChanged(graph),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: active ? _SqlNoir.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: active ? _SqlNoir.onAccent : _SqlNoir.muted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: _SqlNoir.body.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: active ? _SqlNoir.onAccent : _SqlNoir.bodyInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A collapsible table "dropdown": a brown header you tap to expand/collapse,
/// revealing its columns with primary/foreign-key indicators.
class _SchemaTableCard extends StatelessWidget {
  final SqlCaseTable table;
  final List<String> tableNames;
  final bool expanded;
  final VoidCallback onToggle;

  const _SchemaTableCard({
    required this.table,
    required this.tableNames,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final columns = _parseSchemaColumns(table, tableNames);
    return Container(
      decoration: BoxDecoration(
        color: _SqlNoir.paper,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _SqlNoir.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: Container(
                color: _SqlNoir.brown,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.table_chart_outlined,
                      size: 16,
                      color: _SqlNoir.cream,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        table.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _SqlNoir.schemaTitle,
                      ),
                    ),
                    Text(
                      '${columns.length} cols',
                      style: _SqlNoir.schemaTitle.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 160),
                      child: const Icon(
                        Icons.expand_more,
                        size: 18,
                        color: _SqlNoir.cream,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: expanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < columns.length; i++)
                        _SchemaColumnRow(column: columns[i], striped: i.isOdd),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// A single column line inside a table card: role glyph, name, type pill, and
/// (for foreign keys) the referenced table.
class _SchemaColumnRow extends StatelessWidget {
  final _SchemaColumn column;
  final bool striped;

  const _SchemaColumnRow({required this.column, required this.striped});

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor) = _columnGlyph(column);
    return Container(
      color: striped
          ? _SqlNoir.paleAmber.withValues(alpha: 0.35)
          : _SqlNoir.paper,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        children: [
          Icon(icon, size: column.isPrimaryKey ? 14 : 12, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              column.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _SqlNoir.mono.copyWith(
                color: _SqlNoir.ink,
                fontWeight: column.isPrimaryKey
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ),
          if (column.references != null) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '→ ${column.references}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _SqlNoir.mono.copyWith(
                  fontSize: 11,
                  color: _SqlNoir.link,
                ),
              ),
            ),
          ],
          if (column.type.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _SqlNoir.paleAmber,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                column.type,
                style: _SqlNoir.mono.copyWith(
                  fontSize: 11,
                  color: _SqlNoir.bodyInk,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ERD-style schema graph: each table is a node listing its columns, with
/// foreign-key connector lines drawn to the referenced tables. Pan and zoom
/// via [InteractiveViewer].
class _SchemaGraphView extends StatelessWidget {
  final List<SqlCaseTable> tables;
  final List<String> tableNames;

  const _SchemaGraphView({required this.tables, required this.tableNames});

  @override
  Widget build(BuildContext context) {
    final parsed = <String, List<_SchemaColumn>>{
      for (final t in tables) t.name: _parseSchemaColumns(t, tableNames),
    };
    final edges = <_SchemaEdge>[];
    for (final t in tables) {
      for (final column in parsed[t.name]!) {
        final ref = column.references;
        if (ref != null && parsed.containsKey(ref)) {
          edges.add(_SchemaEdge(from: t.name, to: ref, label: column.name));
        }
      }
    }

    double nodeHeight(String name) =>
        _kNodeHeaderH + parsed[name]!.length * _kNodeRowH + 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        const gapX = 44.0;
        const gapY = 54.0;
        final cols = ((available + gapX) / (_kNodeWidth + gapX)).floor().clamp(
          1,
          tables.length,
        );
        final rows = (tables.length / cols).ceil();
        final maxNodeH = tables
            .map((t) => nodeHeight(t.name))
            .fold<double>(0, math.max);

        final positions = <String, Rect>{};
        for (var i = 0; i < tables.length; i++) {
          final r = i ~/ cols;
          final c = i % cols;
          positions[tables[i].name] = Rect.fromLTWH(
            c * (_kNodeWidth + gapX),
            r * (maxNodeH + gapY),
            _kNodeWidth,
            nodeHeight(tables[i].name),
          );
        }

        final canvasW = cols * _kNodeWidth + (cols - 1) * gapX;
        final canvasH = rows * maxNodeH + (rows - 1) * gapY;

        return InteractiveViewer(
          constrained: false,
          boundaryMargin: const EdgeInsets.all(64),
          minScale: 0.5,
          maxScale: 2.5,
          child: SizedBox(
            width: math.max(canvasW, available),
            height: canvasH + 4,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SchemaGraphPainter(
                      edges: edges,
                      positions: positions,
                    ),
                  ),
                ),
                for (final t in tables)
                  Positioned(
                    left: positions[t.name]!.left,
                    top: positions[t.name]!.top,
                    width: _kNodeWidth,
                    child: _SchemaNodeCard(table: t, columns: parsed[t.name]!),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SchemaEdge {
  final String from;
  final String to;
  final String label;

  const _SchemaEdge({
    required this.from,
    required this.to,
    required this.label,
  });
}

/// A fixed-geometry table node for the graph view (heights match [_kNodeRowH]
/// / [_kNodeHeaderH] so connector lines line up with the card edges).
class _SchemaNodeCard extends StatelessWidget {
  final SqlCaseTable table;
  final List<_SchemaColumn> columns;

  const _SchemaNodeCard({required this.table, required this.columns});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _SqlNoir.paper,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _SqlNoir.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: _kNodeHeaderH,
            color: _SqlNoir.brown,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Icon(
                  Icons.table_chart_outlined,
                  size: 15,
                  color: _SqlNoir.cream,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    table.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _SqlNoir.schemaTitle,
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < columns.length; i++)
            _SchemaNodeRow(column: columns[i], striped: i.isOdd),
        ],
      ),
    );
  }
}

class _SchemaNodeRow extends StatelessWidget {
  final _SchemaColumn column;
  final bool striped;

  const _SchemaNodeRow({required this.column, required this.striped});

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor) = _columnGlyph(column);
    return Container(
      height: _kNodeRowH,
      color: striped
          ? _SqlNoir.paleAmber.withValues(alpha: 0.35)
          : _SqlNoir.paper,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(icon, size: column.isPrimaryKey ? 13 : 11, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              column.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _SqlNoir.mono.copyWith(
                fontSize: 12,
                color: _SqlNoir.ink,
                fontWeight: column.isPrimaryKey
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ),
          if (column.type.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              column.type,
              style: _SqlNoir.mono.copyWith(
                fontSize: 10,
                color: _SqlNoir.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Draws the foreign-key connector lines behind the table nodes: a dot at the
/// FK column's table, a line to the referenced table, an arrowhead, and a
/// small label naming the foreign-key column.
class _SchemaGraphPainter extends CustomPainter {
  final List<_SchemaEdge> edges;
  final Map<String, Rect> positions;

  const _SchemaGraphPainter({required this.edges, required this.positions});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = _SqlNoir.link.withValues(alpha: 0.7)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()..color = _SqlNoir.accent;

    for (final edge in edges) {
      final from = positions[edge.from];
      final to = positions[edge.to];
      if (from == null || to == null) continue;

      final start = _edgePoint(from, to.center);
      final end = _edgePoint(to, from.center);
      canvas.drawLine(start, end, linePaint);
      canvas.drawCircle(start, 3, dotPaint);
      _drawArrow(canvas, start, end, linePaint);
      _drawLabel(
        canvas,
        Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2),
        edge.label,
      );
    }
  }

  /// Where the segment from the rect's center toward [toward] crosses its edge.
  Offset _edgePoint(Rect rect, Offset toward) {
    final c = rect.center;
    final dx = toward.dx - c.dx;
    final dy = toward.dy - c.dy;
    if (dx == 0 && dy == 0) return c;
    final sx = dx != 0 ? (rect.width / 2) / dx.abs() : double.infinity;
    final sy = dy != 0 ? (rect.height / 2) / dy.abs() : double.infinity;
    final s = math.min(sx, sy);
    return Offset(c.dx + dx * s, c.dy + dy * s);
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    const len = 9.0;
    canvas.drawLine(
      to,
      Offset(
        to.dx - len * math.cos(angle - 0.5),
        to.dy - len * math.sin(angle - 0.5),
      ),
      paint,
    );
    canvas.drawLine(
      to,
      Offset(
        to.dx - len * math.cos(angle + 0.5),
        to.dy - len * math.sin(angle + 0.5),
      ),
      paint,
    );
  }

  void _drawLabel(Canvas canvas, Offset center, String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: _SqlNoir.link,
          fontFamily: 'monospace',
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = Rect.fromCenter(
      center: center,
      width: tp.width + 10,
      height: tp.height + 6,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));
    canvas.drawRRect(rrect, Paint()..color = _SqlNoir.brown);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = _SqlNoir.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _SchemaGraphPainter oldDelegate) =>
      oldDelegate.edges != edges || oldDelegate.positions != positions;
}

class _LoadingState extends StatelessWidget {
  final String label;

  const _LoadingState({required this.label});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _SqlNoir.accent,
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: _SqlNoir.body),
      ],
    ),
  );
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool active, compact;

  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.active = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: compact ? 15 : 16),
    label: Text(label),
    style: TextButton.styleFrom(
      foregroundColor: active ? _SqlNoir.accent : _SqlNoir.ink,
      backgroundColor: active
          ? _SqlNoir.accent.withValues(alpha: 0.10)
          : Colors.transparent,
      side: BorderSide(color: active ? _SqlNoir.accent : _SqlNoir.inputBorder),
      shape: const RoundedRectangleBorder(
        borderRadius: LandingTokens.smallRadius,
      ),
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14, vertical: 9),
      textStyle: _SqlNoir.body.copyWith(
        fontSize: compact ? 12 : 13,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _CaseBadge extends StatelessWidget {
  final String number;
  final int xp;
  final bool compact;

  const _CaseBadge({
    required this.number,
    required this.xp,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: _SqlNoir.accent.withValues(alpha: 0.10),
      borderRadius: LandingTokens.smallRadius,
      border: Border.all(color: _SqlNoir.accent.withValues(alpha: 0.5)),
    ),
    child: Text(
      compact ? '#$number • $xp XP' : 'CASE #$number • $xp XP',
      style: _SqlNoir.mono.copyWith(
        color: _SqlNoir.accent,
        fontSize: compact ? 11 : 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _HeaderMeta extends StatelessWidget {
  final String label, value;

  const _HeaderMeta({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Text(
      '$label  ·  $value',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _SqlNoir.mutedBody.copyWith(fontSize: 12),
    ),
  );
}

class _TimerChip extends StatelessWidget {
  final GameTimerController timerController;

  const _TimerChip({required this.timerController});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: _SqlNoir.background,
      borderRadius: LandingTokens.smallRadius,
      border: Border.all(color: _SqlNoir.inputBorder),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.access_time, size: 13, color: LandingTokens.textMuted),
        const SizedBox(width: 5),
        ValueListenableBuilder<int>(
          valueListenable: timerController.elapsedSeconds,
          builder: (context, seconds, _) => Text(
            GameTimerController.format(seconds),
            style: _SqlNoir.mono.copyWith(
              fontSize: 12,
              color: LandingTokens.signal,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _RunButton extends StatelessWidget {
  final bool isExecuting, isSyncing;
  final VoidCallback onPressed;

  const _RunButton({
    required this.isExecuting,
    required this.isSyncing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => GradientButton(
    label: isSyncing ? 'Syncing...' : 'Run Query',
    icon: isSyncing ? Icons.sync : Icons.play_arrow_rounded,
    compact: true,
    onPressed: (isExecuting || isSyncing) ? null : onPressed,
  );
}

class _SqlQueryResult {
  final List<String> columns;
  final List<List<Object?>> rows;
  final String? error;

  const _SqlQueryResult(this.columns, this.rows) : error = null;
  const _SqlQueryResult.error(this.error) : columns = const [], rows = const [];
}

/// Terminal-noir palette for the SQL case screen, so it reads as the same
/// product as the landing page and dashboard: near-black surfaces, hairline
/// borders, one hot ember accent, terminal green/cyan for status and links.
/// Kept as a thin facade over [LandingTokens] so every widget in this file
/// stays on the shared design system.
abstract final class _SqlNoir {
  static const background = LandingTokens.voidBlack;
  static const shell = LandingTokens.carbon;
  static const paleAmber = LandingTokens.panel;
  static const paper = LandingTokens.carbon;
  static const brown = LandingTokens.panelRaised;
  static const ink = LandingTokens.textPrimary;
  static const bodyInk = LandingTokens.textMuted;
  static const muted = LandingTokens.textFaint;
  static const cream = LandingTokens.textPrimary;
  static const border = LandingTokens.hairline;
  static const inputBorder = LandingTokens.hairlineStrong;
  static const accent = LandingTokens.ember;

  /// Cyan reserved for foreign-key links/relationships in the schema browser.
  static const link = LandingTokens.circuit;

  /// Text/icon color that sits on a solid ember fill.
  static const onAccent = Color(0xFF0A0500);

  static const success = TextStyle(
    color: LandingTokens.signal,
    fontWeight: FontWeight.w700,
  );
  static const error = TextStyle(
    color: Color(0xFFFF6B6B),
    fontWeight: FontWeight.w600,
  );
  static const heading = TextStyle(
    color: ink,
    fontWeight: FontWeight.w800,
    height: 1.12,
    letterSpacing: -0.3,
  );
  static const body = TextStyle(color: bodyInk, fontSize: 14, height: 1.6);
  static const mutedBody = TextStyle(color: muted, fontSize: 12, height: 1.5);
  static const mono = TextStyle(
    color: ink,
    fontFamily: LandingTokens.monoFontFamily,
    fontFamilyFallback: LandingTokens.monoFontFallback,
    fontSize: 13,
    height: 1.5,
  );
  static const schemaTitle = TextStyle(
    color: cream,
    fontFamily: LandingTokens.monoFontFamily,
    fontFamilyFallback: LandingTokens.monoFontFallback,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );
  static const tableHead = TextStyle(
    color: ink,
    fontFamily: LandingTokens.monoFontFamily,
    fontFamilyFallback: LandingTokens.monoFontFallback,
    fontSize: 11,
    fontWeight: FontWeight.w700,
  );
  static const tableCell = TextStyle(color: ink, fontSize: 12, height: 1.25);
}
