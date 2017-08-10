

# adsb_02: for exploring a day's worth of data at a time to start figuring out 
# how we should start aggregating up to the "trip" level... Not sure how difficult
# that will be yet.


# real clean stuff ----------------------------------------------



# exploration ---------------------------------------------------


list.files()
list.files("data/daily_agg")
GBL_ZIP_DATE <- "2017-07-30" # just for exploration at first
all_dat <- readRDS(file=paste0("data/daily_agg/all_daily_", GBL_ZIP_DATE, ".rds"))

library(readr)
all_dat_csv <- readr::read_csv("data/daily_agg/all_daily_2017-07-30.csv")
readr::write_csv(all_dat_csv, "data/daily_agg/all_daily_2017-07-30_clean.csv")


# to get data into 'utf-8' for python
con<-file('data/daily_agg/all_daily_2017-07-30_clean.csv',encoding="UTF-8")
write.csv(all_dat_csv, file=con, row.names = F)



# temporary fix til we rerun the scraper thing:
all_dat$order_id <- 1:nrow(all_dat)


all_dat <- all_dat %>%
    dplyr::arrange(Icao, order_id)

sapply(all_dat, function(x) sum(x == "" | is.na(x)))


# summary stats for columns
all_dat_sum2 <- all_dat %>%
    dplyr::group_by(Icao) %>%
    dplyr::summarise(
        count = n(),
        NAs = sum(Lat == "NA")) %>%
    dplyr::mutate(
        percent_NA = round(NAs / count * 100, 2)
    )


# keep only the non-missing lat/long
all_dat_latlong <- all_dat %>%
    dplyr::filter(Lat != "" & Long != "" & Lat != '0' & Long != '0')

rm(all_dat); gc()

all_dat_latlong$Lat <- as.numeric(all_dat_latlong$Lat)
all_dat_latlong$Long <- as.numeric(all_dat_latlong$Long)

all_dat_latlong <- all_dat_latlong %>%
    dplyr::filter(Lat <= 90 & Lat >= -90 & !is.na(Lat)) %>%
    dplyr::filter(Long <= 180 & Long >= -180 & !is.na(Long))

hist(all_dat_latlong$Lat, col='light blue')
hist(all_dat_latlong$Long, col='light blue')

write.csv(all_dat_latlong, paste0('data/daily_agg/all_daily_', GBL_ZIP_DATE, '.csv'), row.names = F)
