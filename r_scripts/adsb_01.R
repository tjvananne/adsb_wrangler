


# ADSB Exchange -- first round of processing
# think of a better name than "_01" once we know what we're doing in here

#' 8/23/2017 notes:
#' If the files are too big to process in this manner, then we might need to
#' think about creating a convex hull list of points as we go and then maybe
#' trying to keep track of trips as we go also. Definitely keep track of the
#' total number of points per aircraft as well. Also keep checking the "is on ground"
#' flag as well, that should be a huge help when indicating helicopter "trips"

source("r_scripts/adsb_CONFIG.R")
source("r_scripts/adsb_FUNCTIONS.R")

    
# split into a "downloader" script and a "processor" script

# DOWNLOADER ----------------------------------------------------------------------


# download the big zip file:

    # # don't do this right now... takes too long
    # t0_start <- Sys.time()
    # tv_download_zip(GBL_ZIP_DATE, GBL_ZIP_STAGE_FILE, GBL_ZIP_STAGE_DIR)
    # t0_elapsed <- Sys.time() - t0_start



# PROCESSOR ------------------------------------------------------------------------


# try catch block isn't working - the error portion of the try-catch isn't saving
# the name of the file that produced an error

# "there was an error with this file: 2018-04-15-0356Z.json"
# [1] "here's the error message: Error in parse_con(txt, bigint_as_char): parse error: unallowed token at this point in JSON text\n          
# lgH\":20,\"flgW\":85,\"acList\":[ ,{\"Id\":8834817,\"Rcvr\":23092,\"Ha\n      



list.files("data/temp_staging")

# overwrite global config value with the name of the file we actually want to process
GBL_ZIP_STAGE_FILE  <- "2018-04-19.zip"
GBL_ZIP_DATE        <- "2018-04-19"

# data frame of all files in the zip:
staged_files <- unzip(paste0(GBL_ZIP_STAGE_DIR, GBL_ZIP_STAGE_FILE), list=TRUE)
numb_staged_files <- length(staged_files$Name)
list_of_dfs <- vector(mode="list", numb_staged_files)
error_json_files <- character(numb_staged_files)



t1_start <- Sys.time()

for(i in 1:numb_staged_files) {
# for(i in bad_file_indx) {
    
    print( paste0(round(i / numb_staged_files * 100, 2), " % complete..."))
    
    # this'll be a loop through the files in the zip right here:
    this_file <- staged_files$Name[i]
    print(this_file)  # for debugging only
    this_filename <- tools::file_path_sans_ext(this_file)
    this_filepath <- paste0(GBL_ZIP_STAGE_JSON_DIR, "/", this_file)
    
    
    # unzip the file into the global json staging area
    unzip(zipfile=paste0(GBL_ZIP_STAGE_DIR, GBL_ZIP_STAGE_FILE), files=this_file, exdir=GBL_ZIP_STAGE_JSON_DIR)
    
    
    # JSON can fail from this source, so wrap it in a tryCatch
    error_json_files[i] <- tryCatch(
        expr = {
            
            # read
            print('reading json')
            this_json_content <- jsonlite::read_json(this_filepath)
            dat <- this_json_content$acList
            
            print('extracting values')
            # setup which columns we're after and then extract the values from json:
            this <- tv_extract_json_multi_value(dat, GBL_COLS_TO_EXTRACT, this_filename)
            
                # TODO: add a few different preprocessing steps
                # this is where we'd want to do some daily convex hull
                # daily trip aggregation -- each of these should be a function
            
                # for now, just remove blanks in very key columns
                this <- this[
                    this$Lat != '' &
                    this$Long != '' &
                    this$Reg != ''
                ,]
            
                # remove if these key columns have been duplicated
                keycols <- paste(this$Icao, this$Reg, this$Lat, this$Long, this$Alt, this$Spd, sep='|')
                this <- this[!duplicated(keycols), ]
                
            
            
            # if it is a not-null dataframe, then add it to the list of data frames
            if((!is.null(this)) & is.data.frame(this)) {
                list_of_dfs[[i]] <- this    
            } else {
                list_of_dfs[i] <- NA
            }
            
            
            # to remove the file
            file.remove(paste0(GBL_ZIP_STAGE_JSON_DIR, "/", this_file))
            
        },
        
        error = function(cond) {
            print(paste0("there was an error with this file: ", this_file))
            print(paste0("here's the error message: ", cond))
            file.remove(paste0(GBL_ZIP_STAGE_JSON_DIR, "/", this_file))
            return(this_file)
        }
        #,
        
        # finally = {
        #     # this is the last thing in the for loop, so a next can go in the finally block
        #     next
        # }
    )
    
}

t1_elapsed <- Sys.time() - t1_start
print(t1_elapsed)


t2_start <- Sys.time()
print("combining the list of data frames into one...")
list_of_dfs <- list_of_dfs[!is.na(list_of_dfs)]
# all_dat <- do.call(rbind, list_of_dfs)
all_dat <- bind_rows(list_of_dfs)
t2_elapsed <- Sys.time() - t2_start
print(t2_elapsed)

# exploratory below here ------------------------------------------------------------------


if(!dir.exists("data/daily_agg")) {
    dir.create("data/daily_agg")    
}


error_json_files <- error_json_files[error_json_files != ""]
saveRDS(all_dat, paste0("data/daily_agg/all_daily_", GBL_ZIP_DATE, ".rds"))
saveRDS(error_json_files, paste0("data/daily_agg/error_reports/error_json_files_", GBL_ZIP_DATE, ".rds"))


