#' Get GDAS1 meteorology data files
#'
#' Downloads GDAS1 meteorology data files from the NOAA FTP server and saves
#' them to a specified folder. Files can be downloaded by specifying a list of
#' filenames (in the form of `"gdas1.{month-abbrev}{year-2}.w{wk-num}"`).
#'
#' @inheritParams hysplit_trajectory
#' @param path_met_files A full directory path to which the meteorological data
#'   files will be saved.
#'   
#' @export
get_met_gdas1 <- function(days,
                          duration,
                          direction,
                          path_met_files) {
  
  # Determine the minimum date (as a `Date`) for the model run
  if (direction == "backward") {
    min_date <- 
      (lubridate::as_date(days[1]) - (duration / 24)) %>%
      lubridate::floor_date(unit = "day")
  } else if (direction == "forward") {
    min_date <- 
      (lubridate::as_date(days[1])) %>%
      lubridate::floor_date(unit = "day")
  }
  
  # Determine the maximum date (as a `Date`) for the model run
  if (direction == "backward") {
    max_date <- 
      (lubridate::as_date(days[length(days)])) %>%
      lubridate::floor_date(unit = "day")
  } else if (direction == "forward") {
    max_date <- 
      (lubridate::as_date(days[length(days)]) + (duration / 24)) %>%
      lubridate::floor_date(unit = "day")
  }
  
  met_days <- 
    seq(min_date, max_date, by = "1 day") %>% 
    lubridate::day()
  
  month_names <- 
    seq(min_date, max_date, by = "1 day") %>%
    lubridate::month(label = TRUE, abbr = TRUE, locale = "en_US.UTF-8")  %>%
    as.character() %>%
    tolower()
  
  met_years <- 
    seq(min_date, max_date, by = "1 day") %>%
    lubridate::year() %>% 
    substr(3, 4)
  
  # Only consider the weeks of the month we need:
  #.w1 - days 1-7
  #.w2 - days 8-14
  #.w3 - days 15-21
  #.w4 - days 22-28
  #.w5 - days 29 - rest of the month 
  
  met_week <- ceiling(met_days / 7)
  
  files <- paste0("gdas1.", month_names, met_years, ".w", met_week) %>% unique()
  
  tryCatch({
    get_met_files(
      files = files,
      path_met_files = path_met_files,
      ftp_dir = "ftp://arlftp.arlhq.noaa.gov/archives/gdas1",
      force_update=T #Needed to get the current7days trick work,
    )},
    error=function(err){
      # A common error is when date is too recent and 
      # gdas compiled week file is not available.
      # In this case, we download latest temporary file offered by gdas1
      # named current7days
      if(abs(as.numeric(as.POSIXct(max_date)-Sys.time(), unit="days")) < 7){
        org_file <- files[length(files)]
        new_file <- "current7days"
        
        # Remove downloaded file if too old
        ctime <- file.info(file.path(path_met_files, "current7days"))$ctime
        if(!is.na(ctime) && as.numeric(Sys.time() - ctime, unit="hours") > 12){
          file.remove(file.path(path_met_files, "current7days"))
        }
        
        get_met_files(
          files = new_file,
          path_met_files = path_met_files,
          ftp_dir = "ftp://arlftp.arlhq.noaa.gov/archives/gdas1",
          force_update=T
        )
        
        #hysplit_std is expected the standard name gdas1.***
        file.remove(gsub("//", "/", file.path(path_met_files, org_file)))
        file.copy(file.path(path_met_files, new_file),
                    file.path(path_met_files, org_file)
                    )
      }
      return(files)
    })
}
