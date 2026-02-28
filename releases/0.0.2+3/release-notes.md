# Release Notes

## Version 0.0.2 (Build 3)

Stability and UX release focused on Home range accuracy and branded authentication flow improvements.

### Changed in this release

- Fixed Home range boundary calculations so week/month/quarter/year include the full final day, preventing end-of-period transactions from being excluded in `Spent`, `Budget health`, top categories, and KPI sparkline summaries.
- Preserved existing source-based transaction behavior while applying only a targeted date-range accuracy fix to reduce regression risk.
- Added a new branded auth home screen so users can clearly choose between `Log in` and `Sign up`.
- Refreshed login, sign up, forgot password, and verify email screens with a consistent full-screen branded layout that adapts to light/dark logo assets.
- Added a dedicated branded auto-login/loading state screen for smoother session restore experience.
- Improved auth navigation behavior to avoid login/sign-up route stacking loops by using replacement-based transitions between those screens.
- Updated FAQ entries to document savings bucket transfer behavior, including transfer to existing/new/restored buckets and full-balance transfer archival behavior.

### Notes

- This update addresses an intermittent real-device symptom where transactions could appear in `Recent`/`Transactions` but be missing from same-period Home aggregate cards.
- This build also includes branding-first authentication UI enhancements and FAQ documentation updates for savings bucket transfer behavior.
