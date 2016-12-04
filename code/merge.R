rm(list = ls())
library(gdata)
this.dir = dirname(parent.frame(2)$ofile)
setwd(this.dir)


load("../data/IMDBdata_yearupdated.Rdata")

#ya-shin http://www.ya-shin.com/awards/awards.html
#globes = read.xls("../data/Golden_Globes_2006.xls", sheet = "Golden_Globes", header = TRUE)
#globes = globes[, 1:13] #remove extra NA columns
#save(globes, file = "../data/golden_globes.RData")
#load("../data/golden_globes.RData")

load("../data/globesScrap.RData")
load("../data/aaScrap.RData")

IMDB_globes = merge(IMDBdata, globesScrap[,c("GGyear", "film", "GGstatus")], by.x = "title", by.y = "film", all = TRUE)
#IMDB_globes = merge(IMDBdata, globesScrap[,c("film", "GGstatus")], by.x = "title", by.y = "film", all.x = TRUE)
#IMDB_globes = merge(IMDB_globes, aaScrap[,c("film", "AAstatus")], by.x = "title", by.y = "film", all = TRUE)

IMDB_globes$GGstatus[is.na(IMDB_globes$GGstatus)] = 0
#IMDB_globes$AAstatus[is.na(IMDB_globes$AAstatus)] = 0

IMDB_globes = IMDB_globes[order(IMDB_globes$r_year), ]


t = data.frame(IMDB_globes$title, IMDB_globes$movie_imdb_link, IMDB_globes$year, IMDB_globes$r_year, IMDB_globes$GGyear, IMDB_globes$GGstatus, IMDB_globes$r_month, IMDB_globes$country)
t = na.omit(t)
t = t[which((t$IMDB_globes.r_year - t$IMDB_globes.GGyear) != 0), ]

t$IMDB_globes.r_month = 12
t$IMDB_globes.r_month[which(t$IMDB_globes.title == "Elizabeth")] = 10
t$IMDB_globes.r_month[which(t$IMDB_globes.title == "The Artist")] = 11

t$IMDB_globes.country = "USA"
t$IMDB_globes.r_year = t$IMDB_globes.r_year - 1


for(i in 1:nrow(t)) {
  j = which(IMDB_globes$movie_imdb_link == t[i, ]$IMDB_globes.movie_imdb_link)
  IMDB_globes[j, "r_month"] = t[i, ]$IMDB_globes.r_month
  IMDB_globes[j, "county"] = t[i, ]$IMDB_globes.country
  IMDB_globes[j, "r_year"] = t[i, ]$IMDB_globes.r_year
}

save(IMDB_globes, file = "../data/IMDB_globes.RData")
