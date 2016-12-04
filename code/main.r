rm(list = ls())
library(rvest)

this.dir = dirname(parent.frame(2)$ofile)
setwd(this.dir)
load("../data/IMDBmerged_cleanedalldates.Rdata")

genres = unique(unlist(strsplit(as.character(IMDBdata$genres),"\\|")))
#as.data.frame(table(unlist(strsplit(as.character(IMDBdata$genres),"\\|"))))

getIndicator = function(genList) {
  sapply(genres, grepl, genList)
}
indicators = t(as.matrix(sapply(IMDBdata$genres, getIndicator)))
IMDBdata = cbind(IMDBdata, indicators)

save(IMDBdata, file = "../data/IMDBdata_gIndicator.RData")