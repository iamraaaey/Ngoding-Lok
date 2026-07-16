import '../cybersecurity/cyber_room.dart';

/// Immutable snapshot of the logged-in student: their identity, XP total,
/// and which curriculum modules they've cleared.
class UserSession {
  final String email;

  /// Full display name from the Google profile, when signed in via OAuth.
  /// Null for the simulated email login.
  final String? name;

  /// Google profile picture URL, when available.
  final String? photoUrl;

  final int xp;
  final List<String> completedModuleIds;

  /// Consecutive-day play streak shown on the Home Dashboard. There's no
  /// day-tracking backend in this prototype, so it's seeded at login (see
  /// RootOrchestrator) rather than computed from real timestamps.
  final int streak;

  /// Best "efficiency score" achieved per module id. The League Map reads
  /// this to show how well each cleared level was solved (stars + points).
  final Map<String, int> moduleScores;

  /// Number of "Streak Freeze" tokens the player owns, bought with XP on the
  /// Profile screen. A freeze would spare a missed day from breaking a streak.
  final int streakFreezes;
  final Map<String, CyberRoomProgress> cyberRoomProgress;
  final List<String> badges;

  const UserSession({
    required this.email,
    this.name,
    this.photoUrl,
    this.xp = 0,
    this.completedModuleIds = const [],
    this.streak = 1,
    this.moduleScores = const {},
    this.streakFreezes = 0,
    this.cyberRoomProgress = const {},
    this.badges = const [],
  });

  String get displayName {
    final trimmed = name?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return email.split('@').first;
  }

  UserSession copyWith({
    int? xp,
    List<String>? completedModuleIds,
    int? streak,
    Map<String, int>? moduleScores,
    int? streakFreezes,
    Map<String, CyberRoomProgress>? cyberRoomProgress,
    List<String>? badges,
  }) {
    return UserSession(
      email: email,
      name: name,
      photoUrl: photoUrl,
      xp: xp ?? this.xp,
      completedModuleIds: completedModuleIds ?? this.completedModuleIds,
      streak: streak ?? this.streak,
      moduleScores: moduleScores ?? this.moduleScores,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      cyberRoomProgress: cyberRoomProgress ?? this.cyberRoomProgress,
      badges: badges ?? this.badges,
    );
  }

  UserSession withCyberRoomProgress(
    String moduleId,
    CyberRoomProgress progress,
  ) => copyWith(cyberRoomProgress: {...cyberRoomProgress, moduleId: progress});

  UserSession withBadge(String badge) =>
      copyWith(badges: [...badges, if (!badges.contains(badge)) badge]);

  UserSession withModuleCompleted(String moduleId, int score) {
    final best = moduleScores[moduleId];
    return copyWith(
      xp: xp + score,
      completedModuleIds: [
        ...completedModuleIds,
        if (!completedModuleIds.contains(moduleId)) moduleId,
      ],
      moduleScores: {
        ...moduleScores,
        moduleId: (best == null || score > best) ? score : best,
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'xp': xp,
      'completedModuleIds': completedModuleIds,
      'streak': streak,
      'moduleScores': moduleScores,
      'streakFreezes': streakFreezes,
      'cyberRoomProgress': cyberRoomProgress.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'badges': badges,
    };
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      email: json['email'] as String,
      name: json['name'] as String?,
      photoUrl: json['photoUrl'] as String?,
      xp: json['xp'] as int? ?? 0,
      completedModuleIds:
          (json['completedModuleIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      streak: json['streak'] as int? ?? 1,
      moduleScores:
          (json['moduleScores'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as int),
          ) ??
          const {},
      streakFreezes: json['streakFreezes'] as int? ?? 0,
      cyberRoomProgress:
          (json['cyberRoomProgress'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              CyberRoomProgress.fromJson(value as Map<String, dynamic>),
            ),
          ) ??
          const {},
      badges: (json['badges'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }
}
