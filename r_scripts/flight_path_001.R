
library(dplyr)
library(rstudioapi)
library(jsonlite)
library(tidyjson)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

list.files('../input')
# unzip(zipfile = '../input/2017-03-08.zip', overwrite = F)


file <- list.files()[[5]]

file <- read_json(path=file)


dat <- attr(file, "JSON")[[1]]


    # flattened:
    stuff <- unlist(attr(file, "JSON"))
    stuff[1:100]

    
mymat <- as.matrix(unlist(dat[[9]]), ncol = 29)


# aclist <- dat[[9]] %>%
#     gather_array %>%
#     spread_values(
#         id = jstring("Id"),
#         operator = jstring("Op"),
#         icao = jstring("Icao"),
#         registration = jstring("Reg"),
#         model = jstring("Mdl"),
#         country = jstring("Cou")
#     )

length(dat[[9]])

test_dat <- dat[[9]]



data.frame(dat[[9]][[1]])

class(dat[[9]][[1]])

    # list_df <- function(l) {
    #     return(data.frame(l, stringsAsFactors = F))
    # }


class(dat[[9]])


acinfo <- dat[[9]]
    # list_of_dfs <- list()
    # for(i in 1:length(acinfo)) {
    #     print(i)
    #     temp <- data.frame(id=acinfo[[i]]$Id, op=acinfo[[i]]$Op, stringsAsFactors = F)
    #     
    #     if(ncol(temp) > 0 & nrow(temp) > 0) {
    #         list_of_dfs[[i]] <- temp
    #     }
    #     
    #     rm(temp)
    # }


x <- character(10000000)
sapply(acinfo, function(y) names(unlist(y)))

x <- names(unlist(acinfo))

calc_perc <- function(field, allfields, records) {
    return(sum(allfields == field) / length(records) * 100)
}


sum(x == 'Id') / length(acinfo) * 100


calc_perc('Id', x, acinfo)   # 100
calc_perc('Reg', x, acinfo)  # 91
calc_perc('Op', x, acinfo)   # 91



    # testing finding a non existent name on a list
    mytestlist <- list(name1 = 'name1value', name2 = 'name2value', name3 = 'name3value')
    mytestlist['name1']
    
    thisvarname <- 'name1'        
    mytestlist[thisvarname]    

     


fields_list <- sapply(unique(x), calc_perc, x, acinfo) %>% data.frame()
fields_list$fields <- row.names(fields_list)
names(fields_list) <- c('percent', 'fields')
fields_list <- arrange(fields_list, desc(percent))



data.frame(acinfo[[24]], stringsAsFactors = F)
names(acinfo[[2]])
names(acinfo[[24]])

    
alldfs <- lapply(dat[[9]], list_df)

alldfs <- sapply(dat[[9]], data.frame(), stringsAsFactors = F)

test_dat
class(test_dat)
