import 'package:flutter/material.dart';
import '../../core/session/leaderboard_entry.dart';
import '../theme/landing_tokens.dart';

/// Live rankings panel in the terminal noir style: carbon card, hairline
/// rows, the current player highlighted in signal green.
class LeaderboardPanel extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final String currentUserName;

  const LeaderboardPanel({
    super.key,
    required this.entries,
    required this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LandingTokens.carbon,
        borderRadius: LandingTokens.mediumRadius,
        border: Border.all(color: LandingTokens.hairline),
        boxShadow: LandingTokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                size: 16,
                color: LandingTokens.ember,
              ),
              const SizedBox(width: 8),
              Text(
                '// LIVE RANKINGS',
                style: LandingTokens.label(
                  fontSize: 10,
                  color: LandingTokens.ember,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Builder(
                builder: (context) {
                  final isMe = entry.name == currentUserName;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? LandingTokens.signal.withValues(alpha: 0.08)
                          : LandingTokens.panel,
                      borderRadius: LandingTokens.smallRadius,
                      border: Border.all(
                        color: isMe
                            ? LandingTokens.signal.withValues(alpha: 0.5)
                            : LandingTokens.hairline,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Text(
                            '#${entry.rank}',
                            style: LandingTokens.mono(
                              fontSize: 11,
                              color: isMe
                                  ? LandingTokens.signal
                                  : LandingTokens.textFaint,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(entry.avatar, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: LandingTokens.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          '${entry.xp} XP',
                          style: LandingTokens.mono(
                            fontSize: 11,
                            color: LandingTokens.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
