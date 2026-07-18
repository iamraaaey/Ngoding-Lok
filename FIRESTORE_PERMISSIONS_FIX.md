# Firestore Permission Denied - FIX GUIDE

## Problem
```
[cloud_firestore/permission-denied] Missing or insufficient permissions.
```

All Firestore operations failing with permission denied errors.

## Root Cause
**The Firestore security rules in `firestore.rules` have NOT been deployed to your Firebase project.**

The rules file exists locally but Firebase is running with default rules (deny all).

---

## Solution - Deploy Rules to Firebase

### Option 1: Using Firebase CLI (Recommended)

1. **Install Firebase CLI** (if not already installed):
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Initialize Firebase in project** (if not done):
   ```bash
   cd c:\Users\RAYNOLD\OneDrive\Desktop\2026\codequest-core
   firebase init
   ```
   - Select "Firestore" feature
   - Use existing Firebase project
   - Keep default file locations

4. **Deploy the rules**:
   ```bash
   firebase deploy --only firestore:rules
   ```

   Expected output:
   ```
   ✔  Deploy complete!
   
   Project Console: https://console.firebase.google.com/project/YOUR_PROJECT_ID
   ```

### Option 2: Using Firebase Console (Web UI)

1. **Go to Firebase Console**:
   - https://console.firebase.google.com
   - Select your project

2. **Navigate to Firestore**:
   - Click "Firestore Database" in left menu
   - Click "Rules" tab

3. **Copy & Paste Rules**:
   - Open `firestore.rules` file from your project
   - Copy entire contents
   - Paste into Firebase Console Rules editor
   - Click "Publish"

4. **Verify Deployment**:
   - Should show "Last modified: [timestamp]"
   - No syntax errors in console

---

## Rules Content (Verify Correct)

The `firestore.rules` file should contain:

```firestore
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    function signedIn() {
      return request.auth != null;
    }

    // Users can read/create/update their own profile
    match /users/{userId} {
      allow read: if signedIn();
      allow create: if signedIn() && request.auth.uid == userId;
      allow update: if signedIn() && (
        request.auth.uid == userId ||
        // Referral transaction: referrer can receive XP/friends
        (
          getAfter(/databases/$(database)/documents/referralRedemptions/$(request.auth.uid))
              .data.inviteeUid == request.auth.uid &&
          getAfter(/databases/$(database)/documents/referralRedemptions/$(request.auth.uid))
              .data.referrerUid == userId &&
          getAfter(/databases/$(database)/documents/referralRedemptions/$(request.auth.uid))
              .data.rewardXp == 50 &&
          request.resource.data.xp == resource.data.xp + 50 &&
          request.resource.data.friendIds.hasAny([request.auth.uid])
        )
      );
    }

    // Referral codes are public-readable
    match /referralCodes/{code} {
      allow read: if signedIn();
      allow create, update: if signedIn() &&
          request.resource.data.ownerUid == request.auth.uid &&
          get(/databases/$(database)/documents/users/$(request.auth.uid))
              .data.referralCode == code;
    }

    // Referral redemptions
    match /referralRedemptions/{inviteeUid} {
      allow read: if signedIn() && request.auth.uid == inviteeUid;
      allow create: if signedIn() &&
          request.auth.uid == inviteeUid &&
          request.resource.data.inviteeUid == request.auth.uid &&
          request.resource.data.rewardXp == 50 &&
          request.resource.data.referrerUid != request.auth.uid &&
          get(/databases/$(database)/documents/referralCodes/$(request.resource.data.code))
              .data.ownerUid == request.resource.data.referrerUid;
    }

    // Code Golf entries
    match /codeGolfEntries/{entryId} {
      allow read: if signedIn();
      allow create: if signedIn() &&
          request.resource.data.uid == request.auth.uid &&
          ['python', 'sql', 'java', 'cybersecurity', 'arduino']
              .hasAny([request.resource.data.track]) &&
          request.resource.data.bytes is int &&
          request.resource.data.executionMs is int &&
          request.resource.data.accuracy is number &&
          getAfter(/databases/$(database)/documents/users/$(request.auth.uid))
              .data.completedModuleIds.hasAny([request.resource.data.moduleId]);
      allow update: if signedIn() &&
          resource.data.uid == request.auth.uid &&
          request.resource.data.uid == request.auth.uid &&
          request.resource.data.moduleId == resource.data.moduleId &&
          request.resource.data.track == resource.data.track &&
          request.resource.data.bytes is int &&
          request.resource.data.bytes <= resource.data.bytes &&
          request.resource.data.executionMs is int &&
          request.resource.data.accuracy is number;
    }

    // Certificates are public-readable (LinkedIn requirement)
    match /certificates/{certificateId} {
      allow read: if true;  // PUBLIC - anyone can read
      allow create: if signedIn() &&
          request.resource.data.uid == request.auth.uid &&
          get(/databases/$(database)/documents/users/$(request.auth.uid))
              .data.completedModuleIds.hasAny([request.resource.data.moduleId]);
      allow update: if signedIn() &&
          resource.data.uid == request.auth.uid &&
          request.resource.data.uid == resource.data.uid &&
          request.resource.data.moduleId == resource.data.moduleId;
    }
  }
}
```

---

## Verification Steps

### 1. Check Rules Are Deployed

**In Firebase Console:**
1. Go to Firestore Database
2. Click "Rules" tab
3. You should see your rules code (not empty)
4. Status should show green checkmark
5. "Last modified" timestamp should be recent

**Command Line:**
```bash
firebase rules:list
```

### 2. Test Permissions

After deploying rules, test in your app:

1. **Sign in** with email or Google
2. **Complete a module** - should no longer get permission error
3. **Check browser console** - should see:
   ```
   // No more "permission-denied" errors
   // Instead: "Module completion sync succeeded"
   // Or: "Certificate issued successfully"
   ```

### 3. Verify Firestore Operations

In Firebase Console:
1. Go to Firestore → Collections
2. Look for `users` collection
3. Should see a document with your uid
4. Click it to view data: xp, completedModuleIds, moduleScores, etc.

---

## Common Issues & Fixes

### Issue 1: "Rules file not found"
**Error:** `Error: Could not read rules file`
**Fix:** Make sure you're in correct directory:
```bash
cd c:\Users\RAYNOLD\OneDrive\Desktop\2026\codequest-core
firebase deploy --only firestore:rules
```

### Issue 2: "Missing firebase.json"
**Error:** `Could not locate a active project`
**Fix:** Run initialization:
```bash
firebase init
```
- Select "Firestore"
- Select your existing project
- Accept defaults

### Issue 3: "Invalid JSON in rules"
**Error:** `Rules compilation failed`
**Fix:** Check for syntax errors:
```bash
firebase rules:test
```
Review error message and fix in `firestore.rules`

### Issue 4: Permission Denied still occurring
**Cause:** User not authenticated
**Fix:** Ensure:
1. User signed in with email or Google
2. `request.auth.uid` matches user's Firebase UID
3. Check Firebase Console → Authentication tab
4. Verify user email is created

---

## Step-by-Step Walkthrough

### Step 1: Open Terminal/Command Prompt
```bash
cd c:\Users\RAYNOLD\OneDrive\Desktop\2026\codequest-core
```

### Step 2: Install Firebase CLI (one-time)
```bash
npm install -g firebase-tools
```

### Step 3: Login
```bash
firebase login
```
- Opens browser to login
- Click "Allow"
- Returns to terminal: "✔ Logged in as [your email]"

### Step 4: Initialize (if needed)
```bash
firebase init firestore
```
- Asks: "Use existing project?" → Select your project
- Asks: "Rules file location?" → Keep default: `firestore.rules`
- Asks: "Indexes?" → Keep default

### Step 5: Deploy Rules
```bash
firebase deploy --only firestore:rules
```

Expected success output:
```
=== Deploying to '[project-id]'...

✔ Deploy complete!

Project Console: https://console.firebase.google.com/project/YOUR_PROJECT_ID/database/firestore
```

### Step 6: Test in App
1. Reload your app
2. Sign in
3. Try completing a module
4. Should work without permission errors!

---

## After Deployment

Once rules are deployed, your app will work:

✅ Users can create their own profile  
✅ Users can update their own data (XP, modules, achievements)  
✅ Achievements auto-unlock on completion  
✅ Streaks tracked correctly  
✅ Certificates can be issued  
✅ Code Golf entries save to leaderboard  
✅ Real-time sync works across devices  

---

## Emergency Fallback

If you can't deploy rules immediately, use **Test Mode** (temporary):

**In Firebase Console:**
1. Firestore → Rules
2. Select "Start in test mode"
3. Click "Publish"

**WARNING:** This allows anyone to read/write all data. Only for testing!

Once you fix the rules deployment, switch back to production mode with proper rules.

---

## Support

If still getting errors after deploying:

1. **Check user is signed in:**
   ```dart
   final user = FirebaseAuth.instance.currentUser;
   print('Signed in as: ${user?.uid}');
   ```

2. **Check Firebase Auth is configured:**
   - Firebase Console → Authentication → Providers
   - Email enabled? Google enabled?

3. **Check Firestore database region:**
   - Firebase Console → Firestore → Database Settings
   - Region should match your config

4. **Check firestore.rules syntax:**
   ```bash
   firebase rules:test
   ```

---

**Status:** Rules exist but NOT deployed  
**Priority:** HIGH - App cannot function without this  
**Time to fix:** 5-10 minutes  
**Difficulty:** Low (copy/paste or one command)

Deploy the rules NOW to enable all app features! 🚀
