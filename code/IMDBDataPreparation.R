### This script is to merge meta critic score with IMDB movie dataset (w/ 5000 obs)
### Interesting Subjects: movies released between [1996, 2015] -- 20 years
### filtering IMDB movie dataset so that movies released between 1995 and 2015 are included only!
## load movie_metadata dataset
library(dplyr)
## load movie_metadata dataset
IMDBdata <- read.csv("~/Documents/STA841/project/movie_metadata.csv") 
IMDBdata <- unique(IMDBdata)   # 5043 rows
attach(IMDBdata)
year.isna.obs <- which(is.na(title_year))
IMDBdata.na <- IMDBdata[year.isna.obs,]
IMDBdata.nona <- filter(IMDBdata[-year.isna.obs,], title_year > 1995 & title_year < 2016)
detach(IMDBdata)
IMDBdata <- rbind(IMDBdata.na, IMDBdata.nona) 
## Now the dataset only has observations with title_year from 1996 to 2015 (i.e. [1996, 2015]) & title
## years that are NA
### 4084 observations in total
IMDBdata$movie_title <- gsub("\xe5\xca", "", IMDBdata$movie_title) %>% str_trim(.)
## manually handling movies with weird titles
attach(IMDBdata)
# The Girl with the Dragon Tattoo -- Swedish one, deleted, Americ
# remove the 60th observation
IMDBdata$movie_title[162] = 'Wall E' #Wall E#
IMDBdata$movie_title[540] = "Deja Vu"
IMDBdata$movie_title[1129] = "Bruno"
IMDBdata$movie_title[617 + 2500] = 'Y Tu Mama Tambien'
IMDBdata$movie_title[347 + 2500]   ### 28 days later
IMDBdata$movie_title[281 + 3500] ###"For a Good Time, Call..."
IMDBdata$movie_title[239 + 3500]  ### "The Helix... Loaded"
IMDBdata$movie_title[4003] = "Antarctic Edge: 70 South"
IMDBdata <- IMDBdata[-60,]
names(IMDBdata)[24] = 'year'
names(IMDBdata)[12] = 'title'
title_col_index = which(names(IMDBdata) %in% 'title')
col_index = 1:ncol(IMDBdata)
col_index[1] = title_col_index
col_index[title_col_index] = 1
IMDBdata = IMDBdata[,col_index]

# remove observations that are TV series, not movies  
# this is not exhaustive
TVobs_index = which(grepl('TV\\-',IMDBdata$content_rating))
IMDBdata <- IMDBdata[-TVobs_index,]

save(IMDBdata, file="IMDBdata.RData")