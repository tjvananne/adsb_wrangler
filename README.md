# adsb_wrangler
This project is a data wrangler that collects and processes data from this free online resource: https://www.adsbexchange.com/

## Data Extraction / Collection


...


## Datashader Plots -- One Day at a Time

Each of the most recent days I've looked at have contained roughly 16,000,000 records of good Lat/Long values. This is impossible to plot using traditional methods found in base R, ggplot2, or matplotlib (unless you generalize into some form of heatmap).

**Plotting every flight path colored by a count of flight paths overlapping in that pixel bin:**

![adsb single day plot](docs/images/ds_adsb_001.png)


**Same plot but on a log scale:**

![adsb single day plot log scale](docs/images/ds_adsb_002.png)