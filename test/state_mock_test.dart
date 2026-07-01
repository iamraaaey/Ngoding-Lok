import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/state/game_state.dart';

void main() {
  group('GameState', () {
    test('copyWith preserves grid and target configuration', () {
      const original = GameState(targetX: 4, targetY: 4, gridSize: 6);
      final moved = original.copyWith(playerX: 1, playerY: 2);

      expect(moved.playerX, 1);
      expect(moved.playerY, 2);
      expect(moved.targetX, 4);
      expect(moved.targetY, 4);
      expect(moved.gridSize, 6);
    });

    test('reset returns the player to the origin without losing target config', () {
      const state = GameState(playerX: 3, playerY: 3, targetX: 4, targetY: 4, isExecuting: true);
      final reset = state.reset();

      expect(reset.playerX, 0);
      expect(reset.playerY, 0);
      expect(reset.isExecuting, false);
      expect(reset.targetX, 4);
      expect(reset.targetY, 4);
    });

    test('isAtGoal reflects whether the player occupies the target cell', () {
      const atGoal = GameState(playerX: 3, playerY: 3, targetX: 3, targetY: 3);
      const notAtGoal = GameState(playerX: 0, playerY: 0, targetX: 3, targetY: 3);

      expect(atGoal.isAtGoal, isTrue);
      expect(notAtGoal.isAtGoal, isFalse);
    });
  });
}
