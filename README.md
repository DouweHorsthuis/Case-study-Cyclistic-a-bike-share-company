---
title: 'Case Study: Cyclistic a bike share company. Using R'
author: "Douwe John Horsthuis"
date: "5/16/2022"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
options(scipen = 100)
```

# Cyclistic bike-share 
  
![](https://github.com/DouweHorsthuis/Case-study-Cyclistic-a-bike-share-company/blob/main/images/logo.PNG)  

## Case study by [Douwe Horsthuis](https://github.com/DouweHorsthuis) for the Google Data Analytics Capstone  
For this case study I am looking at data from a fictional company, Cyclistic, and I will try to answer questions based on their openly available data that can be found [here](https://divvy-tripdata.s3.amazonaws.com/index.html)

## steps taken before this using R
1 - download the last 12 months worth of data
2 - unzip all the excel files so they can be uploaded into an sql database (bigquery)
3 - 202009-divvy-tripdata does not work
4- realized it doesn't work quickly so instead use google drive to upload it both for space purposes and speed
5- create a sql statement to get the data
6- made sure that old and new data have the same data types by updating the old datatypes so that new datasets can be added easily.
```{r packages & library, warning=FALSE}
#install.packages("bigrquery")
library(bigrquery)
library(readr) #for csv
library(knitr) #for kable
library(dplyr) #for basic stuff like count
library(Hmisc) #great library for describing dataframes with strings 
library(pastecs) # to get some easy statistics
library(gridExtra)#for plotting plots in a grid
library(grid)
library(ggplot2)#plots
library(lubridate)#for speeding up data as date (4.1X quicker on my laptop)
library(tidyverse)#general aesthetics 
library(sf)#for maps
library(ggmap)#googlemaps
library(viridis)#colors for heat map
```

It's possible to get the dataset directly from google's bigquery. Using the code below. However I personally prefer using the csv file. So 

```{r using sql to load data, eval=FALSE, include=FALSE}
db <- dbConnect(
  bigquery(), 
  dataset = 'cyclistic-a-bike-share-company.bikedata.combined data', 
  project = 'cyclistic-a-bike-share-company', 
  use_legacy_sql = FALSE
)
```
```{sql eval=FALSE, connection=db, include=FALSE, output.var=}
--# Store the project ID
projectid = "cyclistic-a-bike-share-company"

--# Set your query
sql <- SELECT * FROM "cyclistic-a-bike-share-company.bikedata.combined data"

--# Run the query and store the data in a tibble
tb <- bq_project_query(projectid, sql)

--# Print 10 rows of the data
bq_table_download(tb, n_max = 10)
```

```{r Loading csv file, include=FALSE}
data    <- read_csv("data/sql_query_all.csv")
```

```{r first look at the data, echo=TRUE, results=}
kable(head(data))
length(unique(data$ride_id))
unique(data$rideable_type)
length(unique(data$start_station_name))
length(unique(data$f0_))
length(unique(data$end_station_name))
length(unique(data$f1_))
unique(data$member_casual)
```
Because length(unique(data$ride_id)) == the full length of the data, we now know that every ride is unique and that there is no ID number for individual members in this data. We now know that there are 3 types of transportation "docked_bike"   "electric_bike" "classic_bike".
We know that `length(unique(data$start_station_name))`==`length(unique(data$end_station_name))`==705 , but that both f0 and f1 are not the same length and not the same as eachoter. Because of the we leave the ID alone 

# questions about the data
1. How do annual members and casual riders use Cyclistic bikes differently?
2. Why would casual riders buy Cyclistic annual memberships?
3. How can Cyclistic use digital media to influence casual riders to become members?

## How to answer the questions / can we answers the questiosn with the current data
1. split the data in 2 groups see if there are different trends 
2. see if there is something that is the difference that causes people to be in one group or another
3. not sure if answerable with the current data.

# perpairing the data  
  
To prepare the data there are some things we need to do before we can create 2 subgroups.
1. the dates are in the wrong class. 
2. there is no ride length 
3. TBD 

```{r Preparing the data, include=FALSE}
data$start_date<-ymd_hms(data$started_at)# so it is usable as yyyy-mm-dd hh:mm:ss
data$end_date<-ymd_hms(data$ended_at)
data$ride_length<-round(difftime(data$end_date,data$start_date, units = "min")) #creating the difference in minutes
#splitting the data into 2 data frames
data_casual<-subset(data, member_casual=="casual")
data_member<-subset(data, member_casual=="member")
```

## describing the data after creating the 2 groups
```{r summary stats, echo=TRUE}
cat("These are the casual riders\n\n\n\n")
describe(data_casual$rideable_type)
describe(data_casual$start_station_name)
describe(data_casual$end_station_name)
summary(data_casual$ride_length)
stat.desc(data_casual$ride_length)

cat("\n\nThese are the members\n\n\n\n")
describe(data_member$rideable_type)
describe(data_member$start_station_name)
describe(data_member$end_station_name)
summary(data_member$ride_length)
stat.desc(data_member$ride_length)
```
of interest:
1. for both groups the dock_bike is the most used by far (69% & 79%)
2. Both group have the same most used starts/stops and least used starts/stops.
3. There are minus times (in minutes) and the max time is 58720 minuts == 978 hours == 40 days
    - option 1 - get rid of all minus rides and outliers 
    - option 2 - get rid of all minus riders but leave positive
    - option 3 - leave all but see how many of these exist
4. the mean (11.2/44.34) and median (12/22) are very different for (members/casual)

We are looking how much each group wrote
```{r by time, echo=TRUE}
#first organize date by month 
data_casual$start_date<-as.Date(data_casual$start_date,format="%Y-%m-%d")
data_casual$ones<-1
data_casual_grouped <- data_casual %>%
  group_by(start_date, rideable_type) %>%
  summarise(ones=sum(ones))

data_member$start_date<-as.Date(data_member$start_date,format="%Y-%m-%d")
data_member$ones<-1
data_member_grouped <- data_member %>%
  group_by(start_date, rideable_type) %>%
  summarise(ones=sum(ones))




fig1<- ggplot(data=data_casual_grouped, aes(x=start_date, y=ones, color=rideable_type))+
  labs(x = "Time", y = "Amount of rides", title = "Casual Riders", color="Types of Bikes") +
  geom_point()+
  geom_smooth()+
  ylim(0,10000)+
  scale_color_manual(labels = c("Classic bike", "Docked bike", "Electric Bike"), values = c("green", "red", "blue"))


fig2<- ggplot(data=data_member_grouped, aes(x=start_date, y=ones, color=rideable_type))+
    labs(x = "Time", y = "Amount of rides", title = "Members", color="Types of Bikes") +
  geom_point()+
  geom_smooth()+
  ylim(0,10000)+
  scale_color_manual(labels = c("Classic bike", "Docked bike", "Electric Bike"), values = c("green", "red", "blue"))

grid.arrange(fig1,fig2,top=textGrob("Amount of rides per date", gp=gpar(fontsize=20,font=8)))
  
```
We see here an issue, it seems like docked bikes are not existing after a certain date. When looking into the data, and figuring out how this could be the case, it seems like the company changed the name docked_bike to classic_bike. So we need to combine these

But first we are going to try to find out more about the outliers for this we plot them using the boxplot function
```{r looking for outlier, echo=TRUE}
boxplot(data_member$ride_length)
boxplot(data_casual$ride_length)
```
We see that both groups have only a few negative outlier and a bunch of positive ones. Before deleting them I want to take a look at a couple of specific once, just to see if there there isn't just a mistake of oversight on my part. 

We see that the people that have minus time, this has to be wrong. It's outside of the scope of this case study, but when looking at the data it was clear that they all had similar dates (2020-12-15). We are getting rid of them. We also noticed that there are a lot of people with a ride length of 0-3 minutes that have a start and end point at the same station. In this case, it might be people who had an issue with the bike or for whatever reason didn't end up taking it. Since these people won't give us insight in the behavior of both groups we also get rid of them.

Found a mistake, a lot of the extreme values did not have an end station but did have a start station. This meant that I made a mistake in the SQL query I originally did. Because of that, I reviewed the code and found the mistake, and fixed it. Because of that we are reloading the data and running all the cleaning code we created again. We use `rm(list = ls())` for the cleaning so we do not need to reinstall the packages

```{r redoing all}
rm(list = ls()) #clearing everything but packages
data    <- read_csv("data/sql_query_all_updated.csv")

```



```{r first look at the updated data, eval=FALSE, include=FALSE, results=}
kable(head(data))
length(unique(data$ride_id))
unique(data$rideable_type)
length(unique(data$start_station_name))
length(unique(data$start_station_id))
length(unique(data$end_station_name))
length(unique(data$end_station_id))
unique(data$member_casual)
```
Nothing changed except as expected the total amount of rides decreased , which means that we can run the rest of the code.
```{r Preparing the data 2}
data$start_date<-ymd_hms(data$started_at) # so it is usable as yyyy-mm-dd hh:mm:ss
data$end_date<-ymd_hms(data$ended_at)
data$ride_length<-round(difftime(data$end_date,data$start_date, units = "min")) #creating the difference in minutes
#getting rid of the negative numbers
data <- filter(data, ride_length > -0.01)
data <- filter(data, start_station_name!=end_station_name)

## combining classic and docked
data$rt<-NA
data$rt[data$rideable_type=="docked_bike"]<-"classic_bike"
data$rt[data$rideable_type=="classic_bike"]<-"classic_bike"
data$rt[data$rideable_type=="electric_bike"]<-"electric_bike"
data$rideable_type=data$rt
data=subset(data, select = -c(rt) )
#splitting the data into 2 data frames
data_casual              <-subset(data, member_casual=="casual")
data_casual_electric_bike<-subset(data_casual, rideable_type=="electric_bike")
data_casual_classic_bike <-subset(data_casual, rideable_type=="classic_bike")
data_member              <-subset(data, member_casual=="member")
data_member_electric_bike<-subset(data_member, rideable_type=="electric_bike")
data_member_classic_bike <-subset(data_member, rideable_type=="classic_bike")
cat("These are the casual riders electric bike\n start stations \n\n\n\n")
describe(data_casual_electric_bike$start_station_name)
cat("These are the casual riders electric bike\n end stations \n\n\n\n")
describe(data_casual_electric_bike$end_station_name)
cat("These are the casual riders electric bike\n ride length \n\n\n\n")
stat.desc(data_casual_electric_bike$ride_length)
cat("These are the casual riders classic bike\n start stations \n\n\n\n")
describe(data_casual_classic_bike$start_station_name)
cat("These are the casual riders classic bike\n end stations \n\n\n\n")
describe(data_casual_classic_bike$end_station_name)
cat("These are the casual riders classic bike\n ride length \n\n\n\n")
stat.desc(data_casual_classic_bike$ride_length)

cat("These are the member electric bike\n start stations \n\n\n\n")
describe(data_member_electric_bike$start_station_name)
cat("These are the member electric bike\n end stations \n\n\n\n")
describe(data_member_electric_bike$end_station_name)
cat("These are the member electric bike\n ride length \n\n\n\n")
stat.desc(data_member_electric_bike$ride_length)
cat("These are the member classic bike\n start stations \n\n\n\n")
describe(data_member_classic_bike$start_station_name)
cat("These are the member classic bike\n end stations \n\n\n\n")
describe(data_member_classic_bike$end_station_name)
cat("These are the member classic bike\n ride length \n\n\n\n")
stat.desc(data_member_classic_bike$ride_length)
```
The same here, nothing changed a lot so we still want to look at the same data. 
When thinking more about outliers, I am not sure if we want to just exclude them. So instead we are are leaving the code here, but we are only excluding people that took a bike out for over 12hours. Since it would be very unlikely that they are using 1 bike for that long. Unfortunately there is no way of seeing if there was a complaint about unable to dock a bike. 
```{r looking at the data separated}
#first boxplot 
fig1<-ggplot(data_casual, aes( y = ride_length, x = rideable_type, fill=rideable_type)) +            # Applying ggplot function
  geom_boxplot() +
  ggtitle("Casual Riders") +# for the main title
  xlab("types of bikes") +# for the x axis label
  ylab("Bike ride in minutes")+ 
  scale_fill_discrete(name = "Type of bike", labels = c("Classic", "Electric"))
fig2<-ggplot(data_member, aes( y = ride_length, x = rideable_type, fill=rideable_type)) +            # Applying ggplot function
  geom_boxplot()+
  ggtitle("Members") +# for the main title
  xlab("types of bikes") +# for the x axis label
  ylab("Bike ride in minutes")+ 
  scale_fill_discrete(name = "Type of bike", labels = c("Classic", "Electric"))


# outliers_c_cb <- boxplot(data_casual_classic_bike$ride_length, plot=FALSE)$out #cb=classic bike
# outliers_c_cb <- data_casual_classic_bike[which(data_casual_classic_bike$ride_length %in% outliers_c_cb),]
# data_casual <-data_casual[-which(data_casual$ride_id %in% outliers_c_cb$ride_id),]
# 
# outliers_c_eb <- boxplot(data_casual_electric_bike$ride_length, plot=FALSE)$out #eb=electric bike
# outliers_c_eb <- data_casual_electric_bike[which(data_casual_electric_bike$ride_length %in% outliers_c_eb),]
# data_casual <-data_casual[-which(data_casual$ride_id %in% outliers_c_eb$ride_id),]
# 
# outliers_m_cb <- boxplot(data_member_classic_bike$ride_length, plot=FALSE)$out #cb=classic bike
# outliers_m_cb <- data_member_classic_bike[which(data_member_classic_bike$ride_length %in% outliers_m_cb),]
# data_member<-data_member[-which(data_member$ride_id %in% outliers_m_cb$ride_id),]
# 
# outliers_m_eb <- boxplot(data_member_electric_bike$ride_length, plot=FALSE)$out #eb=electric bike
# outliers_m_eb <- data_member_electric_bike[which(data_member_electric_bike$ride_length %in% outliers_m_eb),]
# data_member <-data_member[-which(data_member$ride_id %in% outliers_m_eb$ride_id),]


data <- filter(data, ride_length < 720)#720=12hoursx60=amount of minutes in 12 hours
#splitting the data into 2 data frames
data_casual              <-subset(data, member_casual=="casual")
data_casual_electric_bike<-subset(data_casual, rideable_type=="electric_bike")
data_casual_classic_bike <-subset(data_casual, rideable_type=="classic_bike")
data_member              <-subset(data, member_casual=="member")
data_member_electric_bike<-subset(data_member, rideable_type=="electric_bike")
data_member_classic_bike <-subset(data_member, rideable_type=="classic_bike")
#second boxplot 
fig3<-ggplot(data_casual, aes( y = ride_length, x = rideable_type, fill=rideable_type)) +            # Applying ggplot function
  geom_violin() +
  geom_boxplot(width=0.1)+
  ylim(0, 45)+
  theme(axis.text.x = element_blank())+
  ggtitle("Casual Riders") +# for the main title
  xlab("types of bikes") +# for the x axis label
  ylab("Bike ride in minutes")+ 
  scale_fill_discrete(name = "Type of bike", labels = c("Classic", "Electric"))
fig4<-ggplot(data_member, aes( y = ride_length, x = rideable_type, fill=rideable_type)) +            # Applying ggplot function
  geom_violin()+
  ylim(0, 45)+
  geom_boxplot(width=0.1)+
  theme(axis.text.x = element_blank())+
  ggtitle("Members") +# for the main title
  xlab("types of bikes") +# for the x axis label
  ylab("Bike ride in minutes") + 
  scale_fill_discrete(name = "Type of bike", labels = c("Classic", "Electric"))


grid.arrange(fig1, fig2,ncol=2,top="Comparing both groups \nincluding 12+ hour bike rides")
grid.arrange(fig3, fig4,ncol=2,top="Comparing both groups \nexcluding 12+ hour bike rides")
```
# Back to the questions:
1. split the data in 2 groups see if there are different averages 
  a. We see that there are both groups have very different means, this tells us something about that members use the bikes for shorter trips (median). 
2. see if there is something that is the difference that causes people to be in one group or another
3. not sure if answerable with the current data.


# creating a map 
first things to do is create separate data structures for different `rideable_types`
second thing plot it by month (it probably will take way too long if it's in one go, and it makes it updateable)

```{r plotting out map}
## Make sure to register and activate the google maps key 
#register_google(key = "xxx", write = TRUE) #(replaced it with xxx since it's personal)
map_ch <-get_map("chicago illinois", zoom = 12,maptype = 'satellite')
#creating individual maps
#classic 
fig5<-ggmap(map_ch) +
  stat_density2d(data = data_casual_classic_bike, aes(x = start_lng, y = start_lat, fill = ..density..), geom = 'tile', contour = F, alpha = .5)+
  scale_fill_viridis(option = 'inferno')+
  scale_fill_viridis_c(limits = c(0, 1000))+
  labs(title = str_c('start point'))+
  theme(text = element_text(color = "#444444")
        ,plot.title = element_text(size = 12, face = 'bold')
        ,plot.subtitle = element_text(size = 12)
        ,axis.text = element_blank()
        ,axis.title = element_blank()
        ,axis.ticks = element_blank()
        ) +
  guides(fill = guide_legend(override.aes= list(alpha = 1)))

fig6<-ggmap(map_ch) +
  stat_density2d(data = data_casual_classic_bike, aes(x = end_lng, y = end_lat, fill = ..density..), geom = 'tile', contour = F, alpha = .5)+
  scale_fill_viridis(option = 'inferno')+
  scale_fill_viridis_c(limits = c(0, 1000))+  
  labs(title = str_c('end point'))+
  theme(text = element_text(color = "#444444")
        ,plot.title = element_text(size = 12, face = 'bold')
        ,plot.subtitle = element_text(size = 12)
        ,axis.text = element_blank()
        ,axis.title = element_blank()
        ,axis.ticks = element_blank()
        ) +
  guides(fill = guide_legend(override.aes= list(alpha = 1)))

#electric
fig7<-ggmap(map_ch) +
  stat_density2d(data = data_casual_electric_bike, aes(x = start_lng, y = start_lat, fill = ..density..), geom = 'tile', contour = F, alpha = .5)+
  scale_fill_viridis(option = 'inferno')+
  scale_fill_viridis_c(limits = c(0, 1000))+  
  labs(title = str_c('start point'))+
  theme(text = element_text(color = "#444444")
        ,plot.title = element_text(size = 12, face = 'bold')
        ,plot.subtitle = element_text(size = 12)
        ,axis.text = element_blank()
        ,axis.title = element_blank()
        ,axis.ticks = element_blank()
        ) +
  guides(fill = guide_legend(override.aes= list(alpha = 1)))
fig8<-ggmap(map_ch) +
  stat_density2d(data = data_casual_electric_bike, aes(x = end_lng, y = end_lat, fill = ..density..), geom = 'tile', contour = F, alpha = .5)+
  scale_fill_viridis(option = 'inferno')+
  scale_fill_viridis_c(limits = c(0, 1000))+  
  labs(title = str_c('end point'))+
  theme(text = element_text(color = "#444444")
        ,plot.title = element_text(size = 12, face = 'bold')
        ,plot.subtitle = element_text(size = 12)
        ,axis.text = element_blank()
        ,axis.title = element_blank()
        ,axis.ticks = element_blank()
        ) +
  guides(fill = guide_legend(override.aes= list(alpha = 1)))
## same for the other group
#clasic 
fig9<-ggmap(map_ch) +
  stat_density2d(data = data_member_classic_bike, aes(x = start_lng, y = start_lat, fill = ..density..), geom = 'tile', contour = F, alpha = .5)+
  scale_fill_viridis(option = 'inferno')+
  scale_fill_viridis_c(limits = c(0, 1000))+
  labs(title = str_c('start point'))+
  theme(text = element_text(color = "#444444")
        ,plot.title = element_text(size = 12, face = 'bold')
        ,plot.subtitle = element_text(size = 12)
        ,axis.text = element_blank()
        ,axis.title = element_blank()
        ,axis.ticks = element_blank()
        ) +
  guides(fill = guide_legend(override.aes= list(alpha = 1)))

fig10<-ggmap(map_ch) +
  stat_density2d(data = data_member_classic_bike, aes(x = end_lng, y = end_lat, fill = ..density..), geom = 'tile', contour = F, alpha = .5)+
  scale_fill_viridis(option = 'inferno')+
  scale_fill_viridis_c(limits = c(0, 1000))+  
  labs(title = str_c('end point'))+
  theme(text = element_text(color = "#444444")
        ,plot.title = element_text(size = 12, face = 'bold')
        ,plot.subtitle = element_text(size = 12)
        ,axis.text = element_blank()
        ,axis.title = element_blank()
        ,axis.ticks = element_blank()
        ) +
  guides(fill = guide_legend(override.aes= list(alpha = 1)))
#electric
fig11<-ggmap(map_ch) +
  stat_density2d(data = data_member_electric_bike, aes(x = start_lng, y = start_lat, fill = ..density..), geom = 'tile', contour = F, alpha = .5)+
  scale_fill_viridis(option = 'inferno')+
  scale_fill_viridis_c(limits = c(0, 1000))+  
  labs(title = str_c('start point'))+
  theme(text = element_text(color = "#444444")
        ,plot.title = element_text(size = 12, face = 'bold')
        ,plot.subtitle = element_text(size = 12)
        ,axis.text = element_blank()
        ,axis.title = element_blank()
        ,axis.ticks = element_blank()
        ) +
  guides(fill = guide_legend(override.aes= list(alpha = 1)))
fig12<-ggmap(map_ch) +
  stat_density2d(data = data_member_electric_bike, aes(x = end_lng, y = end_lat, fill = ..density..), geom = 'tile', contour = F, alpha = .5)+
  scale_fill_viridis(option = 'inferno')+
  scale_fill_viridis_c(limits = c(0, 1000))+  
  labs(title = str_c('end point'))+
  theme(text = element_text(color = "#444444")
        ,plot.title = element_text(size = 12, face = 'bold')
        ,plot.subtitle = element_text(size = 12)
        ,axis.text = element_blank()
        ,axis.title = element_blank()
        ,axis.ticks = element_blank()
        ) +
  guides(fill = guide_legend(override.aes= list(alpha = 1)))
#plotting them
grid.arrange(fig5, fig6, ncol=2,top=textGrob("Casual Riders, classic bikes heatmap", gp=gpar(fontsize=20,font=8)))
grid.arrange(fig7, fig8, ncol=2,top=textGrob("Casual Riders, Electric bikes heatmap", gp=gpar(fontsize=20,font=8)))
grid.arrange(fig9, fig10, ncol=2,top=textGrob("Members, classic bikes heatmap", gp=gpar(fontsize=20,font=8)))
grid.arrange(fig11, fig12, ncol=2,top=textGrob("Members, Electric bikes heatmap", gp=gpar(fontsize=20,font=8)))

```
The last thing we want to look at is if either group changes their use of the bikes over the course of the year
For this we plot the data as a function of time and keep it divided by group

```{r by time 2}
#first organize date by month 
data_casual$start_date<-as.Date(data_casual$start_date,format="%Y-%m-%d")
data_casual$ones<-1
data_casual_grouped <- data_casual %>%
  group_by(start_date, rideable_type) %>%
  summarise(ones=sum(ones))

data_member$start_date<-as.Date(data_member$start_date,format="%Y-%m-%d")
data_member$ones<-1
data_member_grouped <- data_member %>%
  group_by(start_date, rideable_type) %>%
  summarise(ones=sum(ones))




fig17<- ggplot(data=data_casual_grouped, aes(x=start_date, y=ones, color=rideable_type))+
  labs(x = "Time", y = "Amount of rides", title = "Casual Riders", color="Types of Bikes") +
  geom_point()+
  geom_smooth()+
  ylim(0,10000)+
  scale_color_manual(labels = c("Classic bike", "Electric Bike"), values = c("green", "red", "blue"))


fig18<- ggplot(data=data_member_grouped, aes(x=start_date, y=ones, color=rideable_type))+
    labs(x = "Time", y = "Amount of rides", title = "Members", color="Types of Bikes") +
  geom_point()+
  geom_smooth()+
  ylim(0,10000)+
  scale_color_manual(labels = c("Classic bike", "Electric Bike"), values = c("green", "red", "blue"))

grid.arrange(fig17,fig18,top=textGrob("Amount of rides per date", gp=gpar(fontsize=20,font=8)))
  
```


# answering questions

1. How do annual members and casual riders use Cyclistic bikes differently?
  From what I see this has mainly to do with ride length. Where as the members (surprisingly?) use the bike for less longer distances as you can see here:
```{r}
grid.arrange(fig3, fig4,ncol=2,top=textGrob("Median ride length in minutes by bike type", gp=gpar(fontsize=20,font=1)))
```
  they seem to use them more often, as you can see here: 
```{r}
grid.arrange(fig17,fig18,top=textGrob("Amount of rides per date", gp=gpar(fontsize=20,font=8)))
```
  
  
  When looking at location we do not see a relevant difference between the two groups we see both groups pretty much spread out around Chicago in the same way. 
```{r plotting casual and members docked bike location in a heatmap}
fig5 + labs(title = str_c('Casual Riders'))
fig9 + labs(title = str_c('Members'))
grid.arrange(fig7, fig9,ncol=2,top=textGrob("Start points across Chicago", gp=gpar(fontsize=20,font=1)))
```
  
  
  
2. Why would casual riders buy Cyclistic annual memberships?
    I'd argue that there is a point to be made that if people figure out how easy and usefull/healty it can be to take the bike, they might opt for a membership. Since members use bike on average for smaller distances, this could relate to how easy it is to use and how it can increase ones mobility.
3. How can Cyclistic use digital media to influence casual riders to become members?  
  - They can use the heat maps showing in a cool way how people across the city of Chicago are using bikes everywhere.
  - They can focus on how after using it once and experiencing how easy it is, that using it for picking up groceries, going to a friend, or in short using it in daily life for short distances would make life more eco friendly, easier, healthier and cheaper. 
  
# disclaimer
The data is missing for september 2020, since the excel file is corrupt. There is unfortunatly no way to deal with that, since it's an corruption before the data was uploaded.




