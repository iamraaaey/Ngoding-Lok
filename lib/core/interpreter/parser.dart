import 'lexer.dart';

enum ExecutionResultType { moved, outOfBounds, syntaxError, goalReached }

class ExecutionStep {
  final int line;
  final ExecutionResultType result;
  final int x;
  final int y;
  final String? detail;

  const ExecutionStep(this.line, this.result, this.x, this.y, {this.detail});
}

/// Maps a token stream onto sequential grid-movement operations, producing
/// an ordered queue of [ExecutionStep]s. The parser is stateless with
/// respect to rendering: it only computes *what should happen*, leaving the
/// UI layer to animate/render each step at its own pace.
class Parser {
  final int gridSize;

  Parser({this.gridSize = 5});

  List<ExecutionStep> run(
    List<Token> tokens, {
    required int startX,
    required int startY,
    required int targetX,
    required int targetY,
  }) {
    final steps = <ExecutionStep>[];
    var x = startX;
    var y = startY;

    for (final token in tokens) {
      switch (token.type) {
        case TokenType.empty:
        case TokenType.comment:
          continue;
        case TokenType.moveRight:
          if (x >= gridSize - 1) {
            steps.add(ExecutionStep(token.line, ExecutionResultType.outOfBounds, x, y,
                detail: 'Out of bounds (Right)'));
            return steps;
          }
          x++;
          break;
        case TokenType.moveDown:
          if (y >= gridSize - 1) {
            steps.add(ExecutionStep(token.line, ExecutionResultType.outOfBounds, x, y,
                detail: 'Out of bounds (Down)'));
            return steps;
          }
          y++;
          break;
        case TokenType.moveLeft:
          if (x <= 0) {
            steps.add(ExecutionStep(token.line, ExecutionResultType.outOfBounds, x, y,
                detail: 'Out of bounds (Left)'));
            return steps;
          }
          x--;
          break;
        case TokenType.moveUp:
          if (y <= 0) {
            steps.add(ExecutionStep(token.line, ExecutionResultType.outOfBounds, x, y,
                detail: 'Out of bounds (Up)'));
            return steps;
          }
          y--;
          break;
        case TokenType.unknown:
          steps.add(ExecutionStep(token.line, ExecutionResultType.syntaxError, x, y,
              detail: "Unknown command '${token.raw}'"));
          return steps;
      }

      if (x == targetX && y == targetY) {
        steps.add(ExecutionStep(token.line, ExecutionResultType.goalReached, x, y));
        return steps;
      }
      steps.add(ExecutionStep(token.line, ExecutionResultType.moved, x, y));
    }

    return steps;
  }
}
