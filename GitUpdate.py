#! /usr/bin/python3

import git

repo = git.Repo("/home/randre/Code/weather_station")

repo.git.add("/home/randre/Code/weather_station/Data/station_obs.*")

repo.git.commit('-m', 'Updated weather obs with latest hourly reading.')

origin = repo.remote(name='origin')

origin.push()
