

# adsb_02: for exploring a day's worth of data at a time to start figuring out 
# how we should start aggregating up to the "trip" level... Not sure how difficult
# that will be yet.


# real clean stuff ----------------------------------------------



# exploration ---------------------------------------------------


list.files()
GBL_ZIP_DATE <- "2016-06-20" # just for exploration at first
all_dat1 <- readRDS(file=paste0("data/daily_agg/all_daily_2016-06-20.rds"))
all_dat2 <- readRDS(file=paste0("data/daily_agg/all_daily_2016-06-21.rds"))



# temporary fix til we rerun the scraper thing:
all_dat$order_id <- 1:nrow(all_dat)


# accidentally have two Lat's and two Long's, remove col 13 and 14 and we're good
all_dat2 <- all_dat[, c(c(1:12), 15:ncol(all_dat))]
all_dat <- all_dat2; rm(all_dat2)


all_dat <- all_dat %>%
    dplyr::arrange(Icao, order_id)


all_dat_sum2 <- all_dat %>%
    dplyr::group_by(Icao) %>%
    dplyr::summarise(
        count = n(),
        NAs = sum(Lat == "NA")) %>%
    dplyr::mutate(
        percent_NA = round(NAs / count * 100, 2)
    )


all_dat_latlong <- all_dat %>%
    dplyr::filter(Lat != "NA" & Long != "NA")

