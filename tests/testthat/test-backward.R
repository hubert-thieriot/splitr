
test_that("the backward approach works", {
  
  dir_hysplit_met <- Sys.getenv("DIR_HYSPLIT_MET")
  dir_hysplit_output <- tempdir()
  
  # Lahore
  lat=31.56008
  lon=74.33589
  height=500
  date_utc = as.POSIXct("2021-01-04 UTC")
  duration_sampling = 4#24
  duration_hour = 24 #72
  
  start_sampling = date_utc
  end_sampling = date_utc + lubridate::hours(duration_sampling)
  end_simulation = end_sampling
  start_simulation = start_sampling - lubridate::hours(duration_hour)
  met_type = "gdas1"
  
  d <- splitr::create_dispersion_model() %>%
    # Source = receptor since we'll use 'backward' direction
    splitr::add_source(
      name = "particle",
      lat = lat, lon = lon, height = height,
      
      # Release dates need to be reversed!!
      # Splitr doesn't generate proper control file otherwise
      # see https://www.ready.noaa.gov/documents/Tutorial/html/src_back.html
      release_start = start_sampling,
      release_end = end_sampling, #We receive particles for 24h
      
      # Receptor factors (taken from https://acp.copernicus.org/articles/20/10259/2020/)
      rate = 1, # mass units per hour
      pdiam = 0.8, # particle diameter in µm
      density = 2, #g/cm3
      shape_factor = 0.8,
    ) %>%
    splitr::add_dispersion_params(
      start_time = start_simulation, #Trace them back for n hours
      #not the real end_time since we're going backward: end-start will be used and retracted to start in splitr
      end_time = end_simulation,
      direction = "backward", #When using backward, duration will have a minus sign in front.
      met_type = met_type,
      met_dir =dir_hysplit_met,
      exec_dir = dir_hysplit_output,
      clean_up = F
    ) %>%
    splitr::run_model()
  
})