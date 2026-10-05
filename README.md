# Borrower Default Risk Prediction

**A credit risk analytics project predicting which borrowers are likely to experience serious
loan delinquency within 2 years, using real lending data and a logistic regression model.**

*Portfolio project | Data cleaning, EDA, predictive modeling, class imbalance handling*

---

## Business Problem

> Al-Rajab Lenders lacks a systematic way to identify borrowers likely to delay payment for 2
> years, resulting in preventable capital losses from approving high-risk loans.

## Stakeholders

| Stakeholder | Role | What they need from this analysis |
|---|---|---|
| **Loan Approving Manager** | Decision-maker | Reliable borrower risk signals to improve approval decisions |
| **CFO** | Influencer | Visibility into expected defaults to manage capital reserves |
| **Shareholders** | Indirectly affected | Protection of profitability and stock value from avoidable loan losses |

## Dataset

- **Source:** [Kaggle — Give Me Some Credit](https://www.kaggle.com/c/GiveMeSomeCredit/data)
- **Size:** 150,000 borrower records, 11 features (149,999 after cleaning)
- **Target variable:** `SeriousDlqin2yrs` — whether the borrower experienced 90+ day delinquency
  within 2 years (imbalanced: ~6.7% positive class)

## Tech Stack

| Tool | Purpose |
|---|---|
| Python (pandas) | Data cleaning and exploratory data analysis |
| scikit-learn | Logistic regression modeling, train-test splitting, feature scaling |
| Jupyter Notebook | Documented, reproducible analysis workflow |

## Methodology

1. **Data Cleaning** — Removed 1 invalid record (`age = 0`), imputed missing `MonthlyIncome`
   and `NumberOfDependents` with median values, and added an `Income_Was_Missing` flag to
   preserve the missingness signal rather than discard it.
2. **Exploratory Data Analysis** — Tested hypotheses on prior late-payment history and borrower
   age against default outcomes.
3. **Predictive Modeling** — Built a logistic regression model with stratified train-test
   splitting and feature scaling, explicitly addressing class imbalance with `class_weight='balanced'`.
4. **Threshold Tuning** — Evaluated the recall/precision trade-off across multiple decision
   thresholds, since the default 0.5 threshold caught only 67% of actual defaulters.
5. **Business Insights** — Converted statistical findings into stakeholder-specific recommendations.

## Key Findings

| Factor | Finding |
|---|---|
| Prior 90+ day late payments | Default rate rises from 4.6% (0 instances) to 60.5% (3+ instances) — the strongest predictor found |
| Borrower age | Default rate falls steadily from 11.7% (20s) to 2.3% (70+) |

## Model Performance

A naive "always predict no default" baseline achieves 93.3% accuracy while catching **zero**
actual defaulters — a clear example of why accuracy alone is misleading on imbalanced data.

| Metric | Dummy Baseline | Logistic Regression (threshold = 0.5) |
|---|---|---|
| Accuracy | 93.3% | 77.0% |
| Recall (catches actual defaulters) | 0% | 67.0% |
| Precision | — | 17.7% |

**Threshold tuning:** Since missing an actual defaulter (losing the full loan principal) is
assumed to be costlier than a false alarm (losing only potential interest income), recall was
prioritized over raw accuracy. Lowering the decision threshold to ~0.3 raises recall to 95.6%
while keeping the model practically usable — pushing it further (e.g. to 0.15) catches 100% of
defaulters but collapses accuracy to 7%, rejecting nearly everyone. 0.3 was selected as a
practical balance.

*Note: this dataset has no loan-amount field, so cost-based claims above are reasoned assumptions,
not figures calculated directly from the data — a limitation worth stating explicitly.*

## Business Recommendations

1. **Flag any borrower with even one instance of 90+ day late payment for stricter review** —
   risk jumps 7x (4.6% → 33.7%) at just one occurrence.
2. **Apply risk-adjusted scrutiny for younger applicants (20s-30s)**, who default at roughly 5x
   the rate of borrowers aged 70+.
3. **Adopt a tuned decision threshold (~0.3) rather than the default 0.5`** to catch significantly
   more actual defaulters, accepting a higher false-alarm rate as a reasoned business trade-off.

## Limitations

- No loan-amount or interest-rate data is included, so financial cost/ROI framing is a reasoned
  estimate, not a dataset-derived figure.
- This is a single baseline model (logistic regression); more advanced models (e.g. gradient
  boosting) were not tested but would be a natural next step.
- Data reflects historical lending patterns and may not capture current market conditions.

## Author

**[Your Name]**

Built as part of a data analytics portfolio, extending a healthcare analytics project into
predictive modeling and class-imbalance handling for finance/credit risk use cases.
