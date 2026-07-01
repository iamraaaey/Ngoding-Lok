import 'package:flutter/material.dart';
import '../../core/session/leaderboard_entry.dart';
import '../theme/doodle.dart';

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
    return DoodleCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events, size: 18, color: Colors.black),
              SizedBox(width: 8),
              Text('Live Rankings', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 14),
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: entry.name == currentUserName ? DoodlePalette.green : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: entry.name == currentUserName ? 3 : 2),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 26,
                      child: Text('#${entry.rank}', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                    Text(entry.avatar, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                    Text('${entry.xp}', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 12)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
