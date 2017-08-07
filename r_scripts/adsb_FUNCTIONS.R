

# R script function definitions
print("Loading in adsb_FUNCTIONS.R file...")




# Downloading a new file ----------------------------------------------------------------------------
    tv_download_zip <- function(p_date, p_dest_file, p_dest_filepath) {
        
        # build the url
        root_url <- "http://history.adsbexchange.com/Aircraftlist.json/" 
        if(is.na(lubridate::ymd(p_date))) { stop("tv_download_zip: 'p_date' should be in YYYY-MM-DD format") }
        full_url <- paste0(root_url, as.character(p_date), ".zip")
        
        
        # check if directory is set up properly -- if not then create it
        if(!dir.exists(p_dest_filepath)) { dir.create(p_dest_filepath, recursive = TRUE) }
        
        
        # remove contents of the staging file
        do.call(file.remove, list(list.files(p_dest_filepath, full.names = T)))
        
        
        # download the new zip file -- place in staging area
        download.file(full_url, destfile = paste0(GBL_ZIP_STAGE_DIR, GBL_ZIP_STAGE_FILE))
        
    }
    

    
    
    
    
# extract all selected columns from all aircraft json list -----------------------------------------------------
    tv_extract_json_multi_value <- function(p_aclist, p_colnamelist, p_jsonfilename="") {
        
        # captive function for extracting a single value from all aircraft records
        tv_extract_json_single_value <- function(p_aclist, p_colname) {
            this_p_colname <- ifelse(is.null(p_aclist[[p_colname]]), "", as.character(p_aclist[[p_colname]][[1]]))
        }
        
        
        # one time length calcs
        num_acs <- length(p_aclist)
        num_colnames <- length(p_colnamelist)
        
        # init space and set an index pointer
        initialized_space <- character(num_acs * num_colnames)
        ipointer <- 1
        
        
        for(i in 1:length(p_colnamelist)) {
            # for each colname, extract that single col, add it to our huge char vec, shift pointer
            temp <- sapply(p_aclist, tv_extract_json_single_value, p_colnamelist[[i]])
            length(initialized_space[ipointer:(ipointer + (length(p_aclist)) - 1)])
            initialized_space[ipointer:(ipointer + num_acs - 1)] <- temp
            ipointer <- ipointer + length(p_aclist)
        }
        
        print("Ok, we're done with the for loop!")
        
        # convert to char matrix from the char string, then dataframe, rename to original colnames
        charmat <- matrix(initialized_space, byrow=FALSE, ncol = num_colnames)
        datframe <- data.frame(charmat, stringsAsFactors = F)
        
        if(length(initialized_space) > 0) {
            names(datframe) <- p_colnamelist
            datframe['jsonfile'] <- p_jsonfilename
            return(datframe)
        }
        
         
    }
    
    
    
