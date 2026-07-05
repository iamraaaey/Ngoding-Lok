import 'package:flutter/material.dart';
import '../../core/session/progression.dart';
import 'doodle.dart';

/// Presentation-side styling for [LeagueTier]s (color + icon). Kept in the
/// presentation layer via an extension so the core [Progression] logic stays
/// free of any Flutter UI dependency.
extension LeagueTierStyle on LeagueTier {
  Color get color => switch (this) {
        LeagueTier.wood => const Color(0xFF9C6B3F),
        LeagueTier.bronze => const Color(0xFFCD7F32),
        LeagueTier.silver => const Color(0xFFB0BEC5),
        LeagueTier.gold => DoodlePalette.yellow,
        LeagueTier.platinum => DoodlePalette.green,
      };

  IconData get icon => switch (this) {
        LeagueTier.wood => Icons.park,
        LeagueTier.bronze => Icons.shield,
        LeagueTier.silver => Icons.shield_moon,
        LeagueTier.gold => Icons.military_tech,
        LeagueTier.platinum => Icons.workspace_premium,
      };
}
