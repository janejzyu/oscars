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
save(IMDBdata, file="IMDBdata.RData")