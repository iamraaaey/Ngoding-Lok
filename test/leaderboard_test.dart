import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/session/leaderboard.dart';
import 'package:ngecode_juh/core/session/user_session.dart';

void main() {
  group('Leaderboard.withUser', () {
    test('ranks the user first when they have the highest XP', () {
      const user = UserSession(email: 'top@school.edu', xp: 99999);
      final board = Leaderboard.withUser(user);

      expect(board.first.name, 'top');
      expect(board.first.rank, 1);
    });

    test('ranks are contiguous and sorted descending by XP', () {
      const user = UserSession(email: 'mid@school.edu', xp: 2000);
      final board = Leaderboard.withUser(user);

      for (var i = 0; i < board.length; i++) {
        expect(board[i].rank, i + 1);
      }
      for (var i = 1; i < board.length; i++) {
        expect(board[i - 1].xp, greaterThanOrEqualTo(board[i].xp));
      }
    });

    test('ties are broken by name ascending', () {
      const user = UserSession(email: 'aaa@school.edu', xp: 1200);
      final board = Leaderboard.withUser(user);
      final tied = board.where((e) => e.xp == 1200).toList();

      expect(tied.first.name, 'aaa');
    });
  });
}
