import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/session/user_session.dart';
import '../models/firestore_user.dart';

/// Repository for Firestore user data operations. Handles syncing,
/// fetching, and updating user data in Firestore.
class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Collection reference for users
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Save user session to Firestore (upsert)
  Future<void> saveUserToFirestore(UserSession user, String uid) async {
    try {
      final firestoreUser = FirestoreUser.fromUserSession(user, uid);
      await _usersCollection.doc(uid).set(
        firestoreUser.toFirestore(),
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error saving user to Firestore: $e');
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
      print('Error fetching user from Firestore: $e');
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

  /// Update specific user fields (optimized for incremental updates)
  Future<void> updateUserFields(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _usersCollection.doc(uid).update(updates);
    } catch (e) {
      print('Error updating user in Firestore: $e');
      rethrow;
    }
  }

  /// Update XP after level completion
  Future<void> updateXp(String uid, int newXp) async {
    await updateUserFields(uid, {'xp': newXp});
  }

  /// Add completed module
  Future<void> addCompletedModule(String uid, String moduleId, int score) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _usersCollection.doc(uid);
        final doc = await transaction.get(docRef);

        final completedModuleIds =
            List<String>.from(doc['completedModuleIds'] as List? ?? []);
        final moduleScores =
            Map<String, int>.from(doc['moduleScores'] as Map? ?? {});

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
      print('Error adding completed module: $e');
      rethrow;
    }
  }

  /// Add badge to user
  Future<void> addBadge(String uid, String badgeId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _usersCollection.doc(uid);
        final doc = await transaction.get(docRef);

        final badges =
            List<String>.from((doc['badges'] as List? ?? []).cast<String>());

        if (!badges.contains(badgeId)) {
          badges.add(badgeId);
        }

        transaction.update(docRef, {
          'badges': badges,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print('Error adding badge: $e');
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

      // Merge strategy: use remote XP and progress, keep local streak if higher
      final mergedSession = localSession.copyWith(
        xp: remoteSession.xp > localSession.xp
            ? remoteSession.xp
            : localSession.xp,
        completedModuleIds: {
          ...localSession.completedModuleIds,
          ...remoteSession.completedModuleIds,
        }.toList(),
        moduleScores: {
          ...localSession.moduleScores,
          ...remoteSession.moduleScores,
        },
        badges: {
          ...localSession.badges,
          ...remoteSession.badges,
        }.toList(),
        streakFreezes: remoteSession.streakFreezes,
        cyberRoomProgress: remoteSession.cyberRoomProgress,
      );

      // Save merged version back
      await saveUserToFirestore(mergedSession, uid);
      return mergedSession;
    } catch (e) {
      print('Error syncing user session: $e');
      return localSession;
    }
  }

  /// Delete user data from Firestore (for account deletion)
  Future<void> deleteUser(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }
}
