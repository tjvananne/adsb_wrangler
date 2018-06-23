

# evaluation of data

list.files("data/daily_agg/")

dat415 <- readRDS("data/daily_agg/all_daily_2018-04-15.rds")
# dat416 <- readRDS("data/daily_agg/all_daily_2018-04-16.rds")


# group by ICAO / Op (Operator) / Mdl (model)

library(data.table)
library(dplyr)


setDT(dat415)
names(dat415)

# Species of aircraft
# 0 = None
# 1 = Land Plane
# 2 = Sea Plane
# 3 = Amphibian
# 4 = Helicopter
# 5 = Gyrocopter
# 6 = Tiltwing
# 7 = Ground Vehicle
# 8 = Tower

x <- as.matrix(c(
    
))



dat415_summary <- dat415 %>%
    dplyr::group_by(Icao, Reg, Mdl, Op, Species) %>%
    dplyr::summarise(count=n()) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(desc(count))





