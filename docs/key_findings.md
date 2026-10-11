# Key Findings & Recommendations

Data: VAHAN registrations, 5 makers × 5 states, 2021–2025 full years (2026 tracked separately as YTD).
All figures from `sql/03_analysis_queries.sql`, run against `india_auto_market.db`.

## Finding 1: Maruti Suzuki dominates but Mahindra is the real story

| Maker | Total Regs (2021–25) | Market Share |
|---|---|---|
| Maruti Suzuki | 2,356,226 | 54.1% |
| Hyundai | 915,497 | 21.0% |
| Mahindra | 514,753 | 11.8% |
| Kia | 429,874 | 9.9% |
| Renault | 136,680 | 3.1% |

Maruti's share has been essentially flat (55.2% → 54.4%, 2021 to 2025) — it isn't
losing ground overall. The real shift is **Mahindra's share nearly**
**tripling, from 6.2% (2021) to 15.4% (2025)**, growing every single year
(+81%, +39%, +19%, +17% YoY). Kia surged in 2022 (+34%) then plateaued.
Hyundai grew steadily through 2023, then slowed and slightly declined in 2025
(-1.2%).

**Interpretation:** Mahindra's gains appear to be coming primarily from
Hyundai, Kia, and Renault's share, not from Maruti Suzuki's — Maruti's
position looks structurally stable across this 5-state sample.

## Finding 2: State-level market leadership is uniform, but margins vary

Maruti Suzuki is the #1 maker in all 5 states — but its dominance is weakest
in Karnataka (51.3% state share) and strongest in Delhi (56.7%). Mahindra's
regional strength also varies notably — it holds 17.5% share in Odisha
(its highest of any state) vs. only 9.8% in Delhi, suggesting stronger
traction in semi-urban/value markets than in metro markets.

## Finding 3: Clear, repeatable seasonality — October is peak, February is the trough

Average monthly registrations across all makers/states/years:

| Month | Avg Regs | Month | Avg Regs |
|---|---|---|---|
| Jan | 3,592 | Jul | 2,857 |
| Feb | 2,604 (lowest) | Aug | 3,070 |
| Mar | 3,032 | Sep | 2,723 |
| Apr | 2,710 | **Oct** | **3,756 (highest)** |
| May | 2,324 | Nov | 2,893 |
| Jun | 2,565 | Dec | 2,698 |

October's peak lines up with the Navratri–Diwali festive buying season,
a well-known pattern in the Indian auto industry. February's dip likely
reflects a post-January-rush pullback (registrations often get pulled
forward into January for year-model/tax reasons) combined with pre-financial-year-end
budget conservatism.

## Finding 4: Confirmed anomaly — COVID-19 second wave, May 2021

The 10 largest single-month drops in the dataset are dominated by
Maruti Suzuki in Maharashtra, but the most structurally significant one is
**May 2021**, where registrations collapsed to near-zero across nearly every
maker and state simultaneously (e.g., Hyundai Delhi: 2,363 in Apr → 13 in
May; Kia Delhi: 598 → 0) — consistent with India's COVID-19 second wave
lockdowns. This is a legitimate market event, not a data error (confirmed in
the Process/validation phase).

## Finding 5: 2026 is tracking as the strongest year yet (YTD)

Comparing Jan–Sep totals year over year: 2021: 533K → 2022: 599K → 2023: 671K
→ 2024: 688K → 2025: 693K → **2026: 821K** — a sharp jump versus the
otherwise steadily-decelerating growth of 2023–2025. Worth flagging as a
trend to watch, not yet a confirmed full-year pattern since 2026 data is
incomplete.

## Recommendations (Act)

1. **Watch Mahindra as the primary competitive threat, not Maruti.** Mahindra's
   compounding share growth (6.2% → 15.4% in 5 years) is the clearest trend
   in the data. A manufacturer competing in this space should benchmark
   product/pricing strategy against Mahindra's recent launches, not assume
   Maruti's dominance is the main risk.
2. **Plan inventory and marketing spend around the Oct festive peak and Feb trough.**
   The ~44% swing between October's peak and February's trough is
   consistent enough across 5 years to treat as a predictable planning input,
   not noise.
3. **Prioritize Karnataka for competitive push, and Odisha for Mahindra-style value positioning.**
   Karnataka shows the most fragmented market (weakest Maruti dominance),
   suggesting more room for a challenger brand to gain share there. Odisha's
   stronger-than-average Mahindra share suggests value/semi-urban positioning
   resonates there specifically.
4. **Monitor 2026's YTD acceleration through year-end** before treating it as
   a structural shift — confirm once full-year data is available.

## Caveats

- 5 states are not nationally representative; findings describe this
  specific sample, not the full Indian market.
- Registrations are a proxy for sales (see `data_cleaning_log.md` for the
  full limitations note).
