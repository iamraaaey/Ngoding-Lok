import '../../core/cybersecurity/cyber_room.dart';
import '../../core/session/user_session.dart';
import '../../core/session/module_performance.dart';
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
  final int bestStreak;
  final String? lastActivityDate;
  final Map<String, int> moduleScores;
  final Map<String, ModulePerformance> modulePerformance;
  final int streakFreezes;
  final Map<String, CyberRoomProgress> cyberRoomProgress;
  final List<String> badges;
  final List<String> achievementIds;
  final String? referralCode;
  final String? referredBy;
  final bool referralRewardClaimed;
  final List<String> friendIds;
  final DateTime updatedAt;

  const FirestoreUser({
    required this.uid,
    required this.email,
    this.name,
    this.photoUrl,
    this.xp = 0,
    this.completedModuleIds = const [],
    this.streak = 1,
    this.bestStreak = 1,
    this.lastActivityDate,
    this.moduleScores = const {},
    this.modulePerformance = const {},
    this.streakFreezes = 0,
    this.cyberRoomProgress = const {},
    this.badges = const [],
    this.achievementIds = const [],
    this.referralCode,
    this.referredBy,
    this.referralRewardClaimed = false,
    this.friendIds = const [],
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
      bestStreak: bestStreak,
      lastActivityDate: lastActivityDate,
      moduleScores: moduleScores,
      modulePerformance: modulePerformance,
      streakFreezes: streakFreezes,
      cyberRoomProgress: cyberRoomProgress,
      badges: badges,
      achievementIds: achievementIds,
      referralCode: referralCode,
      referredBy: referredBy,
      referralRewardClaimed: referralRewardClaimed,
      friendIds: friendIds,
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
      bestStreak: session.bestStreak,
      lastActivityDate: session.lastActivityDate,
      moduleScores: session.moduleScores,
      modulePerformance: session.modulePerformance,
      streakFreezes: session.streakFreezes,
      cyberRoomProgress: session.cyberRoomProgress,
      badges: session.badges,
      achievementIds: session.achievementIds,
      referralCode: session.referralCode,
      referredBy: session.referredBy,
      referralRewardClaimed: session.referralRewardClaimed,
      friendIds: session.friendIds,
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
      'bestStreak': bestStreak,
      'lastActivityDate': lastActivityDate,
      'moduleScores': moduleScores,
      'modulePerformance': modulePerformance.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'streakFreezes': streakFreezes,
      'cyberRoomProgress': cyberRoomProgress.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'badges': badges,
      'achievementIds': achievementIds,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'referralRewardClaimed': referralRewardClaimed,
      'friendIds': friendIds,
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
      xp: (data['xp'] as num?)?.toInt() ?? 0,
      completedModuleIds:
          (data['completedModuleIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      streak: (data['streak'] as num?)?.toInt() ?? 1,
      bestStreak:
          (data['bestStreak'] as num?)?.toInt() ??
          (data['streak'] as num?)?.toInt() ??
          1,
      lastActivityDate: data['lastActivityDate'] as String?,
      moduleScores:
          (data['moduleScores'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          ) ??
          const {},
      modulePerformance:
          (data['modulePerformance'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, ModulePerformance.fromMap(value)),
          ) ??
          const {},
      streakFreezes: (data['streakFreezes'] as num?)?.toInt() ?? 0,
      cyberRoomProgress:
          (data['cyberRoomProgress'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              CyberRoomProgress.fromJson(value as Map<String, dynamic>),
            ),
          ) ??
          const {},
      badges: (data['badges'] as List<dynamic>?)?.cast<String>() ?? const [],
      achievementIds:
          (data['achievementIds'] as List<dynamic>?)?.cast<String>() ??
          const [],
      referralCode: data['referralCode'] as String?,
      referredBy: data['referredBy'] as String?,
      referralRewardClaimed: data['referralRewardClaimed'] as bool? ?? false,
      friendIds:
          (data['friendIds'] as List<dynamic>?)?.cast<String>() ?? const [],
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
    int? bestStreak,
    String? lastActivityDate,
    Map<String, int>? moduleScores,
    Map<String, ModulePerformance>? modulePerformance,
    int? streakFreezes,
    Map<String, CyberRoomProgress>? cyberRoomProgress,
    List<String>? badges,
    List<String>? achievementIds,
    String? referralCode,
    String? referredBy,
    bool? referralRewardClaimed,
    List<String>? friendIds,
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
      bestStreak: bestStreak ?? this.bestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      moduleScores: moduleScores ?? this.moduleScores,
      modulePerformance: modulePerformance ?? this.modulePerformance,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      cyberRoomProgress: cyberRoomProgress ?? this.cyberRoomProgress,
      badges: badges ?? this.badges,
      achievementIds: achievementIds ?? this.achievementIds,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      referralRewardClaimed:
          referralRewardClaimed ?? this.referralRewardClaimed,
      friendIds: friendIds ?? this.friendIds,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
