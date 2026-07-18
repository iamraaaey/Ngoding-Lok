# QUICK FIX - Firestore Permission Denied Error

## The Problem
```
[cloud_firestore/permission-denied] Missing or insufficient permissions.
```

## The Cause
Firestore security rules are not deployed to your Firebase project.

## The Fix (Choose One)

### ⚡ FASTEST - Firebase CLI (2 minutes)

```bash
# Open terminal in your project directory
cd c:\Users\RAYNOLD\OneDrive\Desktop\2026\codequest-core

# Install Firebase CLI (first time only)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Deploy rules
firebase deploy --only firestore:rules
```

Done! ✅

### 🌐 Alternative - Firebase Console (5 minutes)

1. Go to: https://console.firebase.google.com
2. Select your project
3. Click: **Firestore Database**
4. Click: **Rules** tab
5. Copy contents from: `firestore.rules` file
6. Paste into console
7. Click: **Publish**

Done! ✅

### 🚨 Emergency - Test Mode (1 minute)

If you need to test NOW:

1. Firebase Console → Firestore → Rules
2. Click: **Start in test mode**
3. Click: **Publish**

⚠️ **WARNING:** Only for testing! Replace with real rules later.

---

## Verify It Worked

After deploying:

1. Reload your app
2. Sign in
3. Try completing a module
4. Check console - should NOT see permission errors
5. Open Firebase Console → Collections → Check `users` collection exists with your data

---

## Why This Happened

You have `firestore.rules` file ✅  
But it's NOT deployed to Firebase ❌

Local files don't affect Firebase - you must deploy.

---

## Next Steps

Once fixed, everything works:
- ✅ Certificates issue without errors
- ✅ Modules tracked
- ✅ XP awarded
- ✅ Achievements unlock
- ✅ Streaks calculated
- ✅ League map shows scores

---

**Do this now → App will work!** 🚀
