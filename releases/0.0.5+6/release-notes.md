# Release Notes

## Version 0.0.5 (Build 6)

Reliability and About content release focused on safer space joins and a shipped-product Roadmap.

### Changed in this release

- Space join-by-invite now runs in a Firestore transaction: validates the invite, creates membership, updates the user profile, and increments invite `uses` atomically.
- Invite codes are normalized (trim + uppercase) before lookup.
- Firestore rules treat members as active only when `isActive != false`, so inactive members lose space access.
- Joiners may update an invite only to increment `uses` by 1 (within `maxUses`); owners retain full invite manage rights.
- Emulator rules checks cover the join path, invite use increment limits, and inactive-member denial.
- About includes a **Roadmap** entry with a user-facing timeline of what shipped from inception through current releases.
- Analyzer excludes `build/**` so Flutter SPM plugin copies under build do not flood analysis.

### Notes

- This build is compatible with `0.0.4+5`.
- Deploy updated `firestore.rules` with this client so joiners can increment invite uses under the new rule.
