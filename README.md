Case Study: Cyclistic a bike share company. Using R
================
Douwe John Horsthuis
6/5/2022

# Cyclistic bike-share

![](https://github.com/DouweHorsthuis/Case-study-Cyclistic-a-bike-share-company/blob/main/README_files/figure-gfm/logo.PNG)
![](https://github.com/DouweHorsthuis/Case-study-Cyclistic-a-bike-share-company/blob/main/README_files/figure-gfm/coursera.jpg)
![](https://github.com/DouweHorsthuis/Case-study-Cyclistic-a-bike-share-company/blob/main/README_files/figure-gfm/google.jpg)

## Case study by [Douwe Horsthuis](https://github.com/DouweHorsthuis) for the [Google Data Analytics Capstone](https://www.coursera.org/professional-certificates/google-data-analytics)

For this case study I am looking at data from a fictional company,
Cyclistic, and I will try to answer questions based on their openly
available data that can be found
[here](https://divvy-tripdata.s3.amazonaws.com/index.html)

## Steps taken before this using R

1.  [download](https://divvy-tripdata.s3.amazonaws.com/index.html) the
    last 12 months worth of data

2.  unzip all the excel files so they can be uploaded into an SQL
    database (bigquery)

3.  202009-divvy-tripdata does not work

4.  realized it doesn’t work quickly so instead use Google drive to
    upload it both for space purposes and speed

5.  create a SQL statement to get the data

6.  made sure that old and new data have the same data types by updating
    the old datatypes so that new data sets can be added easily.

[**This query can be found here in
BigQuery**](https://console.cloud.google.com/bigquery?sq=305573351494:ddd1f3a16d2b4b27b43887c0db15d4bb)

[**The R code can be found
here**](https://github.com/DouweHorsthuis/Case-study-Cyclistic-a-bike-share-company/blob/main/code.R)

It’s possible to get the dataset directly from Google’s bigquery.
However I personally prefer using the csv file. So that is what the code
uses.

| ride_id          | rideable_type | started_at              | ended_at                | start_station_name | start_station_id | end_station_name                   | end_station_id | start_lat | start_lng | end_lat |  end_lng | member_casual |
|:-----------------|:--------------|:------------------------|:------------------------|:-------------------|:-----------------|:-----------------------------------|:---------------|----------:|----------:|--------:|---------:|:--------------|
| CFB93A48F8739A87 | docked_bike   | 2020-04-26 13:05:31 UTC | 2020-04-26 13:19:47 UTC | Walsh Park         | 628              | California Ave & Francis Pl (Temp) | 259            |   41.9146 |   -87.668 | 41.9185 | -87.6974 | casual        |
| 57350116454F657E | docked_bike   | 2020-04-27 13:03:24 UTC | 2020-04-27 13:16:12 UTC | Walsh Park         | 628              | California Ave & Francis Pl (Temp) | 259            |   41.9146 |   -87.668 | 41.9185 | -87.6974 | casual        |
| F244A35DC2995411 | docked_bike   | 2020-04-05 13:08:30 UTC | 2020-04-05 13:23:32 UTC | Walsh Park         | 628              | California Ave & Francis Pl (Temp) | 259            |   41.9146 |   -87.668 | 41.9185 | -87.6974 | casual        |
| AF097D79FD811EC8 | docked_bike   | 2020-04-18 13:26:42 UTC | 2020-04-18 13:42:45 UTC | Walsh Park         | 628              | California Ave & Francis Pl (Temp) | 259            |   41.9146 |   -87.668 | 41.9185 | -87.6974 | casual        |
| E14E9E37AD877B95 | docked_bike   | 2020-04-25 13:32:35 UTC | 2020-04-25 13:46:59 UTC | Walsh Park         | 628              | California Ave & Francis Pl (Temp) | 259            |   41.9146 |   -87.668 | 41.9185 | -87.6974 | casual        |
| 915EAAD3924C4921 | docked_bike   | 2020-04-11 15:05:47 UTC | 2020-04-11 15:23:24 UTC | Walsh Park         | 628              | California Ave & North Ave         | 276            |   41.9146 |   -87.668 | 41.9104 | -87.6972 | casual        |

    ## 
    ## 
    ## Total amount of unique ride IDs

    ## [1] 2794093

    ## 
    ## 
    ## Types of bikes

    ## [1] "docked_bike"   "electric_bike" "classic_bike"

    ## 
    ## 
    ## Amount of station names

    ## [1] 701

    ## 
    ## 
    ## Amount of start point

    ## [1] 1256

    ## 
    ## 
    ## Amount of end stations

    ## [1] 703

    ## 
    ## 
    ## Amount of end points

    ## [1] 1257

    ## 
    ## 
    ## Types of Customer

    ## [1] "casual" "member"

Because `length(unique(data$ride_id))` == the full length of the data,
we now know that every ride is unique and that there is no ID number for
individual members in this data. We now know that there are 3 types of
transportation “docked_bike” “electric_bike” “classic_bike”. We know
that
`length(unique(data$start_station_name))==length(unique(data$end_station_name))`==705
, but that both start_station_id and end_station_id are not the same
length and not the same as each other. Because of the we leave these IDs
alone

# Questions about the data

1.  How do annual members and casual riders use Cyclistic bikes
    differently?
2.  Why would casual riders buy Cyclistic annual memberships?
3.  How can Cyclistic use digital media to influence casual riders to
    become members?

## How to answer the questions / can we answers the questions with the current data

1.  split the data in 2 groups see if there are different trends
2.  see if there is something that is the difference that causes people
    to be in one group or another
3.  not sure if answerable with the current data.

# Preparing the data

To prepare the data there are some things we need to do before we can
create 2 subgroups.

1.  the dates are in the wrong class.
2.  there is no ride length

<!-- -->

    ## 
    ## 
    ## These are the casual riders electric bike
    ##  start stations

    ## data_casual_electric_bike$start_station_name 
    ##        n  missing distinct 
    ##   122339        0      681 
    ## 
    ## lowest : 2112 W Peterson Ave          63rd St Beach                900 W Harrison St            Aberdeen St & Jackson Blvd   Aberdeen St & Monroe St     
    ## highest: Wood St & Taylor St (Temp)   Woodlawn Ave & 55th St       Woodlawn Ave & 75th St       Woodlawn Ave & Lake Park Ave Yates Blvd & 75th St

    ## 
    ## 
    ## These are the casual riders electric bike
    ##  end stations

    ## data_casual_electric_bike$end_station_name 
    ##        n  missing distinct 
    ##   122339        0      678 
    ## 
    ## lowest : 2112 W Peterson Ave          63rd St Beach                900 W Harrison St            Aberdeen St & Jackson Blvd   Aberdeen St & Monroe St     
    ## highest: Wood St & Taylor St (Temp)   Woodlawn Ave & 55th St       Woodlawn Ave & 75th St       Woodlawn Ave & Lake Park Ave Yates Blvd & 75th St

    ## 
    ## 
    ## These are the casual riders electric bike
    ##  ride length

    ##                           x
    ## nbr.val       122339.000000
    ## nbr.null        2788.000000
    ## nbr.na             0.000000
    ## min           -28940.000000
    ## max              392.000000
    ## range          29332.000000
    ## sum          1603168.000000
    ## median            13.000000
    ## mean              13.104309
    ## SE.mean            1.302287
    ## CI.mean.0.95       2.552461
    ## var           207481.058542
    ## std.dev          455.500888
    ## coef.var          34.759628

    ## 
    ## 
    ## These are the casual riders classic bike
    ##  start stations

    ## data_casual_classic_bike$start_station_name 
    ##        n  missing distinct 
    ##  1013600        0      677 
    ## 
    ## lowest : 2112 W Peterson Ave          63rd St Beach                900 W Harrison St            Aberdeen St & Jackson Blvd   Aberdeen St & Monroe St     
    ## highest: Wood St & Taylor St (Temp)   Woodlawn Ave & 55th St       Woodlawn Ave & 75th St       Woodlawn Ave & Lake Park Ave Yates Blvd & 75th St

    ## 
    ## 
    ## These are the casual riders classic bike
    ##  end stations

    ## data_casual_classic_bike$end_station_name 
    ##        n  missing distinct 
    ##  1013600        0      690 
    ## 
    ## lowest : 2112 W Peterson Ave          63rd St Beach                900 W Harrison St            Aberdeen St & Jackson Blvd   Aberdeen St & Monroe St     
    ## highest: Wood St & Taylor St (Temp)   Woodlawn Ave & 55th St       Woodlawn Ave & 75th St       Woodlawn Ave & Lake Park Ave Yates Blvd & 75th St

    ## 
    ## 
    ## Types of bikes for casual riders

    ## data_casual$rideable_type 
    ##        n  missing distinct 
    ##  1135939        0        2 
    ##                                       
    ## Value       classic_bike electric_bike
    ## Frequency        1013600        122339
    ## Proportion         0.892         0.108

    ## 
    ## 
    ## These are the casual riders classic bike
    ##  ride length

    ##                             x
    ## nbr.val       1013600.0000000
    ## nbr.null         6933.0000000
    ## nbr.na              0.0000000
    ## min            -28996.0000000
    ## max             55684.0000000
    ## range           84680.0000000
    ## sum          49817292.0000000
    ## median             23.0000000
    ## mean               49.1488674
    ## SE.mean             0.4340772
    ## CI.mean.0.95        0.8507766
    ## var            190985.5360878
    ## std.dev           437.0189196
    ## coef.var            8.8917394

    ## 
    ## 
    ## These are the member electric bike
    ##  start stations

    ## data_member_electric_bike$start_station_name 
    ##        n  missing distinct 
    ##   202874        0      660 
    ## 
    ## lowest : 2112 W Peterson Ave          63rd St Beach                900 W Harrison St            Aberdeen St & Jackson Blvd   Aberdeen St & Monroe St     
    ## highest: Wood St & Taylor St (Temp)   Woodlawn Ave & 55th St       Woodlawn Ave & 75th St       Woodlawn Ave & Lake Park Ave Yates Blvd & 75th St

    ## 
    ## 
    ## These are the member electric bike
    ##  end stations

    ## data_member_electric_bike$end_station_name 
    ##        n  missing distinct 
    ##   202874        0      658 
    ## 
    ## lowest : 2112 W Peterson Ave          63rd St Beach                900 W Harrison St            Aberdeen St & Jackson Blvd   Aberdeen St & Monroe St     
    ## highest: Wood St & Taylor St (Temp)   Woodlawn Ave & 55th St       Woodlawn Ave & 75th St       Woodlawn Ave & Lake Park Ave Yates Blvd & 75th St

    ## 
    ## 
    ## These are the member electric bike
    ##  ride length

    ##                          x
    ## nbr.val      202874.000000
    ## nbr.null       1659.000000
    ## nbr.na            0.000000
    ## min          -29050.000000
    ## max             451.000000
    ## range         29501.000000
    ## sum          410989.000000
    ## median            9.000000
    ## mean              2.025834
    ## SE.mean           1.229550
    ## CI.mean.0.95      2.409888
    ## var          306703.412241
    ## std.dev         553.808101
    ## coef.var        273.372924

    ## 
    ## 
    ## These are the member classic bike
    ##  start stations

    ## data_member_classic_bike$start_station_name 
    ##        n  missing distinct 
    ##  1455488        0      664 
    ## 
    ## lowest : 2112 W Peterson Ave          63rd St Beach                900 W Harrison St            Aberdeen St & Jackson Blvd   Aberdeen St & Monroe St     
    ## highest: Wood St & Taylor St (Temp)   Woodlawn Ave & 55th St       Woodlawn Ave & 75th St       Woodlawn Ave & Lake Park Ave Yates Blvd & 75th St

    ## 
    ## 
    ## These are the member classic bike
    ##  end stations

    ## data_member_classic_bike$end_station_name 
    ##        n  missing distinct 
    ##  1455488        0      669 
    ## 
    ## lowest : 2112 W Peterson Ave          63rd St Beach                900 W Harrison St            Aberdeen St & Jackson Blvd   Aberdeen St & Monroe St     
    ## highest: Wood St & Taylor St (Temp)   Woodlawn Ave & 55th St       Woodlawn Ave & 75th St       Woodlawn Ave & Lake Park Ave Yates Blvd & 75th St

    ## 
    ## 
    ## Types of bikes for members

    ## data_member$rideable_type 
    ##        n  missing distinct 
    ##  1658362        0        2 
    ##                                       
    ## Value       classic_bike electric_bike
    ## Frequency        1455488        202874
    ## Proportion         0.878         0.122

    ## 
    ## 
    ## These are the member classic bike
    ##  ride length

    ##                             x
    ## nbr.val       1455488.0000000
    ## nbr.null        20186.0000000
    ## nbr.na              0.0000000
    ## min            -29014.0000000
    ## max             58720.0000000
    ## range           87734.0000000
    ## sum          18687894.0000000
    ## median             12.0000000
    ## mean               12.8396071
    ## SE.mean             0.2788409
    ## CI.mean.0.95        0.5465186
    ## var            113167.4565518
    ## std.dev           336.4037107
    ## coef.var           26.2004677

**Of interest:**

1.  for both groups the classic_bike is the most used by far (89% &
    88%)  
2.  Both group have the same most used starts/stops and least used
    starts/stops  
3.  There are minus times (in minutes) and the max time is 58720 minutes
    == 978 hours == 40 days
    -   option 1 - get rid of all minus rides and outliers

    -   option 2 - get rid of all minus riders but leave positive

    -   option 3 - get rid of all minus riders and find a cutoff for
        positive
4.  the mean (12/49) and median (12/23) are very different for
    (members/casual)

# Cleaning the data

In the following plots we first look at the data all together, but after
that we will delete all trips that have negative time and all trips that
took over 12 hours.

![](README_files/figure-gfm/looking%20at%20the%20data%20separated-1.png)<!-- -->![](README_files/figure-gfm/looking%20at%20the%20data%20separated-2.png)<!-- -->![](README_files/figure-gfm/looking%20at%20the%20data%20separated-3.png)<!-- -->

# Back to the questions:

**How do annual members and casual riders use Cyclistic bikes
differently?**

Split the data in 2 groups see if there are different averages

-   We see that both groups have very different means, this tells us
    something about that members use the bikes for shorter trips
    (median).

**Why would casual riders buy Cyclistic annual memberships?**

See if there is something that is the difference that causes people to
be in one group or another

**How can Cyclistic use digital media to influence casual riders to
become members?**

For now, not sure if answerable with the current data.

# Creating a heat map with starting and stopping locations

First things to do is create separate data structures for different
`rideable_types` second thing plot it by month.

![](README_files/figure-gfm/plotting%20out%20map-1.png)<!-- -->![](README_files/figure-gfm/plotting%20out%20map-2.png)<!-- -->![](README_files/figure-gfm/plotting%20out%20map-3.png)<!-- -->![](README_files/figure-gfm/plotting%20out%20map-4.png)<!-- -->

While these maps could be great for social media to show how much
stations there are or how across the city people are using the bikes, it
doesn’t show a clear difference in group.

## Bike usage across a year

The last thing we want to look at is if either group changes their use
of the bikes over the course of the year For this we plot the data as a
function of time and keep it divided by group

![](README_files/figure-gfm/by%20time%202-1.png)<!-- -->

This shows us that the member group uses the bikes more. This counts for
both types of bikes.

# Answering questions

1.  How do annual members and casual riders use Cyclist bikes
    differently? From what I see this has mainly to do with ride length.
    Where as the members (surprisingly?) use the bike for less longer
    distances as you can see here:

![](README_files/figure-gfm/unnamed-chunk-1-1.png)<!-- -->

they seem to use them more often, as you can see here:

![](README_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

When looking at location we do not see a relevant difference between the
two groups we see both groups pretty much spread out around Chicago in
the same way.

![](README_files/figure-gfm/plotting%20casual%20and%20members%20docked%20bike%20location%20in%20a%20heatmap-1.png)<!-- -->

1.  Why would casual riders buy Cyclistic annual memberships? I’d argue
    that there is a point to be made that if people figure out how easy
    and useful/healthy it can be to take the bike, they might opt for a
    membership. Since members use bike on average for smaller distances,
    this could relate to how easy it is to use and how it can increase
    ones mobility.
2.  How can Cyclistic use digital media to influence casual riders to
    become members?

-   They can use the heat maps showing in a cool way how people across
    the city of Chicago are using bikes everywhere.
-   They can focus on how after using it once and experiencing how easy
    it is, that using it for picking up groceries, going to a friend, or
    in short using it in daily life for short distances would make life
    more eco-friendly, easier, healthier and cheaper.

# Disclaimer

## Missing data

The data is missing for September 2020, since the excel file is corrupt.
There is unfortunately no way to deal with that, since it’s an
corruption before the data was uploaded.

# Mistake

The first time I worked with the data I didn’t realize I had made a
faulty SQL statement. This let to me gaining more insight into the data,
but also not working with data that was as clean as I thought it was. I
noticed that a lot of the extreme values did not have an end station but
did have a start station. This meant that I made a mistake in the SQL
query I originally did. Because of that, I reviewed the code and found
the mistake, and fixed it. The original start of the case study went
like this:

Here you will see the first summary of the data:

First we are going to try to find out more about outliers, for this we
plot them using the boxplot function

![](README_files/figure-gfm/looking%20for%20outlier-1.png)<!-- -->![](README_files/figure-gfm/looking%20for%20outlier-2.png)<!-- -->

We see that both groups have only a few negative outlier and a bunch of
positive ones. Before deleting them I want to take a look at a couple of
specific once, just to see if there there isn’t just a mistake of
oversight on my part.

We see that the people that have minus time, this has to be wrong. It’s
outside of the scope of this case study, but when looking at the data it
was clear that they all had similar dates (2020-12-15). We are getting
rid of them. We also noticed that there are a lot of people with a ride
length of 0-3 minutes that have a start and end point at the same
station. In this case, it might be people who had an issue with the bike
or for whatever reason didn’t end up taking it. Since these people won’t
give us insight in the behavior of both groups we also get rid of them.
While looking at the positive outliers, some seemed to miss an end
station. **This was the point where I realized I had a faulty
statement** I started over, but could still follow most of the same
steps.

# For the code [click here](https://github.com/DouweHorsthuis/Case-study-Cyclistic-a-bike-share-company/blob/main/code.R)
