/*
====================================================================
SQL Analysis
Al-Rajab Lenders -- Borrower Default Risk Analysis
====================================================================

Database: credit_risk.db (SQLite)
Table:    borrowers (149,999 rows, 12 columns)
Source:   Cleaned output of the data cleaning notebook, derived from
          the Kaggle "Give Me Some Credit" dataset.

Purpose: Reproduce the key EDA findings using SQL, validating the
Python-based findings against a relational query structure --
the same cross-validation discipline used in the healthcare project.
====================================================================
*/


-- --------------------------------------------------------------
-- Query 1: Baseline Default Rate
-- --------------------------------------------------------------
-- Purpose: Establish the overall default rate across all borrowers.
-- This is the core baseline metric every other finding is compared against.

SELECT
    SeriousDlqin2yrs,
    COUNT(*) AS group_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM borrowers), 2) AS pct_of_total
FROM borrowers
GROUP BY SeriousDlqin2yrs;

-- Result:
-- 0 (no default) | 139,973 | 93.32%
-- 1 (default)    |  10,026 |  6.68%


-- --------------------------------------------------------------
-- Query 2: Default Rate by Prior Severe Late-Payment History
-- --------------------------------------------------------------
-- Purpose: Test whether borrowers with more instances of being
-- 90+ days late show a higher default rate. Identified in EDA as
-- the strongest predictor found.

SELECT
    CASE
        WHEN NumberOfTimes90DaysLate = 0 THEN '0 times'
        WHEN NumberOfTimes90DaysLate = 1 THEN '1 time'
        WHEN NumberOfTimes90DaysLate = 2 THEN '2 times'
        WHEN NumberOfTimes90DaysLate >= 3 THEN '3+ times'
    END AS late_90_bucket,
    COUNT(*) AS total_borrowers,
    SUM(CASE WHEN SeriousDlqin2yrs = 1 THEN 1 ELSE 0 END) AS default_count,
    ROUND(SUM(CASE WHEN SeriousDlqin2yrs = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS default_pct
FROM borrowers
GROUP BY
    CASE
        WHEN NumberOfTimes90DaysLate = 0 THEN '0 times'
        WHEN NumberOfTimes90DaysLate = 1 THEN '1 time'
        WHEN NumberOfTimes90DaysLate = 2 THEN '2 times'
        WHEN NumberOfTimes90DaysLate >= 3 THEN '3+ times'
    END;

-- Result:
-- 0 times  | 141,661 |  6,554 |  4.6%
-- 1 time   |   5,243 |  1,765 | 33.7%
-- 2 times  |   1,555 |    776 | 49.9%
-- 3+ times |   1,540 |    931 | 60.5%
--
-- Finding: A dramatic, step-by-step increase -- even one instance
-- of severe late payment raises default risk roughly 7x over
-- borrowers with no such history.


-- --------------------------------------------------------------
-- Query 3: Default Rate by Age Group
-- --------------------------------------------------------------
-- Purpose: Test whether younger or older borrowers show a higher
-- default rate.

SELECT
    CASE
        WHEN age < 30 THEN '20-29'
        WHEN age < 40 THEN '30-39'
        WHEN age < 50 THEN '40-49'
        WHEN age < 60 THEN '50-59'
        WHEN age < 70 THEN '60-69'
        ELSE '70+'
    END AS age_bucket,
    COUNT(*) AS total_borrowers,
    SUM(CASE WHEN SeriousDlqin2yrs = 1 THEN 1 ELSE 0 END) AS default_count,
    ROUND(SUM(CASE WHEN SeriousDlqin2yrs = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS default_pct
FROM borrowers
GROUP BY
    CASE
        WHEN age < 30 THEN '20-29'
        WHEN age < 40 THEN '30-39'
        WHEN age < 50 THEN '40-49'
        WHEN age < 60 THEN '50-59'
        WHEN age < 70 THEN '60-69'
        ELSE '70+'
    END
ORDER BY age_bucket;

-- 20-29 |  8,820 | 1,035 | 11.7%
-- 30-39 | 23,183 | 2,335 | 10.1%
-- 40-49 | 34,377 | 2,878 |  8.4%
-- 50-59 | 35,301 | 2,278 |  6.5%
-- 60-69 | 28,905 | 1,050 |  3.6%
-- 70+   | 19,413 |   450 |  2.3%
--
-- Finding: A steady, consistent decline in default rate as age
-- increases -- younger borrowers (20s) default at roughly 5x the
-- rate of the oldest borrowers (70+).
