## This file is intended for splitting the releasedate column
library(lubridate)
library(dplyr)
rm(list = ls())
this.dir = dirname(parent.frame(2)$ofile)
setwd(this.dir)
load("../data/IMDBdata_MisAnalysed.RData")
load('IMDBdata_MisAnalysed.RData')

attach(IMDBdata)
IMDBdata$movie_imdb_link <- as.character(IMDBdata$movie_imdb_link)
# 1.check observations that have "NA" as their releasedate
na_idx = which(is.na(releasedate))   
#IMDBdata$movie_imdb_link[na_idx] 
## upon perusal, this observation was not released in theater, thus not eligible
## remove it!
IMDBdata <- IMDBdata[-na_idx,]
detach(IMDBdata)

# 2. now split the dates by stripping the country and convert
# the dates using existing functions in lubridate
# country that the movies are released (3605 obs, matching the total num of obs in the original data)
r_country = gsub("[\\(\\)]", "", 
                 regmatches(IMDBdata$releasedate, gregexpr("\\(.*?\\)", IMDBdata$releasedate)))
# 3. removed obs whose countries are NOT USA, since a movie has to be released in USA so as to be eligible for 
# an award 
IMDBdata <- IMDBdata[r_country %in% "USA",]  # 3141 obs
# Now all the obs in IMDBdata are movies released in USA
# strip the country so that releasedate only contains dates!
ReleaseDate <- gsub("\\s*\\([^\\)]+\\)","",IMDBdata$releasedate)
## 4. check obsevations that only have years (upon perusal, these are NOT released in the theater, thus 
## not eligible)
OnlyYear_idx = which(nchar(ReleaseDate) == 4)
## IMDBdata$movie_imdb_link[OnlyYear_idx]   ## 6 observations
IMDBdata <- IMDBdata[-OnlyYear_idx,]
ReleaseDate <- ReleaseDate[-OnlyYear_idx]
## 5. format the release date, make them into the format: year-month-date, e.g. 2008-01-17
ReleaseDate_new <- dmy(ReleaseDate)
AbnormalDate_idx <- which(is.na(ReleaseDate_new))  # -2, 
# upon perusal, I removed the 2nd obs because it is not released in theater
IMDBdata <- IMDBdata[-AbnormalDate_idx[2],]
ReleaseDate <- ReleaseDate[-AbnormalDate_idx[2]]
ReleaseDate_new <- ReleaseDate_new[-AbnormalDate_idx[2]]
AbnormalDates_idx <- which(is.na(ReleaseDate_new))
AbnormalDates <- ReleaseDate[AbnormalDates_idx]
AbnormalDates_dat <- data.frame(matrix(unlist(strsplit(AbnormalDates, " ")), ncol = 2, byrow = TRUE))
months = c('January','February', 'March', 'April', 'May', "June", "July", "August", "September",
           "October", "November", "December")
###AbnormalDates_mat[,3] <- which(AbnormalDates_mat[,1] %in% months)    # month
AbnormalDates_dat[,2] <- as.numeric(as.character(AbnormalDates_dat[,2]))
AbnormalDates_dat[,3] <- c(4,1,10,1,2,1,9,1)

## create the data frame of release month and year
r_year <- year(ReleaseDate_new)
r_month <- month(ReleaseDate_new)
ReleaseDate_dat <- data.frame(r_year, r_month)
# impute the missing value from AbnormalDates_dat
ReleaseDate_dat[AbnormalDates_idx,] <- AbnormalDates_dat[,2:3]

## Now this dataset has released dates
IMDBdata <- cbind(IMDBdata, ReleaseDate_dat)

### !!!!! year discrepancy
yearinconsis_idx = which(IMDBdata$year != IMDBdata$r_year)
# we notice that for each year discrepancy, the original year in the dataset is smaller than 
# the one we scraped from IMDB
## reason: 
## 1. cunning movie studios! limited release in Dec, country-wide release in the next year in Jan
## 2. foreign movies: original dataset: earlier year - year released in the foreign country; 
# our scrape result: later year 
## Processing:
# 0. for US movies whose scraped release year - 1 > orginal year, we use the year and month we scraped
# e.g.  http://www.imdb.com/title/tt1068678/?ref_=fn_tt_tt_1 
# 1. for US movies that are released in Jan in the next year according to our scraping, we IMPUTE those
# as released in Dec in the previous years.(They want to have an advantage in the Oscars)
# 2. for US movies that are released in Feb or later in the next year according to our sraping, we use the 
# month and year that we scraped.
# 3. for foreign movies, we use the month and year that we scraped,which are the later dates.

## Bascially, we need to revise observations in category 1
# step 0: these remain unchanged
USA_idx = which(IMDBdata$country[yearinconsis_idx] %in% "USA")
YearLess1US_idx = which(IMDBdata$year[yearinconsis_idx[USA_idx]] ==
                           (IMDBdata$r_year[yearinconsis_idx[USA_idx]] - 1))
USAJan_idx = which(IMDBdata$r_month[yearinconsis_idx[USA_idx[YearLess1US_idx]]] == 1)
# IMPUTE the month as 12
IMDBdata$r_month[yearinconsis_idx[USA_idx[YearLess1US_idx[USAJan_idx]]]] = 12
# Update the year as the earlier year
IMDBdata$r_year[yearinconsis_idx[USA_idx[YearLess1US_idx[USAJan_idx]]]] =
  IMDBdata$year[yearinconsis_idx[USA_idx[YearLess1US_idx[USAJan_idx]]]])
save(IMDBdata, file = "IMDBdata_dates.Rdata")

USAJan_idx = which(IMDBdata$r_month[yearinconsis_idx[USA_idx]] == 1)
which((IMDBdata$r_year[yearinconsis_idx[USA_idx[USAJan_idx]]]  - 1) != IMDBdata$year[yearinconsis_idx[USA_idx[USAJan_idx]]])
