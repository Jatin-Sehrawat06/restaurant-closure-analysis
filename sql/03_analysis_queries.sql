/* ============================================================
   PROJECT: Restaurant Closure Analysis
   GOAL: Figure out what factors are associated with a restaurant
         being closed (is_open = 'f') vs still open (is_open = 't')
   DATASET: restaurants (business_id, name, city, state, star,
            review_count, is_open, price_range)
   ============================================================ */


/* ------------------------------------------------------------
   QUERY 1: Baseline closure rate
   WHY: Every other number in this project gets compared back
        to this one. It's the "average" we're testing against.
   ------------------------------------------------------------ */
SELECT
    COUNT(*) AS total_restaurants,
    SUM(CASE WHEN is_open = 'f' THEN 1 ELSE 0 END) AS closed_count,
    ROUND(
        100.0 * SUM(CASE WHEN is_open = 'f' THEN 1 ELSE 0 END) / COUNT(*),
        1
    ) AS closure_rate_pct
FROM restaurants_only;


/* ------------------------------------------------------------
   QUERY 2: Closure rate by star rating bucket
   WHY: Raw star ratings (1.0, 1.5, 2.0 ... 5.0) are too granular
        to read at a glance, so we group them into 5 buckets
        using CASE WHEN (basically a sorting hat for each row).
   ------------------------------------------------------------ */
SELECT
    CASE
        WHEN star <= 1.5 THEN '1-1.5 (very low)'
        WHEN star <= 2.5 THEN '2-2.5 (low)'
        WHEN star <= 3.5 THEN '3-3.5 (mid)'
        WHEN star <= 4.5 THEN '4-4.5 (high)'
        ELSE '5 (top)'
    END AS star_bucket,
    COUNT(*) AS total,
    ROUND(
        100.0 * SUM(CASE WHEN is_open = 'f' THEN 1 ELSE 0 END) / COUNT(*),
        1
    ) AS closure_rate_pct
FROM restaurants_only
GROUP BY 1
ORDER BY 1;


/* ------------------------------------------------------------
   QUERY 3: Closure rate by price range
   WHY: price_range is already a clean 1-4 scale (1=$, 4=$$$$),
        so no bucketing is needed here, just a straight GROUP BY.
   ------------------------------------------------------------ */
SELECT
    price_range,
    COUNT(*) AS total,
    ROUND(
        100.0 * SUM(CASE WHEN is_open = 'f' THEN 1 ELSE 0 END) / COUNT(*),
        1
    ) AS closure_rate_pct
FROM restaurants_only
GROUP BY price_range
ORDER BY price_range;


/* ------------------------------------------------------------
   QUERY 4: Closure rate by review count quartile
   WHY: review_count is spread out unevenly (some restaurants
        have 3 reviews, some have 3,000), so fixed buckets like
        "0-100, 100-500" would be arbitrary and misleading.
        NTILE(4) instead lines up every restaurant from fewest
        to most reviews and slices the line into 4 equal-sized
        groups -- so each quartile has the same NUMBER of
        restaurants, just very different review counts.
   ------------------------------------------------------------ */
WITH ranked AS (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY review_count) AS review_quartile
    FROM restaurants_only
)
SELECT
    review_quartile,
    MIN(review_count) AS min_reviews,
    MAX(review_count) AS max_reviews,
    COUNT(*) AS total,
    ROUND(
        100.0 * SUM(CASE WHEN is_open = 'f' THEN 1 ELSE 0 END) / COUNT(*),
        1
    ) AS closure_rate_pct
FROM ranked
GROUP BY review_quartile
ORDER BY review_quartile;


/* ------------------------------------------------------------
   QUERY 5: Closure rate by state
   WHY: Same GROUP BY pattern as price range, just swapping
        the column -- this feeds the map visual in Power BI.
   ------------------------------------------------------------ */
SELECT
    state,
    COUNT(*) AS total,
    ROUND(
        100.0 * SUM(CASE WHEN is_open = 'f' THEN 1 ELSE 0 END) / COUNT(*),
        1
    ) AS closure_rate_pct
FROM restaurants_only
GROUP BY state
ORDER BY closure_rate_pct DESC;


/* ------------------------------------------------------------
   QUERY 6 (ADVANCED): Price x Rating risk matrix
   WHY: This is the "wow" query. Instead of looking at price
        and rating separately, we group by BOTH at once. This
        answers a sharper question: "is a cheap-and-mediocre
        restaurant riskier than an expensive-and-mediocre one?"
        Feed this straight into a Power BI matrix/heatmap visual
        -- price_range as columns, star_bucket as rows, and
        closure_rate_pct as the color.
   ------------------------------------------------------------ */
SELECT
    price_range,
    CASE
        WHEN star <= 1.5 THEN '1-1.5 (very low)'
        WHEN star <= 2.5 THEN '2-2.5 (low)'
        WHEN star <= 3.5 THEN '3-3.5 (mid)'
        WHEN star <= 4.5 THEN '4-4.5 (high)'
        ELSE '5 (top)'
    END AS star_bucket,
    COUNT(*) AS total,
    ROUND(
        100.0 * SUM(CASE WHEN is_open = 'f' THEN 1 ELSE 0 END) / COUNT(*),
        1
    ) AS closure_rate_pct
FROM restaurants_only
GROUP BY 1, 2
ORDER BY 1, 2;


/* ------------------------------------------------------------
   QUERY 7 (ADVANCED): Riskiest cities, with a minimum sample
   size filter
   WHY: A city with only 3 restaurants where all 3 closed would
        show a scary "100% closure rate" -- but that's noise,
        not a real trend. HAVING COUNT(*) >= 30 makes sure we
        only rank cities big enough for the number to mean
        something. This shows you know the difference between
        WHERE (filters rows before grouping) and HAVING
        (filters groups after grouping).
   ------------------------------------------------------------ */
SELECT
    city,
    state,
    COUNT(*) AS total,
    ROUND(
        100.0 * SUM(CASE WHEN is_open = 'f' THEN 1 ELSE 0 END) / COUNT(*),
        1
    ) AS closure_rate_pct
FROM restaurants_only
GROUP BY city, state
HAVING COUNT(*) >= 30          -- ignore tiny/noisy cities
ORDER BY closure_rate_pct DESC
LIMIT 10;


/* ------------------------------------------------------------
   QUERY 8 (ADVANCED): How does each state compare to the
   national average?
   WHY: Raw closure rates by state (Query 5) are useful, but
        "34% closure in PA" means more once you can see it next
        to the national number. This uses a window function
        (AVG() OVER) to attach the national average to every
        row WITHOUT collapsing the table, so we can subtract
        and see who's above/below average and by how much.
   ------------------------------------------------------------ */
WITH state_rates AS (
    SELECT
        state,
        COUNT(*) AS total,
        100.0 * SUM(CASE WHEN is_open = 'f' THEN 1 ELSE 0 END) / COUNT(*) AS closure_rate_pct
    FROM restaurants_only
    GROUP BY state
)
SELECT
    state,
    total,
    ROUND(closure_rate_pct, 1) AS closure_rate_pct,
    ROUND(AVG(closure_rate_pct) OVER (), 1) AS national_avg_pct,
    ROUND(closure_rate_pct - AVG(closure_rate_pct) OVER (), 1) AS diff_from_avg,
    RANK() OVER (ORDER BY closure_rate_pct DESC) AS risk_rank
FROM state_rates
ORDER BY risk_rank;


/* ------------------------------------------------------------
   QUERY 9: The master view for Power BI
   WHY: Rather than importing 8 separate pre-aggregated tables
        into Power BI, we import ONE clean, row-level view with
        all the bucket labels already attached, and let Power BI
        do the grouping/filtering/slicing itself. This is the
        single source of truth the whole dashboard connects to.
   ------------------------------------------------------------ */
CREATE VIEW restaurant_analysis AS
SELECT
    business_id,
    name,
    city,
    state,
    star,
    review_count,
    price_range,
    is_open,
    CASE WHEN is_open = 'f' THEN 1 ELSE 0 END AS is_closed,
    CASE
        WHEN star <= 1.5 THEN '1-1.5 (very low)'
        WHEN star <= 2.5 THEN '2-2.5 (low)'
        WHEN star <= 3.5 THEN '3-3.5 (mid)'
        WHEN star <= 4.5 THEN '4-4.5 (high)'
        ELSE '5 (top)'
    END AS star_bucket,
    NTILE(4) OVER (ORDER BY review_count) AS review_quartile
FROM restaurants_only;
