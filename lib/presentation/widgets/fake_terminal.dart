import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;

/// A deliberately closed terminal: it only renders outputs supplied by a room
/// config and never runs processes, opens sockets, or evaluates code.
class FakeTerminal extends StatefulWidget {
  final Map<String, String> script;
  final Map<String, String> hints;
  const FakeTerminal({super.key, required this.script, required this.hints});
  @override
  State<FakeTerminal> createState() => _FakeTerminalState();
}

class _FakeTerminalState extends State<FakeTerminal> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  final List<String> _lines = [
    'Training terminal ready. Type nmap target.thm to begin.',
  ];
  final List<String> _history = [];
  int _historyIndex = 0;
  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _run() {
    final command = _input.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (command.isEmpty) return;
    final normalized = command.toLowerCase();
    final commandName = normalized.split(' ').first;
    const supportedCommands = {
      'nmap',
      'ls',
      'cat',
      'ssh',
      'ftp',
      'cd',
      'whoami',
      'sudo',
      'find',
    };
    final output =
        widget.script[normalized] ??
        (normalized == 'help'
            ? widget.hints['help']
            : supportedCommands.contains(commandName)
            ? 'This safe training room has no scripted response for "$command".'
            : widget.hints['default'] ?? 'Command not found.');
    setState(() {
      _lines.add('student@target:~\$ $command');
      _lines.add(output!);
      _history.add(command);
      _historyIndex = _history.length;
      _input.clear();
    });
  }

  void _historyMove(int direction) {
    if (_history.isEmpty) return;
    setState(() {
      _historyIndex = (_historyIndex + direction).clamp(0, _history.length);
      _input.text = _historyIndex == _history.length
          ? ''
          : _history[_historyIndex];
      _input.selection = TextSelection.collapsed(offset: _input.text.length);
    });
  }

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: const Color(0xFF050505),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: const Color(0x1AFFFFFF)),
    ),
    child: Column(
      children: [
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: const BoxDecoration(
            color: Color(0xFF161616),
            border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
          ),
          child: Row(
            children: [
              const Icon(Icons.terminal, color: Color(0xFFFF5C01), size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'SIMULATED TERMINAL',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF908F88),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              for (final line in _lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SelectableText(
                    line,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.35,
                      color: line.startsWith('student@')
                          ? const Color(0xFFFF5C01)
                          : const Color(0xFFCFCEC7),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
          child: Row(
            children: [
              const Text(
                'student@target:~\$ ',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Color(0xFFFF5C01),
                  fontSize: 13,
                ),
              ),
              Expanded(
                child: Focus(
                  onKeyEvent: (_, event) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                      _historyMove(-1);
                      return KeyEventResult.handled;
                    }
                    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                      _historyMove(1);
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: TextField(
                    controller: _input,
                    focusNode: _focus,
                    onSubmitted: (_) => _run(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Color(0xFFF4F3EF),
                      fontSize: 13,
                    ),
                    cursorColor: const Color(0xFFFF5C01),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
