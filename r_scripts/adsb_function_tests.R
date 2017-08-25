


# function tests

#' this serves as both a testing mechanism to see if any functions are failing as well as
#' documentation to see how to run some of the more common functions in this project



# source in the config file and function definitions
source("r_scripts/adsb_CONFIG.R")
source("r_scripts/adsb_FUNCTIONS.R")


# testing "postime_to_date" function -------------------------------------------

    
    # pass in character
    postime_to_date("1502928031906")  # defaults to GMT
    postime_to_date("1502928031906", "America/Chicago")  # can change to "America/Chicago"
    
    
    # sapply
    postime_vector <- c("1502928031906", "1502928082290", "1502928092812")
    sapply(postime_vector, postime_to_date) 
    sapply(postime_vector, postime_to_date, "America/Chicago")
    
    
    # faster to pass in numeric values (and removes warnings)
    postime_num_vec <- as.numeric(postime_vector)
    sapply(postime_num_vec, postime_to_date)
    sapply(postime_vector, postime_to_date, "America/Chicago")    
    
    
    # using with lubridate:
    library(lubridate)
    lubridate::ymd(substr(postime_to_date(1502928031906), 1, 10))
    
        # for the above example, had to substring out the first 10 characters
        substr("2017-08-17 00:00:31", 1, 10)
    
        
    # WARNING: don't use ymd_hms... it will always think you're using "UTC" timezone...    
    lubridate::ymd_hms(postime_to_date(1502928031906))
    lubridate::ymd_hms(postime_to_date(1502928031906, "America/Chicago"))
    
    
    