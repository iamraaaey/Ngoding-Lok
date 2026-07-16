import 'package:flutter/material.dart';
import '../../core/cybersecurity/cyber_room.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/curriculum/module_config.dart';
import '../widgets/cyber_environments.dart';

class CybersecurityRoomScreen extends StatefulWidget {
  final CurriculumModule module;
  final Future<void> Function({
    required int linesUsed,
    required int executionMs,
  })
  onWin;
  final VoidCallback onBack;
  final CyberRoomProgress? savedProgress;
  final ValueChanged<CyberRoomProgress> onProgressChanged;
  final ValueChanged<String> onBadgeAwarded;
  const CybersecurityRoomScreen({
    super.key,
    required this.module,
    required this.onWin,
    required this.onBack,
    this.savedProgress,
    required this.onProgressChanged,
    required this.onBadgeAwarded,
  });
  @override
  State<CybersecurityRoomScreen> createState() =>
      _CybersecurityRoomScreenState();
}

class _CybersecurityRoomScreenState extends State<CybersecurityRoomScreen> {
  late final DateTime _started = DateTime.now();
  final List<TextEditingController> _answers = [];
  late final Future<CyberRoom> _room;
  final Set<int> _done = {}, _wrong = {}, _hint1 = {}, _hint2 = {};
  bool _finishing = false;
  @override
  void initState() {
    super.initState();
    final c = widget.module.config as CyberSecurityConfig;
    _room = CyberRoomLoader.load(c.roomAsset);
    final saved = widget.savedProgress;
    if (saved != null) {
      _done.addAll(saved.completedTasks);
      _hint1.addAll(saved.hintOneTasks);
      _hint2.addAll(saved.hintTwoTasks);
    }
  }

  int get _elapsedSeconds =>
      (widget.savedProgress?.elapsedSeconds ?? 0) +
      DateTime.now().difference(_started).inSeconds;
  void _saveProgress() => widget.onProgressChanged(
    CyberRoomProgress(
      completedTasks: _done.toList(),
      hintOneTasks: _hint1.toList(),
      hintTwoTasks: _hint2.toList(),
      elapsedSeconds: _elapsedSeconds,
    ),
  );

  Future<void> _showSuccessMessage(CyberRoom room) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0C0C0C),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          side: BorderSide(color: Color(0x8043FFA4)),
        ),
        icon: const Icon(Icons.verified, color: Color(0xFF43FFA4), size: 42),
        title: const Text(
          'Module complete!',
          style: TextStyle(
            color: Color(0xFFF4F3EF),
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Great work. You earned ${room.points} XP and unlocked the ${room.badge} badge.',
          style: const TextStyle(color: Color(0xFF908F88)),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF43FFA4),
              foregroundColor: const Color(0xFF0A0500),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _answers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit(CyberRoom room, int index) async {
    if (_done.contains(index)) return;
    if (!room.tasks[index].accepts(_answers[index].text)) {
      setState(() => _wrong.add(index));
      return;
    }
    setState(() {
      _done.add(index);
      _wrong.remove(index);
    });
    _saveProgress();
    if (_done.length == room.tasks.length && !_finishing) {
      setState(() => _finishing = true);
      widget.onBadgeAwarded(room.badge);
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) {
        await _showSuccessMessage(room);
        if (mounted) {
          await widget.onWin(
            linesUsed: _done.length,
            executionMs: _elapsedSeconds * 1000,
          );
        }
      }
    }
  }

  Future<void> _completeActionRoom(CyberRoom room) async {
    if (_finishing) return;
    setState(() {
      _done.addAll(List.generate(room.tasks.length, (index) => index));
      _finishing = true;
    });
    _saveProgress();
    widget.onBadgeAwarded(room.badge);
    // Leave the auto-shown safety lesson visible before the hub advances.
    await Future.delayed(const Duration(milliseconds: 2400));
    if (mounted) {
      await _showSuccessMessage(room);
      if (mounted) {
        await widget.onWin(linesUsed: 0, executionMs: _elapsedSeconds * 1000);
      }
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<CyberRoom>(
    future: _room,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Scaffold(
          backgroundColor: Color(0xFF070707),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFFFF5C01)),
          ),
        );
      }
      final room = snapshot.data!;
      if (_answers.isEmpty) {
        _answers.addAll(
          List.generate(room.tasks.length, (_) => TextEditingController()),
        );
      }
      // Action-driven rooms intentionally have no typed tasks. Avoid a
      // 0/0 progress value because Flutter renders that as NaN.
      final progress = room.tasks.isEmpty
          ? (_finishing ? 1.0 : 0.0)
          : _done.length / room.tasks.length;
      return Scaffold(
        backgroundColor: const Color(0xFF070707),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                children: [
                  _Header(
                    room: room,
                    progress: progress,
                    onBack: widget.onBack,
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, box) {
                        final tasks = _TaskPanel(
                          room: room,
                          answers: _answers,
                          done: _done,
                          wrong: _wrong,
                          hint1: _hint1,
                          hint2: _hint2,
                          onHint: (i, second) => setState(() {
                            second ? _hint2.add(i) : _hint1.add(i);
                            _saveProgress();
                          }),
                          onSubmit: (i) => _submit(room, i),
                        );
                        final environment = CyberEnvironment(
                          type: room.environment,
                          data: room.environmentData,
                          terminalScript: room.terminalScript,
                          commandHints: room.commandHints,
                          onActionComplete:
                              (room.environment == 'bruteforce' ||
                                  room.environment == 'decision')
                              ? () => _completeActionRoom(room)
                              : null,
                        );
                        final actionOnly =
                            room.environment == 'bruteforce' ||
                            room.environment == 'soc' ||
                            room.environment == 'redblue' ||
                            room.environment == 'decision';
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: box.maxWidth > 860
                              ? SizedBox(
                                  height: 610,
                                  child: actionOnly
                                      ? environment
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(
                                              flex: 6,
                                              child: environment,
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(flex: 5, child: tasks),
                                          ],
                                        ),
                                )
                              : actionOnly
                              ? SizedBox(height: 610, child: environment)
                              : Column(
                                  children: [
                                    SizedBox(height: 410, child: environment),
                                    const SizedBox(height: 16),
                                    tasks,
                                  ],
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _Header extends StatelessWidget {
  final CyberRoom room;
  final double progress;
  final VoidCallback onBack;
  const _Header({
    required this.room,
    required this.progress,
    required this.onBack,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF0C0C0C),
        border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: Color(0xFFF4F3EF)),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.shield_outlined, color: Color(0xFF43FFA4)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.title,
                      style: const TextStyle(
                        color: Color(0xFFF4F3EF),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'SAFE SIMULATION · ${room.points} XP · BADGE: ${room.badge}'
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF908F88),
                        fontSize: 10,
                        fontFamily: 'Consolas',
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Color(0xFF43FFA4),
                  fontFamily: 'Consolas',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF070707),
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF43FFA4),
                  boxShadow: [
                    BoxShadow(color: Color(0x8043FFA4), blurRadius: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskPanel extends StatelessWidget {
  final CyberRoom room;
  final List<TextEditingController> answers;
  final Set<int> done, wrong, hint1, hint2;
  final void Function(int, bool) onHint;
  final ValueChanged<int> onSubmit;
  const _TaskPanel({
    required this.room,
    required this.answers,
    required this.done,
    required this.wrong,
    required this.hint1,
    required this.hint2,
    required this.onHint,
    required this.onSubmit,
  });
  @override
  Widget build(BuildContext context) {
    final vocabulary = switch (room.environment) {
      'browser' => (
        'SQL?',
        'SQL means Structured Query Language, a way applications communicate with databases.',
      ),
      'inbox' => (
        'Phishing?',
        'Phishing is a deceptive message that pressures someone into sharing information or clicking a harmful link.',
      ),
      'cipher' => (
        'Cipher?',
        'A cipher is a method for changing a message so it is not immediately readable.',
      ),
      'files' => (
        'Hidden files?',
        'A hidden file is omitted from ordinary listings. It is not encrypted or automatically secure.',
      ),
      _ => (
        'FTP?',
        'FTP means File Transfer Protocol. It is an older method for moving files between computers.',
      ),
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: ListView(
        children: [
          Text(
            room.scenario,
            style: const TextStyle(color: Color(0xFFB9B8B0), height: 1.35),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF43FFA4),
              ),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(vocabulary.$1),
                  content: Text(vocabulary.$2),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              ),
              icon: const Icon(Icons.help_outline, size: 16),
              label: Text(vocabulary.$1),
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < room.tasks.length; i++)
            _TaskCard(
              index: i,
              task: room.tasks[i],
              answer: answers[i],
              done: done.contains(i),
              wrong: wrong.contains(i),
              showHint1: hint1.contains(i),
              showHint2: hint2.contains(i),
              onHint: (second) => onHint(i, second),
              onSubmit: () => onSubmit(i),
            ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final int index;
  final CyberTask task;
  final TextEditingController answer;
  final bool done, wrong, showHint1, showHint2;
  final ValueChanged<bool> onHint;
  final VoidCallback onSubmit;
  const _TaskCard({
    required this.index,
    required this.task,
    required this.answer,
    required this.done,
    required this.wrong,
    required this.showHint1,
    required this.showHint2,
    required this.onHint,
    required this.onSubmit,
  });
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: done ? const Color(0x1443FFA4) : const Color(0xFF101010),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        color: done ? const Color(0x8043FFA4) : const Color(0x33FFFFFF),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: done
                  ? const Color(0xFF43FFA4)
                  : const Color(0xFFFF5C01),
              child: done
                  ? const Icon(Icons.check, size: 15, color: Color(0xFF0A0500))
                  : Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Color(0xFF0A0500),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SelectableText(
                task.prompt,
                style: const TextStyle(
                  color: Color(0xFFF4F3EF),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        if (!done) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: answer,
                  onSubmitted: (_) => onSubmit(),
                  cursorColor: const Color(0xFFFF5C01),
                  decoration: InputDecoration(
                    hintText: index == 2 ? 'FLAG{...}' : 'Your answer',
                    errorText: wrong
                        ? 'Not quite — use a hint or check the terminal.'
                        : null,
                    isDense: true,
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0x33FFFFFF)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFF5C01)),
                    ),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: const Color(0xFF070707),
                    hintStyle: const TextStyle(color: Color(0xFF56554F)),
                    labelStyle: const TextStyle(color: Color(0xFF908F88)),
                  ),
                  style: const TextStyle(color: Color(0xFFF4F3EF)),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5C01),
                  foregroundColor: const Color(0xFF0A0500),
                ),
                child: const Text('Check'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF43FFA4),
            ),
            onPressed: () => onHint(showHint1),
            icon: const Icon(Icons.lightbulb_outline, size: 16),
            label: Text(showHint1 ? 'Show next hint' : 'Hint'),
          ),
          if (showHint1) _Hint(text: task.hint1),
          if (showHint2) _Hint(text: task.hint2),
        ] else if (task.learn != null)
          _Learn(learn: task.learn!),
      ],
    ),
  );
}

class _Hint extends StatelessWidget {
  final String text;
  const _Hint({required this.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 5),
    child: SelectableText(
      'Hint: $text',
      style: const TextStyle(color: Color(0xFF5C4B12), fontSize: 12),
    ),
  );
}

class _Learn extends StatelessWidget {
  final CyberLearn learn;
  const _Learn({required this.learn});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFDDEEFF),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          'Learn: ${learn.title}',
          style: const TextStyle(
            color: Color(0xFF123B5A),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        SelectableText(
          learn.body,
          style: const TextStyle(
            color: Color(0xFF123B5A),
            fontSize: 12,
            height: 1.25,
          ),
        ),
      ],
    ),
  );
}
