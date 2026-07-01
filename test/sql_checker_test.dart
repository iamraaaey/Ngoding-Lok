import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/curriculum/module_config.dart';
import 'package:ngecode_juh/core/interpreter/sql_checker.dart';

void main() {
  const config = SqlTerminalConfig(
    table: 'users',
    schema: ['id (int)', 'role (str)'],
    instruction: "Find the admin.",
    requiredSubstrings: ['select', 'from users', 'where', "role='admin'"],
  );

  group('SqlChecker', () {
    test('succeeds and returns a server log when all clauses are present', () {
      final result = SqlChecker().check(
        "SELECT * FROM users WHERE role='admin';",
        config,
      );

      expect(result.type, SqlCheckResultType.success);
      expect(result.serverLog, isNotEmpty);
    });

    test('is case-insensitive and tolerant of extra whitespace', () {
      final result = SqlChecker().check(
        "select *\n  from users\n  where   role='admin'",
        config,
      );

      expect(result.type, SqlCheckResultType.success);
    });

    test('reports missing clauses without matching', () {
      final result = SqlChecker().check(
        "SELECT * FROM users WHERE role='user';",
        config,
      );

      expect(result.type, SqlCheckResultType.missingClause);
      expect(result.detail, contains("role='admin'"));
    });

    test('flags an empty query', () {
      final result = SqlChecker().check('   ', config);

      expect(result.type, SqlCheckResultType.empty);
    });
  });
}
