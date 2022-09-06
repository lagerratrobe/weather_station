#! /usr/local/bin/Rscript

# GetWeatherData.R

# Requests data for a specific PWS from Wunderground.com API

# Get the last 7 days of hourly readings for a station
# https://api.weather.com/v2/pws/observations/hourly/7day?stationId=KMAHANOV10&format=json&units=e&apiKey=yourApiKey

# Get Current conditions
#https://api.weather.com/v2/pws/observations/current?stationId=KWASEATT2743&format=json&units=e&apiKey=74227eb901174f2ba27eb90117ef2bde

library(dplyr)
library(httr)
library(jsonlite)

GetWeatherData <- function(
    station_id = NULL,
    obs_type = "current"
) {
  
  if (obs_type == "current") {
    date_range <- "current?"
  } else if (obs_type == "7day") {
    date_range <- "hourly/7day?"
  }
  
  api_key = Sys.getenv("WUNDERGROUND_KEY")
  baseURL <- "https://api.weather.com/v2/pws/observations/"
  
  requestURL <- paste0(baseURL,
                       date_range,
                       "stationId=",
                       station_id,
                       "&format=json",
                       "&units=e",
                       "&apiKey=",
                       api_key)
  print(requestURL)
  # Make the actual request to the API
  response <- httr::GET(requestURL)
  # Get the Status of the request
  status <- httr::http_status(response)
  # Get data
  if (status$message == "Success: (200) OK") {
    # Convert to JSON
    response_json <- httr::content(response, "text", encoding = "UTF-8")
    
    # Convert JSON into list object that we can separate and parse
    response_data <- jsonlite::fromJSON(response_json,
                                        simplifyVector = TRUE,
                                        flatten = TRUE)
    observations <- response_data$observations
  }
  
}

