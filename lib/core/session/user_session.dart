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

  const UserSession({
    required this.email,
    this.name,
    this.photoUrl,
    this.xp = 0,
    this.completedModuleIds = const [],
  });

  String get displayName {
    final trimmed = name?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return email.split('@').first;
  }

  UserSession copyWith({int? xp, List<String>? completedModuleIds}) {
    return UserSession(
      email: email,
      name: name,
      photoUrl: photoUrl,
      xp: xp ?? this.xp,
      completedModuleIds: completedModuleIds ?? this.completedModuleIds,
    );
  }

  UserSession withModuleCompleted(String moduleId, int xpGained) {
    return copyWith(
      xp: xp + xpGained,
      completedModuleIds: [
        ...completedModuleIds,
        if (!completedModuleIds.contains(moduleId)) moduleId,
      ],
    );
  }
}
