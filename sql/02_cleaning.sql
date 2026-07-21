/* ============================================================
   02_cleaning.sql
   Narrows the raw `restaurants` table (all business types) down
   to the final analysis dataset: restaurants only, U.S. states
   only, no low-sample noise states.
   ============================================================ */

-- Step 1: keep only rows tagged as restaurants
CREATE TABLE restaurants_only AS
SELECT *
FROM restaurants
WHERE categories LIKE '%Restaurants%';

ALTER TABLE restaurants_only
ADD PRIMARY KEY (business_id);

-- Step 2: remove Alberta (Canada) -- non-U.S. currency would
-- distort price-tier / rent-style comparisons
DELETE FROM restaurants_only
WHERE state = 'AB';

-- Step 3: remove any remaining states with fewer than 3 records
-- (stray/erroneous codes, not real geographic signal)
DELETE FROM restaurants_only
WHERE state IN (
    SELECT state
    FROM restaurants_only
    GROUP BY state
    HAVING COUNT(state) < 3
);

-- Step 4: sanity check -- should land at 49,853 rows / 13 states
SELECT COUNT(*) AS final_row_count FROM restaurants_only;
SELECT COUNT(DISTINCT state) AS state_count FROM restaurants_only;
