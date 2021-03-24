
test_that("the current7days approach works", {
  
  dir_hysplit_met <- Sys.getenv("DIR_HYSPLIT_MET")
  dir_hysplit_output <- tempdir() # Important so that several computaitons can be ran simultaneously!!
  
  tryCatch({
  t <- splitr::hysplit_trajectory(
    lat = 40,
    lon = 116,
    height = 500,
    duration = 24,
    days = lubridate::today()-7,
    daily_hours = 0,
    direction = "backward",
    met_type = "gdas1",
    met_dir = dir_hysplit_met,
    exec_dir = dir_hysplit_output,
    clean_up = TRUE)
  })
  
})

