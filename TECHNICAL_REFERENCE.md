# Technical Reference - Achievement & Leaderboard System

## Architecture Overview

```
┌─────────────────────────────────────────────┐
│         Firestore Backend                    │
│  (users, codeGolfEntries, referralCodes)    │
└────────────────┬────────────────────────────┘
                 │
         ┌───────▼────────┐
         │ UserRepository │ (Transaction layer)
         └───────┬────────┘
                 │
    ┌────────────┼────────────┐
    │            │            │
    ▼            ▼            ▼
recordModule   recordActivity  streamUser
Completion     recordActivity  FromFirestore
    │            │            │
    └────────────┼────────────┘
                 │
         ┌───────▼──────────┐
         │  UserSession     │ (Domain model)
         │  + Achievements  │
         └───────┬──────────┘
                 │
    ┌────────────┼────────────┐
    │            │            │
    ▼            ▼            ▼
ProfileScreen  CodeGolfScreen  HomeScreen
(UI Layer)
```

---

## Key Classes

### 1. UserSession
**File:** `lib/core/session/user_session.dart`

```dart
class UserSession {
  // Identity
  final String email;
  final String? name;
  final String? photoUrl;

  // Progress
  final int xp;
  final List<String> completedModuleIds;
  final Map<String, int> moduleScores;
  final Map<String, ModulePerformance> modulePerformance;

  // Streaks
  final int streak;                    // Current streak (1-N days)
  final int bestStreak;                // Personal record
  final String? lastActivityDate;      // "yyyy-MM-dd" format
  final int streakFreezes;             // Tokens owned

  // Achievements
  final List<String> achievementIds;   // Unlocked achievement IDs

  // Social
  final List<String> friendIds;
  final String? referralCode;
  final String? referredBy;

  // Instance method: Apply login activity
  UserSession withActivity({DateTime? now}) {
    // Recalculates streak based on gap from lastActivityDate
    // Updates bestStreak if current streak is higher
  }

  // Instance method: Record module completion
  UserSession withModuleCompleted(String moduleId, int score) {
    // Adds module to completedModuleIds
    // Updates best score for that module
    // Returns new instance (immutable)
  }
}
```

### 2. Achievement
**File:** `lib/core/social/achievement.dart`

```dart
class Achievement {
  final String id;                  // Unique identifier
  final String title;               // Display name
  final String description;         // Player-facing text
  final bool unlocked;              // Is this achievement earned?
  final int progress;               // Current progress (0-target)
  final int target;                 // Goal progress

  double get progressRatio => progress / target;  // 0.0-1.0
}

class Achievements {
  // Computes all achievements for a user (no storage needed)
  static List<Achievement> forUser(UserSession user) {
    // Returns 22-25 Achievement instances
    // Each derived from user.xp, completedModuleIds, streak, etc.
  }

  // Extract unlocked IDs for Firestore storage
  static List<String> unlockedIds(UserSession user) {
    return [for (final a in forUser(user)) if (a.unlocked) a.id];
  }
}
```

**Key Design:** Achievements are **computed, not stored** in the object.
- No desync: Always matches actual progress
- Stateless: Can re-calculate anytime
- Efficient: Only computed on profile view

### 3. ModulePerformance
**File:** `lib/core/session/module_performance.dart`

```dart
class ModulePerformance {
  final int score;                  // Best score on this module
  final int linesUsed;              // Code length
  final int executionMs;            // Execution time
  final double accuracy;            // score / maxScore (0.0-1.0)
  final int attempts;               // Total attempts
  final DateTime firstCompletedAt;  // When first cleared
  final DateTime lastCompletedAt;   // When last improved

  // Stored in Firestore under user.modulePerformance[moduleId]
}
```

### 4. CodeGolfEntry
**File:** `lib/core/social/code_golf.dart`

```dart
class CodeGolfEntry {
  final String uid;
  final String player;              // Display name
  final String avatar;              // Emoji avatar
  final int bytes;                  // Solution length
  final LanguageTrack track;        // python/sql/java
  final String moduleId;            // Which module
  final String moduleTitle;
  final String source;              // Actual code (gated by UI)
  final bool isFriend;              // Player is in friend list?
  final int executionMs;            // Runtime
  final double accuracy;            // Score ratio
  final int completionScore;        // XP earned
  final DateTime? completedAt;      // When submitted (KEY FOR SPEEDRUN)

  // Built from Firestore document
  factory CodeGolfEntry.fromMap(
    String documentId,
    Map<String, dynamic> data, {
    required Set<String> friendIds,
  }) { ... }
}
```

### 5. UserRepository
**File:** `lib/data/repositories/user_repository.dart`

#### recordModuleCompletion()
```dart
Future<UserSession> recordModuleCompletion({
  required String uid,                    // Firestore user ID
  required UserSession user,              // Current session
  required CurriculumModule module,       // What was completed
  required int score,                     // Score achieved
  required int linesUsed,                 // Solution metrics
  required int executionMs,
  required String source,                 // Source code
}) async {
  // Atomic transaction:
  // 1. Read current user doc
  // 2. Check if this is first completion or improvement
  // 3. Update: xp, completedModuleIds, moduleScores, modulePerformance
  // 4. Recalculate: achievements (auto-unlock), streak
  // 5. Write Code Golf entry (if code track)
  // 6. Return updated UserSession
}
```

**Atomic Safety:** Uses `_database.runTransaction()` to prevent race conditions
- Multiple tabs/devices can't double-award XP
- Code Golf leaderboard stays sorted correctly
- Achievement counts always match actual progress

#### recordActivity()
```dart
Future<UserSession> recordActivity(String uid) async {
  // Called on login
  // 1. Read lastActivityDate from Firestore
  // 2. Calculate streak delta:
  //    - Same day: no change
  //    - +1 day: increment streak
  //    - +2 days with freeze: use freeze, keep streak
  //    - Gap > 2 or no freeze: reset to 1
  // 3. Recalculate achievements
  // 4. Return updated UserSession with fresh streak
}
```

#### streamUserFromFirestore()
```dart
Stream<UserSession?> streamUserFromFirestore(String uid) {
  // Real-time listener on user document
  // Emits UserSession whenever Firestore doc changes
  // Used in Root Orchestrator to auto-sync across devices
}
```

---

## Firestore Schema

### Collection: `users`
```
users/
  {uid}/
    email: string
    name: string | null
    photoUrl: string | null
    xp: number
    completedModuleIds: array<string>
    moduleScores: map<string, number>
    modulePerformance: map<string, object>
      {moduleId}:
        score: number
        linesUsed: number
        executionMs: number
        accuracy: number (0.0-1.0)
        attempts: number
        firstCompletedAt: timestamp
        lastCompletedAt: timestamp
    streak: number
    bestStreak: number
    lastActivityDate: string (yyyy-MM-dd)
    streakFreezes: number
    achievementIds: array<string>
    badges: array<string>
    friendIds: array<string>
    referralCode: string
    referredBy: string | null
    referralRewardClaimed: boolean
    updatedAt: timestamp
```

### Collection: `codeGolfEntries`
```
codeGolfEntries/
  {moduleId}_{uid}/
    uid: string
    track: string (python|sql|java)
    moduleId: string
    moduleTitle: string
    bytes: number
    source: string (code)
    executionMs: number
    completionScore: number (XP)
    accuracy: number (0.0-1.0)
    playerName: string
    avatar: string (emoji)
    completedAt: timestamp  ◄─── SPEEDRUN SORT KEY
    updatedAt: timestamp
```

---

## UI Components

### Profile Screen Components

#### _ProfileCard
- Displays name, email, tier
- Uses `user.xp` → `Progression.tier`
- Shows linked GitHub status

#### _StreakCard
- Renders `user.streak` and `user.bestStreak`
- **_StreakCalendar** sub-widget:
  - Generates 4-week grid (Sun-Sat columns)
  - Highlights last `streak` days
  - Outlines today's cell
- Streak Freeze purchase button
- Shows `user.streakFreezes` owned

#### _BadgesCard
- Calls `Achievements.forUser(user)` to get all 22+ achievements
- Maps achievement ID → icon and color:
  ```dart
  _iconFor(id) => match(id) {
    'first_steps' => Icons.flag,
    'golf_enthusiast' => Icons.golf_course,  // NEW
    'golf_master' => Icons.sports_golf,      // NEW
    ...
  }
  
  _colorFor(id) => match(id) {
    'golf_enthusiast' => Color(0xFF00D98E),  // Green
    'golf_master' => Color(0xFFFFD700),      // Gold
    ...
  }
  ```
- **_BadgeTile** for each achievement:
  - Icon + color for unlocked
  - Lock icon + faded for locked
  - Progress bar if multi-step (e.g., "3 / 7")
  - Title and description

### Code Golf Screen Components

#### Board Mode Toggle
```dart
_SegTabs(
  options: const ['Bytes', 'Speedrun', 'Accuracy'],
  selected: _boardMode,  // 0, 1, or 2
  onSelected: (i) => setState(() => _boardMode = i),
)
```

#### Sorting Logic
```dart
List<CodeGolfEntry> _sortEntries(List<CodeGolfEntry> entries) {
  return entries..sort((a, b) {
    if (_boardMode == 0) {  // Bytes
      if (a.bytes != b.bytes) return a.bytes.compareTo(b.bytes);
      if (a.executionMs != b.executionMs) 
        return a.executionMs.compareTo(b.executionMs);
      return b.accuracy.compareTo(a.accuracy);
    }
    else if (_boardMode == 1) {  // Speedrun ◄─── NEW
      final aTime = a.completedAt ?? DateTime(2099);
      final bTime = b.completedAt ?? DateTime(2099);
      if (aTime != bTime) return aTime.compareTo(bTime);
      if (a.executionMs != b.executionMs)
        return a.executionMs.compareTo(b.executionMs);
      return b.accuracy.compareTo(a.accuracy);
    }
    else {  // Accuracy
      if (a.accuracy != b.accuracy) 
        return b.accuracy.compareTo(a.accuracy);
      if (a.bytes != b.bytes) return a.bytes.compareTo(b.bytes);
      return a.executionMs.compareTo(b.executionMs);
    }
  });
}
```

#### _GolfRow
- Rank number, player name, avatar
- Primary stat (bytes / time / accuracy) based on mode
- Secondary metrics (speed, accuracy)
- Expandable to show source code (gated by module unlock)

---

## Data Flow Example: Module Completion

### User Completes Python Module 3

```
1. Game Screen calls onWin()
   ├─ score = 95 (XP earned)
   ├─ linesUsed = 42
   ├─ executionMs = 245
   └─ sourceCode = "def solve()..."

2. RootOrchestrator._handleModuleWin()
   ├─ Call ApiService.syncLevelComplete() [backend simulation]
   └─ result = { finalScore: 95, xpBonus: 0 }

3. Call _userRepository.recordModuleCompletion()
   ├─ Start Firestore transaction
   ├─ Read current user doc from Firestore
   ├─ Check: Is this first completion? (m3 not in completedModuleIds)
   ├─ ✓ First time → Award full 95 XP
   ├─ Update user doc:
   │  ├─ xp: 1150 → 1245
   │  ├─ completedModuleIds: [..., "m3"]
   │  ├─ moduleScores["m3"]: 95
   │  ├─ modulePerformance["m3"]:
   │  │  ├─ score: 95
   │  │  ├─ accuracy: 0.95
   │  │  ├─ linesUsed: 42
   │  │  ├─ executionMs: 245
   │  │  ├─ attempts: 1
   │  │  └─ firstCompletedAt: now
   │  ├─ streak/bestStreak: (recalculated in transaction)
   │  └─ achievementIds: [..., "golf_enthusiast"] ◄── NEW (3+ golf modules)
   ├─ Write codeGolfEntries["m3_uid"]:
   │  ├─ bytes: 156 (utf8 of source)
   │  ├─ source: "def solve()..."
   │  ├─ completedAt: 2026-07-18T14:23:45Z ◄── SPEEDRUN RANKING KEY
   │  └─ ...other fields
   └─ Transaction commits (atomic)

4. RootOrchestrator receives updated UserSession
   ├─ Updates local state: _user = updated
   ├─ Saves to local persistence
   └─ UI rebuilds with new achievement unlocked

5. Profile Screen updates
   ├─ Calls Achievements.forUser(updatedUser)
   ├─ New achievement "Golf Enthusiast" now has unlocked: true
   └─ Badge tile appears in full color at grid position

6. Code Golf Screen updates
   ├─ streamCodeGolfEntries() emits new list
   ├─ Player's entry appears in both:
   │  ├─ Bytes board (ranked by 156 bytes)
   │  └─ Speedrun board (ranked by 2026-07-18T14:23:45Z)
   └─ Friends see entry if they're in friendIds
```

---

## Testing Utilities

### Manual Firestore Query
Firebase Console → Firestore → Query:
```
Collection: users
Where: email == "your@email.com"
→ Document shows real-time updates
```

### Local Testing
```bash
# Run user session tests
flutter test test/user_session_test.dart

# Run specific achievement test
flutter test test/user_session_test.dart -k "achievement"

# Debug: Print achievements
debugPrint(Achievements.forUser(mySession).toJsonString());
```

### Debugging Leaderboard Sort
Add debug output to `_sortEntries()`:
```dart
if (_boardMode == 1) {  // Speedrun
  entries.sort((a, b) {
    debugPrint('Comparing ${a.player} (${a.completedAt})'
      ' vs ${b.player} (${b.completedAt})');
    final aTime = a.completedAt ?? DateTime(2099);
    final bTime = b.completedAt ?? DateTime(2099);
    return aTime.compareTo(bTime);
  });
}
```

---

## Performance Optimization

### Achievement Computation Cost
- **O(n)** where n = number of curriculum modules (~50)
- **Called:** Once per Profile screen open
- **Cost:** <10ms on most devices
- **Cacheable:** Yes, but invalidates on any module completion

### Firestore Query Costs
- **recordModuleCompletion():** 2 reads + 2 writes = 4 document ops
- **streamCodeGolfEntries():** 1 read per listener + continuous sync
- **recordActivity():** 1 read + 1 write = 2 document ops
- **Estimated daily cost per active user:** 10-20 document operations

### Leaderboard Sorting Cost
- **Client-side sort:** O(n log n) where n = entries in track (~10-100)
- **Happens:** Every time stream updates or user switches mode
- **Improvement:** Could move to Firestore-native sorting (not needed for scale)

---

## Gotchas & Edge Cases

### 1. Timezone Issues
**Problem:** `lastActivityDate` is "2026-07-18" but user's timezone differs
**Solution:** Date is always local midnight (`DateTime.now()` in user's timezone)
**Risk:** User in NY logs in, travels to Tokyo, logs in same UTC day → not consecutive
**Mitigation:** Accept this as correct behavior (respects player's local calendar)

### 2. Replay Attack Protection
**Problem:** User completes module, refreshes page, XP awarded twice
**Solution:** `moduleScores[moduleId]` prevents full XP award on replay
```dart
final xpDelta = currentScore == null
    ? score                     // First completion: full award
    : (score - currentScore).clamp(0, score).toInt();  // Replay: 0 delta
```

### 3. Achievement Unlock Race
**Problem:** User completes module → achievement should unlock immediately
**Solution:** `recordModuleCompletion()` calculates and saves new achievements in same transaction
**Guarantee:** Profile screen always sees latest achievements (no lag)

### 4. Code Golf Duplicate Entries
**Problem:** User submits twice, two entries appear
**Solution:** Document ID is `{moduleId}_{uid}` → upsert not insert
```dart
final docId = '${module.id}_$uid';  // Same ID = same entry
transaction.set(docRef, {...}, SetOptions(merge: true));  // Upsert
```

### 5. Leaderboard Ties
**Problem:** Two users have same byte count and execution time
**Solution:** Final tiebreaker is accuracy (descending)
**Fair:** Highest quality solution ranks higher even if same size/speed

---

## Monitoring & Analytics

### Firestore Metrics
Monitor in Firebase Console → Firestore:
- **Read Ops:** Should increase with profile views and leaderboard loads
- **Write Ops:** Should increase only on module completion
- **Storage:** `users` + `codeGolfEntries` collections size
- **Latency:** Typical reads <100ms, writes <500ms

### User Segment Analytics
Track in your analytics:
- **Streak Retention:** % of players with streak > 1 day
- **Achievement Distribution:** % unlocked per achievement
- **Code Golf Participation:** % of users submitting solutions
- **Leaderboard Mode:** Which ranking mode is most popular?

---

## Deployment Checklist

- [ ] Firestore collections created (`users`, `codeGolfEntries`)
- [ ] Firestore rules deployed (allow authenticated read/write)
- [ ] Firebase auth enabled (Google OAuth + Email)
- [ ] Environment variables set (Firebase config)
- [ ] Test database synced with production
- [ ] Backups configured for user data
- [ ] Monitoring alerts set for high read/write costs
- [ ] Beta testers have access to test all three leaderboard modes

---

**Last Updated:** 2026-07-18
**Maintained By:** Claude Code
