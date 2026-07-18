# Achievement & Leaderboard Features Guide

## 🎯 Achievement System

### How It Works
- **Automatic Unlock:** Achievements unlock immediately when you complete a module
- **22+ Achievement Badges:** Track progress across all learning paths
- **Progress Bars:** See how close you are to multi-step achievements

### Achievement Categories

#### Module-Based
- **First Steps** - Complete any level
- **Sequential Steps** - Complete Module 1
- **Grid Master** - Complete a logic grid challenge
- **SQL Sleuth** - Complete a database query challenge
- **Rocket Scientist** - Complete an escape velocity challenge

#### Track-Based
- **Cyber Defender** - Complete a cybersecurity room
- **Java Starter** - Complete a Java track quest
- **The Polyglot Badge** - Complete all levels in a track

#### Progression
- **Module Runner** - Complete 3 curriculum modules (3/3)
- **Halfway There** - Complete half the curriculum (N/total)
- **Curriculum Complete** - Finish all modules

#### Streak-Based (Daily Login)
- **The Persistence Badge** - Hold 3-day coding streak
- **Week Warrior** - Hold 7-day coding streak
- **Streak Legend** - Hold 14-day coding streak

#### Performance
- **High Roller** - Earn 500+ XP
- **Efficiency Expert** - Score 90%+ on a module
- **Speedrunner** - Complete a quest in under 60 seconds

#### Code Golf (NEW!)
- **Code Golfer** - Submit a solution to the global board
- **Golf Enthusiast** - Complete 3 code golf modules
- **Golf Master** - Complete all code golf modules

---

## 📊 Code Golf Leaderboards

### Three Ranking Modes

#### 1️⃣ **Bytes Mode** (Default)
> "Fewest bytes wins" - Traditional code golf

- Primary: Shortest solution (byte count)
- Tiebreaker 1: Fastest execution time
- Tiebreaker 2: Best accuracy score

**Use Case:** Challenge yourself to write the most compact code

#### 2️⃣ **Speedrun Mode** (NEW)
> "Who finished first?" - Race to completion

- Primary: Earliest completion timestamp
- Tiebreaker 1: Fastest execution speed
- Tiebreaker 2: Best accuracy score

**Use Case:** Compete for first-completion bragging rights on new modules

#### 3️⃣ **Accuracy Mode** (NEW)
> "Highest accuracy" - Solution quality

- Primary: Highest score/accuracy (90%+)
- Tiebreaker 1: Shortest solution
- Tiebreaker 2: Fastest execution

**Use Case:** Find the most elegant, efficient solutions

### Scope Filters
- **Global** - See all submissions from all players worldwide
- **Friends** - See only submissions from your connected friends

### Track Filters
- **Python** - Python solutions
- **SQL** - Database queries
- **Java** - Java code solutions

### Example Leaderboard Entry
```
🥇 Rank 1 | 120 bytes | completed 2026-07-15 14:23 UTC
   👤 raynold's solution | 245ms execution | 95% accuracy
   ✨ Friend | [Show code if you've completed this module]

🥈 Rank 2 | 156 bytes | completed 2026-07-15 16:45 UTC
   👤 alex_codes | 312ms execution | 87% accuracy
```

---

## 🔥 Streak System

### Daily Login Streak
- **Tracks:** Consecutive days you log in
- **Best Streak:** Your personal record (never decreases)
- **Calendar:** 4-week heatmap showing active days

### How Streaks Work
1. **Day 1:** Log in → Streak = 1
2. **Day 2:** Log in same time next day → Streak = 2
3. **Miss a day:** Streak resets to 1 (unless you use a Freeze)
4. **Gap = 2 days exactly:** Freeze token saves your streak (+1)

### Streak Freeze Token
- **Cost:** 200 XP
- **Effect:** Protects ONE missed day (prevents reset)
- **Buy:** Profile screen > "Streak Freeze" button
- **Own:** Displays how many you have saved

### Achievement Rewards
- 3-day → **The Persistence Badge**
- 7-day → **Week Warrior Badge**
- 14-day → **Streak Legend Badge** (Gold!)

---

## 📱 Profile Screen

### Left Column
1. **Player Card**
   - Your name and email
   - Current league tier
   - GitHub link (coming soon)

2. **Friends & Referrals**
   - Connected friend count
   - Invite coders for +50 XP each

3. **Module Certificates**
   - Count of completed modules
   - Issue public LinkedIn-shareable credentials

4. **Coding Streak**
   - Current X-day streak
   - 4-week activity calendar
   - Streak Freeze purchase button

### Right Column
- **Achievement Grid** (22+ badges)
  - Unlocked badges: Full color, visible details
  - Locked badges: 50% opacity, lock icon
  - Progress bars for multi-step achievements
  - Total count: "12 / 22 unlocked"

---

## 🌟 Data Accuracy

### What's Tracked
- ✅ Module completion time (first completed, last improved)
- ✅ Code execution performance (lines of code, execution ms)
- ✅ Solution accuracy (score as % of max XP)
- ✅ Code Golf submissions (bytes, execution time, accuracy)
- ✅ Daily login activity (timezone-aware `yyyy-MM-dd`)
- ✅ Streak progression (consecutive days, best streak)

### Backend Guarantees
- **Atomic Transactions:** All user updates happen together (no partial states)
- **Best Score Tracking:** Prevents XP replay attacks
- **Timestamp Precision:** All times recorded to millisecond
- **Real-time Sync:** Firestore streams changes to all devices

### Leaderboard Sorting Rules
- **Bytes:** Bytes ↑ → Speed ↓ → Accuracy ↓
- **Speedrun:** Completed time ↑ → Speed ↓ → Accuracy ↓
- **Accuracy:** Accuracy ↓ → Bytes ↑ → Speed ↓

(↑ = ascending, ↓ = descending)

---

## 🛡️ Firestore Collections

### `users` Collection
```json
{
  "email": "player@example.com",
  "xp": 1250,
  "completedModuleIds": ["m1", "m2", "m3"],
  "streak": 5,
  "bestStreak": 14,
  "lastActivityDate": "2026-07-18",
  "moduleScores": {
    "m1": 100,
    "m2": 95,
    "m3": 87
  },
  "modulePerformance": {
    "m1": {
      "score": 100,
      "linesUsed": 15,
      "executionMs": 245,
      "accuracy": 1.0,
      "attempts": 3,
      "firstCompletedAt": "2026-07-10T14:23:00Z",
      "lastCompletedAt": "2026-07-12T09:15:00Z"
    }
  },
  "achievementIds": ["first_steps", "persistence", "module_runner"],
  "streakFreezes": 2
}
```

### `codeGolfEntries` Collection
```json
{
  "uid": "user123",
  "moduleId": "m5",
  "moduleTitle": "Python Loops",
  "track": "python",
  "bytes": 120,
  "source": "for i in range(10): print(i)",
  "executionMs": 245,
  "completionScore": 100,
  "accuracy": 0.95,
  "playerName": "alex_codes",
  "completedAt": "2026-07-15T14:23:45Z",
  "updatedAt": "2026-07-16T10:00:00Z"
}
```

---

## 🚀 Next Steps After Implementation

### For Players
1. Complete your first module → Unlock "First Steps" achievement
2. Keep logging in → Build a 3-day streak → Get "Persistence" badge
3. Submit a code golf solution → Appear on global leaderboard
4. Compete for speedrun records → See your name on "Speedrun" board

### For Developers
1. Monitor Firestore for performance (database read/write costs)
2. Set up achievement notifications (toast on unlock)
3. Add achievements export/share to social media
4. Create "Hall of Fame" for record holders

---

## 📚 Terminal Noir Design

### Colors Used
- **Primary Accent:** Orange #FF5C01 (ember)
- **Success:** Green #00D98E (signal)
- **Secondary:** Blue #00D0FF (circuit)
- **Gold:** #FFD700 & #FFFF00 (premium achievements)
- **Background:** Dark #0A0500 (noir)

### Typography
- **Labels:** Monospace, all-caps (achievement titles)
- **Values:** Bold sans-serif (scores, counts)
- **Body:** Regular sans-serif (descriptions)

### Components
- Hairline borders (1px)
- Small radius (4px)
- Smooth animations (150-200ms)
- Fire icon (🔥) for active streaks

---

## 🐛 Troubleshooting

### Achievement Not Unlocking
- ✅ Module complete but achievement not showing?
  - **Solution:** Close and reopen Profile screen
  - **Why:** Achievements computed fresh on each view

### Leaderboard Not Updating
- ✅ Submitted code golf entry not on board?
  - **Solution:** Check if in Friends-only mode (switch to Global)
  - **Why:** Friend filter is case-sensitive on user IDs

### Streak Showing Wrong Count
- ✅ Logged in today but streak didn't increase?
  - **Solution:** Check if last login was yesterday (or freeze was used)
  - **Why:** Gap must be exactly 1 day (timezone matters)

### Firestore Sync Not Working
- ✅ Local changes not saving to Firestore?
  - **Solution:** Check Firebase auth (must be signed in)
  - **Why:** Anonymous sessions can't write to Firestore

---

**Questions?** Check the implementation details in `SYSTEM_IMPLEMENTATION_SUMMARY.md`
