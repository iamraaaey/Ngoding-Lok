/// Recognized token kinds emitted by the [RocketLexer].
enum RocketTokenType { preflight, engineStart, throttle, comment, empty, unknown }

class RocketToken {
  final RocketTokenType type;
  final String raw;
  final int line;
  final int? throttleValue;

  const RocketToken(this.type, this.raw, this.line, {this.throttleValue});
}

/// Tokenizes a rocket launch script into [RocketToken]s. Never throws:
/// unrecognized lines become [RocketTokenType.unknown] so the parser can
/// report a line-numbered error instead of crashing, mirroring [Lexer].
class RocketLexer {
  static final RegExp _throttlePattern = RegExp(r'^throttle\((\d+)\)$');

  List<RocketToken> tokenize(String source) {
    final lines = source.split('\n');
    final tokens = <RocketToken>[];

    for (var i = 0; i < lines.length; i++) {
      final lineNumber = i + 1;
      final trimmed = lines[i].trim().toLowerCase();

      if (trimmed.isEmpty) {
        tokens.add(RocketToken(RocketTokenType.empty, trimmed, lineNumber));
        continue;
      }
      if (trimmed.startsWith('//')) {
        tokens.add(RocketToken(RocketTokenType.comment, trimmed, lineNumber));
        continue;
      }

      final normalized = trimmed.endsWith(';')
          ? trimmed.substring(0, trimmed.length - 1)
          : trimmed;

      if (normalized == 'sys.preflight()') {
        tokens.add(RocketToken(RocketTokenType.preflight, normalized, lineNumber));
        continue;
      }
      if (normalized == 'engine.start()') {
        tokens.add(RocketToken(RocketTokenType.engineStart, normalized, lineNumber));
        continue;
      }

      final throttleMatch = _throttlePattern.firstMatch(normalized);
      if (throttleMatch != null) {
        final value = int.tryParse(throttleMatch.group(1)!);
        tokens.add(RocketToken(RocketTokenType.throttle, normalized, lineNumber,
            throttleValue: value));
        continue;
      }

      tokens.add(RocketToken(RocketTokenType.unknown, normalized, lineNumber));
    }

    return tokens;
  }
}
