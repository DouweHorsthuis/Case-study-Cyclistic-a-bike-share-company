---
title: 'Case Study: Cyclistic a bike share company. Using R'
author: "Douwe John Horsthuis"
date: "4/4/2022"
output: github_document 
---
  
```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE,warning=FALSE, message=FALSE)
```


``` sql
SELECT ride_id, rideable_type,started_at, ended_at, start_station_name, CAST(start_station_id AS STRING), end_station_name, CAST(end_station_id AS STRING), start_lat, start_lng, end_lat,end_lng,member_casual
FROM `cyclistic-a-bike-share-company.bikedata.data`
UNION ALL
SELECT ride_id, rideable_type,started_at, ended_at, start_station_name, CAST(start_station_id AS STRING), end_station_name, CAST(end_station_id AS STRING), start_lat, start_lng, end_lat,end_lng,member_casual
FROM `cyclistic-a-bike-share-company.bikedata.data_2020_08`
UNION ALL
SELECT ride_id, rideable_type,started_at, ended_at, start_station_name, CAST(start_station_id AS STRING), end_station_name, CAST(end_station_id AS STRING), start_lat, start_lng, end_lat,end_lng,member_casual
FROM `cyclistic-a-bike-share-company.bikedata.data_2020_10`
UNION ALL
SELECT ride_id, rideable_type,started_at, ended_at, start_station_name, CAST(start_station_id AS STRING), end_station_name, CAST(end_station_id AS STRING), start_lat, start_lng, end_lat,end_lng,member_casual
FROM `cyclistic-a-bike-share-company.bikedata.data_2020_11`
-- from here downwards we need to correct the int(s) that are string. since the will be more data eventually below, I updated the above to strings where needed
UNION ALL
SELECT *
FROM `cyclistic-a-bike-share-company.bikedata.data_2020_12`
UNION ALL
SELECT *
FROM `cyclistic-a-bike-share-company.bikedata.data_2021_01`
UNION ALL
SELECT *
FROM `cyclistic-a-bike-share-company.bikedata.data_2021_02`
UNION ALL
SELECT *
FROM `cyclistic-a-bike-share-company.bikedata.data_2021_03`

where -- double checking if there are null values

ride_id IS NOT NULL
AND rideable_type  IS NOT NULL
AND started_at  IS NOT NULL
AND ended_at  IS NOT NULL
AND start_station_name  IS NOT NULL --149 
AND start_station_id  IS NOT NULL
AND end_station_name  IS NOT NULL --1855
AND end_station_id  IS NOT NULL
AND member_casual IS NOT NULL

ORDER BY
started_at DESC
```

# loading library


library(knitr)

