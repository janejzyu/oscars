### This R script is intended for handling missing values, 
# the dataset we revise here is: IMDBdata.RData
###
load('IMDBdata.Rdata')
attach(IMDBdata)
## missing directornames
MissingNames_index <-which(director_name == '')  ## 39 director names missing!!
# check these one by one
IMDBdata <- IMDBdata[-MissingNames_index,]
save(IMDBdata, file = 'IMDBdata_nomissdirec.RData')
## missing content rating (content rating == '' / 'Unrated')
MissContRate_index = which(IMDBdata$content_rating == '')  ## 237
#range(IMDBdata$imdb_score[MissContRate_index])
#IMDBdata$movie_imdb_link[MissContRate_index]  
### I noticed that for observations that have missing content rating, they are
### either TV series (named after an existing movie), or video names (named after
### an existing movie), or foreign movies that are not shown in US cinemas
IMDBdata <- IMDBdata[-MissContRate_index,]
## movies that are unrated are not played in theatre, therefore cannot possibly receive
## an Oscar
Unrated_index = which(IMDBdata$content_rating %in% "Unrated")  
IMDBdata <- IMDBdata[-Unrated_index,]
NotRated_index = which(IMDBdata$content_rating %in% "Not Rated")
IMDBdata <- IMDBdata[-NotRated_index, ]
## missing "num_user_for_reviews"

###IMDBdata$movie_imdb_link[misNumUser_index]
names(IMDBdata)
## missing duration (imputation)
misDur_idx = which(is.na(IMDBdata$duration))
IMDBdata$duration[misDur_idx[1]] = 115
IMDBdata$duration[misDur_idx[2]] = 85

## missing gross
## a few observations:
## 1. movies with missing metascore but not Gross generally have bad user review
## so, impute these missing metascore with user review
## 2. movie with missing both metascore and gross: 68/180 has user review >= 6, 
## most has relatively low review
## so, imput metascore with user reivew, gross with 100,000
## 3. movie with missing Gross but not meta score, 
misGross_idx = which(is.na(IMDBdata$gross))
misCritic_idx = which(is.na(IMDBdata$metascore))
misGrossCritic_idx = which(is.na(IMDBdata$metascore) & is.na(IMDBdata$gross))

IMDBdata <- IMDBdata[-misGrossCritic_idx[180], ]   # not released in the theater, remove!
misGrossCritichighUser_idx = which(is.na(IMDBdata$metascore) &
                                     is.na(IMDBdata$gross) &
                                     (IMDBdata$imdb_score >= 6) )
misGrosswMetascore_idx = which((!is.na(IMDBdata$metascore)) &
                                 is.na(IMDBdata$gross))  ## 88 counts
IMDBdata$gross[misGrosswMetascore_idx[87]] = 13888
IMDBdata$gross[misGrosswMetascore_idx[86]] = 600896 
hist(IMDBdata$metascore[misGrosswMetascore_idx], 
     main = "Histogram of Metascore when Gross earnings are missing",
     xlab = 'Metascore')
table(IMDBdata$metascore[misGrosswMetascore_idx] >= 60)  # 70: Metascore < 60, 
# 18: Metascore >= 60
misGrosswHighMeta_idx = which((!is.na(IMDBdata$metascore)) &
                                 is.na(IMDBdata$gross) &
                                 (IMDBdata$metascore >= 60) )
## imputing missing values  (I checked, Gross in the dataset refers to "domestic gross income")
IMDBdata$gross[misGrosswHighMeta_idx[1]] = 16003576
IMDBdata$gross[misGrosswHighMeta_idx[2]] = 2547047
IMDBdata$gross[misGrosswHighMeta_idx[12]] = 6870
IMDBdata$gross[misGrosswHighMeta_idx[15]] = 43073
## movie no.10 is not released - remove it!!
IMDBdata <- IMDBdata[-misGrosswHighMeta_idx[10],]
## For other movies that havee missing values, they are not released in USA. 

misGrossCriticUsercount_idx = which(is.na(IMDBdata$metascore) & 
                                      is.na(IMDBdata$gross)&
                                      is.na(IMDBdata$num_user_for_reviews))
misScorewGross_idx = which(is.na(IMDBdata$metascore) & (!is.na(IMDBdata$gross)))

save(IMDBdata, file = 'IMDBdata_MisAnalysed.Rdata')
