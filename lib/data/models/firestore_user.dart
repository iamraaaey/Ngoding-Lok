import '../../core/cybersecurity/cyber_room.dart';
import '../../core/session/user_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore-compatible representation of user data. Mirrors UserSession
/// but includes Firestore-specific handling (timestamps, document reference).
class FirestoreUser {
  final String uid;
  final String email;
  final String? name;
  final String? photoUrl;
  final int xp;
  final List<String> completedModuleIds;
  final int streak;
  final Map<String, int> moduleScores;
  final int streakFreezes;
  final Map<String, CyberRoomProgress> cyberRoomProgress;
  final List<String> badges;
  final DateTime updatedAt;

  const FirestoreUser({
    required this.uid,
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
    required this.updatedAt,
  });

  /// Convert Firestore user to app's UserSession (for use in app logic)
  UserSession toUserSession() {
    return UserSession(
      email: email,
      name: name,
      photoUrl: photoUrl,
      xp: xp,
      completedModuleIds: completedModuleIds,
      streak: streak,
      moduleScores: moduleScores,
      streakFreezes: streakFreezes,
      cyberRoomProgress: cyberRoomProgress,
      badges: badges,
    );
  }

  /// Create FirestoreUser from app's UserSession
  static FirestoreUser fromUserSession(UserSession session, String uid) {
    return FirestoreUser(
      uid: uid,
      email: session.email,
      name: session.name,
      photoUrl: session.photoUrl,
      xp: session.xp,
      completedModuleIds: session.completedModuleIds,
      streak: session.streak,
      moduleScores: session.moduleScores,
      streakFreezes: session.streakFreezes,
      cyberRoomProgress: session.cyberRoomProgress,
      badges: session.badges,
      updatedAt: DateTime.now(),
    );
  }

  /// Serialize to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
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
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Deserialize from Firestore document
  factory FirestoreUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirestoreUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String?,
      photoUrl: data['photoUrl'] as String?,
      xp: data['xp'] as int? ?? 0,
      completedModuleIds: (data['completedModuleIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      streak: data['streak'] as int? ?? 1,
      moduleScores: (data['moduleScores'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as int),
          ) ??
          const {},
      streakFreezes: data['streakFreezes'] as int? ?? 0,
      cyberRoomProgress:
          (data['cyberRoomProgress'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              CyberRoomProgress.fromJson(value as Map<String, dynamic>),
            ),
          ) ??
          const {},
      badges: (data['badges'] as List<dynamic>?)?.cast<String>() ?? const [],
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  FirestoreUser copyWith({
    String? uid,
    String? email,
    String? name,
    String? photoUrl,
    int? xp,
    List<String>? completedModuleIds,
    int? streak,
    Map<String, int>? moduleScores,
    int? streakFreezes,
    Map<String, CyberRoomProgress>? cyberRoomProgress,
    List<String>? badges,
    DateTime? updatedAt,
  }) {
    return FirestoreUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      xp: xp ?? this.xp,
      completedModuleIds: completedModuleIds ?? this.completedModuleIds,
      streak: streak ?? this.streak,
      moduleScores: moduleScores ?? this.moduleScores,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      cyberRoomProgress: cyberRoomProgress ?? this.cyberRoomProgress,
      badges: badges ?? this.badges,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
