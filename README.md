# finance_ledger_builds

Public distribution repository for **ChillCheck (Finance Ledger)**.

This repository provides:
- Latest Android APK download
- Version tracking
- Release notes history
- Privacy Policy
- Terms of Service

## About The App

ChillCheck is a shared finance manager for families and trusted members.

It helps users track shared expenses, savings, and zakat in one space, with real-time sync across members and a simple, calm interface so everyone stays clear on where money goes every month.

### What ChillCheck does

- Auth flow: login, register, verify, and persistent sessions
- Space-based collaboration: create, join, switch, and manage shared spaces
- Daily finance tracking: expenses, income, split expense support, and history visibility
- Savings buckets: bucket balances, entry history, deposit/withdraw flows
- Zakat and gold tools: holdings tracking and due-date-based calculation support
- Reports and exports: monthly snapshots with PDF save/share support
- Vehicle logs: maintenance-focused cost and record tracking
- Utilities and support: currency converter, gold prices, FAQ, and feedback

### Core app flow

1. Sign in (`login/register/verify`)
2. Select a space
3. Use main dashboard tabs (`Home`, `Transactions`, `Reports`, `Vehicles`)
4. Access additional modules from drawer (`Spaces`, `Zakat`, `Saved reports`, `Currency converter`, `Gold prices`, `About/Options`, `Feedback`)

## Download Latest APK

<!-- RELEASE_DOWNLOAD_BLOCK_START -->
- **Latest:** 
- **Current stable release page:** 

[![Download Latest APK (v0.0.1+2)](https://img.shields.io/badge/Download%20Latest-v0.0.1%2B2-2ea44f?style=for-the-badge&logo=android)](https://github.com/daniyalsaeed20/finance_ledger_builds/releases/latest/download/chillcheck_latest.apk)

[![Download v0.0.1+2 APK](https://img.shields.io/badge/Download-v0.0.1%2B2-blue?style=for-the-badge&logo=android)](https://github.com/daniyalsaeed20/finance_ledger_builds/releases/download/v0.0.1+2/chillcheck_v0.0.1+2.apk)

Direct links:
- Latest channel: 
- Version : 
<!-- RELEASE_DOWNLOAD_BLOCK_END -->

## Latest Release Notes

<!-- RELEASE_NOTES_LATEST_START -->
### 0.0.1+2
- Latest public release for ChillCheck.
- Download and install from the button/link section above.
- Detailed notes: 
<!-- RELEASE_NOTES_LATEST_END -->

Full notes: `releases/0.0.1+1/release-notes.md`

## Legal

- Privacy Policy: `privacy-policy.md`
- Terms of Service: `terms-of-service.md`

## Version Metadata

Machine-readable version file: `VERSION.json`

## Release Automation

Use the release script to repeat the same flow every time:

```bash
./tool/publish_release.sh <version> <apk_path> [notes_path]
```

Example:

```bash
./tool/publish_release.sh 0.0.2+2 "/absolute/path/to/app-release.apk" "../finance_ledger/release_notes.md"
```

What the script does:
- Copies release notes to `releases/<version>/release-notes.md`
- Copies APK locally to `releases/<version>/chillcheck_v<version>.apk` (ignored by git)
- Updates `README.md` latest version/download blocks
- Updates `VERSION.json` latest metadata
- Commits and pushes metadata updates
- Creates or updates GitHub release `v<version>` and uploads both:
  - `chillcheck_v<version>.apk`
  - `chillcheck_latest.apk`
