## Version 0.0.6 (Build 7)

Gold pricing reliability and Home chart clarity release.

### Changed in this release

- Live gold rates are fetched **at most once per calendar day** into a single global Firestore doc (`goldPrices/latest`), instead of writing a new `goldPriceDaily/{yyyyMMdd}` document each day.
- Fetch chain for today: KmalServico (Pakistan 24k PKR/gram) → exchangerate.host → gold-api + open.er-api; same-day opens reuse the cached latest doc.
- **Zakat year freeze (per space):** when a year is past, or zakat for that year is paid in full, the space locks that year’s gold rate under `zakat/yearGoldPrice/years/{year}` so later market moves do not change dues.
- Current-year Zakat (while unfrozen) uses the global daily latest rate; Tools → Gold Price always uses the global latest and ignores space freezes.
- Legacy `goldPriceDaily` docs remain readable but are no longer written; Firestore rules allow `goldPrices/latest` and lock down new `goldPriceDaily` writes.
- Zakat screen shows cached dues quickly, with an “Updating gold prices…” refresh state while live rates load.
- Home KPI carousel graphs share one time axis across Income / Spent / Savings / Budget remaining (daily / weekly / monthly buckets by range length), with fixed three-tick axes, 0-anchored nice Y scales, carry-forward balances, and smoother filled sparklines.
- FAQ, Roadmap, README, architecture, and coverage audit updated for daily-latest gold, year freezes, and shared-axis Home charts.

### Notes

- This build is compatible with `0.0.5+6`.
- Deploy updated `firestore.rules` with this client so `goldPrices/latest` writes succeed and old daily-cache writes stay blocked.
