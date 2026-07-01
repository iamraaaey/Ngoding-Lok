import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/interpreter/lexer.dart';
import 'package:ngecode_juh/core/interpreter/parser.dart';

void main() {
  final lexer = Lexer();

  group('Lexer', () {
    test('tokenizes known movement commands', () {
      final tokens = lexer.tokenize('move.right();\nmove.down();');
      expect(tokens[0].type, TokenType.moveRight);
      expect(tokens[1].type, TokenType.moveDown);
    });

    test('ignores blank lines and comments', () {
      final tokens = lexer.tokenize('\n// a comment\nmove.up();');
      expect(tokens[0].type, TokenType.empty);
      expect(tokens[1].type, TokenType.comment);
      expect(tokens[2].type, TokenType.moveUp);
    });

    test('flags unrecognized syntax as unknown', () {
      final tokens = lexer.tokenize('teleport();');
      expect(tokens[0].type, TokenType.unknown);
    });
  });

  group('Parser', () {
    test('walks toward the target and reports success', () {
      final tokens = lexer.tokenize('move.right();\nmove.right();\nmove.right();\nmove.down();\nmove.down();\nmove.down();');
      final parser = Parser(gridSize: 5);
      final steps = parser.run(tokens, startX: 0, startY: 0, targetX: 3, targetY: 3);

      expect(steps.last.result, ExecutionResultType.goalReached);
      expect(steps.last.x, 3);
      expect(steps.last.y, 3);
    });

    test('stops execution and reports out-of-bounds movement', () {
      final tokens = lexer.tokenize('move.left();');
      final parser = Parser(gridSize: 5);
      final steps = parser.run(tokens, startX: 0, startY: 0, targetX: 3, targetY: 3);

      expect(steps, hasLength(1));
      expect(steps.first.result, ExecutionResultType.outOfBounds);
    });

    test('stops execution on unknown command with a syntax error', () {
      final tokens = lexer.tokenize('fly.up();');
      final parser = Parser(gridSize: 5);
      final steps = parser.run(tokens, startX: 0, startY: 0, targetX: 3, targetY: 3);

      expect(steps, hasLength(1));
      expect(steps.first.result, ExecutionResultType.syntaxError);
    });
  });
}
