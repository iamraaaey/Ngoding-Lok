/// Immutable snapshot of the player's position and execution status on the
/// grid. New states are produced via [copyWith] rather than mutation so the
/// UI layer can diff cheaply and avoid redundant repaints.
class GameState {
  final int playerX;
  final int playerY;
  final int targetX;
  final int targetY;
  final int gridSize;
  final bool isExecuting;
  final int activeLineIndex;
  final bool goalReached;

  const GameState({
    this.playerX = 0,
    this.playerY = 0,
    this.targetX = 3,
    this.targetY = 3,
    this.gridSize = 5,
    this.isExecuting = false,
    this.activeLineIndex = -1,
    this.goalReached = false,
  });

  GameState copyWith({
    int? playerX,
    int? playerY,
    bool? isExecuting,
    int? activeLineIndex,
    bool? goalReached,
  }) {
    return GameState(
      playerX: playerX ?? this.playerX,
      playerY: playerY ?? this.playerY,
      targetX: targetX,
      targetY: targetY,
      gridSize: gridSize,
      isExecuting: isExecuting ?? this.isExecuting,
      activeLineIndex: activeLineIndex ?? this.activeLineIndex,
      goalReached: goalReached ?? this.goalReached,
    );
  }

  GameState reset() => GameState(
        targetX: targetX,
        targetY: targetY,
        gridSize: gridSize,
      );

  bool get isAtGoal => playerX == targetX && playerY == targetY;
}
