import 'package:flutter/material.dart';

import '../../core/curriculum/curriculum_module.dart';
import '../../core/curriculum/module_config.dart';
import '../../core/cybersecurity/cyber_room.dart';
import '../widgets/cyber_training_components.dart';
import '../widgets/fake_terminal.dart';

/// The shell for all five Cybersecurity Track rooms. It owns only shared room
/// state; each environment is a reusable, config-driven training component.
class CybersecurityRoomScreen extends StatefulWidget {
  final CurriculumModule module;
  final Future<void> Function({required int linesUsed, required int executionMs}) onWin;
  final VoidCallback onBack;
  final CyberRoomProgress? savedProgress;
  final ValueChanged<CyberRoomProgress> onProgressChanged;
  final ValueChanged<String> onBadgeAwarded;
  const CybersecurityRoomScreen({super.key, required this.module, required this.onWin, required this.onBack, this.savedProgress, required this.onProgressChanged, required this.onBadgeAwarded});
  @override State<CybersecurityRoomScreen> createState() => _CybersecurityRoomScreenState();
}

class _CybersecurityRoomScreenState extends State<CybersecurityRoomScreen> {
  late final DateTime _started = DateTime.now();
  late final Future<CyberRoom> _room;
  final List<TextEditingController> _answers = [];
  final Set<int> _done = {}, _wrong = {}, _hint1 = {}, _hint2 = {};
  bool _intro = true, _learn = false, _finishing = false;
  int _actionHints = 0;

  @override void initState() {
    super.initState();
    _room = CyberRoomLoader.load((widget.module.config as CyberSecurityConfig).roomAsset);
    final saved = widget.savedProgress;
    if (saved != null) { _done.addAll(saved.completedTasks); _hint1.addAll(saved.hintOneTasks); _hint2.addAll(saved.hintTwoTasks); _actionHints = saved.actionHintsUsed; }
  }
  int get _elapsed => (widget.savedProgress?.elapsedSeconds ?? 0) + DateTime.now().difference(_started).inSeconds;
  void _save() => widget.onProgressChanged(CyberRoomProgress(completedTasks: _done.toList(), hintOneTasks: _hint1.toList(), hintTwoTasks: _hint2.toList(), elapsedSeconds: _elapsed, actionHintsUsed: _actionHints));
  @override void dispose() { for (final c in _answers) { c.dispose(); } super.dispose(); }

  Future<void> _finish(CyberRoom room) async {
    if (_finishing) return;
    setState(() { _finishing = true; _learn = true; _done.addAll(List.generate(room.tasks.isEmpty ? 1 : room.tasks.length, (i) => i)); });
    _save(); widget.onBadgeAwarded(room.badge);
  }
  Future<void> _leaveAfterLearn(CyberRoom room) async {
    if (!mounted) return;
    await showDialog<void>(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF0C0C0C), icon: const Icon(Icons.workspace_premium, color: Color(0xFF43FFA4), size: 44),
      title: const Text('Flag secured!', style: TextStyle(color: Color(0xFFF4F3EF), fontWeight: FontWeight.bold)),
      content: Text('You earned ${room.points} XP and the ${room.badge} badge.', style: const TextStyle(color: Color(0xFFB9B8B0))),
      actions: [FilledButton(onPressed: () => Navigator.pop(context), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF43FFA4), foregroundColor: const Color(0xFF07110C)), child: const Text('Continue'))],
    ));
    if (mounted) await widget.onWin(linesUsed: _done.length, executionMs: _elapsed * 1000);
  }
  void _submit(CyberRoom room, int i) {
    if (_finishing || _done.contains(i)) return;
    if (!room.tasks[i].accepts(_answers[i].text)) { setState(() => _wrong.add(i)); return; }
    setState(() { _done.add(i); _wrong.remove(i); }); _save();
    if (_done.length == room.tasks.length) _finish(room);
  }
  void _actionHint(int count) { if (!mounted) return; setState(() => _actionHints = count); _save(); }

  @override Widget build(BuildContext context) => FutureBuilder<CyberRoom>(future: _room, builder: (context, snap) {
    if (snap.connectionState != ConnectionState.done) return const Scaffold(backgroundColor: Color(0xFF070707), body: Center(child: CircularProgressIndicator(color: Color(0xFF43FFA4))));
    final room = snap.data ?? CyberRoom.fromJson(const {});
    if (_answers.isEmpty && room.tasks.isNotEmpty) _answers.addAll(List.generate(room.tasks.length, (_) => TextEditingController()));
    if (_intro) return Scaffold(backgroundColor: const Color(0xFF070707), body: SafeArea(child: Padding(padding: const EdgeInsets.all(18), child: TopicBriefLearnPanel(learn: false, title: room.topicTitle, body: room.topicBrief, actionLabel: 'Start safe simulation', onAction: () => setState(() => _intro = false)))));
    if (_learn) return Scaffold(backgroundColor: const Color(0xFF070707), body: SafeArea(child: Padding(padding: const EdgeInsets.all(18), child: TopicBriefLearnPanel(learn: true, title: room.learn.title, body: room.learn.body, actionLabel: 'Claim ${room.badge}', onAction: () => _leaveAfterLearn(room)))));
    final actionRoom = const {'evidence', 'ladder', 'phish', 'injection', 'capstone', 'malware', 'mitm'}
        .contains(room.environment);
    final progress = room.tasks.isEmpty ? 0.0 : _done.length / room.tasks.length;
    return Scaffold(backgroundColor: const Color(0xFF070707), body: SafeArea(child: Column(children: [
      _RoomHeader(room: room, progress: progress, onBack: widget.onBack),
      Expanded(child: LayoutBuilder(builder: (context, size) {
        final environment = _environment(room);
        final typed = _TypedTasks(room: room, answers: _answers, done: _done, wrong: _wrong, hint1: _hint1, hint2: _hint2, onHint: (index, two) { setState(() { if (two) { _hint2.add(index); } else { _hint1.add(index); } }); _save(); }, onSubmit: (i) => _submit(room, i));
        return Padding(padding: const EdgeInsets.all(16), child: actionRoom
          ? environment
          : size.maxWidth > 880
            ? Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(flex: 6, child: environment), const SizedBox(width: 16), Expanded(flex: 5, child: typed)])
            : Column(children: [Expanded(child: environment), const SizedBox(height: 16), Expanded(child: typed)]));
      }))
    ])));
  });
  Widget _environment(CyberRoom room) => switch (room.environment) {
    'browser' => FakeBrowserTraining(data: room.environmentData),
    'evidence' => EvidenceTrayPanel(data: room.environmentData, malware: room.environmentData['domain'] == 'malware', onHintUsed: _actionHint, onComplete: () => _finish(room)),
    'ladder' => InvestigatePanel(data: room.environmentData, onHintUsed: _actionHint, onComplete: () => _finish(room)),
    'phish' => PhishingEmailPanel(data: room.environmentData, onHintUsed: _actionHint, onComplete: () => _finish(room)),
    'injection' => InjectionBlockPanel(data: room.environmentData, onHintUsed: _actionHint, onComplete: () => _finish(room)),
    'capstone' => PhishingToBreachPanel(data: room.environmentData, onHintUsed: _actionHint, onComplete: () => _finish(room)),
    'malware' => MalwareResponsePanel(data: room.environmentData, onHintUsed: _actionHint, onComplete: () => _finish(room)),
    'mitm' => MitmTrapPanel(data: room.environmentData, onHintUsed: _actionHint, onComplete: () => _finish(room)),
    _ => FakeTerminal(script: room.terminalScript, hints: room.commandHints),
  };
}

class _RoomHeader extends StatelessWidget {
  final CyberRoom room; final double progress; final VoidCallback onBack;
  const _RoomHeader({required this.room, required this.progress, required this.onBack});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.fromLTRB(12, 10, 18, 12), color: const Color(0xFF0C0C0C), child: Column(children: [
    Row(children: [IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back, color: Color(0xFFF4F3EF))), const Icon(Icons.shield_outlined, color: Color(0xFF43FFA4)), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(room.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFF4F3EF), fontSize: 18, fontWeight: FontWeight.w800)), Text('SAFE SIMULATION · ${room.points} XP · ${room.badge}'.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF908F88), fontFamily: 'monospace', fontSize: 10))])), Text('${(progress * 100).round()}%', style: const TextStyle(color: Color(0xFF43FFA4), fontFamily: 'monospace'))]),
    const SizedBox(height: 9), LinearProgressIndicator(value: progress, minHeight: 5, backgroundColor: const Color(0xFF202020), color: const Color(0xFF43FFA4)),
  ]));
}

class _TypedTasks extends StatelessWidget {
  final CyberRoom room; final List<TextEditingController> answers; final Set<int> done, wrong, hint1, hint2; final void Function(int, bool) onHint; final ValueChanged<int> onSubmit;
  const _TypedTasks({required this.room, required this.answers, required this.done, required this.wrong, required this.hint1, required this.hint2, required this.onHint, required this.onSubmit});
  @override Widget build(BuildContext context) => Container(decoration: BoxDecoration(color: const Color(0xFF0C0C0C), border: Border.all(color: const Color(0x22FFFFFF)), borderRadius: BorderRadius.circular(6)), child: ListView(padding: const EdgeInsets.all(16), children: [
    Text(room.scenario, style: const TextStyle(color: Color(0xFFCFCEC7), height: 1.35)), const SizedBox(height: 12),
    for (var i = 0; i < room.tasks.length; i++) _TaskCard(index: i, task: room.tasks[i], controller: answers[i], complete: done.contains(i), incorrect: wrong.contains(i), firstHint: hint1.contains(i), secondHint: hint2.contains(i), onHint: onHint, onSubmit: onSubmit),
  ]));
}
class _TaskCard extends StatelessWidget {
  final int index; final CyberTask task; final TextEditingController controller; final bool complete, incorrect, firstHint, secondHint; final void Function(int, bool) onHint; final ValueChanged<int> onSubmit;
  const _TaskCard({required this.index, required this.task, required this.controller, required this.complete, required this.incorrect, required this.firstHint, required this.secondHint, required this.onHint, required this.onSubmit});
  @override Widget build(BuildContext context) => Card(color: complete ? const Color(0xFF102419) : const Color(0xFF151515), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('TASK ${index + 1}', style: const TextStyle(color: Color(0xFF43FFA4), fontFamily: 'monospace', fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(task.prompt, style: const TextStyle(color: Color(0xFFF4F3EF), height: 1.25)), if (!complete) ...[
      const SizedBox(height: 10), TextField(controller: controller, onSubmitted: (_) => onSubmit(index), style: const TextStyle(color: Colors.white, fontFamily: 'monospace'), decoration: InputDecoration(errorText: incorrect ? 'Not quite — use a hint or keep investigating.' : null, border: const OutlineInputBorder(), isDense: true)), const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 6, children: [OutlinedButton(onPressed: () => onHint(index, false), child: const Text('Hint 1')), if (firstHint) OutlinedButton(onPressed: () => onHint(index, true), child: const Text('Hint 2')), FilledButton(onPressed: () => onSubmit(index), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF43FFA4), foregroundColor: const Color(0xFF07110C)), child: const Text('Submit'))]),
      if (firstHint) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Hint 1: ${task.hint1}', style: const TextStyle(color: Color(0xFFFFD58A)))), if (secondHint) Padding(padding: const EdgeInsets.only(top: 5), child: Text('Hint 2: ${task.hint2}', style: const TextStyle(color: Color(0xFFFFD58A)))),
    ] else const Padding(padding: EdgeInsets.only(top: 8), child: Text('✓ Complete', style: TextStyle(color: Color(0xFF43FFA4), fontWeight: FontWeight.bold))),
  ])));
}
