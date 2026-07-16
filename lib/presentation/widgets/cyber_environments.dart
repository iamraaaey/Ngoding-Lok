import 'dart:async';
import 'package:flutter/material.dart';
import 'fake_terminal.dart';

class CyberEnvironment extends StatelessWidget {
  final String type;
  final Map<String, dynamic> data;
  final Map<String, String> terminalScript, commandHints;
  final VoidCallback? onActionComplete;
  const CyberEnvironment({
    super.key,
    required this.type,
    required this.data,
    required this.terminalScript,
    required this.commandHints,
    this.onActionComplete,
  });
  @override
  Widget build(BuildContext context) {
    if (type == 'browser') return FakeBrowserMock(data: data);
    if (type == 'inbox') return FakeInboxMock(data: data);
    if (type == 'cipher') return FakeCipherTool(data: data);
    if (type == 'files') return FakeFileExplorer(data: data);
    if (type == 'bruteforce') {
      return FakeBruteForceSimulator(data: data, onComplete: onActionComplete);
    }
    if (type == 'soc') {
      return FakeSocDashboard(data: data, onComplete: onActionComplete);
    }
    if (type == 'redblue') {
      return FakeRedBlueScenario(data: data, onComplete: onActionComplete);
    }
    if (type == 'decision') {
      return DecisionTreeEnvironment(data: data, onComplete: onActionComplete);
    }
    return FakeTerminal(script: terminalScript, hints: commandHints);
  }
}

class FakeBruteForceSimulator extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onComplete;
  const FakeBruteForceSimulator({
    super.key,
    required this.data,
    this.onComplete,
  });
  @override
  State<FakeBruteForceSimulator> createState() => _FakeBruteForceState();
}

class _FakeBruteForceState extends State<FakeBruteForceSimulator> {
  Timer? _timer;
  final List<String> _logs = [];
  int _attempt = 0;
  bool _running = false, _found = false, _loggedIn = false;
  String _size = 'Small';
  List<String> get _attempts =>
      (widget.data['attempts'] as List).cast<String>();
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _launch() {
    if (_running || _found) return;
    setState(() {
      _running = true;
      _logs.clear();
      _attempt = 0;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 380), (timer) {
      if (!mounted) return;
      if (_attempt >= _attempts.length) {
        timer.cancel();
        setState(() {
          _running = false;
          _found = true;
        });
        return;
      }
      final credential = _attempts[_attempt++];
      setState(
        () => _logs.add(
          'trying admin:$credential... ${credential == widget.data['winningPassword'] ? '✓' : '✗'}',
        ),
      );
    });
  }

  void _useCredentials() {
    setState(() => _loggedIn = true);
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) => _Shell(
    'Attack Console · simulated only',
    Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0x2EFF5C01),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0x66FF5C01)),
            ),
            child: Row(
              children: [
                Icon(
                  _loggedIn ? Icons.lock_open : Icons.lock,
                  color: _loggedIn
                      ? const Color(0xFF43FFA4)
                      : const Color(0xFFFF7A2F),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _loggedIn
                        ? 'Admin panel unlocked (training mockup)'
                        : 'Fictional admin login · locked',
                    style: const TextStyle(
                      color: Color(0xFFFF7A2F),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (_loggedIn)
                  Text(
                    '${widget.data['flag']}',
                    style: const TextStyle(
                      color: Color(0xFF43FFA4),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Wordlist size:',
                style: TextStyle(
                  color: Color(0xFFCFCEC7),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _size,
                style: const TextStyle(color: Color(0xFFF4F3EF)),
                items: const [
                  DropdownMenuItem(value: 'Small', child: Text('Small')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                ],
                onChanged: _running ? null : (v) => setState(() => _size = v!),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF050505),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0x1AFFFFFF)),
              ),
              child: ListView(
                children: [
                  if (_logs.isEmpty)
                    const Text(
                      'Ready. This is a fixed, scripted animation—not real cracking.',
                      style: TextStyle(
                        color: Color(0xFF908F88),
                        fontFamily: 'monospace',
                      ),
                    ),
                  for (final line in _logs)
                    Text(
                      line,
                      style: TextStyle(
                        color: line.endsWith('✓')
                            ? const Color(0xFF43FFA4)
                            : const Color(0xFFCFCEC7),
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (!_found)
            FilledButton.icon(
              onPressed: _running ? null : _launch,
              icon: const Icon(Icons.play_arrow),
              label: Text(_running ? 'Attack running…' : 'Launch Attack'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF5C01),
                foregroundColor: const Color(0xFF0A0500),
              ),
            )
          else if (!_loggedIn)
            FilledButton.icon(
              onPressed: _useCredentials,
              icon: const Icon(Icons.login),
              label: const Text('Use Credentials'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF43FFA4),
                foregroundColor: const Color(0xFF0A0500),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0x1443FFA4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                'Learn: ${widget.data['learnTitle']}\n\n${widget.data['learnBody']}',
                style: const TextStyle(color: Color(0xFF43FFA4), height: 1.3),
              ),
            ),
        ],
      ),
    ),
  );
}

class FakeSocDashboard extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onComplete;
  const FakeSocDashboard({super.key, required this.data, this.onComplete});
  @override
  State<FakeSocDashboard> createState() => _SocState();
}

class _SocState extends State<FakeSocDashboard> {
  final Set<int> _blocked = {};
  String? _feedback;
  bool _won = false;
  List<Map<String, dynamic>> get _feed => (widget.data['feed'] as List)
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();
  void _block(int index) {
    final item = _feed[index];
    if (item['malicious'] == true) {
      setState(() {
        _blocked.add(index);
        _feedback = 'Threat blocked — nice read!';
        if (_blocked.length >= (widget.data['threshold'] as int)) _won = true;
      });
      if (_blocked.length >= (widget.data['threshold'] as int)) {
        widget.onComplete?.call();
      }
    } else {
      setState(
        () => _feedback =
            'That was legitimate traffic — check the pattern again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) => _Shell(
    'SOC Dashboard · Security Operations Center',
    Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0x1A00E5FF),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0x3300E5FF)),
            ),
            child: const Text(
              'SOC = Security Operations Center. Block red entries with repeated failures, odd hours, or unusual locations.',
              style: TextStyle(
                color: Color(0xFF9DEEFF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                for (var i = 0; i < _feed.length; i++)
                  _TrafficRow(
                    item: _feed[i],
                    blocked: _blocked.contains(i),
                    onBlock: () => _block(i),
                  ),
              ],
            ),
          ),
          if (_feedback != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                _feedback!,
                style: TextStyle(
                  color: _feedback!.startsWith('Threat')
                      ? const Color(0xFF43FFA4)
                      : const Color(0xFFFF7A2F),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (_won)
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0x1443FFA4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                'Breach Prevented!\n${widget.data['flag']}\n\nLearn: ${widget.data['learnBody']}',
                style: const TextStyle(
                  color: Color(0xFF43FFA4),
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _TrafficRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool blocked;
  final VoidCallback onBlock;
  const _TrafficRow({
    required this.item,
    required this.blocked,
    required this.onBlock,
  });
  @override
  Widget build(BuildContext context) => Card(
    color: item['malicious'] == true
        ? const Color(0x1FFF6B6B)
        : const Color(0xFF101010),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
      side: const BorderSide(color: Color(0x1AFFFFFF)),
    ),
    child: ListTile(
      leading: Icon(
        item['malicious'] == true ? Icons.warning_amber : Icons.check_circle,
        color: item['malicious'] == true
            ? const Color(0xFFFF6B6B)
            : const Color(0xFF43FFA4),
      ),
      title: Text(
        item['text'] as String,
        style: const TextStyle(
          color: Color(0xFFF4F3EF),
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        item['reason'] as String,
        style: const TextStyle(color: Color(0xFF908F88)),
      ),
      trailing: blocked
          ? const Icon(Icons.block, color: Color(0xFFFF6B6B))
          : OutlinedButton(
              onPressed: onBlock,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF6B6B),
              ),
              child: const Text('Block'),
            ),
    ),
  );
}

class FakeRedBlueScenario extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onComplete;
  const FakeRedBlueScenario({super.key, required this.data, this.onComplete});
  @override
  State<FakeRedBlueScenario> createState() => _RedBlueState();
}

class _RedBlueState extends State<FakeRedBlueScenario> {
  int _phase = 0, _step = 0;
  bool _complete = false;
  List<Map<String, dynamic>> get _attacker =>
      (widget.data['attackerSteps'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
  List<Map<String, dynamic>> get _defender =>
      (widget.data['defenderSteps'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
  void _advance() {
    final steps = _phase == 0 ? _attacker : _defender;
    setState(() {
      _step++;
      if (_step >= steps.length && _phase == 0) {
        _phase = 1;
        _step = 0;
      } else if (_step >= steps.length) {
        _complete = true;
      }
    });
    if (_complete) widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _phase == 0 ? _attacker : _defender;
    final current = _complete ? null : steps[_step];
    return _Shell(
      'Red Team vs Blue Team · capstone',
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _complete
                  ? 'Capstone complete'
                  : _phase == 0
                  ? 'PHASE 1 · Red Team: explore the flaw'
                  : 'PHASE 2 · Blue Team: fix the flaw',
              style: const TextStyle(
                color: Color(0xFFF4F3EF),
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _complete ? 1 : (_phase * 3 + _step) / 6,
              color: _phase == 0
                  ? const Color(0xFFFF6B6B)
                  : const Color(0xFF43FFA4),
              backgroundColor: const Color(0xFF161616),
            ),
            const SizedBox(height: 16),
            if (current != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _phase == 0
                      ? const Color(0x1FFF6B6B)
                      : const Color(0x1443FFA4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  current['response'] as String,
                  style: const TextStyle(
                    color: Color(0xFFCFCEC7),
                    height: 1.35,
                  ),
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _advance,
                icon: Icon(_phase == 0 ? Icons.bolt : Icons.build),
                label: Text(current['label'] as String),
                style: FilledButton.styleFrom(
                  backgroundColor: _phase == 0
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF43FFA4),
                  foregroundColor: const Color(0xFF0A0500),
                ),
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(12),
                color: const Color(0x1443FFA4),
                child: SelectableText(
                  'Captured flag: ${widget.data['flag1']}\nPatched-system flag: ${widget.data['flag2']}\n\nLearn: ${widget.data['learnBody']}',
                  style: const TextStyle(
                    color: Color(0xFF43FFA4),
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DecisionTreeEnvironment extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onComplete;
  const DecisionTreeEnvironment({
    super.key,
    required this.data,
    this.onComplete,
  });
  @override
  State<DecisionTreeEnvironment> createState() => _DecisionTreeState();
}

class _DecisionTreeState extends State<DecisionTreeEnvironment> {
  int _step = 0, _service = -1, _method = -1, _threats = 0;
  final Set<int> _evidence = {}, _blocked = {};
  String? _feedback;
  bool _complete = false;
  // Environment data is intentionally separate from the room metadata. Keep
  // the decision widget resilient when an older cached room omits optional
  // fields instead of crashing the whole Flutter view with a null cast.
  String get mode => (widget.data['mode'] as String?) ?? 'room3';
  String get title =>
      (widget.data['title'] as String?) ??
      switch (mode) {
        'room4' => 'SOC Dashboard Defense',
        'room5' => 'Red Team, Then Blue Team',
        _ => 'Pick the Right Exploit',
      };
  List<Map<String, dynamic>> _maps(String key) => (widget.data[key] as List)
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();
  void _finish() {
    if (_complete) return;
    setState(() => _complete = true);
    widget.onComplete?.call();
  }

  Widget _learn() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0x1443FFA4),
      borderRadius: BorderRadius.circular(9),
    ),
    child: SelectableText(
      'Learn: ${widget.data['learnBody']}\n\n${widget.data['flag'] ?? '${widget.data['flag1']}\n${widget.data['flag2'] ?? ''}'}',
      style: const TextStyle(
        color: Color(0xFF43FFA4),
        height: 1.35,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
  void _pair() {
    final services = _maps('services');
    final methods = _maps('methods');
    final correctService =
        services[_service]['id'] == widget.data['correctService'];
    final correctMethod =
        methods[_method]['id'] == widget.data['correctMethod'];
    if (correctService && correctMethod) {
      _finish();
    } else {
      setState(
        () => _feedback =
            'That pairing failed in the scripted lab. Re-read the service banner and try again.',
      );
    }
  }

  void _block(int index) {
    final feed = _maps('feed');
    final selected = _evidence.length;
    if (selected < 2) {
      setState(
        () => _feedback =
            'Select at least two supporting signals before blocking.',
      );
      return;
    }
    if (feed[index]['malicious'] != true) {
      setState(() {
        _feedback =
            'That traffic is legitimate. One unusual detail is not enough evidence.';
        _evidence.clear();
      });
      return;
    }
    setState(() {
      _blocked.add(index);
      _evidence.clear();
      _feedback = 'Good correlation — threat blocked.';
      _threats++;
    });
    if (_threats >= (widget.data['threshold'] as int)) _finish();
  }

  void _choose(int optionIndex) {
    final steps = _maps('steps');
    final options = (steps[_step]['options'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final option = options[optionIndex];
    if (option['correct'] == true) {
      if (_step + 1 >= steps.length) {
        _finish();
      } else {
        setState(() {
          _step++;
          _feedback = option['response'] as String;
        });
      }
    } else {
      setState(() => _feedback = option['feedback'] as String);
    }
  }

  Widget _room3() {
    final services = _maps('services');
    final methods = _maps('methods');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Scan results',
          style: TextStyle(
            color: Color(0xFFF4F3EF),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        for (var i = 0; i < services.length; i++)
          Card(
            color: _service == i
                ? const Color(0x2600E5FF)
                : const Color(0xFF101010),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(
                color: _service == i
                    ? const Color(0x6600E5FF)
                    : const Color(0x1AFFFFFF),
              ),
            ),
            child: ListTile(
              onTap: () => setState(() => _service = i),
              title: Text(
                '${services[i]['port']} · ${services[i]['service']}',
                style: const TextStyle(
                  color: Color(0xFFF4F3EF),
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                '${services[i]['version']}\n${services[i]['banner']}',
                style: const TextStyle(color: Color(0xFF908F88)),
              ),
            ),
          ),
        const SizedBox(height: 8),
        const Text(
          'Choose an attack method to match the clue',
          style: TextStyle(
            color: Color(0xFFF4F3EF),
            fontWeight: FontWeight.w800,
          ),
        ),
        for (var i = 0; i < methods.length; i++)
          Card(
            color: _method == i
                ? const Color(0x2EFF5C01)
                : const Color(0xFF101010),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(
                color: _method == i
                    ? const Color(0x66FF5C01)
                    : const Color(0x1AFFFFFF),
              ),
            ),
            child: ListTile(
              onTap: () => setState(() => _method = i),
              leading: const Icon(
                Icons.build_outlined,
                color: Color(0xFFFF7A2F),
              ),
              title: Text(
                methods[i]['label'] as String,
                style: const TextStyle(
                  color: Color(0xFFF4F3EF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        FilledButton(
          onPressed: _service >= 0 && _method >= 0 ? _pair : null,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF5C01),
            foregroundColor: const Color(0xFF0A0500),
          ),
          child: const Text('Match & Test'),
        ),
        if (_feedback != null)
          Text(
            _feedback!,
            style: const TextStyle(
              color: Color(0xFFFF7A2F),
              fontWeight: FontWeight.w700,
            ),
          ),
        if (_complete) _learn(),
      ],
    );
  }

  Widget _room4() {
    final feed = _maps('feed');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Build the case: select at least two supporting signals before committing a block.',
          style: TextStyle(
            color: Color(0xFFF4F3EF),
            fontWeight: FontWeight.w800,
          ),
        ),
        for (var i = 0; i < feed.length; i++)
          Card(
            color: _blocked.contains(i)
                ? const Color(0x1443FFA4)
                : const Color(0xFF101010),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: const BorderSide(color: Color(0x1AFFFFFF)),
            ),
            child: ExpansionTile(
              shape: const Border(),
              collapsedShape: const Border(),
              title: Text(
                feed[i]['summary'] as String,
                style: const TextStyle(
                  color: Color(0xFFF4F3EF),
                  fontWeight: FontWeight.w700,
                ),
              ),
              children: [
                for (var j = 0; j < (feed[i]['signals'] as List).length; j++)
                  CheckboxListTile(
                    value: _evidence.contains(i * 10 + j),
                    onChanged: _blocked.contains(i)
                        ? null
                        : (v) => setState(
                            () => v == true
                                ? _evidence.add(i * 10 + j)
                                : _evidence.remove(i * 10 + j),
                          ),
                    title: Text(
                      (feed[i]['signals'] as List)[j] as String,
                      style: const TextStyle(color: Color(0xFFCFCEC7)),
                    ),
                  ),
                if (!_blocked.contains(i))
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        final ids = _evidence
                            .where((id) => id ~/ 10 == i)
                            .toSet();
                        if (ids.length < 2) {
                          setState(
                            () => _feedback =
                                'Select two signals inside this entry first.',
                          );
                          return;
                        }
                        _block(i);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFF6B6B),
                      ),
                      child: const Text('Commit Block'),
                    ),
                  ),
              ],
            ),
          ),
        if (_feedback != null)
          Text(
            _feedback!,
            style: const TextStyle(
              color: Color(0xFFFF7A2F),
              fontWeight: FontWeight.w700,
            ),
          ),
        if (_complete) _learn(),
      ],
    );
  }

  Widget _room5() {
    final steps = _maps('steps');
    final step = steps[_step];
    final options = (step['options'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0x33FFFFFF)),
          ),
          child: Text(
            step['context'] as String,
            style: const TextStyle(
              color: Color(0xFFF4F3EF),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < options.length; i++)
          Card(
            color: const Color(0xFF101010),
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: const BorderSide(color: Color(0x33FFFFFF)),
            ),
            child: ListTile(
              dense: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              onTap: () => _choose(i),
              title: Text(
                options[i]['label'] as String,
                style: const TextStyle(
                  color: Color(0xFFF4F3EF),
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Color(0xFF908F88),
              ),
            ),
          ),
        if (_feedback != null)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0x2EFF5C01),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0x66FF5C01)),
            ),
            child: Text(
              _feedback!,
              style: const TextStyle(
                color: Color(0xFFFF9A5C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        if (_complete) _learn(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => _Shell(
    title,
    SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: mode == 'room3'
          ? _room3()
          : mode == 'room4'
          ? _room4()
          : _room5(),
    ),
  );
}

class _Shell extends StatelessWidget {
  final String title;
  final Widget child;
  const _Shell(this.title, this.child);
  @override
  Widget build(BuildContext c) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: const Color(0xFF0C0C0C),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: const Color(0x1AFFFFFF)),
    ),
    child: Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(11),
          decoration: const BoxDecoration(
            color: Color(0xFF161616),
            border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
          ),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFF4F3EF),
              fontFamily: 'Consolas',
              fontSize: 11,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    ),
  );
}

class FakeBrowserMock extends StatefulWidget {
  final Map<String, dynamic> data;
  const FakeBrowserMock({super.key, required this.data});
  @override
  State<FakeBrowserMock> createState() => _BrowserState();
}

class _BrowserState extends State<FakeBrowserMock> {
  final input = TextEditingController();
  bool admin = false, inspect = false;
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => _Shell(
    'Browser mockup',
    Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.data['url'] as String,
            style: const TextStyle(
              color: Color(0xFFCFCEC7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          if (!admin) ...[
            Text(
              widget.data['siteTitle'] as String,
              style: const TextStyle(
                color: Color(0xFFF4F3EF),
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextField(
              controller: input,
              cursorColor: const Color(0xFFFF5C01),
              decoration: const InputDecoration(
                labelText: 'Username or password',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0x33FFFFFF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF5C01)),
                ),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFF070707),
                labelStyle: TextStyle(color: Color(0xFF908F88)),
              ),
              style: const TextStyle(color: Color(0xFFF4F3EF)),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: () => setState(
                () => admin = input.text.trim() == widget.data['injection'],
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF5C01),
                foregroundColor: const Color(0xFF0A0500),
              ),
              child: const Text('Sign in'),
            ),
          ] else ...[
            const Text(
              'Admin panel (simulated)',
              style: TextStyle(
                color: Color(0xFFF4F3EF),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () => setState(() => inspect = !inspect),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF5C01),
              ),
              child: const Text('Open simulated Inspect panel'),
            ),
            if (inspect)
              Text(
                '<!-- ${widget.data['flag']} -->',
                style: const TextStyle(
                  color: Color(0xFF43FFA4),
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ],
      ),
    ),
  );
}

class FakeInboxMock extends StatefulWidget {
  final Map<String, dynamic> data;
  const FakeInboxMock({super.key, required this.data});
  @override
  State<FakeInboxMock> createState() => _InboxState();
}

class _InboxState extends State<FakeInboxMock> {
  final Set<int> marked = {};
  @override
  Widget build(BuildContext c) {
    final emails = List<Map<String, dynamic>>.from(
      (widget.data['emails'] as List).map(
        (e) => Map<String, dynamic>.from(e as Map),
      ),
    );
    final total = emails.where((e) => e['phishing'] == true).length;
    final won = marked.length == total;
    return _Shell(
      'Email inbox mockup',
      Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                for (var i = 0; i < emails.length; i++)
                  ListTile(
                    leading: Icon(
                      marked.contains(i) ? Icons.flag : Icons.mail_outline,
                    ),
                    title: Text(
                      emails[i]['subject'] as String,
                      style: const TextStyle(
                        color: Color(0xFFF4F3EF),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      emails[i]['sender'] as String,
                      style: const TextStyle(color: Color(0xFF908F88)),
                    ),
                    onTap: () => showDialog(
                      context: c,
                      builder: (_) => AlertDialog(
                        title: Text(
                          emails[i]['subject'] as String,
                          style: const TextStyle(color: Color(0xFFF4F3EF)),
                        ),
                        content: Text(
                          emails[i]['body'] as String,
                          style: const TextStyle(color: Color(0xFFCFCEC7)),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFFF5C01),
                            ),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.flag_outlined),
                      onPressed: () => setState(
                        () => marked.contains(i)
                            ? marked.remove(i)
                            : marked.add(i),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (won)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Nice spotting! ${widget.data['flag']}',
                style: const TextStyle(
                  color: Color(0xFF43FFA4),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FakeCipherTool extends StatefulWidget {
  final Map<String, dynamic> data;
  const FakeCipherTool({super.key, required this.data});
  @override
  State<FakeCipherTool> createState() => _CipherState();
}

class _CipherState extends State<FakeCipherTool> {
  int shift = 0;
  @override
  Widget build(BuildContext c) => _Shell(
    'Cipher puzzle',
    Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Encoded: ${widget.data['encoded']}',
            style: const TextStyle(
              color: Color(0xFFF4F3EF),
              fontSize: 20,
              fontFamily: 'monospace',
            ),
          ),
          const Spacer(),
          Text(
            'Caesar shift: $shift',
            style: const TextStyle(
              color: Color(0xFFCFCEC7),
              fontWeight: FontWeight.w700,
            ),
          ),
          Slider(
            value: shift.toDouble(),
            min: 0,
            max: 26,
            divisions: 26,
            onChanged: (v) => setState(() => shift = v.round()),
          ),
          if (shift == widget.data['correctShift'])
            Text(
              'Decoded: ${widget.data['decoded']}\n${widget.data['flag']}',
              style: const TextStyle(
                color: Color(0xFF43FFA4),
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    ),
  );
}

class FakeFileExplorer extends StatefulWidget {
  final Map<String, dynamic> data;
  const FakeFileExplorer({super.key, required this.data});
  @override
  State<FakeFileExplorer> createState() => _FilesState();
}

class _FilesState extends State<FakeFileExplorer> {
  bool show = false;
  String? opened;
  @override
  Widget build(BuildContext c) {
    final files = List<Map<String, dynamic>>.from(
      (widget.data['files'] as List).map(
        (e) => Map<String, dynamic>.from(e as Map),
      ),
    ).where((f) => show || f['hidden'] != true).toList();
    return _Shell(
      'File explorer mockup',
      Column(
        children: [
          SwitchListTile(
            title: const Text(
              'Show hidden files',
              style: TextStyle(
                color: Color(0xFFF4F3EF),
                fontWeight: FontWeight.w700,
              ),
            ),
            value: show,
            onChanged: (v) => setState(() => show = v),
          ),
          Expanded(
            child: ListView(
              children: [
                for (final f in files)
                  ListTile(
                    title: Text(
                      f['name'] as String,
                      style: const TextStyle(
                        color: Color(0xFFF4F3EF),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      f['metadata'] as String,
                      style: const TextStyle(color: Color(0xFF908F88)),
                    ),
                    onTap: () =>
                        setState(() => opened = f['content'] as String),
                  ),
              ],
            ),
          ),
          if (opened != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                opened!,
                style: const TextStyle(
                  color: Color(0xFF43FFA4),
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
