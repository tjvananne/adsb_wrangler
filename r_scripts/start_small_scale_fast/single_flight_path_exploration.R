


# explanation of fields 
# https://www.adsbexchange.com/datafields/
library(dplyr)

source("r_scripts/adsb_FUNCTIONS.R")


list.files("data/daily_agg/")
dat <- readRDS("data/daily_agg/all_daily_2018-04-15.rds")


names(dat)
table(dat$Mlat, dat$Species)  # 1 is land plane, 4 is helicopter, 5 is gyrocopter
table(dat$Mlat)


dat_sub <- dat[dat$Mlat == "FALSE", ]
dat_sub <- dat[dat$Species == "4", ]
gc()


dat_helitreck <- dat_sub[dat_sub$Op == "Helitreck", ]
dat_helitreck$date <- postime_to_date(dat_helitreck$PosTime)
dat_helitreck$date_milli <- paste0(as.character(dat_helitreck$date), ".", sprintf("%03d", as.numeric(dat_helitreck$PosTime) %% 1000))
sum(duplicated(dat_helitreck$date_milli))

dat_helitreck$Lat  <- as.numeric(dat_helitreck$Lat)
dat_helitreck$Long <- as.numeric(dat_helitreck$Long) 

dat_helitreck <- dat_helitreck[dat_helitreck$Icao == dat_helitreck$Icao[1], ] %>% arrange(PosTime)


# one thing we'll need to do is determine when a trip starts/stops if there are multiple per day...
getOption("scipen")
options("scipen"=999)
dat_helitreck$PosTime <- as.numeric(dat_helitreck$PosTime)
dat_helitreck$PosTime_lag <- dplyr::lag(dat_helitreck$PosTime)
dat_helitreck$minutes_since_last_read <- (dat_helitreck$PosTime - dat_helitreck$PosTime_lag) / 1000 / 60

# some type of logic to show a '1' if either we move on to a new ICAO/Reg/Op combo, or our threshold of # of minutes within trip is met
trip_limit_minute_threshold <- 60  # if 60 minutes pass without a reading, we'll assume they are two separate trips

dat_helitreck$trip_start <- as.integer(dat_helitreck$minutes_since_last_read >= trip_limit_minute_threshold)
dat_helitreck$trip_start[is.na(dat_helitreck$trip_start)] <- 1
dat_helitreck$trip_number <- cumsum(dat_helitreck$trip_start)

dat_helitreck <- dat_helitreck[dat_helitreck$trip_number == 1, ]

summary(dat_helitreck$minutes_since_last_read)


library(leaflet)

leaflet() %>% addTiles() %>%
    addPolylines(lng=dat_helitreck$Long, lat=dat_helitreck$Lat, weight=2) %>%
    leaflet::addCircles(lng=dat_helitreck$Long[1], lat=dat_helitreck$Lat[1], 
                        color="green", opacity=1, radius=200) %>%
    leaflet::addCircles(lng=dat_helitreck$Long[nrow(dat_helitreck)], lat=dat_helitreck$Lat[nrow(dat_helitreck)], 
                        color="red", opacity=1, radius=200)


library(fractaldim)
?fractaldim::fd.estim.boxcount()

#' trip features I'd be interested in capturing:
#'   - crows flight distance between start/end of trip
#'   - fractile dimension of the trip (how complex are the curves?)
#'   - convex hull of points in trip
#'   





    # dat_helitreck$duped <- as.integer(duplicated(dat_helitreck$PosTime))
    # dat_helitreck$duped_lead <- dplyr::lead(dat_helitreck$duped)
    # dat_helitreck$duped_lead2 <- dplyr::lead(dat_helitreck$duped, 2)
    # dat_helitreck_dupes <- dat_helitreck %>% filter(duped == 1 | duped_lead == 1 | duped_lead2 == 1)
    # dat_helitreck_dupes <- dat_helitreck_dupes %>% arrange(PosTime, duped_lead2, duped_lead, duped)

