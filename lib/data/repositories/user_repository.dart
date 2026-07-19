import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/curriculum/language_track.dart';
import '../../core/curriculum/module_type.dart';
import '../../core/streaming/switch_latest.dart';
import '../../core/session/leaderboard_entry.dart';
import '../../core/session/module_performance.dart';
import '../../core/social/code_golf.dart';
import '../../core/social/achievement.dart';
import '../../core/social/friend.dart';
import '../../core/social/referral_reconciliation.dart';
import '../../core/session/user_session.dart';
import '../models/module_certificate.dart';
import '../models/firestore_user.dart';

/// Thrown when a referral code cannot be redeemed safely.
class ReferralException implements Exception {
  final String message;

  const ReferralException(this.message);

  @override
  String toString() => message;
}

/// Thrown when a certificate is requested for a module that is not verified
/// as completed in Firestore.
class CertificateException implements Exception {
  final String message;

  const CertificateException(this.message);

  @override
  String toString() => message;
}

/// Repository for Firestore user data operations. Handles syncing,
/// fetching, and updating user data in Firestore.
class UserRepository {
  final FirebaseFirestore? _firestore;

  UserRepository({FirebaseFirestore? firestore}) : _firestore = firestore;

  // Firebase is optional for the local/demo session. Resolve it only when a
  // repository method is actually called, so simply building the app does not
  // crash before Firebase.initializeApp has completed.
  FirebaseFirestore get _database => _firestore ?? FirebaseFirestore.instance;

  /// Collection reference for users
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _database.collection('users');

  CollectionReference<Map<String, dynamic>> get _referralCodesCollection =>
      _database.collection('referralCodes');

  CollectionReference<Map<String, dynamic>> get _redemptionsCollection =>
      _database.collection('referralRedemptions');

  CollectionReference<Map<String, dynamic>> get _certificatesCollection =>
      _database.collection('certificates');

  CollectionReference<Map<String, dynamic>> get _codeGolfCollection =>
      _database.collection('codeGolfEntries');

  /// The referral code is deterministic, so it is available immediately for
  /// a newly authenticated account and does not need a second invite-code
  /// generation service.
  String referralCodeForUid(String uid) {
    final normalized = uid
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .toUpperCase();
    final suffix = normalized.length > 8
        ? normalized.substring(0, 8)
        : normalized.padRight(8, 'X');
    return 'NG$suffix';
  }

  /// Save user session to Firestore (upsert)
  Future<void> saveUserToFirestore(UserSession user, String uid) async {
    try {
      final session = user.referralCode == null
          ? user.copyWith(referralCode: referralCodeForUid(uid))
          : user;
      final firestoreUser = FirestoreUser.fromUserSession(session, uid);
      final userRef = _usersCollection.doc(uid);

      // Session saves can race a referral transaction (for example while a
      // second tab is restoring its cached session). Preserve server-owned
      // relationship state instead of allowing an older snapshot to erase a
      // newly-created friend link or referral reward.
      await _database.runTransaction((transaction) async {
        final existing = await transaction.get(userRef);
        final existingData = existing.data() ?? const <String, dynamic>{};
        final data = firestoreUser.toFirestore();
        data['friendIds'] = {
          ..._stringList(existingData['friendIds']),
          ...session.friendIds,
        }.toList();
        data['achievementIds'] = {
          ..._stringList(existingData['achievementIds']),
          ...session.achievementIds,
        }.toList();
        data['badges'] = {
          ..._stringList(existingData['badges']),
          ...session.badges,
        }.toList();
        data['completedModuleIds'] = {
          ..._stringList(existingData['completedModuleIds']),
          ...session.completedModuleIds,
        }.toList();
        data['referralRewardClaimed'] =
            existingData['referralRewardClaimed'] == true ||
            session.referralRewardClaimed;
        data['referredBy'] = existingData['referredBy'] ?? session.referredBy;
        if (existing.exists) {
          // XP is awarded monotonically by the server transactions. A stale
          // local save must never roll it back.
          data['xp'] = math.max(_intValue(existingData['xp']), session.xp);
          transaction.set(userRef, data, SetOptions(merge: true));
        } else {
          transaction.set(userRef, data);
        }
      });

      // This small public index lets a new user redeem a code without
      // exposing the referrer's private progress fields.
      final code = session.referralCode!;
      await _referralCodesCollection.doc(code).set({
        'ownerUid': uid,
        'ownerName': session.displayName,
        'ownerEmail': session.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving user to Firestore: $e');
      rethrow;
    }
  }

  /// Fetch user data from Firestore
  Future<UserSession?> fetchUserFromFirestore(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (!doc.exists) return null;

      final firestoreUser = FirestoreUser.fromFirestore(doc);
      return firestoreUser.toUserSession();
    } catch (e) {
      debugPrint('Error fetching user from Firestore: $e');
      return null;
    }
  }

  /// Set up real-time listener for user data changes
  Stream<UserSession?> streamUserFromFirestore(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      final firestoreUser = FirestoreUser.fromFirestore(doc);
      return firestoreUser.toUserSession();
    });
  }

  /// Resolves the current friend list from the latest user documents. The
  /// IDs live in the user's session, while this query keeps displayed XP and
  /// names fresh as friends continue learning.
  Future<List<FriendSummary>> fetchFriends(List<String> friendIds) async {
    final uniqueIds = friendIds.toSet().toList();
    if (uniqueIds.isEmpty) return const [];

    final docs = await Future.wait(
      uniqueIds.map((id) => _usersCollection.doc(id).get()),
    );
    return [
      for (final doc in docs)
        if (doc.exists) FriendSummary.fromFirestore(doc),
    ];
  }

  /// Live friend list: emits whenever any friend document changes.
  Stream<List<FriendSummary>> streamFriends(List<String> friendIds) {
    final uniqueIds = friendIds.toSet().toList();
    if (uniqueIds.isEmpty) return Stream.value(const <FriendSummary>[]);

    final controller = StreamController<List<FriendSummary>>();
    final latestByUid = <String, FriendSummary>{};
    final subs = <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];

    void emit() {
      final ordered = [
        for (final id in uniqueIds)
          if (latestByUid.containsKey(id)) latestByUid[id]!,
      ];
      controller.add(ordered);
    }

    final chunks = _chunked(uniqueIds, 10);
    for (final chunk in chunks) {
      final sub = _usersCollection
          .where(FieldPath.documentId, whereIn: chunk)
          .snapshots()
          .listen((snapshot) {
            for (final doc in snapshot.docs) {
              latestByUid[doc.id] = FriendSummary.fromFirestore(doc);
            }
            emit();
          }, onError: controller.addError);
      subs.add(sub);
    }

    controller.onCancel = () async {
      for (final sub in subs) {
        await sub.cancel();
      }
    };

    return controller.stream;
  }

  /// Live friend list driven by the signed-in user's Firestore document.
  /// This is intentionally based on the remote relationship list rather than
  /// a widget's cached session so both sides of a referral update immediately.
  Stream<List<FriendSummary>> streamFriendsForUser(String uid) {
    return switchLatest(
      _usersCollection
          .doc(uid)
          .snapshots()
          .map((doc) => streamFriends(_stringList(doc.data()?['friendIds']))),
    );
  }

  /// Global XP leaderboard from real Firestore user profiles.
  Stream<List<LeaderboardEntry>> streamGlobalLeaderboard({
    required String currentUid,
    required UserSession currentUser,
    int limit = 50,
  }) {
    return _usersCollection
        .orderBy('xp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          final entries = <LeaderboardEntry>[];
          var rank = 1;
          var includedCurrentUser = false;

          for (final doc in snapshot.docs) {
            final data = doc.data();
            final name = _displayNameFromData(data);
            final xp = _intValue(data['xp']);
            if (doc.id == currentUid) includedCurrentUser = true;
            entries.add(
              LeaderboardEntry(
                rank: rank++,
                name: name,
                xp: xp,
                avatar: _avatarForUser(doc.id, name),
              ),
            );
          }

          // Keep the signed-in user visible if they are outside the top list.
          if (!includedCurrentUser) {
            final plusSelf = [
              ...entries,
              LeaderboardEntry(
                rank: 0,
                name: currentUser.displayName,
                xp: currentUser.xp,
                avatar: _avatarForUser(currentUid, currentUser.displayName),
              ),
            ]..sort((a, b) => b.xp.compareTo(a.xp));

            return [
              for (var i = 0; i < plusSelf.length; i++)
                LeaderboardEntry(
                  rank: i + 1,
                  name: plusSelf[i].name,
                  xp: plusSelf[i].xp,
                  avatar: plusSelf[i].avatar,
                ),
            ];
          }

          return entries;
        });
  }

  /// Real-time Code Golf standings for one track.
  Stream<List<CodeGolfEntry>> streamCodeGolfEntries({
    required LanguageTrack track,
    required List<String> friendIds,
  }) {
    final friendSet = friendIds.toSet();
    return _codeGolfCollection
        .where('track', isEqualTo: codeGolfTrackKey(track))
        .snapshots()
        .map((snapshot) {
          final entries =
              [
                for (final doc in snapshot.docs)
                  CodeGolfEntry.fromMap(
                    doc.id,
                    doc.data(),
                    friendIds: friendSet,
                  ),
              ]..sort(
                (a, b) => a.bytes != b.bytes
                    ? a.bytes.compareTo(b.bytes)
                    : a.executionMs != b.executionMs
                    ? a.executionMs.compareTo(b.executionMs)
                    : a.accuracy != b.accuracy
                    ? b.accuracy.compareTo(a.accuracy)
                    : _dateSort(a.completedAt, b.completedAt),
              );
          return entries;
        });
  }

  /// Upserts the signed-in user's best Code Golf score for a module.
  Future<void> upsertCodeGolfEntry({
    required String uid,
    required UserSession user,
    required CurriculumModule module,
    required String source,
    required int executionMs,
    required int completionScore,
    required double accuracy,
  }) async {
    final normalizedSource = source.trim();
    final byteCount = utf8.encode(normalizedSource).length;
    if (byteCount <= 0) return;

    final docId = '${module.id}_$uid';
    final docRef = _codeGolfCollection.doc(docId);

    await _database.runTransaction((transaction) async {
      final existing = await transaction.get(docRef);
      final existingData = existing.data() ?? const <String, dynamic>{};
      final currentBytes = _intValue(existingData['bytes']);
      final currentTime = _intValue(existingData['executionMs']);
      final currentAccuracy =
          (existingData['accuracy'] as num?)?.toDouble() ?? 0;
      final shouldUpdate =
          !existing.exists ||
          byteCount < currentBytes ||
          (byteCount == currentBytes && executionMs < currentTime) ||
          (byteCount == currentBytes &&
              executionMs == currentTime &&
              accuracy > currentAccuracy);
      if (!shouldUpdate) {
        return;
      }

      transaction.set(docRef, {
        'uid': uid,
        'track': codeGolfTrackKey(module.track),
        'moduleId': module.id,
        'moduleTitle': module.title,
        'bytes': byteCount,
        'source': normalizedSource,
        'executionMs': executionMs,
        'completionScore': completionScore,
        'accuracy': accuracy,
        'playerName': user.displayName,
        'avatar': _avatarForUser(uid, user.displayName),
        'completedAt':
            existingData['completedAt'] ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  /// Records a sign-in/activity event in the same document that powers the
  /// profile. The transaction makes a second tab or a refresh idempotent for
  /// the current day and applies a freeze only when there was exactly one
  /// missed day.
  Future<UserSession> recordActivity(String uid) async {
    final userRef = _usersCollection.doc(uid);
    await _database.runTransaction((transaction) async {
      final doc = await transaction.get(userRef);
      if (!doc.exists) return;
      final data = doc.data() ?? const <String, dynamic>{};
      final activity = _nextActivity(
        lastActivityDate: data['lastActivityDate'] as String?,
        streak: _intValue(data['streak'], fallback: 1),
        bestStreak: _intValue(
          data['bestStreak'],
          fallback: _intValue(data['streak'], fallback: 1),
        ),
        streakFreezes: _intValue(data['streakFreezes']),
      );
      final existingAchievements = _stringList(data['achievementIds']);
      final current = FirestoreUser.fromFirestore(doc).toUserSession();
      final projected = current.copyWith(
        streak: activity.streak,
        bestStreak: activity.bestStreak,
        lastActivityDate: activity.lastActivityDate,
        streakFreezes: activity.streakFreezes,
      );
      final achievements = {
        ...existingAchievements,
        ...Achievements.unlockedIds(projected),
      }.toList();
      transaction.update(userRef, {
        'streak': activity.streak,
        'bestStreak': activity.bestStreak,
        'lastActivityDate': activity.lastActivityDate,
        'streakFreezes': activity.streakFreezes,
        'achievementIds': achievements,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
    return await fetchUserFromFirestore(uid) ??
        (throw StateError('Profile could not be refreshed after activity.'));
  }

  /// Atomically persists a verified module result, XP delta, streak update,
  /// achievement unlocks, performance metrics and the Code Golf submission.
  /// A replay can improve a score or Code Golf result, but never awards the
  /// full module XP a second time.
  Future<UserSession> recordModuleCompletion({
    required String uid,
    required UserSession user,
    required CurriculumModule module,
    required int score,
    required int linesUsed,
    required int executionMs,
    required String source,
  }) async {
    final userRef = _usersCollection.doc(uid);
    final codeGolfRef = _codeGolfCollection.doc('${module.id}_$uid');
    final isCodeTrack =
        module.type == ModuleType.logicGrid ||
        module.type == ModuleType.sqlTerminal ||
        module.type == ModuleType.rocketFlight;

    await _database.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) {
        throw StateError('Profile not found.');
      }
      final codeDoc = isCodeTrack ? await transaction.get(codeGolfRef) : null;
      final data = userDoc.data() ?? const <String, dynamic>{};
      final completed = _stringList(data['completedModuleIds']);
      final scores = _intMap(data['moduleScores']);
      final performanceMap = _mapValue(data['modulePerformance']);
      final existingPerformance = performanceMap[module.id] == null
          ? null
          : ModulePerformance.fromMap(performanceMap[module.id]);
      final currentScore = scores[module.id];
      final bestScore = currentScore == null || score > currentScore
          ? score
          : currentScore;
      final improvesPerformance =
          existingPerformance == null ||
          score > existingPerformance.score ||
          (score == existingPerformance.score &&
              executionMs < existingPerformance.executionMs);
      final now = DateTime.now();
      final nextPerformance = improvesPerformance
          ? ModulePerformance(
              score: bestScore,
              linesUsed: linesUsed,
              executionMs: executionMs,
              accuracy: (score / module.xpReward).clamp(0.0, 1.0),
              attempts: (existingPerformance?.attempts ?? 0) + 1,
              firstCompletedAt: existingPerformance?.firstCompletedAt ?? now,
              lastCompletedAt: now,
            )
          : existingPerformance.copyWith(
              score: bestScore,
              attempts: existingPerformance.attempts + 1,
              lastCompletedAt: now,
            );
      if (!completed.contains(module.id)) completed.add(module.id);
      scores[module.id] = bestScore;
      final firestorePerformance = nextPerformance.toMap();
      if (existingPerformance == null) {
        firestorePerformance['firstCompletedAt'] = FieldValue.serverTimestamp();
      }
      firestorePerformance['lastCompletedAt'] = FieldValue.serverTimestamp();
      performanceMap[module.id] = firestorePerformance;

      final currentXp = _intValue(data['xp']);
      final xpDelta = currentScore == null
          ? score
          : (score - currentScore).clamp(0, score).toInt();
      final activity = _nextActivity(
        lastActivityDate: data['lastActivityDate'] as String?,
        streak: _intValue(data['streak'], fallback: 1),
        bestStreak: _intValue(
          data['bestStreak'],
          fallback: _intValue(data['streak'], fallback: 1),
        ),
        streakFreezes: _intValue(data['streakFreezes']),
      );
      final current = FirestoreUser.fromFirestore(userDoc).toUserSession();
      final projected = current.copyWith(
        xp: currentXp + xpDelta,
        completedModuleIds: completed,
        moduleScores: scores,
        modulePerformance: {
          for (final entry in performanceMap.entries)
            entry.key: ModulePerformance.fromMap(entry.value),
        },
        streak: activity.streak,
        bestStreak: activity.bestStreak,
        lastActivityDate: activity.lastActivityDate,
        streakFreezes: activity.streakFreezes,
      );
      final achievements = {
        ..._stringList(data['achievementIds']),
        ...Achievements.unlockedIds(projected),
      }.toList();
      transaction.update(userRef, {
        'xp': currentXp + xpDelta,
        'completedModuleIds': completed,
        'moduleScores': scores,
        'modulePerformance': performanceMap,
        'streak': activity.streak,
        'bestStreak': activity.bestStreak,
        'lastActivityDate': activity.lastActivityDate,
        'streakFreezes': activity.streakFreezes,
        'achievementIds': achievements,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final normalizedSource = source.trim();
      final bytes = utf8.encode(normalizedSource).length;
      if (isCodeTrack && bytes > 0) {
        final previous = codeDoc?.data() ?? const <String, dynamic>{};
        final previousBytes = _intValue(previous['bytes']);
        final previousTime = _intValue(previous['executionMs']);
        final previousAccuracy =
            (previous['accuracy'] as num?)?.toDouble() ?? 0;
        final shouldWrite =
            !codeDoc!.exists ||
            bytes < previousBytes ||
            (bytes == previousBytes && executionMs < previousTime) ||
            (bytes == previousBytes &&
                executionMs == previousTime &&
                projected.modulePerformance[module.id]!.accuracy >
                    previousAccuracy);
        if (shouldWrite) {
          transaction.set(codeGolfRef, {
            'uid': uid,
            'track': codeGolfTrackKey(module.track),
            'moduleId': module.id,
            'moduleTitle': module.title,
            'bytes': bytes,
            'source': normalizedSource,
            'executionMs': executionMs,
            'completionScore': score,
            'accuracy': (score / module.xpReward).clamp(0.0, 1.0),
            'playerName': user.displayName,
            'avatar': _avatarForUser(uid, user.displayName),
            'completedAt':
                previous['completedAt'] ?? FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }
    });

    return await fetchUserFromFirestore(uid) ??
        (throw StateError('Profile could not be refreshed after completion.'));
  }

  /// Stable ID used by both the private issue flow and the public certificate
  /// page. Issuing the same module twice returns the same certificate.
  String certificateIdFor(String uid, String moduleId) => '${uid}_$moduleId';

  /// Creates a public certificate only after Firestore confirms that the user
  /// completed [module]. This is deliberately checked server-side in the
  /// transaction and again in firestore.rules, so the UI cannot mint a dummy
  /// certificate by changing local state.
  Future<ModuleCertificate> ensureModuleCertificate({
    required String uid,
    required UserSession user,
    required CurriculumModule module,
  }) async {
    final certificateId = certificateIdFor(uid, module.id);
    final certificateRef = _certificatesCollection.doc(certificateId);
    final userRef = _usersCollection.doc(uid);
    final score = user.moduleScores[module.id] ?? module.xpReward;

    await _database.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      final certificateDoc = await transaction.get(certificateRef);

      if (certificateDoc.exists) return;
      if (!userDoc.exists) {
        throw const CertificateException('Your profile was not found.');
      }

      final completed =
          (userDoc.data()?['completedModuleIds'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const <String>[];
      if (!completed.contains(module.id)) {
        throw CertificateException(
          'Complete ${module.title} before issuing its certificate.',
        );
      }

      final certificate = ModuleCertificate(
        certificateId: certificateId,
        uid: uid,
        moduleId: module.id,
        moduleTitle: module.title,
        moduleDescription: module.description,
        trackLabel: module.track.label,
        learnerName: user.displayName,
        score: score,
        issuedAt: DateTime.now(),
      );
      transaction.set(certificateRef, certificate.toFirestore());
    });

    final certificateDoc = await certificateRef.get();
    if (!certificateDoc.exists) {
      throw const CertificateException(
        'Certificate was not saved. Please try again.',
      );
    }
    return ModuleCertificate.fromFirestore(certificateDoc);
  }

  /// Public read used by the certificate page linked from LinkedIn. Firestore
  /// rules allow reads of certificate records but not arbitrary user records.
  Future<ModuleCertificate?> fetchPublicCertificate(
    String certificateId,
  ) async {
    if (certificateId.trim().isEmpty || certificateId.contains('/')) {
      return null;
    }
    final doc = await _certificatesCollection.doc(certificateId).get();
    if (!doc.exists) return null;
    return ModuleCertificate.fromFirestore(doc);
  }

  /// Reads the user's existing credentials by their deterministic IDs. This
  /// keeps the certificates page fast and lets it show "View" immediately
  /// after a credential was already issued on another device.
  Future<Map<String, ModuleCertificate>> fetchCertificatesForUser({
    required String uid,
    required Iterable<String> moduleIds,
  }) async {
    final ids = moduleIds.toSet();
    if (ids.isEmpty) return const {};
    final docs = await Future.wait(
      ids.map(
        (moduleId) =>
            _certificatesCollection.doc(certificateIdFor(uid, moduleId)).get(),
      ),
    );
    return {
      for (final doc in docs)
        if (doc.exists) doc.id: ModuleCertificate.fromFirestore(doc),
    };
  }

  /// Atomically accepts an invite code, connects both accounts, and awards
  /// exactly 50 XP to each account. The redemption document and the guarded
  /// `referralRewardClaimed` field make retries idempotent.
  Future<UserSession> redeemReferralCode(String uid, String rawCode) async {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) {
      throw const ReferralException('Enter a referral code first.');
    }

    final codeDoc = await _referralCodesCollection.doc(code).get();
    if (!codeDoc.exists) {
      throw const ReferralException('That referral code was not found.');
    }

    final codeData = codeDoc.data() ?? const <String, dynamic>{};
    final referrerUid = codeData['ownerUid'] as String?;
    if (referrerUid == null || referrerUid.isEmpty) {
      throw const ReferralException('That referral code is no longer valid.');
    }
    if (referrerUid == uid) {
      throw const ReferralException('You cannot use your own referral code.');
    }

    final inviteeRef = _usersCollection.doc(uid);
    final referrerRef = _usersCollection.doc(referrerUid);
    final redemptionRef = _redemptionsCollection.doc(uid);

    await _database.runTransaction((transaction) async {
      final inviteeDoc = await transaction.get(inviteeRef);
      final referrerDoc = await transaction.get(referrerRef);
      final redemptionDoc = await transaction.get(redemptionRef);

      if (!inviteeDoc.exists) {
        throw const ReferralException(
          'Your account is not ready for referrals yet.',
        );
      }
      if (!referrerDoc.exists) {
        throw const ReferralException(
          'The inviting account could not be found.',
        );
      }
      if (redemptionDoc.exists ||
          inviteeDoc.data()?['referralRewardClaimed'] == true ||
          (inviteeDoc.data()?['referredBy'] as String?)?.isNotEmpty == true) {
        throw const ReferralException(
          'This account has already used a referral reward.',
        );
      }

      final inviteeData = inviteeDoc.data()!;
      final referrerData = referrerDoc.data()!;
      final inviteeFriends = _stringList(inviteeData['friendIds']);
      final referrerFriends = _stringList(referrerData['friendIds']);
      if (!inviteeFriends.contains(referrerUid)) {
        inviteeFriends.add(referrerUid);
      }
      if (!referrerFriends.contains(uid)) {
        referrerFriends.add(uid);
      }

      transaction.update(inviteeRef, {
        'xp': _intValue(inviteeData['xp']) + 50,
        'friendIds': inviteeFriends,
        'referredBy': referrerUid,
        'referralRewardClaimed': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(referrerRef, {
        'xp': _intValue(referrerData['xp']) + 50,
        'friendIds': referrerFriends,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(redemptionRef, {
        'inviteeUid': uid,
        'referrerUid': referrerUid,
        'code': code,
        'rewardXp': 50,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    final updated = await fetchUserFromFirestore(uid);
    if (updated == null) {
      throw const ReferralException(
        'Referral saved, but your profile could not be refreshed.',
      );
    }
    return updated;
  }

  /// Repairs a relationship created before a stale session save could erase
  /// referral fields from the invitee. The validated redemption record is the
  /// authority, so the repair is safe to repeat and never links arbitrary
  /// accounts.
  Future<void> reconcileReferralFriendLink(String uid) async {
    final inviteeRef = _usersCollection.doc(uid);
    final redemptionRef = _redemptionsCollection.doc(uid);

    await _database.runTransaction((transaction) async {
      final inviteeDoc = await transaction.get(inviteeRef);
      final redemptionDoc = await transaction.get(redemptionRef);
      if (!inviteeDoc.exists || !redemptionDoc.exists) return;

      final inviteeData = inviteeDoc.data() ?? const <String, dynamic>{};
      final redemption = redemptionDoc.data() ?? const <String, dynamic>{};
      final referrerUid = redemption['referrerUid'] as String?;
      if (referrerUid == null || referrerUid.isEmpty) return;

      final referrerRef = _usersCollection.doc(referrerUid);
      final referrerDoc = await transaction.get(referrerRef);
      if (!referrerDoc.exists) return;

      final plan = ReferralReconciliationPlan.fromDocuments(
        inviteeUid: uid,
        redemption: redemption,
        invitee: inviteeData,
        referrer: referrerDoc.data() ?? const <String, dynamic>{},
      );
      if (plan == null) return;

      if (plan.needsInviteeUpdate(inviteeData)) {
        final inviteeUpdate = <String, dynamic>{
          'friendIds': plan.inviteeFriendIds,
          'referredBy': plan.referrerUid,
          'referralRewardClaimed': true,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (plan.awardsInvitee) {
          inviteeUpdate['xp'] = plan.repairedInviteeXp;
        }
        transaction.update(inviteeRef, inviteeUpdate);
      }
      if (plan.needsReferrerUpdate) {
        transaction.update(referrerRef, {
          'friendIds': plan.referrerFriendIds,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  /// Update specific user fields (optimized for incremental updates)
  Future<void> updateUserFields(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _usersCollection.doc(uid).update(updates);
    } catch (e) {
      debugPrint('Error updating user in Firestore: $e');
      rethrow;
    }
  }

  /// Update XP after level completion
  Future<void> updateXp(String uid, int newXp) async {
    await updateUserFields(uid, {'xp': newXp});
  }

  /// Add completed module
  @Deprecated('Use recordModuleCompletion so metrics and streaks stay atomic.')
  Future<void> addCompletedModule(
    String uid,
    String moduleId,
    int score,
  ) async {
    try {
      await _database.runTransaction((transaction) async {
        final docRef = _usersCollection.doc(uid);
        final doc = await transaction.get(docRef);
        if (!doc.exists) throw StateError('Profile not found.');
        final data = doc.data() ?? const <String, dynamic>{};

        final completedModuleIds = _stringList(data['completedModuleIds']);
        final moduleScores = _intMap(data['moduleScores']);

        if (!completedModuleIds.contains(moduleId)) {
          completedModuleIds.add(moduleId);
        }

        final currentScore = moduleScores[moduleId];
        if (currentScore == null || score > currentScore) {
          moduleScores[moduleId] = score;
        }

        transaction.update(docRef, {
          'completedModuleIds': completedModuleIds,
          'moduleScores': moduleScores,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      debugPrint('Error adding completed module: $e');
      rethrow;
    }
  }

  /// Add badge to user
  Future<void> addBadge(String uid, String badgeId) async {
    try {
      await _database.runTransaction((transaction) async {
        final docRef = _usersCollection.doc(uid);
        final doc = await transaction.get(docRef);

        final badges = List<String>.from(
          (doc['badges'] as List? ?? []).cast<String>(),
        );

        if (!badges.contains(badgeId)) {
          badges.add(badgeId);
        }

        transaction.update(docRef, {
          'badges': badges,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      debugPrint('Error adding badge: $e');
      rethrow;
    }
  }

  /// Sync local user session with Firestore (merge strategy: Firestore wins on conflicts)
  Future<UserSession> syncUserSession(
    String uid,
    UserSession localSession,
  ) async {
    try {
      final remoteSession = await fetchUserFromFirestore(uid);
      if (remoteSession == null) {
        // No remote data, save local to Firestore
        await saveUserToFirestore(localSession, uid);
        return localSession;
      }

      final mergedScores = <String, int>{...remoteSession.moduleScores};
      for (final entry in localSession.moduleScores.entries) {
        final remoteScore = mergedScores[entry.key];
        if (remoteScore == null || entry.value > remoteScore) {
          mergedScores[entry.key] = entry.value;
        }
      }
      final mergedPerformance = <String, ModulePerformance>{
        ...remoteSession.modulePerformance,
      };
      for (final entry in localSession.modulePerformance.entries) {
        final remotePerformance = mergedPerformance[entry.key];
        if (remotePerformance == null ||
            _isBetterPerformance(entry.value, remotePerformance)) {
          mergedPerformance[entry.key] = entry.value;
        }
      }

      // Merge progress monotonically. A refresh must not erase a locally
      // finished module or replace a best score with an older device snapshot.
      final mergedSession = localSession.copyWith(
        xp: remoteSession.xp > localSession.xp
            ? remoteSession.xp
            : localSession.xp,
        completedModuleIds: {
          ...localSession.completedModuleIds,
          ...remoteSession.completedModuleIds,
        }.toList(),
        moduleScores: mergedScores,
        modulePerformance: mergedPerformance,
        streak: remoteSession.lastActivityDate == null
            ? localSession.streak
            : remoteSession.streak,
        bestStreak: remoteSession.bestStreak > localSession.bestStreak
            ? remoteSession.bestStreak
            : localSession.bestStreak,
        lastActivityDate:
            remoteSession.lastActivityDate ?? localSession.lastActivityDate,
        badges: {...localSession.badges, ...remoteSession.badges}.toList(),
        achievementIds: {
          ...localSession.achievementIds,
          ...remoteSession.achievementIds,
        }.toList(),
        streakFreezes: remoteSession.streakFreezes,
        cyberRoomProgress: {
          ...localSession.cyberRoomProgress,
          ...remoteSession.cyberRoomProgress,
        },
        referralCode: remoteSession.referralCode ?? localSession.referralCode,
        referredBy: remoteSession.referredBy ?? localSession.referredBy,
        referralRewardClaimed:
            remoteSession.referralRewardClaimed ||
            localSession.referralRewardClaimed,
        friendIds: {
          ...localSession.friendIds,
          ...remoteSession.friendIds,
        }.toList(),
      );

      // Save merged version back
      await saveUserToFirestore(mergedSession, uid);
      return mergedSession;
    } catch (e) {
      debugPrint('Error syncing user session: $e');
      return localSession;
    }
  }

  /// Delete user data from Firestore (for account deletion)
  Future<void> deleteUser(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }

  static int _dateSort(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }

  static bool _isBetterPerformance(
    ModulePerformance candidate,
    ModulePerformance current,
  ) =>
      candidate.score > current.score ||
      (candidate.score == current.score &&
          candidate.executionMs < current.executionMs);

  static Map<String, dynamic> _mapValue(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  static Map<String, int> _intMap(Object? value) {
    final map = _mapValue(value);
    return {for (final entry in map.entries) entry.key: _intValue(entry.value)};
  }

  static _ActivityState _nextActivity({
    required String? lastActivityDate,
    required int streak,
    required int bestStreak,
    required int streakFreezes,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final today = _dayKey(current);
    if (lastActivityDate == today) {
      return _ActivityState(
        streak: streak,
        bestStreak: bestStreak,
        lastActivityDate: today,
        streakFreezes: streakFreezes,
      );
    }

    final previous = lastActivityDate == null
        ? null
        : DateTime.tryParse(lastActivityDate);
    final currentDay = DateTime(current.year, current.month, current.day);
    final gap = previous == null
        ? null
        : currentDay
              .difference(DateTime(previous.year, previous.month, previous.day))
              .inDays;
    var nextStreak = 1;
    var nextFreezes = streakFreezes;
    if (gap == 1) {
      nextStreak = streak + 1;
    } else if (gap == 2 && streakFreezes > 0) {
      nextStreak = streak + 1;
      nextFreezes--;
    }
    return _ActivityState(
      streak: nextStreak,
      bestStreak: nextStreak > bestStreak ? nextStreak : bestStreak,
      lastActivityDate: today,
      streakFreezes: nextFreezes,
    );
  }

  static String _dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static int _intValue(Object? value, {int fallback = 0}) =>
      (value as num?)?.toInt() ?? fallback;

  static List<String> _stringList(Object? value) =>
      (value as List<dynamic>?)?.whereType<String>().toList() ?? <String>[];

  static List<List<String>> _chunked(List<String> values, int size) {
    if (values.isEmpty) return const <List<String>>[];
    final chunks = <List<String>>[];
    for (var i = 0; i < values.length; i += size) {
      final end = i + size > values.length ? values.length : i + size;
      chunks.add(values.sublist(i, end));
    }
    return chunks;
  }

  static String _displayNameFromData(Map<String, dynamic> data) {
    final rawName = data['name'] as String?;
    if (rawName != null && rawName.trim().isNotEmpty) {
      return rawName.trim();
    }
    final email = data['email'] as String?;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'coder';
  }

  static String _avatarForUser(String uid, String seed) {
    const avatars = [
      '\u{1F464}',
      '\u{1F6F0}',
      '\u{1F9E0}',
      '\u{1F680}',
      '\u{2699}',
      '\u{1F6E1}',
    ];
    final hash = uid.hashCode ^ seed.hashCode;
    return avatars[hash.abs() % avatars.length];
  }
}

class _ActivityState {
  final int streak;
  final int bestStreak;
  final String lastActivityDate;
  final int streakFreezes;

  const _ActivityState({
    required this.streak,
    required this.bestStreak,
    required this.lastActivityDate,
    required this.streakFreezes,
  });
}
