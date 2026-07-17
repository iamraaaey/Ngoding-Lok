import 'package:flutter/material.dart';

/// The shared bookends for every room. Keeping them independent of the game
/// mechanics makes each lesson follow the same beginner-friendly rhythm.
class TopicBriefLearnPanel extends StatelessWidget {
  final bool learn;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;
  const TopicBriefLearnPanel({
    super.key,
    required this.learn,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 650),
      child: Card(
        color: const Color(0xFF0C0C0C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0x3343FFA4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(learn ? Icons.school_outlined : Icons.shield_outlined, color: const Color(0xFF43FFA4), size: 38),
            const SizedBox(height: 18),
            Text(learn ? 'LEARN PANEL' : 'TOPIC BRIEF', style: const TextStyle(color: Color(0xFF43FFA4), fontFamily: 'monospace', letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Color(0xFFF4F3EF), fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Text(body, style: const TextStyle(color: Color(0xFFCFCEC7), height: 1.55, fontSize: 16)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAction,
              icon: Icon(learn ? Icons.arrow_back : Icons.play_arrow),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF43FFA4), foregroundColor: const Color(0xFF07110C)),
              label: Text(actionLabel),
            ),
          ]),
        ),
      ),
    ),
  );
}

class FakeBrowserTraining extends StatefulWidget {
  final Map<String, dynamic> data;
  const FakeBrowserTraining({super.key, required this.data});
  @override
  State<FakeBrowserTraining> createState() => _FakeBrowserTrainingState();
}

class _FakeBrowserTrainingState extends State<FakeBrowserTraining> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _admin = false;
  bool _inspect = false;
  String? _message;
  @override
  void dispose() { _username.dispose(); _password.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final payload = '${widget.data['injection'] ?? "' OR '1'='1"}';
    final flag = '${widget.data['flag'] ?? 'FLAG{safe_training_flag}'}';
    final url = '${widget.data['url'] ?? 'https://portal.training.thm/login'}';
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF5F6F8), borderRadius: BorderRadius.circular(7), border: Border.all(color: const Color(0x33555555))),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        Container(color: const Color(0xFFE4E7EB), padding: const EdgeInsets.all(10), child: Row(children: [
          const Icon(Icons.arrow_back, size: 17, color: Color(0xFF4A5560)), const SizedBox(width: 10), const Icon(Icons.arrow_forward, size: 17, color: Color(0xFF4A5560)), const SizedBox(width: 10),
          Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), color: Colors.white, child: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF39414A), fontSize: 12)))),
        ])),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: _admin
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Campus Portal — Admin', style: TextStyle(color: Color(0xFF16202A), fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12), const Text('Welcome, training administrator. This is a local mockup only.', style: TextStyle(color: Color(0xFF39414A))),
              const SizedBox(height: 18), OutlinedButton.icon(onPressed: () => setState(() => _inspect = !_inspect), icon: const Icon(Icons.code), label: Text(_inspect ? 'Close Inspect Element' : 'Inspect Element')),
              if (_inspect) Container(width: double.infinity, margin: const EdgeInsets.only(top: 12), padding: const EdgeInsets.all(12), color: const Color(0xFF202124), child: Text('<!-- training flag: $flag -->\n<div id="admin-panel">Safe local simulation</div>', style: const TextStyle(color: Color(0xFF9AF6B7), fontFamily: 'monospace', fontSize: 12))),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Campus Portal', style: TextStyle(color: Color(0xFF16202A), fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8), const Text('Fictional training login', style: TextStyle(color: Color(0xFF55606C))), const SizedBox(height: 18),
              TextField(
                controller: _username,
                style: const TextStyle(color: Color(0xFF16202A)),
                decoration: const InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Color(0xFF39414A)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF7B8794))),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF7B8794))),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF1565C0), width: 2)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                style: const TextStyle(color: Color(0xFF16202A)),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Color(0xFF39414A)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF7B8794))),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF7B8794))),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF1565C0), width: 2)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: () { final joined = '${_username.text} ${_password.text}'; setState(() { if (joined.contains(payload)) { _admin = true; _message = null; } else { _message = 'Mock login rejected. This room accepts one fixed teaching input only.'; } }); }, child: const Text('Sign in')),
              if (_message != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_message!, style: const TextStyle(color: Color(0xFFC34040)))),
            ]))),
      ]),
    );
  }
}

class EvidenceTrayPanel extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool malware;
  final ValueChanged<int> onHintUsed;
  final VoidCallback onComplete;
  const EvidenceTrayPanel({super.key, required this.data, required this.malware, required this.onHintUsed, required this.onComplete});
  @override
  State<EvidenceTrayPanel> createState() => _EvidenceTrayPanelState();
}

class _EvidenceTrayPanelState extends State<EvidenceTrayPanel> {
  final Set<String> _tray = {};
  final Set<String> _blocked = {};
  final Set<String> _safe = {};
  String? _selected;
  String? _feedback;
  bool _finished = false;
  int _hints = 0;
  List<Map<String, dynamic>> get _entries => _items(widget.data['entries']);
  Map<String, dynamic>? get _entry {
    for (final entry in _entries) {
      if ('${entry['id']}' == _selected) return entry;
    }
    return null;
  }
  void _add(String id) { if (_tray.add(id)) setState(() {}); }
  void _hint() {
    if (_hints >= _number(widget.data['hintLimit'], widget.malware ? 2 : 3)) return;
    final safe = _entries.where((e) => '${e['role']}' == 'safe' && !_safe.contains('${e['id']}')).firstOrNull;
    if (safe == null) return;
    setState(() { _hints++; _safe.add('${safe['id']}'); _feedback = widget.malware ? 'Second opinion: focus on the ${safe['section'] ?? 'other'} report section, not ${safe['title'] ?? 'this safe entry'}.' : 'Senior analyst: ${safe['title'] ?? safe['summary']} is definitely safe; do not block it.'; });
    widget.onHintUsed(_hints);
  }
  void _commit([bool? malicious]) {
    if (_finished || _entry == null) { setState(() => _feedback = 'Select one report entry first.'); return; }
    final entry = _entry!;
    final valid = _strings(entry['validEvidence']);
    final required = _number(entry['requiredEvidenceCount'], 2);
    final goodEvidence = _tray.where(valid.contains).length;
    final isThreat = '${entry['role']}' == 'genuine-threat';
    if (widget.malware) {
      final reportVerdict = '${widget.data['verdict'] ?? 'malicious'}' == 'malicious';
      final allValid = _strings(widget.data['validEvidence']);
      final reportRequired = _number(widget.data['requiredEvidenceCount'], 2);
      final evidenceOkay = _tray.where(allValid.contains).length >= reportRequired;
      if (malicious == reportVerdict && evidenceOkay) { setState(() { _finished = true; _feedback = 'Confirmed — Trojan.GenericKD. Simulated quarantine complete.'; }); widget.onComplete(); }
      else { setState(() => _feedback = evidenceOkay ? 'The verdict does not match the combined report evidence. Re-check the details.' : 'Build a stronger case: add ${reportRequired - _tray.where(allValid.contains).length} relevant indicator(s) to the verdict tray.'); }
      return;
    }
    if (!isThreat) { setState(() => _feedback = '${entry['title'] ?? entry['summary']} is not a threat. Investigate more before blocking ordinary activity.'); return; }
    if (goodEvidence < required) { setState(() => _feedback = 'That is a possible lead, but add ${required - goodEvidence} supporting signal(s) from this entry first.'); return; }
    setState(() { _blocked.add('${entry['id']}'); _tray.clear(); _feedback = 'Nice catch — that is a real threat. The block is simulated.'; });
    final threats = _entries.where((e) => '${e['role']}' == 'genuine-threat').map((e) => '${e['id']}').toSet();
    if (threats.isNotEmpty && threats.every(_blocked.contains)) { setState(() => _finished = true); widget.onComplete(); }
  }
  @override
  Widget build(BuildContext context) {
    if (_entries.isEmpty) return const Center(child: Text('This evidence report could not be loaded.', style: TextStyle(color: Colors.white70)));
    return LayoutBuilder(builder: (context, constraints) {
      final tray = _Tray(tray: _tray, onAdd: _add, onRemove: (id) => setState(() => _tray.remove(id)));
      final list = ListView(children: _entries.map((e) => _EvidenceCard(entry: e, selected: '${e['id']}' == _selected, blocked: _blocked.contains('${e['id']}'), ruledSafe: _safe.contains('${e['id']}'), onTap: () => setState(() { _selected = '${e['id']}'; _tray.clear(); _feedback = null; }), onAdd: _add)).toList());
      final action = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(widget.malware ? 'VERDICT EVIDENCE' : 'BLOCK DECISION', style: const TextStyle(color: Color(0xFF43FFA4), fontFamily: 'monospace', fontWeight: FontWeight.bold)), const SizedBox(height: 8),
        Expanded(child: tray), const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: _hints >= _number(widget.data['hintLimit'], widget.malware ? 2 : 3) ? null : _hint, icon: const Icon(Icons.support_agent), label: Text(widget.malware ? 'Second opinion (${_number(widget.data['hintLimit'], 2) - _hints})' : 'Ask senior analyst (${_number(widget.data['hintLimit'], 3) - _hints})')),
        if (widget.malware) Row(children: [Expanded(child: OutlinedButton(onPressed: _finished ? null : () => _commit(false), child: const Text('Benign'))), const SizedBox(width: 8), Expanded(child: FilledButton(onPressed: _finished ? null : () => _commit(true), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF43FFA4), foregroundColor: const Color(0xFF07110C)), child: const Text('Malicious')))] ) else FilledButton(onPressed: _finished ? null : _commit, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF43FFA4), foregroundColor: const Color(0xFF07110C)), child: const Text('Commit block decision')),
        if (_feedback != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_feedback!, style: const TextStyle(color: Color(0xFFFFD58A), height: 1.3))),
      ]);
      if (constraints.maxWidth > 850) return Row(children: [Expanded(flex: 6, child: list), const SizedBox(width: 16), SizedBox(width: 330, child: action)]);
      return Column(children: [Expanded(child: list), SizedBox(height: 260, child: action)]);
    });
  }
}

class _EvidenceCard extends StatelessWidget {
  final Map<String, dynamic> entry; final bool selected, blocked, ruledSafe; final VoidCallback onTap; final ValueChanged<String> onAdd;
  const _EvidenceCard({required this.entry, required this.selected, required this.blocked, required this.ruledSafe, required this.onTap, required this.onAdd});
  @override Widget build(BuildContext context) {
    final attributes = _items(entry['attributes']);
    return Card(color: selected ? const Color(0xFF12231B) : const Color(0xFF101010), shape: RoundedRectangleBorder(side: BorderSide(color: selected ? const Color(0xFF43FFA4) : const Color(0x22FFFFFF))), child: ExpansionTile(
      onExpansionChanged: (_) => onTap(), title: Text('${entry['title'] ?? entry['summary'] ?? 'Evidence entry'}', style: const TextStyle(color: Color(0xFFF4F3EF), fontWeight: FontWeight.w700)), subtitle: Text(blocked ? 'BLOCKED (simulated)' : ruledSafe ? 'CLEARED SAFE' : '${entry['section'] ?? 'Traffic'} • tap to inspect', style: TextStyle(color: blocked ? const Color(0xFF43FFA4) : const Color(0xFF9A9992))), children: attributes.map((a) { final id = '${entry['id']}:${a['id']}'; return ListTile(title: Text('${a['label']}: ${a['value']}', style: const TextStyle(color: Color(0xFFDFDED7))), subtitle: Text('${a['why'] ?? 'Inspect this clue in context.'}', style: const TextStyle(color: Color(0xFF9A9992))), trailing: LongPressDraggable<String>(data: id, feedback: Material(color: Colors.transparent, child: Chip(label: Text('${a['label']}'))), child: IconButton(tooltip: 'Drag or add as evidence', icon: const Icon(Icons.add_circle_outline, color: Color(0xFF43FFA4)), onPressed: () => onAdd(id)))); }).toList(),
    ));
  }
}

class _Tray extends StatelessWidget { final Set<String> tray; final ValueChanged<String> onAdd, onRemove; const _Tray({required this.tray, required this.onAdd, required this.onRemove}); @override Widget build(BuildContext context) => DragTarget<String>(onAcceptWithDetails: (d) { if (!tray.contains(d.data)) onAdd(d.data); }, builder: (context, candidates, _) => Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF070707), border: Border.all(color: candidates.isNotEmpty ? const Color(0xFF43FFA4) : const Color(0x33FFFFFF))), child: tray.isEmpty ? const Center(child: Text('Drag 2–3 relevant clues here\nor tap + on an attribute.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF908F88)))) : Wrap(spacing: 6, runSpacing: 6, children: tray.map((id) => InputChip(label: Text(id.split(':').last), onDeleted: () => onRemove(id))).toList()))); }

class MalwareResponsePanel extends StatefulWidget {
  final Map<String, dynamic> data;
  final ValueChanged<int> onHintUsed;
  final VoidCallback onComplete;
  const MalwareResponsePanel({super.key, required this.data, required this.onHintUsed, required this.onComplete});
  @override State<MalwareResponsePanel> createState() => _MalwareResponsePanelState();
}

class _MalwareResponsePanelState extends State<MalwareResponsePanel> {
  int _stageIndex = 0, _integrity = 100, _hints = 0, _stageHints = 0;
  String? _selected, _feedback;
  bool _neutralized = false, _claimed = false;
  List<Map<String, dynamic>> get _stages => _items(widget.data['stages']);
  Map<String, dynamic>? get _stage => _stageIndex < _stages.length ? _stages[_stageIndex] : null;
  int get _penalty => _number(widget.data['penalty'], 10);
  void _select(String id) { if (!_neutralized) setState(() => _selected = id); }
  void _act() {
    final stage = _stage;
    if (stage == null || _neutralized || _selected == null) return;
    final item = _items(stage['items']).where((item) => '${item['id']}' == _selected).firstOrNull;
    if (item == null) return;
    if (item['malicious'] == true) {
      if (_stageIndex == _stages.length - 1) {
        setState(() { _neutralized = true; _feedback = 'Threat neutralized. The integrity meter is now locked.'; });
      } else {
        setState(() { _stageIndex++; _selected = null; _stageHints = 0; _feedback = 'Correct containment. Continue with the next response tool.'; });
      }
    } else {
      setState(() { _integrity = (_integrity - _penalty).clamp(0, 100).toInt(); _selected = null; _feedback = '${item['detail'] ?? 'That item is benign. Review the evidence and try again.'} Integrity dropped by $_penalty%, but the simulation remains recoverable.'; });
    }
  }
  void _hint() {
    final stage = _stage;
    if (stage == null || _neutralized || _stageHints >= 2) return;
    setState(() { _stageHints++; _hints++; _feedback = '${stage[_stageHints == 1 ? 'hint1' : 'hint2'] ?? 'Review the item details carefully.'}'; });
    widget.onHintUsed(_hints);
  }
  @override Widget build(BuildContext context) {
    final stage = _stage;
    if (stage == null) return const Center(child: Text('Incident-response data is unavailable.', style: TextStyle(color: Colors.white70)));
    final items = _items(stage['items']);
    if (_neutralized) return _MalwareResolution(integrity: _integrity, flag: '${widget.data['flag'] ?? 'FLAG{training_complete}'}', claimed: _claimed, onClaim: () { if (!_claimed) { setState(() => _claimed = true); widget.onComplete(); } });
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _InstructionBanner(text: '${stage['instruction'] ?? 'Follow the incident-response procedure.'}'), const SizedBox(height: 10),
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF211716), border: Border.all(color: const Color(0xFFC34040)), borderRadius: BorderRadius.circular(6)), child: Row(children: [const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFD58A)), const SizedBox(width: 8), const Expanded(child: Text('CRITICAL ALERT: Unauthorized system modifications detected.', style: TextStyle(color: Color(0xFFF4F3EF), fontWeight: FontWeight.bold))), Text('INTEGRITY $_integrity%', style: const TextStyle(color: Color(0xFFFFD58A), fontFamily: 'monospace'))])),
      const SizedBox(height: 6), LinearProgressIndicator(value: _integrity / 100, minHeight: 7, color: _integrity > 40 ? const Color(0xFF43FFA4) : const Color(0xFFC34040), backgroundColor: const Color(0xFF333333)), const SizedBox(height: 10),
      Wrap(spacing: 8, children: List.generate(_stages.length, (index) { final tool = '${_stages[index]['tool']}'; return Chip(avatar: Icon(_toolIcon(tool), size: 16, color: index == _stageIndex ? const Color(0xFF43FFA4) : const Color(0xFF777777)), label: Text('${_stages[index]['title']}', style: TextStyle(color: index == _stageIndex ? Colors.white : const Color(0xFF777777))), backgroundColor: index == _stageIndex ? const Color(0xFF163325) : const Color(0xFF202020)); })), const SizedBox(height: 10),
      Text('${stage['title']}', style: const TextStyle(color: Color(0xFFF4F3EF), fontSize: 21, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text('Select an item to inspect it, then use ${stage['actionLabel']}.', style: const TextStyle(color: Color(0xFFB9B8B0))), const SizedBox(height: 8),
      Expanded(child: ListView(children: items.map((item) { final selected = _selected == '${item['id']}'; return Card(color: selected ? const Color(0xFF173426) : const Color(0xFF101010), child: ListTile(onTap: () => _select('${item['id']}'), leading: Icon(_itemIcon('${item['icon']}'), color: selected ? const Color(0xFF43FFA4) : const Color(0xFFB9B8B0)), title: Text('${item['name']}', style: const TextStyle(color: Color(0xFFF4F3EF), fontWeight: FontWeight.w700)), subtitle: Text('${item['metadata']}\n${item['publisher']}', style: const TextStyle(color: Color(0xFFB9B8B0))), trailing: selected ? const Icon(Icons.check_circle, color: Color(0xFF43FFA4)) : null)); }).toList())),
      if (_selected != null) Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF0C0C0C), border: Border.all(color: const Color(0x3343FFA4))), child: Text('${items.where((item) => '${item['id']}' == _selected).firstOrNull?['detail'] ?? ''}', style: const TextStyle(color: Color(0xFFCFCEC7)))), const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 6, children: [OutlinedButton.icon(onPressed: _stageHints >= 2 ? null : _hint, icon: const Icon(Icons.lightbulb_outline), label: Text(_stageHints == 0 ? 'Hint 1' : 'Hint 2')), FilledButton.icon(onPressed: _selected == null ? null : _act, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF43FFA4), foregroundColor: const Color(0xFF07110C)), icon: Icon(_toolIcon('${stage['tool']}')), label: Text('${stage['actionLabel']}'))]),
      if (_feedback != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_feedback!, style: const TextStyle(color: Color(0xFFFFD58A), height: 1.3))),
    ]);
  }
}

class _MalwareResolution extends StatelessWidget {
  final int integrity; final String flag; final bool claimed; final VoidCallback onClaim;
  const _MalwareResolution({required this.integrity, required this.flag, required this.claimed, required this.onClaim});
  @override Widget build(BuildContext context) => Center(child: Container(constraints: const BoxConstraints(maxWidth: 620), padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF102419), border: Border.all(color: const Color(0xFF43FFA4)), borderRadius: BorderRadius.circular(8)), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.verified_user, color: Color(0xFF43FFA4), size: 48), const SizedBox(height: 12), const Text('Threat Neutralized', style: TextStyle(color: Color(0xFFF4F3EF), fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text('After-action report: system integrity held at $integrity%. The malicious process, backdoor, and staged files were contained in the right order.', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFCFCEC7), height: 1.35)), const SizedBox(height: 14), SelectableText(flag, style: const TextStyle(color: Color(0xFF43FFA4), fontFamily: 'monospace', fontWeight: FontWeight.bold)), const SizedBox(height: 14), FilledButton.icon(onPressed: claimed ? null : onClaim, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF43FFA4), foregroundColor: const Color(0xFF07110C)), icon: const Icon(Icons.flag), label: const Text('Secure this training flag'))])));
}

class MitmTrapPanel extends StatefulWidget {
  final Map<String, dynamic> data; final ValueChanged<int> onHintUsed; final VoidCallback onComplete;
  const MitmTrapPanel({super.key, required this.data, required this.onHintUsed, required this.onComplete});
  @override State<MitmTrapPanel> createState() => _MitmTrapPanelState();
}

class _MitmTrapPanelState extends State<MitmTrapPanel> {
  final Set<String> _found = {};
  int _hints = 0;
  String? _feedback, _outcome;
  bool _decision = false, _compare = false, _secured = false, _claimed = false;
  List<Map<String, dynamic>> get _regions => _items(widget.data['clickableRegions']);
  Map<String, dynamic> get _browser => widget.data['browser'] is Map ? Map<String, dynamic>.from(widget.data['browser'] as Map) : const {};
  int get _threats => _regions.where((region) => region['isThreatIndicator'] == true).length;
  void _inspect(String area) {
    if (_decision) return;
    final region = _regions.where((region) => '${region['area']}' == area).firstOrNull;
    if (region == null) return;
    final id = '${region['id'] ?? area}';
    setState(() { if (region['isThreatIndicator'] == true) _found.add(id); _feedback = '${region['explanation'] ?? 'Inspect this connection detail.'}'; if (_found.length >= _threats && _threats > 0) _decision = true; });
    if (area == 'lock') showDialog<void>(context: context, builder: (_) => AlertDialog(backgroundColor: const Color(0xFF101010), title: const Text('Certificate details', style: TextStyle(color: Color(0xFFFFD58A))), content: Text('${_browser['certificate'] ?? 'Certificate details unavailable.'}', style: const TextStyle(color: Color(0xFFCFCEC7), fontFamily: 'monospace')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]));
  }
  void _hint() { final hints = _strings(widget.data['hints']); if (_hints >= hints.length || _decision) return; setState(() { _feedback = hints[_hints++]; }); widget.onHintUsed(_hints); }
  void _choose(Map<String, dynamic> option) { if (_secured) return; setState(() { _outcome = '${option['scriptedOutcome'] ?? 'Review the connection and try again.'}'; _secured = option['isCorrect'] == true; }); }
  @override Widget build(BuildContext context) {
    if (_regions.isEmpty) return const Center(child: Text('Connection-inspection data is unavailable.', style: TextStyle(color: Colors.white70)));
    final instructions = _strings(widget.data['instructions']);
    final hints = _strings(widget.data['hints']);
    if (_secured) return _MitmSecure(flag: '${widget.data['flag'] ?? 'FLAG{secure_connection}'}', claimed: _claimed, onClaim: () { if (!_claimed) { setState(() => _claimed = true); widget.onComplete(); } });
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _InstructionBanner(text: instructions.isEmpty ? 'Inspect the connection before entering credentials.' : instructions[_decision && instructions.length > 1 ? 1 : 0]), const SizedBox(height: 10),
      const Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, children: [Chip(label: Text('Laptop'), avatar: Icon(Icons.laptop_mac)), Icon(Icons.arrow_forward, color: Color(0xFFFFD54F)), Chip(label: Text('Free_Cafe_WiFi'), avatar: Icon(Icons.wifi, color: Color(0xFFFFD54F))), Icon(Icons.arrow_forward, color: Color(0xFFFFD54F)), Chip(label: Text('University server'), avatar: Icon(Icons.school))]), const SizedBox(height: 10),
      if (!_decision) Expanded(child: SingleChildScrollView(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF5F6F8), borderRadius: BorderRadius.circular(7)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [InkWell(onTap: () => _inspect('lock'), child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.lock_open, color: Color(0xFFC34040)))), Expanded(child: InkWell(onTap: () => _inspect('url'), child: Container(padding: const EdgeInsets.all(10), color: Colors.white, child: Text('${_browser['url']}', style: const TextStyle(color: Color(0xFFC34040), fontFamily: 'monospace')))))]) , const SizedBox(height: 18),
        InkWell(onTap: () => _inspect('title'), child: Text('${_browser['title']}', style: const TextStyle(color: Color(0xFF16202A), fontSize: 22, fontWeight: FontWeight.bold))), const SizedBox(height: 12), InkWell(onTap: () => _inspect('content'), child: Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFCBD2D9))), child: Text('${_browser['body']}', style: const TextStyle(color: Color(0xFF39414A), height: 1.35)))), const SizedBox(height: 14),
        OutlinedButton.icon(onPressed: () => setState(() => _compare = !_compare), icon: const Icon(Icons.compare_arrows), label: const Text('Compare to Official Site')), if (_compare) Container(width: double.infinity, margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(12), color: const Color(0xFFD9F2E2), child: Text('Official connection\n${_browser['officialUrl']}\nTrusted university certificate\nEncrypted HTTPS', style: const TextStyle(color: Color(0xFF164A2C), fontFamily: 'monospace'))),
        const SizedBox(height: 12), OutlinedButton.icon(onPressed: _hints >= hints.length ? null : _hint, icon: const Icon(Icons.lightbulb_outline), label: Text('Hint ${_hints + 1}')), if (_feedback != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_feedback!, style: const TextStyle(color: Color(0xFF9C3D00), fontWeight: FontWeight.w600))),
      ])))),
      if (_decision) Expanded(child: ListView(children: [const Text('Connection threat documented. How will you proceed?', style: TextStyle(color: Color(0xFFF4F3EF), fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 12), ..._items(widget.data['options']).map((option) => Card(color: const Color(0xFF101010), child: ListTile(onTap: () => _choose(option), title: Text('${option['label']}', style: const TextStyle(color: Color(0xFFF4F3EF), fontWeight: FontWeight.w700)), subtitle: Text('${option['detail']}', style: const TextStyle(color: Color(0xFFB9B8B0)))))), if (_outcome != null) Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF211716), border: Border.all(color: const Color(0xFFC34040))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_outcome!, style: const TextStyle(color: Color(0xFFFFD58A), height: 1.35)), const SizedBox(height: 10), OutlinedButton(onPressed: () => setState(() => _outcome = null), child: const Text('Try again'))]))])),
    ]);
  }
}

class _MitmSecure extends StatelessWidget { final String flag; final bool claimed; final VoidCallback onClaim; const _MitmSecure({required this.flag, required this.claimed, required this.onClaim}); @override Widget build(BuildContext context) => Center(child: Container(constraints: const BoxConstraints(maxWidth: 620), padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF102419), border: Border.all(color: const Color(0xFF43FFA4)), borderRadius: BorderRadius.circular(8)), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.vpn_lock, color: Color(0xFF43FFA4), size: 48), const SizedBox(height: 12), const Text('Encrypted tunnel established', style: TextStyle(color: Color(0xFFF4F3EF), fontSize: 23, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('The simulated portal reloads over a trusted HTTPS connection. Your credentials never touched the intercepted cafe network.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFCFCEC7), height: 1.35)), const SizedBox(height: 14), SelectableText(flag, style: const TextStyle(color: Color(0xFF43FFA4), fontFamily: 'monospace', fontWeight: FontWeight.bold)), const SizedBox(height: 14), FilledButton.icon(onPressed: claimed ? null : onClaim, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF43FFA4), foregroundColor: const Color(0xFF07110C)), icon: const Icon(Icons.flag), label: const Text('Secure this training flag'))]))); }

class _InstructionBanner extends StatelessWidget { final String text; const _InstructionBanner({required this.text}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: const Color(0xFF12352A), border: Border.all(color: const Color(0xFF43FFA4)), borderRadius: BorderRadius.circular(6)), child: Row(children: [const Icon(Icons.assistant_navigation, color: Color(0xFF43FFA4)), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(color: Color(0xFFF4F3EF), fontWeight: FontWeight.w600)))])); }
IconData _toolIcon(String tool) => switch (tool) { 'process' => Icons.memory, 'firewall' => Icons.security, 'quarantine' => Icons.folder_zip, _ => Icons.build };
IconData _itemIcon(String icon) => switch (icon) { 'warning' => Icons.warning_amber_rounded, 'backup' => Icons.backup, 'shield' => Icons.shield_outlined, 'folder' => Icons.folder_outlined, 'note' => Icons.note_outlined, 'cloud' => Icons.cloud_outlined, 'network' => Icons.hub_outlined, 'delete' => Icons.delete_outline, _ => Icons.help_outline };

class PhishingEmailPanel extends StatefulWidget {
  final Map<String, dynamic> data;
  final ValueChanged<int> onHintUsed;
  final VoidCallback onComplete;
  final VoidCallback? onAllFlagsFound;
  final VoidCallback? onLinkTapped;
  const PhishingEmailPanel({super.key, required this.data, required this.onHintUsed, required this.onComplete, this.onAllFlagsFound, this.onLinkTapped});
  @override State<PhishingEmailPanel> createState() => _PhishingEmailPanelState();
}

class _PhishingEmailPanelState extends State<PhishingEmailPanel> {
  final Set<String> _found = {};
  int _hints = 0;
  String? _feedback, _highlighted;
  bool _complete = false, _claimed = false, _showDestination = false;
  Map<String, dynamic> get _email => widget.data['emailContent'] is Map ? Map<String, dynamic>.from(widget.data['emailContent'] as Map) : const {};
  List<Map<String, dynamic>> get _regions => _items(widget.data['clickableRegions']);
  Map<String, dynamic>? _region(String area) => _regions.where((region) => '${region['area']}' == area).firstOrNull;
  int get _redFlagCount => _regions.where((region) => region['isRedFlag'] == true).length;

  void _tap(String area) {
    final region = _region(area);
    if (region == null) {
      setState(() => _feedback = 'That part looks normal. Keep looking for details that do not match.');
      return;
    }
    final id = '${region['id'] ?? area}';
    if (region['isRedFlag'] != true) {
      setState(() => _feedback = '${region['explanation'] ?? 'That part looks normal.'}');
      return;
    }
    if (_found.contains(id)) {
      setState(() => _feedback = 'You already found that clue. Look for another detail.');
      return;
    }
    setState(() {
      _found.add(id);
      _highlighted = null;
      _feedback = '${region['explanation'] ?? 'Nice catch - that is a phishing clue.'}';
      if (_found.length >= _redFlagCount && _redFlagCount > 0) _complete = true;
    });
    if (_complete) widget.onAllFlagsFound?.call();
  }

  void _claim() {
    if (_complete && !_claimed) {
      setState(() => _claimed = true);
      widget.onComplete();
    }
  }

  void _hint() {
    if (_hints >= _number(widget.data['hintLimit'], 3)) return;
    final next = _regions.where((region) => region['isRedFlag'] == true && !_found.contains('${region['id'] ?? region['area']}')).firstOrNull;
    if (next == null) return;
    setState(() {
      _hints++;
      _highlighted = '${next['area']}';
      _feedback = 'A general area has been highlighted. Inspect the detail, then decide why it matters.';
    });
    widget.onHintUsed(_hints);
  }

  @override Widget build(BuildContext context) {
    if (_regions.isEmpty) return const Center(child: Text('This email could not be loaded.', style: TextStyle(color: Colors.white70)));
    final sender = '${_email['sender'] ?? 'notices@sample-mail.thm'}';
    final linkLabel = '${_email['linkLabel'] ?? 'Open message'}';
    final destination = '${_email['linkDestination'] ?? 'https://safe-preview.thm'}';
    return SingleChildScrollView(child: Container(
      constraints: const BoxConstraints(maxWidth: 760),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFFF5F6F8), borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('INBOX / NEW MESSAGE', style: TextStyle(color: Color(0xFF52606D), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        _EmailHotspot(area: 'sender', label: 'From', value: sender, highlighted: _highlighted == 'sender', found: _found.contains('${_region('sender')?['id'] ?? 'sender'}'), onTap: () => _tap('sender')),
        _EmailHotspot(area: 'subject', label: 'Subject', value: '${_email['subject'] ?? 'Account notice'}', highlighted: _highlighted == 'subject', found: _found.contains('${_region('subject')?['id'] ?? 'subject'}'), onTap: () => _tap('subject')),
        const Divider(height: 24, color: Color(0xFFCBD2D9)),
        _EmailHotspot(area: 'greeting', label: null, value: '${_email['greeting'] ?? 'Hello,'}', highlighted: _highlighted == 'greeting', found: _found.contains('${_region('greeting')?['id'] ?? 'greeting'}'), onTap: () => _tap('greeting')),
        const SizedBox(height: 10),
        _EmailHotspot(area: 'body', label: null, value: '${_email['body'] ?? 'Please review the attached message.'}', highlighted: _highlighted == 'body', found: _found.contains('${_region('body')?['id'] ?? 'body'}'), onTap: () => _tap('body')),
        const SizedBox(height: 10),
        _EmailHotspot(area: 'urgency', label: null, value: '${_email['urgentPhrase'] ?? 'Please respond as soon as possible.'}', highlighted: _highlighted == 'urgency', found: _found.contains('${_region('urgency')?['id'] ?? 'urgency'}'), onTap: () => _tap('urgency')),
        const SizedBox(height: 14),
        MouseRegion(
          onEnter: (_) => setState(() => _showDestination = true),
          onExit: (_) => setState(() => _showDestination = false),
          child: _EmailHotspot(area: 'link', label: null, value: linkLabel, link: true, highlighted: _highlighted == 'link', found: _found.contains('${_region('link')?['id'] ?? 'link'}'), onTap: widget.onLinkTapped ?? () => _tap('link')),
        ),
        if (_showDestination) Padding(padding: const EdgeInsets.only(top: 6), child: Text('Link preview: $destination', style: const TextStyle(color: Color(0xFFC05621), fontFamily: 'monospace', fontSize: 12))),
        if (_email['attachment'] != null) ...[const SizedBox(height: 12), _EmailHotspot(area: 'attachment', label: 'Attachment', value: '${_email['attachment']}', highlighted: _highlighted == 'attachment', found: _found.contains('${_region('attachment')?['id'] ?? 'attachment'}'), onTap: () => _tap('attachment'))],
        if (_email['closing'] != null) ...[const SizedBox(height: 14), _EmailHotspot(area: 'closing', label: null, value: '${_email['closing']}', highlighted: _highlighted == 'closing', found: _found.contains('${_region('closing')?['id'] ?? 'closing'}'), onTap: () => _tap('closing'))],
        const SizedBox(height: 18),
        OutlinedButton.icon(onPressed: _hints >= _number(widget.data['hintLimit'], 3) || _complete ? null : _hint, icon: const Icon(Icons.lightbulb_outline), label: Text('Highlight a clue (${_number(widget.data['hintLimit'], 3) - _hints})')),
        if (_feedback != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_feedback!, style: TextStyle(color: _complete ? const Color(0xFF137333) : const Color(0xFF9C3D00), fontWeight: FontWeight.w600))),
        if (_complete) ...[const SizedBox(height: 10), if (widget.data['completionFlag'] != null) SelectableText('${widget.data['completionFlag']}', style: const TextStyle(color: Color(0xFF137333), fontFamily: 'monospace', fontWeight: FontWeight.bold)), const SizedBox(height: 10), FilledButton.icon(onPressed: _claimed ? null : _claim, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF137333), foregroundColor: Colors.white), icon: const Icon(Icons.verified_user), label: Text('${widget.data['completeActionLabel'] ?? (widget.data['completionFlag'] == null ? 'Mark email as suspicious' : 'Secure this training flag')}'))],
      ],
    )));
  }
}

class _EmailHotspot extends StatelessWidget {
  final String area, value;
  final String? label;
  final bool highlighted, found, link;
  final VoidCallback onTap;
  const _EmailHotspot({required this.area, required this.value, required this.highlighted, required this.found, required this.onTap, this.label, this.link = false});
  @override Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(4),
    child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: found ? const Color(0xFFD9F2E2) : highlighted ? const Color(0xFFFFF0B3) : Colors.transparent, borderRadius: BorderRadius.circular(4), border: found ? Border.all(color: const Color(0xFF2E8B57)) : highlighted ? Border.all(color: const Color(0xFFE3A008)) : null), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (label != null) SizedBox(width: 72, child: Text('$label:', style: const TextStyle(color: Color(0xFF52606D), fontWeight: FontWeight.bold))),
      Expanded(child: Text(value, style: TextStyle(color: link ? const Color(0xFF1565C0) : const Color(0xFF202A33), decoration: link ? TextDecoration.underline : null, fontWeight: found ? FontWeight.w700 : FontWeight.normal))),
      if (found) const Icon(Icons.check_circle, color: Color(0xFF2E8B57), size: 18),
    ])),
  ));
}

class InjectionBlockPanel extends StatefulWidget {
  final Map<String, dynamic> data;
  final ValueChanged<int> onHintUsed;
  final VoidCallback onComplete;
  const InjectionBlockPanel({super.key, required this.data, required this.onHintUsed, required this.onComplete});
  @override State<InjectionBlockPanel> createState() => _InjectionBlockPanelState();
}

class _InjectionBlockPanelState extends State<InjectionBlockPanel> {
  final List<String> _selected = [];
  int _hints = 0;
  String? _feedback, _hintedBlock;
  bool _success = false, _completed = false, _showStretch = false;
  List<Map<String, dynamic>> get _blocks => _items(widget.data['availableBlocks']);
  List<List<String>> get _validSequences => (widget.data['validSequences'] is List ? (widget.data['validSequences'] as List).whereType<List>().map((sequence) => sequence.map((id) => '$id').toList()).toList() : const []);
  Map<String, dynamic>? _block(String id) => _blocks.where((block) => '${block['id']}' == id).firstOrNull;
  String get _preview => _selected.map((id) => '${_block(id)?['value'] ?? ''}').join(' ');
  bool get _isValid => _validSequences.any((sequence) => sequence.length == _selected.length && _sameSequence(sequence, _selected));

  void _add(String id) {
    if (_success || _selected.contains(id) || _block(id) == null) return;
    setState(() { _selected.add(id); _feedback = null; _hintedBlock = null; });
  }
  void _run() {
    if (_success) return;
    setState(() { _success = _isValid; _feedback = _isValid ? 'The scripted search returns restricted catalogue items. You found the teaching flag.' : 'No hidden products matched. This combination did not make the check always true - revise the blocks.'; });
  }
  void _hint() {
    if (_hints >= _number(widget.data['hintLimit'], 1) || _validSequences.isEmpty) return;
    final sequence = _validSequences.first;
    final next = sequence.length > _selected.length ? sequence[_selected.length] : sequence.last;
    final block = _block(next);
    if (block == null) return;
    setState(() { _hints++; _hintedBlock = next; _feedback = 'One working placement: put "${block['label']}" next in the search input.'; });
    widget.onHintUsed(_hints);
  }
  void _claim() { if (_success && !_completed) { setState(() => _completed = true); widget.onComplete(); } }

  @override Widget build(BuildContext context) {
    if (_blocks.isEmpty || _validSequences.isEmpty) return const Center(child: Text('The block puzzle could not be loaded.', style: TextStyle(color: Colors.white70)));
    final products = _items(widget.data['products']);
    return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${widget.data['shopName'] ?? 'Training Store'}', style: const TextStyle(color: Color(0xFFF4F3EF), fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 5), Text('${widget.data['instruction'] ?? 'Build a safe, scripted search test from the available blocks.'}', style: const TextStyle(color: Color(0xFFB9B8B0))), const SizedBox(height: 14),
      Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF5F6F8), borderRadius: BorderRadius.circular(7)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('PRODUCT SEARCH', style: TextStyle(color: Color(0xFF52606D), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)), const SizedBox(height: 8),
        Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF7B8794)), borderRadius: BorderRadius.circular(4)), child: Text(_preview.isEmpty ? 'Tap blocks below to build the search input' : _preview, style: TextStyle(color: _preview.isEmpty ? const Color(0xFF667085) : const Color(0xFF16202A), fontFamily: 'monospace'))),
        if (_selected.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Wrap(spacing: 6, children: _selected.map((id) => InputChip(label: Text('${_block(id)?['label'] ?? id}'), onDeleted: _success ? null : () => setState(() => _selected.remove(id)))).toList())),
        const SizedBox(height: 8), Text('Preview: SELECT * FROM products WHERE name LIKE \'%$_preview%\'  [scripted only]', style: const TextStyle(color: Color(0xFF52606D), fontFamily: 'monospace', fontSize: 11)),
      ])), const SizedBox(height: 14),
      const Text('SYNTAX BLOCKS', style: TextStyle(color: Color(0xFF43FFA4), fontFamily: 'monospace', fontWeight: FontWeight.bold)), const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: _blocks.map((block) { final id = '${block['id']}'; return Tooltip(message: '${block['meaning'] ?? 'A search token.'}', child: OutlinedButton(onPressed: _success || _selected.contains(id) ? null : () => _add(id), style: OutlinedButton.styleFrom(side: BorderSide(color: _hintedBlock == id ? const Color(0xFFFFD54F) : const Color(0xFF43FFA4))), child: Text('${block['label']}', style: const TextStyle(fontFamily: 'monospace')))); }).toList()),
      const SizedBox(height: 14), Wrap(spacing: 10, runSpacing: 8, children: [OutlinedButton.icon(onPressed: _hints >= _number(widget.data['hintLimit'], 1) || _success ? null : _hint, icon: const Icon(Icons.lightbulb_outline), label: const Text('Show me one working piece')), OutlinedButton.icon(onPressed: _selected.isEmpty || _success ? null : () => setState(() { _selected.clear(); _feedback = null; }), icon: const Icon(Icons.restart_alt), label: const Text('Clear blocks')), FilledButton(onPressed: _selected.isEmpty || _success ? null : _run, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF43FFA4), foregroundColor: const Color(0xFF07110C)), child: const Text('Run Search'))]),
      if (_feedback != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_feedback!, style: TextStyle(color: _success ? const Color(0xFF43FFA4) : const Color(0xFFFFD58A), height: 1.3))),
      if (_success) ...[const SizedBox(height: 16), const Text('RESTRICTED RESULTS', style: TextStyle(color: Color(0xFF43FFA4), fontFamily: 'monospace', fontWeight: FontWeight.bold)), const SizedBox(height: 8), Wrap(spacing: 10, runSpacing: 10, children: products.map((product) => Card(color: const Color(0xFF102419), child: SizedBox(width: 190, child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${product['name'] ?? 'Restricted item'}', style: const TextStyle(color: Color(0xFFF4F3EF), fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text('${product['detail'] ?? ''}', style: const TextStyle(color: Color(0xFFB9B8B0))), if (product['flag'] != null) Padding(padding: const EdgeInsets.only(top: 8), child: SelectableText('${product['flag']}', style: const TextStyle(color: Color(0xFF43FFA4), fontFamily: 'monospace')))]))))).toList()), if (widget.data['showStretch'] == true) ...[const SizedBox(height: 14), OutlinedButton.icon(onPressed: () => setState(() => _showStretch = !_showStretch), icon: const Icon(Icons.login), label: Text(_showStretch ? 'Hide optional login stretch' : 'Try the optional login stretch')), if (_showStretch) Container(width: double.infinity, margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF101010), border: Border.all(color: const Color(0xFF43FFA4))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('FICTIONAL LOGIN FIELD', style: TextStyle(color: Color(0xFF43FFA4), fontFamily: 'monospace', fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text(_preview, style: const TextStyle(color: Color(0xFFF4F3EF), fontFamily: 'monospace')), const SizedBox(height: 6), const Text('The same unsafe pattern would affect this scripted login check. Parameterised queries would treat the value only as data.', style: TextStyle(color: Color(0xFFB9B8B0), height: 1.3))]))], const SizedBox(height: 14), FilledButton.icon(onPressed: _completed ? null : _claim, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF43FFA4), foregroundColor: const Color(0xFF07110C)), icon: const Icon(Icons.flag), label: const Text('Secure this training flag'))],
    ]));
  }
}

bool _sameSequence(List<String> left, List<String> right) => left.length == right.length && List.generate(left.length, (index) => left[index] == right[index]).every((same) => same);

class PhishingToBreachPanel extends StatefulWidget {
  final Map<String, dynamic> data;
  final ValueChanged<int> onHintUsed;
  final VoidCallback onComplete;
  const PhishingToBreachPanel({super.key, required this.data, required this.onHintUsed, required this.onComplete});
  @override State<PhishingToBreachPanel> createState() => _PhishingToBreachPanelState();
}

class _PhishingToBreachPanelState extends State<PhishingToBreachPanel> {
  bool _phishChecked = false, _breached = false, _showBreach = false;
  Map<String, dynamic> get _phish => widget.data['phishing'] is Map ? Map<String, dynamic>.from(widget.data['phishing'] as Map) : const {};
  Map<String, dynamic> get _breach => widget.data['breach'] is Map ? Map<String, dynamic>.from(widget.data['breach'] as Map) : const {};
  void _openLink() => setState(() { if (_phishChecked) { _showBreach = true; } else { _breached = true; } });
  @override Widget build(BuildContext context) {
    if (_showBreach) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('STAGE 2 / SCRIPTED LOGIN TEST', style: TextStyle(color: Color(0xFF43FFA4), fontFamily: 'monospace', fontWeight: FontWeight.bold)), const SizedBox(height: 8), Expanded(child: InjectionBlockPanel(data: _breach, onHintUsed: widget.onHintUsed, onComplete: widget.onComplete))]);
    if (_breached) return Center(child: Container(constraints: const BoxConstraints(maxWidth: 560), padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF211716), border: Border.all(color: const Color(0xFFC34040)), borderRadius: BorderRadius.circular(8)), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.phishing, color: Color(0xFFFFD58A), size: 42), const SizedBox(height: 12), const Text('You got phished - in this safe simulation.', style: TextStyle(color: Color(0xFFF4F3EF), fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('The message rushed you into following a link before you checked its warning signs. In a real inbox, pause and verify first.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFCFCEC7), height: 1.35)), const SizedBox(height: 16), FilledButton(onPressed: () => setState(() => _breached = false), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF43FFA4), foregroundColor: const Color(0xFF07110C)), child: const Text('Retry the email investigation'))])));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('STAGE 1 / CHECK THE EMAIL', style: TextStyle(color: Color(0xFF43FFA4), fontFamily: 'monospace', fontWeight: FontWeight.bold)), const SizedBox(height: 8), Expanded(child: PhishingEmailPanel(data: _phish, onHintUsed: widget.onHintUsed, onAllFlagsFound: () => setState(() => _phishChecked = true), onComplete: () => setState(() { _phishChecked = true; _showBreach = true; }), onLinkTapped: _openLink))]);
  }
}

class InvestigatePanel extends StatefulWidget {
  final Map<String, dynamic> data; final ValueChanged<int> onHintUsed; final VoidCallback onComplete;
  const InvestigatePanel({super.key, required this.data, required this.onHintUsed, required this.onComplete});
  @override State<InvestigatePanel> createState() => _InvestigatePanelState();
}
class _InvestigatePanelState extends State<InvestigatePanel> {
  int _stage = 0, _hints = 0; String? _selected, _feedback; bool _done = false; final Set<String> _eliminated = {};
  List<Map<String, dynamic>> get _stages => _items(widget.data['stages']);
  void _choose() { if (_done || _stage >= _stages.length || _selected == null) return; final candidate = _items(_stages[_stage]['candidates']).where((c) => '${c['id']}' == _selected).firstOrNull; if (candidate == null) return; if (candidate['correct'] == true) { if (_stage == _stages.length - 1) { setState(() { _done = true; _feedback = 'ROOT ACCESS GRANTED — simulated flag unlocked.'; }); widget.onComplete(); } else { setState(() { _stage++; _selected = null; _feedback = 'Verified. Carry that finding into the next stage.'; }); } } else { setState(() { _selected = null; _feedback = '${candidate['feedback'] ?? 'That candidate does not fit the evidence.'} Stage ${_stage + 1} is still open; earlier work is saved.'; }); } }
  void _hint() { if (_hints >= _number(widget.data['hintPool'], 3) || _stage >= _stages.length) return; final decoy = _items(_stages[_stage]['candidates']).where((c) => c['correct'] != true && !_eliminated.contains('${c['id']}')).firstOrNull; if (decoy == null) return; setState(() { _hints++; _eliminated.add('${decoy['id']}'); _feedback = 'Senior analyst crossed out “${decoy['label']}”. It does not fit the chain.'; }); widget.onHintUsed(_hints); }
  @override Widget build(BuildContext context) { if (_stages.isEmpty) return const Center(child: Text('Investigation data is unavailable.', style: TextStyle(color: Colors.white70))); final stage = _stages[_stage.clamp(0, _stages.length - 1).toInt()]; final candidates = _items(stage['candidates']); return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Wrap(spacing: 8, children: List.generate(_stages.length, (i) => Chip(label: Text('Stage ${i + 1}'), backgroundColor: i <= _stage ? const Color(0xFF193828) : const Color(0xFF202020), labelStyle: const TextStyle(color: Colors.white))),), const SizedBox(height: 12),
    Text('${stage['title'] ?? 'Investigate'}', style: const TextStyle(color: Color(0xFFF4F3EF), fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text('${stage['brief'] ?? ''}', style: const TextStyle(color: Color(0xFFB9B8B0), height: 1.35)), const SizedBox(height: 10),
    if (_items(stage['sources']).isNotEmpty) SizedBox(height: 76, child: ListView(scrollDirection: Axis.horizontal, children: _items(stage['sources']).map((source) => SizedBox(width: 235, child: Card(color: const Color(0xFF101010), child: InkWell(onTap: () => showDialog<void>(context: context, builder: (_) => AlertDialog(backgroundColor: const Color(0xFF101010), title: Text('${source['label']}', style: const TextStyle(color: Color(0xFF43FFA4))), content: SelectableText('${source['output']}', style: const TextStyle(color: Color(0xFFCFCEC7), fontFamily: 'monospace')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))])), child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [const Icon(Icons.folder_open, color: Color(0xFF43FFA4)), const SizedBox(width: 8), Expanded(child: Text('${source['label']}', style: const TextStyle(color: Color(0xFFF4F3EF), fontWeight: FontWeight.bold)))])))))).toList())),
    Expanded(child: ListView(children: candidates.map((c) { final eliminated = _eliminated.contains('${c['id']}'); return Card(color: _selected == '${c['id']}' ? const Color(0xFF12231B) : const Color(0xFF101010), child: ListTile(enabled: !eliminated && !_done, onTap: () => setState(() => _selected = '${c['id']}'), title: Text('${c['label']}', style: TextStyle(color: eliminated ? const Color(0xFF777777) : const Color(0xFFF4F3EF), decoration: eliminated ? TextDecoration.lineThrough : null)), subtitle: Text(eliminated ? 'Eliminated by consultation' : '${c['detail']}', style: const TextStyle(color: Color(0xFF9A9992))), trailing: _selected == '${c['id']}' ? const Icon(Icons.check_circle, color: Color(0xFF43FFA4)) : null)); }).toList())),
    Row(children: [Expanded(child: OutlinedButton.icon(onPressed: _hints >= _number(widget.data['hintPool'], 3) || _done ? null : _hint, icon: const Icon(Icons.support_agent), label: Text('Consult senior analyst (${_number(widget.data['hintPool'], 3) - _hints})'))), const SizedBox(width: 10), Expanded(child: FilledButton(onPressed: _selected == null || _done ? null : _choose, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF43FFA4), foregroundColor: const Color(0xFF07110C)), child: Text(_done ? 'ROOT' : 'Confirm finding')))],),
    if (_feedback != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_feedback!, style: const TextStyle(color: Color(0xFFFFD58A)))),
  ]); }
}

List<Map<String, dynamic>> _items(Object? value) => value is List ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : const [];
List<String> _strings(Object? value) => value is List ? value.map((e) => '$e').toList() : const [];
int _number(Object? value, int fallback) => value is int ? value : (value is num ? value.toInt() : fallback);
extension _IterableX<T> on Iterable<T> { T? get firstOrNull => isEmpty ? null : first; }
