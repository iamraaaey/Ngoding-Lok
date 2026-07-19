# Setup & Deployment Guide

Quick reference for setting up and deploying Ngoding Lok.

---

## Quick Start

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) compatible with Dart `^3.10.4`
- A supported target: Chrome for web, Windows desktop, or an Android device/emulator

### Run the Client

```bash
flutter pub get
flutter run -d chrome
```

Other available examples:

```bash
flutter run -d windows
flutter run -d android
```

The client can be explored immediately. When OAuth or AI hints are not configured, the applicable UI follows its local/static fallback instead of preventing play. Rewarded hints require configured live ad inventory; the app does not substitute a fake ad preview.

### Run Quality Checks

```bash
flutter analyze
flutter test
flutter build web --release
```

The CI workflow runs these same Flutter checks for pushes and pull requests, then uploads `build/web` as an artifact. It does **not** deploy web hosting or the Cloud Function.

---

## Web Deployment

### Production Web Build

```bash
flutter build web --release --no-wasm-dry-run --no-pub
```

### Redeploy Command (The Two Commands You Need)

```powershell
flutter build web --release
firebase deploy --only hosting
```

That's the whole loop: build the release bundle into `build/web`, then push it to Firebase Hosting. The site is live within seconds of "Deploy complete!".

**Live site:** https://ngoding-lok.web.app

### One-Time Setup (Already Done)

- `firebase.json` → `hosting` block serves `build/web` with SPA rewrites, plus a `/privacy` → `/privacy.html` rewrite.
- `.firebaserc` → links this repo to the `ngoding-lok` Firebase project.
- Logged in via `firebase login` as the Google account that owns the project.

If a new machine isn't logged in: `firebase login`.

---

## Firebase Authentication Setup

Firebase is initialized by the app using committed generated options. For a fork or a different Firebase project, generate/configure your own options before sharing a build.

### Configuration Steps

1. In Firebase Authentication, enable and configure the **Google** and **GitHub** providers you intend to use.

2. Add your local and deployed domains to the providers' allowed origins/redirect configuration.

3. For the committed Google web client configuration, add `http://localhost:5000` as an authorized JavaScript origin and use a fixed port:

   ```bash
   flutter run -d chrome --web-port=5000
   ```

4. In **Firebase Console → Authentication → Sign-in method**, enable **Email/Password** and **Phone** and save them.

5. In **Authentication → Templates → Password reset**, customize the sender name and reset email if needed. Also customize **Email address verification**, **Email address change**, and **Multi-factor enrolment notification** when MFA is enabled. Keep `ngoding-lok.web.app` and your local development domain in the project's authorized domains.

6. Create a test email/password user in **Authentication → Users**.

7. Add Firebase test phone numbers under the Phone provider settings for SMS testing.

8. For SMS MFA, upgrade the project to **Identity Platform**, enable SMS MFA under **Authentication → Sign-in method → Advanced**, and configure Android SHA-256, iOS APNs, and an authorized web domain.

9. SMTP is not configured by Flutter code. Configure the sender/domain and custom SMTP settings in Firebase Authentication/Identity Platform, then publish the required DNS records. The app only calls Firebase Auth.

### Email Template Customization

Access email templates in **Firebase Console → Authentication → Templates**.

Available templates:
- **Email Address Verification** - Sent when users sign up or request re-verification
- **Password Reset** - Sent when users click "Forgot Password"
- **Email Address Change** - Sent when users request to change email
- **Multi-Factor Authentication Enrollment** - Notification when user enables SMS MFA

Example template structure:
```
Subject: Verify your email for %APP_NAME%

Message:
Hello %DISPLAY_NAME%,

Follow this link to verify your email address.
[Link: %LINK%]

Thank you,
Ngoding Lok Team
```

---

## Rewarded Ads Configuration

Rewarded hints are configured for real ad providers only:

### Web — Google AdSense (H5 Games / Ad Placement API)

- Publisher ID lives in `web/index.html`:
  ```html
  window.__NGECODE_ADSENSE_PUBLISHER_ID__ = 'ca-pub-2836563830601298';
  ```
- The exact AdSense verification snippet is a static `<script>` in `<head>`.
- To preview test rewarded ads **after** H5 Games approval, set
  `window.__NGECODE_ADSENSE_TEST_MODE__ = true;`, rebuild, and redeploy.
- A public, approved AdSense H5 Games domain and account approval are required before `adBreak()` can return a live rewarded placement.

### Android/iOS — Google AdMob (Rewarded Video)

- Registered package: `com.ngecodejuh.ngecode_juh`
- App ID placeholder in `android/app/src/main/AndroidManifest.xml` (`com.google.android.gms.ads.APPLICATION_ID`) — replace the test ID with the real AdMob App ID before release.
- Development builds use Google's official rewarded test units automatically.
- Production build with your real rewarded unit:

  ```powershell
  flutter build apk --release `
    --dart-define=ADMOB_LIVE_ADS=true `
    --dart-define=ADMOB_ANDROID_REWARDED_AD_UNIT_ID=ca-app-pub-YOUR_ID/YOUR_REWARDED_UNIT
  ```

AdMob rewarded videos are native full-screen SDK overlays, while AdSense controls web playback. No fake `SPONSOR MESSAGE` or local-preview card is used.

---

## Socratic Hint Backend

Deploy this function to enable live GPT-powered hints after the rewarded-ad gate. It requires Node.js 20, the Firebase CLI, a Firebase project, and an LLM API key.

### Deployment Steps

```bash
cd functions
npm install

firebase login
firebase use --add
firebase functions:secrets:set LLM_API_KEY
npm run deploy
```

For local web debugging when AdSense has no rewarded fill, run the client with:

```bash
flutter run -d chrome --dart-define=DEBUG_HINT_FLOW=true
```

After deployment, the app uses the `ngoding-lok` function URL from `lib/core/config/backend_config.dart`.

For another Firebase project, pass `--dart-define=HINT_ENDPOINT_URL=https://.../generateSocraticHint` at build time.

See `functions/README.md` for the local emulator command and request/response contract.

### Security Notes

The function verifies the signed-in Firebase user's ID token before calling the configured GPT/OpenAI-compatible model. Add production rate limiting and monitoring appropriate for your deployment before opening the feature to a large audience.

---

## Responsive Design Breakpoints

Reference for mobile, tablet, and desktop layouts.

```dart
// Extra Small: Small phones (width < 360px)
isExtraSmall = constraints.maxWidth < 360;

// Small: Large phones (360px ≤ width < 560px)
isSmall = constraints.maxWidth < 560;

// Medium: Tablets (560px ≤ width < 900px)
isMedium = constraints.maxWidth < 900;

// Large: Desktops (width ≥ 900px)
isLarge = constraints.maxWidth >= 900;
```

### Device Mapping

| Category | Devices | Width | Breakpoint |
|----------|---------|-------|-----------|
| **Extra Small** | iPhone SE, older phones | 320-375px | < 360px |
| **Small** | iPhone 13/14/15 | 390-430px | 360-560px |
| **Small Plus** | iPhone 13/14 Pro Max | 430-450px | 360-560px |
| **Medium** | iPad (10.9"), small tablets | 560-768px | 560-900px |
| **Medium Plus** | iPad Pro (11"), large tablets | 768-900px | 560-900px |
| **Large** | Desktop, large monitors | 900-1920px+ | ≥ 900px |

---

## Deployment Checklist

- [ ] Firestore collections created (`users`, `codeGolfEntries`)
- [ ] Firestore rules deployed (allow authenticated read/write)
- [ ] Firebase auth enabled (Google OAuth + Email)
- [ ] Environment variables set (Firebase config)
- [ ] Test database synced with production
- [ ] Backups configured for user data
- [ ] Monitoring alerts set for high read/write costs
- [ ] Beta testers have access to test all features
- [ ] `build/` and `.firebase/` are gitignored
- [ ] AdSense/AdMob configuration verified for production

---

## Key Configuration Files

**firebase.json** - Hosting configuration with SPA rewrites
**firebaserc** - Firebase project link
**web/index.html** - AdSense publisher ID and verification
**lib/core/config/backend_config.dart** - Socratic hint endpoint
**android/app/src/main/AndroidManifest.xml** - AdMob app ID
**pubspec.yaml** - Flutter dependencies and asset registration

---

**Live site:** https://ngoding-lok.web.app | **Privacy policy:** https://ngoding-lok.web.app/privacy
