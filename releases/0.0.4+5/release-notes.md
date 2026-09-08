# Release Notes

## Version 0.0.4 (Build 5)

Web / PWA delivery release. ChillCheck is now available as an installable Progressive Web App alongside the Android APK.

### New in this release

- Flutter web platform with ChillCheck-branded web shell (`index.html`, `manifest.json`, icons, splash).
- Firebase Hosting deploy for the live web app at https://chillcheck-app.web.app.
- Full product surface on web (auth, spaces, ledger, loans, zakat, vehicles, tools) using the same codebase as Android.
- Reports **Download PDF** on web (browser download); on-device **Saved reports** library remains mobile-only.
- Platform-conditional PDF persistence and saved-reports store for web vs native.
- Documentation updates for PWA hosting, web PDF behavior, and iOS home-screen install.

### Notes

- Production URL is https://chillcheck-app.web.app (`chillcheck.web.app` was already reserved on Firebase).
- iOS users can install via Safari → Share → Add to Home Screen (no App Store build required for PWA access).
- This Android build remains compatible with `0.0.3+4`.
- Confirm `chillcheck-app.web.app` under Authentication → Authorized domains if sign-in fails on the live URL.
