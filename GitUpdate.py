#! /usr/bin/python3

import os
import git

repo = git.Repo(os.getcwd())

repo.git.add("/home/randre/Code/weather_station/Data/station_obs.RDS")

repo.git.commit('-m', 'Updated weather obs with latest hourly reading.')

origin = repo.remote(name='origin')

origin.push()
