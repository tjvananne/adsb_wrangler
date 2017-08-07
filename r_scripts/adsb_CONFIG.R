


# R script config

library(RCurl)
library(lubridate)
library(dplyr)
library(tidyjson)
library(jsonlite)

print("running adsb_CONFIG.R code...")


GBL_JSON_BATCH_SIZE <- 5
GBL_ZIP_STAGE_DIR <- "data/temp_staging/"
GBL_ZIP_STAGE_JSON_DIR <- "data/temp_staging/jsonfiles"  # unzip doesn't like slashes on the end of the dir name
GBL_ZIP_STAGE_FILE <- "temp_zip.zip"


GBL_COLS_TO_EXTRACT <- c("Id", "Icao", "Rcvr", "Lat", "Long", "Reg", "Fseen", "Tsecs", "Cmsgs", "Alt",
                         "Galt", "AltT", "PosTime", "Mlat", "Spd", "SpdTyp", "Trak", "TrkH",
                         "Type", "Mdl", "Man", "Year", "Cnum", "Op", "OpIcao", "Sqk", "Vsi", "VsiT", "WTC",
                         "Species", "EngType", "Mil", "Cou", "Call", "Talt", "Ttrk")
