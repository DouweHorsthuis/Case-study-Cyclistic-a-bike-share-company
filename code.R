#all the R code for Case Study: Cyclistic a bike share company. Using R

#libraries
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
#sql
db <- dbConnect(
  bigquery(),
  dataset = 'cyclistic-a-bike-share-company.bikedata.combined data',
  project = 'cyclistic-a-bike-share-company',
  use_legacy_sql = FALSE
)

--# Store the project ID
projectid = "cyclistic-a-bike-share-company"

--# Set your query
sql <- SELECT * FROM "cyclistic-a-bike-share-company.bikedata.combined data"

--# Run the query and store the data in a tibble
tb <- bq_project_query(projectid, sql)

--# Print 10 rows of the data
bq_table_download(tb, n_max = 10)
#load data
data    <- read_csv("data/sql_query_all.csv")

#getting info

kable(head(data))
length(unique(data$ride_id))
unique(data$rideable_type)
length(unique(data$start_station_name))
length(unique(data$f0_))
length(unique(data$end_station_name))
length(unique(data$f1_))
unique(data$member_casual)
#cleaning and organizing data
data$start_date<-ymd_hms(data$started_at)# so it is usable as yyyy-mm-dd hh:mm:ss
data$end_date<-ymd_hms(data$ended_at)
data$ride_length<-round(difftime(data$end_date,data$start_date, units = "min")) #creating the difference in minutes
#splitting the data into 2 data frames
data_casual<-subset(data, member_casual=="casual")
data_member<-subset(data, member_casual=="member")

#more summary
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

# plotting
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
  geom_smooth(formula = y ~ x, method = "loess")+
  ylim(0,10000)+
  scale_color_manual(labels = c("Classic bike", "Docked bike", "Electric Bike"), values = c("green", "red", "blue"))


fig2<- ggplot(data=data_member_grouped, aes(x=start_date, y=ones, color=rideable_type))+
  labs(x = "Time", y = "Amount of rides", title = "Members", color="Types of Bikes") +
  geom_point()+
  geom_smooth(formula = y ~ x, method = "loess")+
  ylim(0,10000)+
  scale_color_manual(labels = c("Classic bike", "Docked bike", "Electric Bike"), values = c("green", "red", "blue"))

grid.arrange(fig1,fig2,top=textGrob("Amount of rides per date", gp=gpar(fontsize=20,font=8)))

#outliers 
boxplot(data_member$ride_length, main="Members")
boxplot(data_casual$ride_length, main="Casual Riders")

#restart
rm(list = ls()) #clearing everything but packages
data    <- read_csv("data/sql_query_all_updated.csv")

kable(head(data))
length(unique(data$ride_id))
unique(data$rideable_type)
length(unique(data$start_station_name))
length(unique(data$start_station_id))
length(unique(data$end_station_name))
length(unique(data$end_station_id))
unique(data$member_casual)

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
cat("\n\nThese are the casual riders electric bike\n start stations \n\n")
describe(data_casual_electric_bike$start_station_name)
cat("\n\nThese are the casual riders electric bike\n end stations \n\n")
describe(data_casual_electric_bike$end_station_name)
cat("\n\nThese are the casual riders electric bike\n ride length \n\n")
stat.desc(data_casual_electric_bike$ride_length)
cat("\n\nThese are the casual riders classic bike\n start stations \n\n")
describe(data_casual_classic_bike$start_station_name)
cat("\n\nThese are the casual riders classic bike\n end stations \n\n")
describe(data_casual_classic_bike$end_station_name)
cat("\n\nThese are the casual riders classic bike\n ride length \n\n")
stat.desc(data_casual_classic_bike$ride_length)

cat("\n\nThese are the member electric bike\n start stations \n\n")
describe(data_member_electric_bike$start_station_name)
cat("\n\nThese are the member electric bike\n end stations \n\n")
describe(data_member_electric_bike$end_station_name)
cat("\n\nThese are the member electric bike\n ride length \n\n")
stat.desc(data_member_electric_bike$ride_length)
cat("\n\nThese are the member classic bike\n start stations \n\n")
describe(data_member_classic_bike$start_station_name)
cat("\n\nThese are the member classic bike\n end stations \n\n")
describe(data_member_classic_bike$end_station_name)
cat("\n\nThese are the member classic bike\n ride length \n\n")
stat.desc(data_member_classic_bike$ride_length)

# plotting 

#first boxplot 
fig1<-ggplot(data_casual, aes( y = as.numeric(ride_length), x = rideable_type, fill=rideable_type)) +            # Applying ggplot function
  geom_boxplot() +
  ggtitle("Casual Riders") +# for the main title
  xlab("types of bikes") +# for the x axis label
  ylab("Bike ride in minutes")+ 
  scale_fill_discrete(name = "Type of bike", labels = c("Classic", "Electric"))
fig2<-ggplot(data_member, aes( y = as.numeric(ride_length), x = rideable_type, fill=rideable_type)) +            # Applying ggplot function
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
fig3<-ggplot(data_casual, aes( y = as.numeric(ride_length), x = rideable_type, fill=rideable_type)) +            # Applying ggplot function
  geom_violin() +
  geom_boxplot(width=0.1)+
  ylim(0, 45)+
  theme(axis.text.x = element_blank())+
  ggtitle("Casual Riders") +# for the main title
  xlab("types of bikes") +# for the x axis label
  ylab("Bike ride in minutes")+ 
  scale_fill_discrete(name = "Type of bike", labels = c("Classic", "Electric"))
fig4<-ggplot(data_member, aes( y = as.numeric(ride_length), x = rideable_type, fill=rideable_type)) +            # Applying ggplot function
  geom_violin()+
  ylim(0, 45)+
  geom_boxplot(width=0.1)+
  theme(axis.text.x = element_blank())+
  ggtitle("Members") +# for the main title
  xlab("types of bikes") +# for the x axis label
  ylab("Bike ride in minutes") + 
  scale_fill_discrete(name = "Type of bike", labels = c("Classic", "Electric"))
fig3.1<-ggplot(data_casual, aes( y = as.numeric(ride_length), x = rideable_type, fill=rideable_type)) +            # Applying ggplot function
  geom_violin() +
  geom_boxplot(width=0.1)+
  #ylim(0, 45)+
  theme(axis.text.x = element_blank())+
  ggtitle("Casual Riders") +# for the main title
  xlab("types of bikes") +# for the x axis label
  ylab("Bike ride in minutes")+ 
  scale_fill_discrete(name = "Type of bike", labels = c("Classic", "Electric"))
fig4.1<-ggplot(data_member, aes( y = as.numeric(ride_length), x = rideable_type, fill=rideable_type)) +            # Applying ggplot function
  geom_violin()+
  #ylim(0, 45)+
  geom_boxplot(width=0.1)+
  theme(axis.text.x = element_blank())+
  ggtitle("Members") +# for the main title
  xlab("types of bikes") +# for the x axis label
  ylab("Bike ride in minutes") + 
  scale_fill_discrete(name = "Type of bike", labels = c("Classic", "Electric"))

grid.arrange(fig1, fig2,ncol=2,top="Comparing both groups \nincluding 12+ hour bike rides")
grid.arrange(fig3.1, fig4.1,ncol=2,top="Comparing both groups \nexcluding 12+ hour bike rides")
grid.arrange(fig3, fig4, ncol=2,top="Comparing both groups \nexcluding 12+ hour bike rides, zoomed in")

## heatmaps on top of city map
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

# amount of rides per group
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

# overview
grid.arrange(fig3, fig4,ncol=2,top=textGrob("Median ride length in minutes by bike type", gp=gpar(fontsize=20,font=1)))
grid.arrange(fig17,fig18,top=textGrob("Amount of rides per date", gp=gpar(fontsize=20,font=8)))
fig5 + labs(title = str_c('Casual Riders'))
fig9 + labs(title = str_c('Members'))
grid.arrange(fig7, fig9,ncol=2,top=textGrob("Start points across Chicago", gp=gpar(fontsize=20,font=1)))