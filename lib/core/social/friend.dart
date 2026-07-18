import 'package:cloud_firestore/cloud_firestore.dart';

/// Public, read-only data shown for a friend in the social hub.
class FriendSummary {
  final String uid;
  final String email;
  final String? name;
  final String? photoUrl;
  final int xp;
  final int streak;
  final int completedCount;
  final int streakFreezes;

  const FriendSummary({
    required this.uid,
    required this.email,
    this.name,
    this.photoUrl,
    this.xp = 0,
    this.streak = 0,
    this.completedCount = 0,
    this.streakFreezes = 0,
  });

  String get displayName {
    final trimmed = name?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return email.split('@').first;
  }

  factory FriendSummary.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final completed =
        (data['completedModuleIds'] as List<dynamic>?)
            ?.whereType<String>()
            .toList() ??
        const <String>[];
    return FriendSummary(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String?,
      photoUrl: data['photoUrl'] as String?,
      xp: (data['xp'] as num?)?.toInt() ?? 0,
      streak: (data['streak'] as num?)?.toInt() ?? 0,
      completedCount: completed.length,
      streakFreezes: (data['streakFreezes'] as num?)?.toInt() ?? 0,
    );
  }
}
