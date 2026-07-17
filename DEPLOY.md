# Deploy — Ngoding Lok (web)

Live site: **https://ngoding-lok.web.app**
Privacy policy: **https://ngoding-lok.web.app/privacy**
Firebase project: `ngoding-lok`

## Redeploy the web app (the two commands you need)

```powershell
flutter build web --release
firebase deploy --only hosting
```

That's the whole loop: build the release bundle into `build/web`, then push it to
Firebase Hosting. The site is live within seconds of "Deploy complete!".

## One-time setup (already done)

- `firebase.json` → `hosting` block serves `build/web` with SPA rewrites, plus a
  `/privacy` → `/privacy.html` rewrite.
- `.firebaserc` → links this repo to the `ngoding-lok` Firebase project.
- Logged in via `firebase login` as the Google account that owns the project.

If a new machine isn't logged in: `firebase login`.

## Ads configuration

### Web — Google AdSense (H5 Games / Ad Placement API)
- Publisher ID lives in `web/index.html`:
  `window.__NGECODE_ADSENSE_PUBLISHER_ID__ = 'ca-pub-2836563830601298';`
- The exact AdSense verification snippet is a static `<script>` in `<head>`.
- To preview test rewarded ads **after** H5 Games approval, set
  `window.__NGECODE_ADSENSE_TEST_MODE__ = true;`, rebuild, and redeploy.

### Android — Google AdMob (rewarded video)
- Registered package: `com.ngecodejuh.ngecode_juh`
- App ID placeholder in `android/app/src/main/AndroidManifest.xml`
  (`com.google.android.gms.ads.APPLICATION_ID`) — replace the test ID with the
  real AdMob App ID before release.
- Development build uses Google's safe test units automatically.
- Production build with your real rewarded unit:

  ```powershell
  flutter build apk --release `
    --dart-define=ADMOB_LIVE_ADS=true `
    --dart-define=ADMOB_ANDROID_REWARDED_AD_UNIT_ID=ca-app-pub-YOUR_ID/YOUR_REWARDED_UNIT
  ```

## Notes
- `build/` and `.firebase/` are gitignored; don't commit them.
- Hosting stays on the free Spark plan — no cost for this setup.
