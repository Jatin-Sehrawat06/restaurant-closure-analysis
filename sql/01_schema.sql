/* ============================================================
   01_schema.sql
   Creates the base table that the cleaned Yelp business CSV
   is loaded into. Run this once, before loading data.

   NOTE: confirm the rating column name matches what your
   loader/notebook writes -- this project has used both `stars`
   and `star` across different files at different points.
   Pick one and use it consistently everywhere below.
   ============================================================ */

CREATE TABLE restaurants (
    business_id   VARCHAR(50) PRIMARY KEY,
    name          VARCHAR(500),
    city          VARCHAR(100),
    state         VARCHAR(10),
    stars         NUMERIC(2,1) CHECK (stars >= 1.0 AND stars <= 5.0),
    review_count  INT,
    is_open       BOOL,
    price_range   INT,
    categories    TEXT
);
