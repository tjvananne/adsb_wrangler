

# workflow for ADSB-Exchange project

# home pc
setwd("C:/Users/Taylor/Documents/Nerd/adsb_exchange")


# source in the config file
source("r_scripts/adsb_CONFIG.R")


# source in the functions file
source("r_scripts/adsb_FUNCTIONS.R")


# not sure where to put this yet, but this'll be looped once we have a good process
# GBL_ZIP_DATE <- "2016-06-20"
GBL_ZIP_DATE <- "2017-07-30"



# 01) download and process the file, saving it as a daily aggregate RDS:
source("r_scripts/adsb_01.R")


