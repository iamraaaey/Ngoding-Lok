import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/interpreter/rocket_lexer.dart';
import 'package:ngecode_juh/core/interpreter/rocket_parser.dart';

void main() {
  final lexer = RocketLexer();

  group('RocketLexer', () {
    test('tokenizes known launch commands', () {
      final tokens = lexer.tokenize('sys.preflight();\nengine.start();\nthrottle(20);');
      expect(tokens[0].type, RocketTokenType.preflight);
      expect(tokens[1].type, RocketTokenType.engineStart);
      expect(tokens[2].type, RocketTokenType.throttle);
      expect(tokens[2].throttleValue, 20);
    });

    test('ignores blank lines and comments', () {
      final tokens = lexer.tokenize('\n// a comment\nsys.preflight();');
      expect(tokens[0].type, RocketTokenType.empty);
      expect(tokens[1].type, RocketTokenType.comment);
      expect(tokens[2].type, RocketTokenType.preflight);
    });

    test('flags unrecognized syntax as unknown', () {
      final tokens = lexer.tokenize('warp.jump();');
      expect(tokens[0].type, RocketTokenType.unknown);
    });
  });

  group('RocketParser', () {
    test('reaches target altitude and reports success', () {
      final tokens = lexer.tokenize(
          'sys.preflight();\nengine.start();\nthrottle(100);');
      final parser = RocketParser(targetAltitude: 20);
      final steps = parser.run(tokens);

      expect(steps.last.result, RocketResultType.goalReached);
      expect(steps.last.altitude, greaterThanOrEqualTo(20));
    });

    test('engine start without preflight explodes', () {
      final tokens = lexer.tokenize('engine.start();');
      final parser = RocketParser(targetAltitude: 100);
      final steps = parser.run(tokens);

      expect(steps, hasLength(1));
      expect(steps.first.result, RocketResultType.exploded);
    });

    test('throttle before engine start is invalid', () {
      final tokens = lexer.tokenize('sys.preflight();\nthrottle(50);');
      final parser = RocketParser(targetAltitude: 100);
      final steps = parser.run(tokens);

      expect(steps.last.result, RocketResultType.invalidThrottle);
    });

    test('unknown command halts with a syntax error', () {
      final tokens = lexer.tokenize('warp.jump();');
      final parser = RocketParser(targetAltitude: 100);
      final steps = parser.run(tokens);

      expect(steps, hasLength(1));
      expect(steps.first.result, RocketResultType.syntaxError);
    });
  });
}
