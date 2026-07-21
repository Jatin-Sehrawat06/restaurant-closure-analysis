### __Restaurant Closure Analysis__

A SQL and Power BI case study exploring which factors are associated with restaurant closures in the United States.

## Project overview
This project analyzes data from the Yelp Open Dataset to answer one core business question:

What factors are associated with a restaurant being closed rather than open?

Using restaurant listing data, the analysis examines the relationship between closure status and:

-> Star rating
-> Price range
-> Review volume
-> Geographic location
-> Combined price and rating risk
The project follows an end-to-end analytics workflow: extracting a large raw dataset with Python, cleaning and loading it into PostgreSQL, conducting SQL analysis, and presenting the results in an interactive Power BI dashboard.

## Key findings

- **Review volume is the strongest single predictor of closure** — restaurants in the bottom quartile of review counts close at 44.5%, more than double the 20.8% rate in the top quartile.
- **Mid-rated restaurants close more than poorly-rated ones.** 3–3.5-star restaurants close at 39.1% — the highest rate of any rating band — compared to 20.2% for 1–1.5-star restaurants. Being unremarkable predicts closure more strongly than being bad.
- **Price and rating combine.** Cheap, poorly-rated restaurants survive reasonably well (15.4% closure); expensive, average-rated restaurants are the highest-risk segment in the dataset (58–68% closure at the $$$ tier for 2–3.5-star restaurants).
- **Geography matters.** California shows the highest closure rate (42.5%); Pennsylvania, Missouri, Nevada, and Louisiana all run above the 32.4% average-across-states baseline.

Full findings, methodology, and limitations: [`Restaurant_Closure_Analysis_Report.pdf`](Restaurant_Closure_Analysis_Report.pdf)

## Data source
The source data is the Yelp Open Dataset, specifically the business.json file.

**Get the data.** Download the [Yelp Open Dataset](https://business.yelp.com/data/resources/open-dataset/) (`business.json`, inside the full archive). Raw data isn't committed to this repo — Yelp's terms don't permit redistribution.

The original dataset is large, approximately 5 GB when downloaded as an archive. 

## Known limitations

- **`is_open` is a single snapshot**, not a time series. This dataset supports *correlation* with closure status at one point in time, not a true survival/prediction model.
- **`price_range` is partially imputed.** Rows missing a price tag in the source data default to `2` rather than being left null — this was a deliberate simplification, but it means the $$ tier is somewhat inflated relative to true pricing.
- **Geographic coverage is uneven.** 13 states are represented, but sample sizes range from under 1,000 restaurants (e.g. IL, DE) to over 12,000 (PA) — state-level comparisons should be read with sample size in mind.

## License

Code in this repository is MIT licensed. The underlying restaurant data is subject to [Yelp's Open Dataset license](https://business.yelp.com/data/resources/open-dataset/) and is not redistributed here.
