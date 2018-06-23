


list.files("data/daily_agg/error_reports/")

errors416 <- readRDS("data/daily_agg/error_reports/error_json_files_2018-04-16.rds")

errors416[errors416 != 'TRUE']
badfile <- errors416[errors416 != 'TRUE'][1]


list.files("data/zips/2018-04-16.zip")

staged_files <- unzip("data/zips/2018-04-16.zip", list=TRUE)
sum(badfile %in% staged_files$Name)

unzip

