# Data Dictionary

Final analysis table: `restaurants_only` (49,853 rows, 13 U.S. states, 903 cities)

| Column | Type | Description |
|---|---|---|
| `business_id` | varchar(50), PK | Unique Yelp business identifier |
| `name` | varchar(500) | Restaurant name |
| `city` | varchar(100) | City |
| `state` | varchar(10) | Two-letter U.S. state code |
| `stars` | numeric(2,1) | Average star rating, 1.0–5.0 |
| `review_count` | int | Total number of Yelp reviews |
| `is_open` | bool | `true` = open, `false` = closed, as of the dataset snapshot date |
| `price_range` | int | 1 ($) to 4 ($$$$); defaults to 2 when not present in the source `attributes` field |
| `categories` | text | Raw Yelp category tags (used to filter to restaurants; not otherwise parsed in this analysis) |

## Known limitations

- **`is_open` is a single snapshot**, not a time series. This dataset supports *correlation* with closure status at one point in time, not a true survival/prediction model.
- **`price_range` is partially imputed.** Rows missing a price tag in the source data default to `2` ($$) rather than being left null — this was a deliberate simplification, but it means the $$ tier is somewhat inflated relative to true pricing.
- **Geographic coverage is uneven.** 13 states are represented, but sample sizes range from under 1,000 restaurants (e.g. IL, DE) to over 12,000 (PA) — state-level comparisons should be read with sample size in mind.
