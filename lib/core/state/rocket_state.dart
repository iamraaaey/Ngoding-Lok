/// Immutable snapshot of the rocket module's simulation. Mirrors
/// [GameState]'s copyWith pattern.
class RocketState {
  final int altitude;
  final int targetAltitude;
  final bool preflightDone;
  final bool engineStarted;
  final bool exploded;
  final bool goalReached;
  final bool isExecuting;
  final int activeLineIndex;

  const RocketState({
    this.altitude = 0,
    required this.targetAltitude,
    this.preflightDone = false,
    this.engineStarted = false,
    this.exploded = false,
    this.goalReached = false,
    this.isExecuting = false,
    this.activeLineIndex = -1,
  });

  RocketState copyWith({
    int? altitude,
    bool? preflightDone,
    bool? engineStarted,
    bool? exploded,
    bool? goalReached,
    bool? isExecuting,
    int? activeLineIndex,
  }) {
    return RocketState(
      altitude: altitude ?? this.altitude,
      targetAltitude: targetAltitude,
      preflightDone: preflightDone ?? this.preflightDone,
      engineStarted: engineStarted ?? this.engineStarted,
      exploded: exploded ?? this.exploded,
      goalReached: goalReached ?? this.goalReached,
      isExecuting: isExecuting ?? this.isExecuting,
      activeLineIndex: activeLineIndex ?? this.activeLineIndex,
    );
  }

  RocketState reset() => RocketState(targetAltitude: targetAltitude);
}
