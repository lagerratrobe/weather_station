#! /usr/local/bin/Rscript

# UpdateStationObs.R

# Grabs the current weather obs and appends them to the running list

library(dplyr)
library(data.table)

source("/home/randre/Code/weather_station/R/GetWeatherData.R")

# Running set of obs
data_obs <- readRDS("/home/randre/Code/weather_station/Data/station_obs.RDS")

# Stations to pull data for
stations <- c('KTXDALLA724', 'KWASEATT2743', 'KWASEQUI431')

# Pull the current obs for each station and append it to the running list
for (id in stations) {
  current <- GetWeatherData(station_id = id, 
                            obs_type = "current") %>%
    select(-c(neighborhood,
              softwareType,
              country,
              realtimeFrequency,
              qcStatus,
              imperial.elev))
  data_obs <- rbind(data_obs, current)
}

saveRDS(data_obs, "/home/randre/Code/weather_station/Data/station_obs.RDS")
fwrite(data_obs, "/home/randre/Code/weather_station/Data/station_obs.CSV") 

system("echo `date` >> /home/randre/Code/weather_update.log")
