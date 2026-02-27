# Release Notes

## Version 0.0.1 (Build 1)

First public build of ChillCheck. This is the foundation release, so all currently available modules and capabilities are included as new.

### New in this release

- Account authentication flow with login, registration, verification, and persistent sessions.
- Space-based collaboration model with create/join/switch flows, invite-code onboarding, member access control, and ownership transfer support.
- Dashboard shell with bottom navigation for Home, Transactions, Reports, and Vehicles.
- Drawer-based modules for Spaces, Zakat, Saved Reports, Currency Converter, Gold Prices, About, Options, and Feedback.
- Real-time shared ledger powered by Firestore with offline-ready sync behavior.
- Full transaction workflows including add expense, add income, add savings entries, split expense support, transaction detail view, and history visibility.
- Soft-delete and audit-history aligned ledger behavior for safer financial record keeping.
- Savings buckets system with bucket creation, bucket detail view, entry history, deposit/withdraw actions, and migration compatibility for legacy spaces.
- Savings migration readiness with schema-version-aware reads, dual-write compatibility controls, and release-check tooling.
- Home summaries and KPI surfaces for quick monthly finance visibility.
- Reports module with monthly snapshots, PDF generation, save/share flows, and saved-report management.
- Vehicle tracking module for finance-adjacent maintenance and log management.
- Zakat module with gold holdings tracking, due-date-based calculations, and zakat payment recording.
- Gold price and currency utility tooling for valuation and conversion assistance.
- About and legal surfaces with in-app Privacy Policy PDF, Terms of Service PDF, and searchable FAQ.
- Feedback capture flow for bug reports, feature requests, and product sentiment.
- Design-system-driven Material 3 UI with theming/options support and reusable UI primitives.

### Notes

- This is the initial launch release, so release notes are intentionally broad.
- Future versions will use shorter, delta-focused notes highlighting only what changed since the previous version.
