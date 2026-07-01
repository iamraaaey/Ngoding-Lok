/// Recognized token kinds emitted by the [Lexer].
enum TokenType { moveRight, moveDown, moveLeft, moveUp, comment, empty, unknown }

class Token {
  final TokenType type;
  final String raw;
  final int line;

  const Token(this.type, this.raw, this.line);
}

/// Sanitizes raw multi-line script input into a flat list of [Token]s.
///
/// The lexer never throws on malformed input: unrecognized lines become
/// [TokenType.unknown] tokens so the parser can surface a syntax error tied
/// to the originating line number instead of aborting the whole script.
class Lexer {
  static const Map<String, TokenType> _keywords = {
    'move.right()': TokenType.moveRight,
    'move.down()': TokenType.moveDown,
    'move.left()': TokenType.moveLeft,
    'move.up()': TokenType.moveUp,
  };

  List<Token> tokenize(String source) {
    final lines = source.split('\n');
    final tokens = <Token>[];

    for (var i = 0; i < lines.length; i++) {
      final lineNumber = i + 1;
      final trimmed = lines[i].trim().toLowerCase();

      if (trimmed.isEmpty) {
        tokens.add(Token(TokenType.empty, trimmed, lineNumber));
        continue;
      }
      if (trimmed.startsWith('//')) {
        tokens.add(Token(TokenType.comment, trimmed, lineNumber));
        continue;
      }

      final normalized = trimmed.endsWith(';')
          ? trimmed.substring(0, trimmed.length - 1)
          : trimmed;
      final type = _keywords[normalized] ?? TokenType.unknown;
      tokens.add(Token(type, normalized, lineNumber));
    }

    return tokens;
  }
}
