import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Content-only definition of a safe, scripted CTF room. No command in this
/// model is ever executed: [terminalScript] is simply a lookup table.
class CyberRoom {
  final String id;
  final String title;
  final String scenario;
  final int points;
  final String badge;
  final String environment;
  final Map<String, dynamic> environmentData;
  final List<CyberTask> tasks;
  final Map<String, String> terminalScript;
  final Map<String, String> commandHints;

  const CyberRoom({
    required this.id,
    required this.title,
    required this.scenario,
    required this.points,
    required this.badge,
    required this.environment,
    required this.environmentData,
    required this.tasks,
    required this.terminalScript,
    required this.commandHints,
  });

  factory CyberRoom.fromJson(Map<String, dynamic> json) => CyberRoom(
    id: json['id'] as String,
    title: json['title'] as String,
    scenario: json['scenario'] as String,
    points: json['points'] as int,
    badge: json['badge'] as String,
    environment: json['environment'] as String? ?? 'terminal',
    environmentData:
        (json['environmentData'] as Map<String, dynamic>?) ?? const {},
    tasks: (json['tasks'] as List)
        .map((e) => CyberTask.fromJson(e as Map<String, dynamic>))
        .toList(),
    terminalScript:
        ((json['terminalScript'] as Map<String, dynamic>?) ?? const {}).map(
          (k, v) => MapEntry(k, v as String),
        ),
    commandHints: ((json['commandHints'] as Map<String, dynamic>?) ?? const {})
        .map((k, v) => MapEntry(k, v as String)),
  );
}

class CyberTask {
  final String prompt, hint1, hint2, answer;
  final List<String> acceptedAnswers;
  final bool caseSensitive;
  final CyberLearn? learn;
  const CyberTask({
    required this.prompt,
    required this.hint1,
    required this.hint2,
    required this.answer,
    required this.acceptedAnswers,
    required this.caseSensitive,
    this.learn,
  });
  factory CyberTask.fromJson(Map<String, dynamic> json) => CyberTask(
    prompt: json['prompt'] as String,
    hint1: json['hint1'] as String,
    hint2: json['hint2'] as String,
    answer: json['answer'] as String,
    acceptedAnswers: (json['acceptedAnswers'] as List? ?? const [])
        .cast<String>(),
    caseSensitive: json['caseSensitive'] as bool? ?? false,
    learn: json['learn'] == null
        ? null
        : CyberLearn.fromJson(json['learn'] as Map<String, dynamic>),
  );
  bool accepts(String value) {
    final normalize = caseSensitive
        ? (String s) => s.trim()
        : (String s) => s.trim().toLowerCase();
    final input = normalize(value);
    return [
      answer,
      ...acceptedAnswers,
    ].any((candidate) => normalize(candidate) == input);
  }
}

class CyberLearn {
  final String title, body;
  const CyberLearn(this.title, this.body);
  factory CyberLearn.fromJson(Map<String, dynamic> json) =>
      CyberLearn(json['title'] as String, json['body'] as String);
}

/// Persisted, client-side snapshot of an in-progress training room. It holds
/// only game state; no terminal input or sensitive information is stored.
class CyberRoomProgress {
  final List<int> completedTasks;
  final List<int> hintOneTasks;
  final List<int> hintTwoTasks;
  final int elapsedSeconds;
  const CyberRoomProgress({
    this.completedTasks = const [],
    this.hintOneTasks = const [],
    this.hintTwoTasks = const [],
    this.elapsedSeconds = 0,
  });
  Map<String, dynamic> toJson() => {
    'completedTasks': completedTasks,
    'hintOneTasks': hintOneTasks,
    'hintTwoTasks': hintTwoTasks,
    'elapsedSeconds': elapsedSeconds,
  };
  factory CyberRoomProgress.fromJson(Map<String, dynamic> json) =>
      CyberRoomProgress(
        completedTasks: (json['completedTasks'] as List? ?? const [])
            .cast<int>(),
        hintOneTasks: (json['hintOneTasks'] as List? ?? const []).cast<int>(),
        hintTwoTasks: (json['hintTwoTasks'] as List? ?? const []).cast<int>(),
        elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
      );
}

class CyberRoomLoader {
  static Future<CyberRoom> load(String assetPath) async => CyberRoom.fromJson(
    jsonDecode(await rootBundle.loadString(assetPath)) as Map<String, dynamic>,
  );
}
