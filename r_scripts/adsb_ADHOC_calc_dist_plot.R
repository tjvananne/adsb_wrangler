

# 1) plot aircraft locations
# 2) Calculating distances and bearings
# 2.5) Calculate time based on the pos time
# 3) add these calculations to the plots in a creative way



#' I want to know where the aircraft is and what direction it is heading in. I then want to
#' map the specific marker I use to identify it's current location based on the direction it
#' is currently heading in (we know the next point because this is all historical data, no real 
#' time processing here.)
#' 
#' massive bonus points if we can control the color of the arrow icon based on altitude of the aircraft.
#' Black could be the aircraft on the ground, then gradually fade it up to maybe a bright red for high altitude.
#' 
#' Additional massive bonus points awarded if we can create a custom START / END marker point to indicate the 
#' total day's worth of activity. (Note how I said day and not trip, still figuring that out).




# 0 load data -------------------------------------------------------------

list.files('data/daily_agg/')
all_dat <- readRDS('data/daily_agg/all_daily_2017-08-17.rds')


# I did this within each individual minute, but it needs to be done again at the aggregate level
keycols <- paste(all_dat$Icao, all_dat$Reg, all_dat$Lat, all_dat$Long, all_dat$Alt, all_dat$Spd, sep='|')
all_dat <- all_dat[!duplicated(keycols), ]  # eliminates 6.6 million rows
gc()



# create the mapping of aircraft registration number, operator, and model of aircraft
unq_reg_op_mdl <- all_dat %>% select(Reg, Op, Mdl) %>% unique()


# identify the bell helicopters
bell_helis <- unq_reg_op_mdl[grepl(" bell ", unq_reg_op_mdl$Mdl, ignore.case = T) | # "bell" token on its own
                                 grepl("^bell ", unq_reg_op_mdl$Mdl, ignore.case = T) | # starts with "bell" then space
                                 grepl(" bell$", unq_reg_op_mdl$Mdl, ignore.case = T)   # space then ends with "bell"
                             , ]


# collect all data where the Registration number of the aircraft is found in our Bell aircraft dataset
all_dat_bell <- all_dat[all_dat$Reg %in% bell_helis$Reg, ]
gc()


# make PosTime numeric, generate some friendly character dates
all_dat_bell$PosTime <- as.numeric(all_dat_bell$PosTime)
all_dat_bell$date_gmt <- sapply(all_dat_bell$PosTime, postime_to_date)
all_dat_bell$date_cdt <- sapply(all_dat_bell$PosTime, postime_to_date, "America/Chicago")
gc()


# calculate time between points
all_dat_bell <- all_dat_bell %>%
    arrange(Reg, PosTime) %>%
    group_by(Reg) %>%
    mutate(lag_PosTime = lag(PosTime)) %>%
    mutate(time_diff_seconds = (PosTime - lag_PosTime) / (1000),
           time_diff_minutes = (PosTime - lag_PosTime) / (1000 * 60),
           time_diff_hours = (PosTime - lag_PosTime) / (1000 * 60 * 60))




# 1 basic plotting on a leaflet -------------------------------------------

library(leaflet)

bell_helis

this_rec <- which(bell_helis$Reg == "N419CF")
# this_rec <- 7
bell_helis[this_rec, ]


# bell_helis[1,]  # NYPD has a 429
# bell_helis[2,]  # CareFlight has a 429
# bell_helis[3,]  # Mercy One has a 429 (Iowa's version of careflight)


# top 10 most popular models?
# table(bell_helis$Mdl) %>% data.frame() %>% arrange(desc(Freq)) %>% top_n(10, Freq)



# isolate one of the Bell helicopters and pull in all of its records for this day
all_dat_sub <- all_dat_bell[all_dat_bell$Reg == bell_helis$Reg[this_rec], ]



nrow(all_dat_sub)


    all_dat_sub$Lat <- as.numeric(all_dat_sub$Lat)
    all_dat_sub$Long <- as.numeric(all_dat_sub$Long)
    all_dat_sub$Alt <- as.numeric(all_dat_sub$Alt)


# https://rstudio.github.io/leaflet/markers.html
all_dat_sub <- all_dat_sub %>% arrange(PosTime)
all_dat_sub$row_id <- as.character(1:nrow(all_dat_sub))

all_dat_sub2 <- all_dat_sub[(1:nrow(all_dat_sub)) %% 10 == 0 | all_dat_sub$row_id == '1', ]

library(leaflet)

# plot points
m <- leaflet( data = all_dat_sub) %>% addTiles() %>%
    addMarkers(lng = ~Long, lat = ~Lat, popup = ~row_id)

library(mapview)
mapshot(m, file=paste0("Bell_flight_points.png"))


# plot lines
leaflet(data=all_dat_sub) %>% addTiles() %>%
    addPolylines(lng=all_dat_sub$Long, lat=all_dat_sub$Lat)


?leaflet




