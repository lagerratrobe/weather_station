# UpdateWeatherS3.R

# Gets data from Wunderground and writes it to an RDS stored in S3

library(dplyr)
library(httr)
library(jsonlite)
library(aws.s3)

####################### ---- API querying function ---- ########################
GetWeather <- function(
    station_id = NULL,
    api_key = '6532d6454b8aa370768e63d6ba5a832e' # public key (don't fret)
) {
  
  baseURL <- "https://api.weather.com/v2/pws/observations/current?"
  requestURL <- paste0(baseURL,
                       "stationId=",
                       station_id,
                       "&format=json",
                       "&units=e",
                       "&apiKey=",
                       api_key)
  
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
  
  return(observations)
  
}

###################### ---- S3 Bucket Data Logic ---- ########################

# Relies on the following environment variables being set 
#   AWS_ACCESS_KEY_ID                                
#   AWS_DEFAULT_REGION                               
#   AWS_SECRET_ACCESS_KEY  

# Uncomment to verify that the RDS exists in the bucket
# get_bucket("randre-weather-data")

# Read the existing RDS out of S3
obs_df <- s3readRDS(object = "weather_station_obs.RDS", 
                    bucket = "randre-weather-data")

# Stations of interest
# 'KTXDALLA724' = Dallas, TX
# 'KWASEATT2743' = Seattle, WA (my house)
stations <- c('KTXDALLA724', 'KWASEATT2743')

# Get a weather reading for each station and add it to the obs_df
for (id in stations) {
  obs_df <- rbind(obs_df, GetWeather(id))
}

# Save the updated RDS
s3saveRDS(x = obs_df, 
          object =  "weather_station_obs.RDS",
          bucket = "randre-weather-data",
          compress = TRUE)
