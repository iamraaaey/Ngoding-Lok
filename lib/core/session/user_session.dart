/// Immutable snapshot of the logged-in student: their identity, XP total,
/// and which curriculum modules they've cleared.
class UserSession {
  final String email;
  final int xp;
  final List<String> completedModuleIds;

  const UserSession({
    required this.email,
    this.xp = 0,
    this.completedModuleIds = const [],
  });

  String get displayName => email.split('@').first;

  UserSession copyWith({int? xp, List<String>? completedModuleIds}) {
    return UserSession(
      email: email,
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
