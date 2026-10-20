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
Hyundai grew through 2023, then went flat in 2024 (+0.5%) and declined in
2025 (-1.2%) while the market kept growing — so its share fell every year
(23.3% → 21.5% → 21.2% → 20.6% → 19.3%).

**Where Mahindra's gains came from (share change, 2021 → 2025, in percentage points):**

| Maker | Share 2021 | Share 2025 | Change |
|---|---|---|---|
| Mahindra | 6.2% | 15.4% | **+9.2** |
| Maruti Suzuki | 55.2% | 54.4% | -0.8 |
| Kia | 9.6% | 9.2% | -0.4 |
| Renault | 5.7% | 1.8% | -3.9 |
| Hyundai | 23.3% | 19.3% | **-4.1** |

**Interpretation:** Mahindra's +9.2 points are offset almost entirely by
**Hyundai (-4.1) and Renault (-3.9)**. Kia (-0.4) and Maruti Suzuki (-0.8)
barely moved, so Maruti's position looks structurally stable across this
5-state sample. This shows *correlation* in share, not proof that Hyundai's or
Renault's buyers switched to Mahindra — that would need model-level data.

## Finding 2: State-level market leadership is uniform, but margins vary

Maruti Suzuki is the #1 maker in all 5 states — but its dominance is weakest
in Karnataka (51.3% state share) and strongest in Delhi (56.7%). Mahindra's
regional strength also varies notably — it holds 17.5% share in Odisha
(its highest of any state) vs. only 9.8% in Delhi, suggesting stronger
traction in semi-urban/value markets than in metro markets.

## Finding 3: Clear, repeatable seasonality — October is peak, February is the trough

Average monthly registrations per state-maker, shown two ways. 2021 is
excluded in the second column because May 2021 (COVID second wave, see
Finding 4) drags May down and hides the normal seasonal pattern.

| Month | Avg 2021–25 | Avg 2022–25 (excl. 2021) |
|---|---|---|
| Jan | 3,592 | 3,662 |
| Feb | 2,604 | **2,574 (lowest)** |
| Mar | 3,032 | 3,045 |
| Apr | 2,710 | 2,896 |
| May | **2,324 (lowest)** | 2,770 |
| Jun | 2,565 | 2,793 |
| Jul | 2,857 | 2,829 |
| Aug | 3,070 | 3,133 |
| Sep | 2,723 | 2,812 |
| Oct | **3,756 (highest)** | **4,099 (highest)** |
| Nov | 2,893 | 3,071 |
| Dec | 2,698 | 2,825 |

Including 2021, May looks like the weakest month — but only because of the
pandemic. With 2021 removed, **February is the trough (2,574) and October the
peak (4,099)**, a swing of about **59%**.

October's peak lines up with the Navratri–Diwali festive buying season,
a well-known pattern in the Indian auto industry. February's dip likely
reflects a post-January-rush pullback (registrations often get pulled
forward into January for year-model/tax reasons) combined with pre-financial-year-end
budget conservatism. Both explanations are plausible but are not tested in this dataset.

## Finding 4: Confirmed anomaly — COVID-19 second wave, May 2021

The 10 largest single-month drops by absolute count (Q5) are all Maruti Suzuki
or other large-volume rows falling after the festive peak (Oct → Nov, Jan → Feb),
so they do not show the COVID effect. Measuring April → May 2021 by
percentage change per state (Q5b) does:

| State | Apr 2021 | May 2021 | Change |
|---|---|---|---|
| Delhi | 6,003 | 24 | -99.6% |
| Karnataka | 12,254 | 520 | -95.8% |
| Odisha | 4,172 | 541 | -87.0% |
| Tamil Nadu | 13,826 | 2,497 | -81.9% |
| Maharashtra | 12,937 | 9,891 | -23.5% |

Four of the five states collapsed by more than 80%, while **Maharashtra fell
only 23.5%** — the shock was heavily regional, not uniform. At maker level
(e.g., Hyundai Delhi: 1,343 in Apr → 13 in May; Kia Delhi: 598 → 0), 9 of the
25 state-maker pairs fell below 5% of their April level. This is consistent
with India's COVID-19 second wave lockdowns, which hit states at different
times and severity. It is a legitimate market event, not a data error
(confirmed in the Process/validation phase: VAHAN's own totals match).

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
   The ~59% swing between October's peak and February's trough (2022–2025
   averages, excluding the COVID-distorted 2021) is consistent enough to
   treat as a predictable planning input, not noise.
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
