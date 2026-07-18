import 'package:flutter/material.dart';

import '../../core/curriculum/curriculum_module.dart';
import '../../core/curriculum/module_config.dart';
import '../../core/cybersecurity/cyber_room.dart';
import '../theme/landing_tokens.dart';
import '../widgets/cyber_training_components.dart';
import '../widgets/fake_terminal.dart';
import '../widgets/landing/landing_button.dart';

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
      backgroundColor: const Color(0xFF0C0C0C), icon: const Icon(Icons.workspace_premium, color: Color(0xFFFF5C01), size: 44),
      title: const Text('Flag secured!', style: TextStyle(color: Color(0xFFF4F3EF), fontWeight: FontWeight.bold)),
      content: Text('You earned ${room.points} XP and the ${room.badge} badge.', style: const TextStyle(color: Color(0xFFB9B8B0))),
      actions: [FilledButton(onPressed: () => Navigator.pop(context), style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF5C01), foregroundColor: const Color(0xFF0A0500)), child: const Text('Continue'))],
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
    if (snap.connectionState != ConnectionState.done) return const Scaffold(backgroundColor: Color(0xFF070707), body: Center(child: CircularProgressIndicator(color: Color(0xFFFF5C01))));
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
  final CyberRoom room;
  final double progress;
  final VoidCallback onBack;
  const _RoomHeader({
    required this.room,
    required this.progress,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) => Container(
    color: LandingTokens.voidBlack,
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: LandingTokens.carbon,
        borderRadius: LandingTokens.mediumRadius,
        border: Border.all(color: LandingTokens.hairline),
        boxShadow: LandingTokens.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _RoomBackButton(onPressed: onBack),
              const SizedBox(width: 10),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: LandingTokens.ember.withValues(alpha: 0.1),
                  borderRadius: LandingTokens.smallRadius,
                  border: Border.all(
                    color: LandingTokens.ember.withValues(alpha: 0.55),
                  ),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: LandingTokens.ember,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: LandingTokens.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SAFE SIMULATION · ${room.points} XP · ${room.badge}'
                          .toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LandingTokens.label(
                        fontSize: 9.5,
                        color: LandingTokens.textFaint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(progress * 100).round()}%',
                style: LandingTokens.mono(
                  fontSize: 13,
                  color: LandingTokens.ember,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: LandingTokens.hairline,
              color: LandingTokens.ember,
            ),
          ),
        ],
      ),
    ),
  );
}

class _RoomBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _RoomBackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Back to dashboard',
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: LandingTokens.smallRadius,
            border: Border.all(color: LandingTokens.hairlineStrong),
          ),
          child: const Icon(
            Icons.arrow_back,
            color: LandingTokens.textPrimary,
            size: 16,
          ),
        ),
      ),
    ),
  );
}

class _TypedTasks extends StatelessWidget {
  final CyberRoom room;
  final List<TextEditingController> answers;
  final Set<int> done, wrong, hint1, hint2;
  final void Function(int, bool) onHint;
  final ValueChanged<int> onSubmit;
  const _TypedTasks({
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
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: LandingTokens.carbon,
      border: Border.all(color: LandingTokens.hairline),
      borderRadius: LandingTokens.mediumRadius,
      boxShadow: LandingTokens.cardShadow,
    ),
    clipBehavior: Clip.antiAlias,
    child: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          room.scenario,
          style: LandingTokens.body(
            fontSize: 14,
            color: LandingTokens.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < room.tasks.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TaskCard(
              index: i,
              task: room.tasks[i],
              controller: answers[i],
              complete: done.contains(i),
              incorrect: wrong.contains(i),
              firstHint: hint1.contains(i),
              secondHint: hint2.contains(i),
              onHint: onHint,
              onSubmit: onSubmit,
            ),
          ),
      ],
    ),
  );
}

class _TaskCard extends StatelessWidget {
  final int index;
  final CyberTask task;
  final TextEditingController controller;
  final bool complete, incorrect, firstHint, secondHint;
  final void Function(int, bool) onHint;
  final ValueChanged<int> onSubmit;
  const _TaskCard({
    required this.index,
    required this.task,
    required this.controller,
    required this.complete,
    required this.incorrect,
    required this.firstHint,
    required this.secondHint,
    required this.onHint,
    required this.onSubmit,
  });

  static const _hintAmber = Color(0xFFFFD58A);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: complete ? LandingTokens.emberDim : LandingTokens.panel,
      border: Border.all(
        color: complete
            ? LandingTokens.ember.withValues(alpha: 0.5)
            : LandingTokens.hairline,
      ),
      borderRadius: LandingTokens.mediumRadius,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IndexBadge(index: index + 1, complete: complete),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  task.prompt,
                  style: const TextStyle(
                    color: LandingTokens.textPrimary,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (!complete) ...[
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            onSubmitted: (_) => onSubmit(index),
            style: LandingTokens.mono(
              fontSize: 13,
              color: LandingTokens.textPrimary,
            ),
            cursorColor: LandingTokens.ember,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Your answer',
              hintStyle: LandingTokens.mono(
                fontSize: 13,
                color: LandingTokens.textFaint,
              ),
              filled: true,
              fillColor: LandingTokens.voidBlack,
              errorText: incorrect
                  ? 'Not quite — use a hint or keep investigating.'
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: LandingTokens.smallRadius,
                borderSide: BorderSide(color: LandingTokens.hairlineStrong),
              ),
              border: const OutlineInputBorder(
                borderRadius: LandingTokens.smallRadius,
                borderSide: BorderSide(color: LandingTokens.hairlineStrong),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: LandingTokens.smallRadius,
                borderSide: BorderSide(color: LandingTokens.ember, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CinematicOutlineButton(
                onPressed: () => onHint(index, false),
                icon: Icons.lightbulb_outline,
                label: 'Hint',
                compact: true,
              ),
              if (firstHint) ...[
                const SizedBox(width: 8),
                CinematicOutlineButton(
                  onPressed: () => onHint(index, true),
                  icon: Icons.lightbulb,
                  label: 'Hint 2',
                  compact: true,
                ),
              ],
              const Spacer(),
              GradientButton(
                onPressed: () => onSubmit(index),
                icon: Icons.check,
                label: 'Check',
                compact: true,
              ),
            ],
          ),
          if (firstHint)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Hint 1: ${task.hint1}',
                style: LandingTokens.mono(fontSize: 12, color: _hintAmber),
              ),
            ),
          if (secondHint)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Hint 2: ${task.hint2}',
                style: LandingTokens.mono(fontSize: 12, color: _hintAmber),
              ),
            ),
        ] else
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 38),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: LandingTokens.signal,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Solved',
                  style: LandingTokens.label(
                    fontSize: 11,
                    color: LandingTokens.signal,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _IndexBadge extends StatelessWidget {
  final int index;
  final bool complete;
  const _IndexBadge({required this.index, required this.complete});

  @override
  Widget build(BuildContext context) => Container(
    width: 26,
    height: 26,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: complete ? LandingTokens.signal : LandingTokens.ember,
      shape: BoxShape.circle,
    ),
    child: complete
        ? const Icon(Icons.check, size: 15, color: Color(0xFF07110C))
        : Text(
            '$index',
            style: const TextStyle(
              color: Color(0xFF0A0500),
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
  );
}
