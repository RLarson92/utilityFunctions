# this script pulls together the two data tables that Wildlife Insights gives
# you when you download data from their site. it combines the correct
# metadata to each animal detection, and adds back in the non-detections for
# use with occupancy models
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)

# now that all the packages are loaded, let's load in the detection data
# your file will be something called "images_xxxxx.csv" with the number strings
# being unique to each WI project
myData <- read.csv('./data/images_2007723.csv')

# this file has lots of columns that I don't really need, so I'm subsetting it
c <- c(2,9,14,16)
myData <- myData[,c]

# now it's a smaller dataframe including the deployment id (season+site), the
# taxonomic class and common names of detections, and the datetime of the
# detection
# my dataset has a lot of bird (class Aves) bycatch that I don't want and some
# unknown detections, so I'm filtering to only get mammals
myData %>% 
  filter(class == "Mammalia") -> myData

# then I'm going to use lubridate to pull the date info from the datetime as I'm
# only interested in daily capture rates and thus only need one capture per day
myData$timestamp <- lubridate::mdy_hm(myData$timestamp)
myData$timestamp <- as.Date(myData$timestamp)
tmp <- distinct(myData)

# finally, I'll use some tidyr/dplyr commands to group by deployment ID and get
# the number of daily detections of each species per deployment
tmp %>%
  group_by(deployment_id) %>%
  count(common_name) -> dat
dat <- as.data.frame(dat)
rm(tmp)

# In my dataset, I do have some sites that did not detect mammals for a variety
# of reasons (e.g., dead batteries, theft, etc.) so 'dat' does not contain
# ALL of my camera locations and deployments, which needs to be fixed.

# First, let's load in my metadata, which will have all my sites. I'm also using
# lubridate to calculate the number of days a camera was active
myMetadata <- read.csv("./data/deployments.csv")
myMetadata$start_date <- lubridate::mdy_hm(myMetadata$start_date)
myMetadata$end_date <- lubridate::mdy_hm(myMetadata$end_date)
myMetadata$daysActive <- as.numeric(as.duration(myMetadata$end_date - 
                                                  myMetadata$start_date),"days")

# again, because it has a bunch of columns that I don't need/want, I'm 
# subsetting
c<-c(2,3,30)
tmp <- myMetadata[,c]

# now, let's to a full join between tmp and dat. This join will add rows for
# sites with no mammal detections, with the common name and n appearing as 'NA'
tmp1 <- full_join(tmp, dat, by = "deployment_id")
tmp1 %>%
  group_by(placename, deployment_id, common_name) -> tmp1
# the next code won't work if the common name field is blank, so I'm putting in
# a 'dummy' species that we'll filter out later
tmp1$common_name[is.na(tmp1$common_name)] <- "dummy"
tmp1$n[is.na(tmp1$n)] <- "0"
tmp1 <- as.data.frame(tmp1)

# we still need all combos of species and sites, so we'll use the expand
# function 
tmp1 %>%
  expand(deployment_id, common_name) -> tmp2

# then we will right join the original dat file back to our tmp2 file, which 
# fill in the detections while preserving the empty rows
data <- right_join(dat, tmp2)
data <- as.data.frame(data)
# AND THEN, we'll join the metadata (site names, days active) to the dataframe
data <- right_join(tmp, data)
data <- as.data.frame(data)
# let's replace the non-detections (which are NA's) to 0's
data[is.na(data)] <- 0
# and then add back in the true NA's (missing data)
data$n[data$daysActive < 1] <- NA
# I like to re-name the columns to match with the code I typically use for my 
# models. "Season" = season/sample period; "site" = site name; "J" = # of 
# sampling days for that season at that site; "species" = species name; and
# "Y" = number of detections during that season
# also trimming up a couple of the columns
colnames(data) <- c("season","site","J","species","Y")
data$season <- strtrim(data$season, 4)
J <- ceiling(J)
# put the data in the correct order and clean up the environment. you're done!
data <- data[order(
  data[,"species"],
  data[,"season"],
  data[,"site"]),]
rm(c, tmp, tmp1, tmp2, dat)
# enjoy your long-form Wildlife Insights detection/nondetection data in the
# occupancy model of your choosing
