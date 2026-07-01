import 'rocket_lexer.dart';

enum RocketResultType {
  preflightOk,
  engineStarted,
  throttled,
  exploded,
  invalidThrottle,
  syntaxError,
  goalReached,
}

class RocketStep {
  final int line;
  final RocketResultType result;
  final int altitude;
  final String? detail;

  const RocketStep(this.line, this.result, this.altitude, {this.detail});
}

/// Maps a [RocketToken] stream onto sequential launch-sequence steps,
/// producing an ordered queue of [RocketStep]s. Pure function with respect
/// to rendering/timing, mirroring [Parser]: given identical tokens it
/// always produces an identical step queue.
///
/// Rules:
///  - `engine.start()` before `sys.preflight()` -> [RocketResultType.exploded], halt.
///  - `throttle(N)` before the engine has started -> [RocketResultType.invalidThrottle], halt.
///  - `throttle(N)` while started -> altitude += round(N / 5).
///  - unrecognized token -> [RocketResultType.syntaxError], halt.
///  - altitude >= [targetAltitude] -> [RocketResultType.goalReached], halt.
class RocketParser {
  final int targetAltitude;

  RocketParser({required this.targetAltitude});

  List<RocketStep> run(List<RocketToken> tokens) {
    final steps = <RocketStep>[];
    var preflightDone = false;
    var engineStarted = false;
    var altitude = 0;

    for (final token in tokens) {
      switch (token.type) {
        case RocketTokenType.empty:
        case RocketTokenType.comment:
          continue;
        case RocketTokenType.preflight:
          preflightDone = true;
          steps.add(RocketStep(token.line, RocketResultType.preflightOk, altitude));
          break;
        case RocketTokenType.engineStart:
          if (!preflightDone) {
            steps.add(RocketStep(token.line, RocketResultType.exploded, altitude,
                detail: 'Engine ignited without preflight checks. Catastrophic failure.'));
            return steps;
          }
          engineStarted = true;
          steps.add(RocketStep(token.line, RocketResultType.engineStarted, altitude));
          break;
        case RocketTokenType.throttle:
          if (!engineStarted) {
            steps.add(RocketStep(token.line, RocketResultType.invalidThrottle, altitude,
                detail: 'Cannot throttle. Engines offline.'));
            return steps;
          }
          if (token.throttleValue == null) {
            steps.add(RocketStep(token.line, RocketResultType.syntaxError, altitude,
                detail: 'Syntax Error: Invalid throttle value.'));
            return steps;
          }
          altitude += (token.throttleValue! / 5).round();
          steps.add(RocketStep(token.line, RocketResultType.throttled, altitude));
          break;
        case RocketTokenType.unknown:
          steps.add(RocketStep(token.line, RocketResultType.syntaxError, altitude,
              detail: "Unknown command '${token.raw}'"));
          return steps;
      }

      if (altitude >= targetAltitude) {
        steps.add(RocketStep(token.line, RocketResultType.goalReached, altitude));
        return steps;
      }
    }

    return steps;
  }
}
