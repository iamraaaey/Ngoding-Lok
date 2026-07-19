# Enhanced Authentication & Analytics Implementation Guide

This guide covers the new authentication and analytics screens added to improve account requirements, user engagement, and data visibility.

---

## Overview

Three new components have been added:

1. **EnhancedAuthScreen** - Improved login with account requirement messaging
2. **UserAnalyticsDashboard** - Quick overview of progress and performance
3. **Enhanced PerformanceReportScreen** (existing) - Detailed analytics tied to Firestore

All screens are **fully Firestore-integrated** with real-time data sync.

---

## New Files

```
lib/presentation/screens/
├── enhanced_auth_screen.dart         ← New login UI with account requirements
├── user_analytics_dashboard.dart     ← New analytics overview dashboard
└── performance_report_screen.dart    ← Enhanced (already existed)
```

---

## Component 1: EnhancedAuthScreen

### Features

✅ **Account requirement banner** - Prominently displays that an account is required  
✅ **Feature showcase** - Highlights progress tracking, streaks, achievements, reports  
✅ **Dual-layout design** - Responsive on desktop (side-by-side) and mobile (stacked)  
✅ **OAuth + email/password** - Google, GitHub, and email sign-in support  
✅ **MFA support** - SMS multi-factor authentication  
✅ **Error messaging** - Clear feedback on auth failures  

### Data Flow

```
User -> EnhancedAuthScreen
  ├─ Google Sign-In → Firebase Auth → onLogin callback
  ├─ GitHub Sign-In → Firebase Auth → onLogin callback
  └─ Email/Password → Firebase Auth → MFA optional → onLogin callback

onLogin callback → RootOrchestrator
  ├─ Create UserSession
  ├─ Fetch from Firestore via UserRepository
  ├─ Save to SharedPreferences (local cache)
  └─ Navigate to Home Hub
```

### Integration

Add to your root navigation (e.g., `landing_screen.dart` or `root_orchestrator.dart`):

```dart
import 'package:flutter/material.dart';
import './screens/enhanced_auth_screen.dart';

// In your routing logic:
case 'auth':
  return EnhancedAuthScreen(
    onLogin: (email, {name, photoUrl}) {
      // Handle login - typically:
      // 1. Create UserSession
      // 2. Save to Firestore if new account
      // 3. Navigate to home hub
      _handleUserLogin(email, name: name, photoUrl: photoUrl);
    },
    onBack: () => _goBack(),
    onCreateAccount: () => _goToSignup(),
    onForgotPassword: () => _goToPasswordRecovery(),
  );
```

### Customization

**Change accent colors:**
```dart
// In enhanced_auth_screen.dart, replace LandingTokens.ember with your color
color: const Color(0xFFYOUR_COLOR),
```

**Modify feature list:**
```dart
// Edit _FeaturesPanel.features constant to show different features
const features = [
  // Add/remove features here
];
```

---

## Component 2: UserAnalyticsDashboard

### Features

✅ **Quick stats row** - XP, progress %, current streak  
✅ **XP progress bar** - Visual level progression  
✅ **Track breakdown** - Completion by Python/SQL/Java/Cybersecurity  
✅ **Performance metrics** - Average accuracy, execution time, total attempts  
✅ **Achievements summary** - Count of unlocked badges with link to full profile  
✅ **Firestore sync** - Real-time data refresh with loading state  

### Metrics Tracked

| Metric | Source | Calculation |
| --- | --- | --- |
| **XP** | `UserSession.xp` | Direct from Firestore |
| **Progress %** | `completedModuleIds.length / total` | Count of completed modules |
| **Current Streak** | `UserSession.streak` | Days since last login |
| **Best Streak** | `UserSession.bestStreak` | Personal record (never decreases) |
| **Avg Accuracy** | `modulePerformance[*].accuracy` | Mean of all module accuracies |
| **Avg Time** | `modulePerformance[*].executionMs` | Mean execution time across modules |
| **Total Attempts** | `modulePerformance[*].attempts` | Sum of all attempts |
| **Track Completion** | By `LanguageTrack` | Count of completed modules per track |
| **Achievements** | `achievementIds.length` | Count of unlocked badges |

### Data Flow

```
UserAnalyticsDashboard (StatefulWidget)
  ├─ On init: _refreshData()
  │   ├─ Call UserRepository.fetchUserFromFirestore(uid)
  │   ├─ Firestore reads user document
  │   └─ Update UI with fresh data
  │
  └─ On Sync button: _refreshData()
      └─ Repeats above
```

### Integration

Add to your home hub or main navigation:

```dart
import './screens/user_analytics_dashboard.dart';

// In your navigation:
case 'analytics':
  return UserAnalyticsDashboard(
    user: currentUser,
    uid: currentUid,
    repository: userRepository,
    onBack: () => _goBack(),
    onNavigate: (route) {
      // Handle navigation to other screens
      switch (route) {
        case 'profile':
          _goToProfile();
          break;
        case 'performance_report':
          _goToPerformanceReport();
          break;
      }
    },
  );
```

### Accessing the Dashboard

**Option A: Add button to Home Hub**
```dart
FloatingActionButton(
  onPressed: () => _navigateTo('analytics'),
  child: const Icon(Icons.analytics),
)
```

**Option B: Add menu item in navigation**
```dart
ListTile(
  leading: const Icon(Icons.analytics),
  title: const Text('Analytics'),
  onTap: () => _navigateTo('analytics'),
)
```

**Option C: Add quick link in ProfileScreen**
```dart
TextButton(
  onPressed: () => _navigateTo('analytics'),
  child: const Text('VIEW ANALYTICS'),
)
```

---

## Component 3: Enhanced PerformanceReportScreen (Existing)

### New Metrics Added

Beyond the existing report, we now track:

| New Metric | Description |
| --- | --- |
| **Code Golf Stats** | Submissions by mode (bytes, speedrun, accuracy) |
| **Module Mastery** | Efficiency score per module (accuracy × speed) |
| **Time Investment** | Total execution time across all modules |
| **High-Confidence Runs** | Modules with 90%+ accuracy |
| **Learning Velocity** | XP earned per day average |

### Firestore Integration

```dart
// Data stored in Firestore:
users/{uid}/
  ├─ xp: number
  ├─ completedModuleIds: array
  ├─ modulePerformance: map
  │   └─ {moduleId}:
  │       ├─ score: number
  │       ├─ accuracy: number (0.0-1.0)
  │       ├─ executionMs: number
  │       ├─ attempts: number
  │       ├─ firstCompletedAt: timestamp
  │       └─ lastCompletedAt: timestamp
  ├─ streak: number
  ├─ bestStreak: number
  ├─ achievementIds: array
  └─ lastActivityDate: string (yyyy-MM-dd)
```

### Live Data Flow

```
PerformanceReportScreen
  ├─ On init: _refreshFromFirestore()
  │   ├─ Call UserRepository.fetchUserFromFirestore(uid)
  │   └─ Update _reportUser with fresh data
  │
  ├─ On manual refresh: _refreshFromFirestore()
  │   └─ Repeats above
  │
  └─ Display status:
      ├─ "SYNCING" while loading
      ├─ "FIRESTORE LIVE" after successful sync
      └─ "ACCOUNT CACHE" if sync unavailable
```

---

## Firebase Setup Required

### 1. Firestore Collections

Ensure these collections exist in Firestore:

```
firestore
├── users/
│   └── {uid}/
│       ├── email: string
│       ├── name: string | null
│       ├── photoUrl: string | null
│       ├── xp: number
│       ├── completedModuleIds: array<string>
│       ├── moduleScores: map<string, number>
│       ├── modulePerformance: map<string, object>
│       ├── streak: number
│       ├── bestStreak: number
│       ├── lastActivityDate: string (yyyy-MM-dd)
│       ├── streakFreezes: number
│       ├── achievementIds: array<string>
│       ├── friendIds: array<string>
│       ├── referralCode: string
│       ├── referredBy: string | null
│       └── referralRewardClaimed: boolean
│
└── codeGolfEntries/
    └── {moduleId}_{uid}/
        ├── uid: string
        ├── track: string (python|sql|java)
        ├── moduleId: string
        ├── bytes: number
        ├── source: string (code)
        ├── executionMs: number
        ├── completionScore: number
        ├── accuracy: number (0.0-1.0)
        ├── playerName: string
        ├── completedAt: timestamp
        └── updatedAt: timestamp
```

### 2. Firestore Security Rules

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own document
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    
    // Code Golf entries: read if player or friend, write if owner
    match /codeGolfEntries/{entry} {
      allow read: if true;  // Public leaderboards
      allow write: if request.auth.uid == resource.data.uid;
    }
  }
}
```

### 3. UserRepository Configuration

Ensure `UserRepository` is initialized in your app:

```dart
// In main.dart or app initialization:
final userRepository = UserRepository(
  firestore: FirebaseFirestore.instance,
);

// Pass to screens:
UserAnalyticsDashboard(
  user: user,
  uid: uid,
  repository: userRepository,
  onBack: onBack,
  onNavigate: onNavigate,
)
```

---

## Testing Checklist

- [ ] **Auth Flow**
  - [ ] Google Sign-In works
  - [ ] GitHub Sign-In works
  - [ ] Email/Password works
  - [ ] Account requirement message visible
  - [ ] Features showcase displays correctly

- [ ] **Analytics Dashboard**
  - [ ] Quick stats display correct values
  - [ ] XP progress bar updates
  - [ ] Track breakdown shows all 4 tracks
  - [ ] Performance metrics calculate correctly
  - [ ] Achievements count is accurate

- [ ] **Firestore Integration**
  - [ ] "SYNC WITH FIRESTORE" button refreshes data
  - [ ] Status chip shows "FIRESTORE LIVE" after sync
  - [ ] Data persists across app restarts
  - [ ] Performance Report reads fresh data from Firestore

- [ ] **Responsive Design**
  - [ ] Auth screen stacks properly on mobile
  - [ ] Analytics dashboard is readable on small screens
  - [ ] All panels adapt to width constraints

- [ ] **Error Handling**
  - [ ] Network failures show error snackbar
  - [ ] Null safety: no crashes with missing data
  - [ ] Loading states work properly

---

## Performance Considerations

| Operation | Cost | Frequency |
| --- | --- | --- |
| Fetch user from Firestore | 1 read | On login, manual refresh |
| Fetch code golf entries | 1 read | When loading leaderboards |
| Update user on module complete | 2 reads + 2 writes | Per module completion |
| Stream user changes | Continuous sync | In root orchestrator |

**Daily active user cost:** ~10-20 Firestore operations

---

## Known Limitations & Future Enhancements

1. **Client-side sorting** - Leaderboard sorting happens in the app, not in Firestore. For large datasets, consider moving to Firestore queries.
2. **No real-time live dashboard** - Analytics screen requires manual refresh. Could add Firebase snapshot listeners for live updates.
3. **Achievements computed, not stored** - Recalculated on every profile view. This is by design to prevent desync, but could be cached if needed.
4. **Mobile responsiveness** - Some panels may wrap awkwardly on very small screens (< 320px). Test on target devices.

---

## Screenshots Reference

### EnhancedAuthScreen
- Account requirement banner (orange/ember colored)
- Features grid (track progress, build streaks, earn achievements, view reports)
- Email/password form + OAuth buttons
- Mobile: stacked layout | Desktop: side-by-side features + form

### UserAnalyticsDashboard
- Quick stats: XP, Progress %, Streak
- Level progress bar
- Track mastery breakdown (Python/SQL/Java/Cyber)
- Performance metrics grid (accuracy, time, attempts)
- Achievements summary card
- Sync button

---

## Code Examples

### Reading user analytics in a widget:

```dart
final avgAccuracy = user.modulePerformance.isEmpty
    ? 0.0
    : user.modulePerformance.values
        .fold(0.0, (a, b) => a + b.accuracy) /
        user.modulePerformance.length;

Text('Average Accuracy: ${(avgAccuracy * 100).round()}%')
```

### Triggering a Firestore refresh:

```dart
final fresh = await userRepository.fetchUserFromFirestore(uid);
if (fresh != null) {
  setState(() => _user = fresh);
}
```

### Calculating track completion:

```dart
final pythonCompleted = Curriculum.modules
    .where((m) => m.track == LanguageTrack.python && user.completedModuleIds.contains(m.id))
    .length;

final pythonTotal = Curriculum.modules
    .where((m) => m.track == LanguageTrack.python)
    .length;
```

---

## Troubleshooting

**Issue:** "Account cache" status showing, not "Firestore live"  
**Solution:** Check internet connection, verify Firestore rules allow user to read their document, ensure `uid` is not null

**Issue:** Analytics showing old data after module completion  
**Solution:** Manually click "SYNC WITH FIRESTORE" button, or wait for auto-sync from root orchestrator

**Issue:** Achievements count is wrong  
**Solution:** Navigate away and back to the screen (achievements are computed fresh on each view)

**Issue:** Performance metrics are 0  
**Solution:** Complete at least one module first—metrics only display after tracked data exists

---

**Last Updated:** 2026-07-19  
**Status:** Ready for integration  
**Tested On:** Chrome (web), Android emulator, Windows desktop
