


# ADSB Exchange -- first round of processing
# think of a better name than "_01" once we know what we're doing in here


# split into a "downloader" script and a "processor" script

# DOWNLOADER ----------------------------------------------------------------------


# download the big zip file:

t0_start <- Sys.time()
tv_download_zip(GBL_ZIP_DATE, GBL_ZIP_STAGE_FILE, GBL_ZIP_STAGE_DIR)
t0_elapsed <- Sys.time() - t0_start



# PROCESSOR ------------------------------------------------------------------------

# data frame of all files in the zip:
staged_files <- unzip(paste0(GBL_ZIP_STAGE_DIR, GBL_ZIP_STAGE_FILE), list=TRUE)
numb_staged_files <- length(staged_files$Name)
list_of_dfs <- vector(mode="list", numb_staged_files)

t1_start <- Sys.time()

for(i in 1:numb_staged_files) {
    
    print( paste0(round(i / numb_staged_files * 100, 2), " % complete..."))
    
    # this'll be a loop through the files in the zip right here:
    this_file <- staged_files$Name[i]
    print(this_file)  # for debugging only
    this_filename <- tools::file_path_sans_ext(this_file)
    this_filepath <- paste0(GBL_ZIP_STAGE_JSON_DIR, "/", this_file)
    
    
    # unzip the file into the global json staging area
    unzip(zipfile=paste0(GBL_ZIP_STAGE_DIR, GBL_ZIP_STAGE_FILE), files=this_file, exdir=GBL_ZIP_STAGE_JSON_DIR)
    
    
    # JSON can fail from this source, so wrap it in a tryCatch
    tryCatch(
        expr = {
            
            # read
            print('reading json')
            this_json_content <- jsonlite::read_json(this_filepath)
            dat <- this_json_content$acList
            
            print('extracting values')
            # setup which columns we're after and then extract the values from json:
            this <- tv_extract_json_multi_value(dat, GBL_COLS_TO_EXTRACT, this_filename)
            
            
            # if it is a not-null dataframe, then add it to the list of data frames
            if((!is.null(this)) & is.data.frame(this)) {
                list_of_dfs[[i]] <- this    
            } else {
                list_of_dfs[i] <- NA
            }
            
            
            # to remove the file
            file.remove(paste0(GBL_ZIP_STAGE_JSON_DIR, "/", this_file))
            
        },
        
        finally = {
            # this is the last thing in the for loop, so a next can go in the finally block
            next
        }
    )
    
}

t1_elapsed <- Sys.time() - t1_start
print(t1_elapsed)


t2_start <- Sys.time()
list_of_dfs <- list_of_dfs[!is.na(list_of_dfs)]
all_dat <- do.call(rbind, list_of_dfs)
t2_elapsed <- Sys.time() - t2_start
print(t2_elapsed)

# exploratory below here ------------------------------------------------------------------


if(!dir.exists("data/daily_agg")) {
    dir.create("data/daily_agg")    
}

saveRDS(all_dat, paste0("data/daily_agg/all_daily_", GBL_ZIP_DATE, ".rds"))



