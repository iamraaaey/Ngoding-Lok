import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/curriculum/curriculum.dart';
import 'package:ngecode_juh/core/curriculum/language_track.dart';
import 'package:ngecode_juh/core/curriculum/module_config.dart';
import 'package:ngecode_juh/core/curriculum/module_type.dart';
import 'package:ngecode_juh/core/interpreter/sql_checker.dart';
import 'package:ngecode_juh/core/social/code_golf.dart';

void main() {
  group('Curriculum learning tracks', () {
    test('keeps every module in its explicit ordered track', () {
      expect(
        Curriculum.modulesForTrack(LanguageTrack.python).map((m) => m.id),
        orderedEquals([
          'm1',
          'm3',
          'm4',
          'm5',
          'm7',
          'm8',
          'm10',
          'm11',
          'm13',
        ]),
      );
      expect(
        Curriculum.modulesForTrack(LanguageTrack.sql).map((m) => m.id),
        orderedEquals(['m2', 'm6', 'm9', 'm12', 'j2']),
      );
      expect(
        Curriculum.modulesForTrack(LanguageTrack.java).map((m) => m.id),
        orderedEquals(['j1', 'j3']),
      );
      expect(
        Curriculum.modulesForTrack(
          LanguageTrack.cybersecurity,
        ).map((m) => m.id),
        orderedEquals([
          'cyber-warmup',
          'cyber-default-credentials',
          'cyber-spot-the-phish',
          'cyber-save-your-laptop',
          'cyber-free-wifi-trap',
        ]),
      );

      expect(Curriculum.sortedModules, hasLength(Curriculum.modules.length));
    });

    test('places every SQL exercise in the SQL track', () {
      final sqlModules = Curriculum.modules
          .where((module) => module.type == ModuleType.sqlTerminal)
          .toList();

      expect(sqlModules, hasLength(5));
      expect(
        sqlModules.every((module) => module.track == LanguageTrack.sql),
        isTrue,
      );
      expect(
        sqlModules.every((module) => module.config is SqlTerminalConfig),
        isTrue,
      );
    });

    test('accepts a solution for every SQL-track mission', () {
      const solutions = <String, String>{
        'm2': "SELECT password FROM users WHERE role = 'admin';",
        'm6': "SELECT name FROM students WHERE grade = 'A';",
        'm9': 'SELECT * FROM scores ORDER BY points DESC;',
        'm12': 'SELECT COUNT(*) FROM players;',
        'j2': "SELECT name FROM students WHERE grade = 'A';",
      };
      final checker = SqlChecker();

      for (final entry in solutions.entries) {
        final module = Curriculum.byId(entry.key);
        final config = module.config as SqlTerminalConfig;

        expect(module.track, LanguageTrack.sql);
        expect(
          checker.check(entry.value, config).type,
          SqlCheckResultType.success,
        );
      }
    });
  });

  group('Code Golf track data', () {
    test('track keys map both ways for Firestore payloads', () {
      for (final track in LanguageTrack.values) {
        final key = codeGolfTrackKey(track);
        expect(codeGolfTrackFromKey(key), track);
      }

      // Unknown values default safely to python.
      expect(codeGolfTrackFromKey('unknown'), LanguageTrack.python);
    });
  });
}
