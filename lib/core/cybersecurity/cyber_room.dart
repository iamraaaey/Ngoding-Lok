import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// A content-only definition of one safe cybersecurity training room. All
/// interaction data is loaded from JSON; none of the rooms execute commands,
/// contact a server, or inspect a real file.
class CyberRoom {
  final String id;
  final String title;
  final String scenario;
  final String topicTitle;
  final String topicBrief;
  final int points;
  final String badge;
  final String environment;
  final Map<String, dynamic> environmentData;
  final List<CyberTask> tasks;
  final Map<String, String> terminalScript;
  final Map<String, String> commandHints;
  final CyberLearn learn;

  const CyberRoom({
    required this.id,
    required this.title,
    required this.scenario,
    required this.topicTitle,
    required this.topicBrief,
    required this.points,
    required this.badge,
    required this.environment,
    required this.environmentData,
    required this.tasks,
    required this.terminalScript,
    required this.commandHints,
    required this.learn,
  });

  factory CyberRoom.fromJson(Map<String, dynamic> json) {
    final learnJson = _map(json['learn']);
    return CyberRoom(
      id: _string(json['id'], 'training-room'),
      title: _string(json['title'], 'Cybersecurity training'),
      scenario: _string(json['scenario'], 'A safe, fictional investigation.'),
      topicTitle: _string(json['topicTitle'], 'Before you begin'),
      topicBrief: _string(
        json['topicBrief'],
        'This is a fully scripted learning simulation. Nothing here contacts a real system.',
      ),
      points: _int(json['points'], 0),
      badge: _string(json['badge'], 'Safe Investigator'),
      environment: _string(json['environment'], 'terminal'),
      environmentData: _map(json['environmentData']),
      tasks: _list(json['tasks'])
          .whereType<Map>()
          .map((task) => CyberTask.fromJson(Map<String, dynamic>.from(task)))
          .toList(),
      terminalScript: _stringMap(json['terminalScript']),
      commandHints: _stringMap(json['commandHints']),
      learn: CyberLearn.fromJson(learnJson),
    );
  }
}

class CyberTask {
  final String prompt, hint1, hint2, answer;
  final List<String> acceptedAnswers;
  final bool caseSensitive;

  const CyberTask({
    required this.prompt,
    required this.hint1,
    required this.hint2,
    required this.answer,
    required this.acceptedAnswers,
    required this.caseSensitive,
  });

  factory CyberTask.fromJson(Map<String, dynamic> json) => CyberTask(
    prompt: _string(json['prompt'], 'Complete the simulated task.'),
    hint1: _string(json['hint1'], 'Review the scenario and look for a clue.'),
    hint2: _string(json['hint2'], 'Use the safe simulator to inspect the evidence.'),
    answer: _string(json['answer']),
    acceptedAnswers: _list(json['acceptedAnswers']).map((e) => '$e').toList(),
    caseSensitive: json['caseSensitive'] == true,
  );

  bool accepts(String value) {
    final normalise = caseSensitive
        ? (String v) => v.trim()
        : (String v) => v.trim().toLowerCase();
    final input = normalise(value);
    return [answer, ...acceptedAnswers].any((candidate) => normalise(candidate) == input);
  }
}

class CyberLearn {
  final String title;
  final String body;
  const CyberLearn(this.title, this.body);
  factory CyberLearn.fromJson(Map<String, dynamic> json) => CyberLearn(
    _string(json['title'], 'What you learned'),
    _string(json['body'], 'Practice careful, evidence-based security decisions.'),
  );
}

/// Persisted client-side state. The lists deliberately retain the earlier
/// shape so saved sessions from previous versions remain readable.
class CyberRoomProgress {
  final List<int> completedTasks;
  final List<int> hintOneTasks;
  final List<int> hintTwoTasks;
  final int elapsedSeconds;
  final int actionHintsUsed;

  const CyberRoomProgress({
    this.completedTasks = const [],
    this.hintOneTasks = const [],
    this.hintTwoTasks = const [],
    this.elapsedSeconds = 0,
    this.actionHintsUsed = 0,
  });

  Map<String, dynamic> toJson() => {
    'completedTasks': completedTasks,
    'hintOneTasks': hintOneTasks,
    'hintTwoTasks': hintTwoTasks,
    'elapsedSeconds': elapsedSeconds,
    'actionHintsUsed': actionHintsUsed,
  };

  factory CyberRoomProgress.fromJson(Map<String, dynamic> json) => CyberRoomProgress(
    completedTasks: _list(json['completedTasks']).whereType<int>().toList(),
    hintOneTasks: _list(json['hintOneTasks']).whereType<int>().toList(),
    hintTwoTasks: _list(json['hintTwoTasks']).whereType<int>().toList(),
    elapsedSeconds: _int(json['elapsedSeconds'], 0),
    actionHintsUsed: _int(json['actionHintsUsed'], 0),
  );
}

class CyberRoomLoader {
  static Future<CyberRoom> load(String assetPath) async {
    try {
      final decoded = jsonDecode(await rootBundle.loadString(assetPath));
      if (decoded is Map<String, dynamic>) return CyberRoom.fromJson(decoded);
      if (decoded is Map) return CyberRoom.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      // The fallback keeps a malformed authored room from blanking the app.
    }
    return CyberRoom.fromJson(const {});
  }
}

Map<String, dynamic> _map(Object? value) => value is Map
    ? Map<String, dynamic>.from(value)
    : const <String, dynamic>{};
List<dynamic> _list(Object? value) => value is List ? List<dynamic>.from(value) : const [];
Map<String, String> _stringMap(Object? value) => _map(value).map((k, v) => MapEntry(k, '$v'));
String _string(Object? value, [String fallback = '']) => value is String && value.trim().isNotEmpty ? value : fallback;
int _int(Object? value, int fallback) => value is int ? value : (value is num ? value.toInt() : fallback);
