rm(list = ls())
library(rvest)

this.dir = dirname(parent.frame(2)$ofile)
setwd(this.dir)
load("../data/IMDBdata_MisAnalysed.Rdata")

genres = unique(unlist(strsplit(as.character(IMDBdata$genres),"\\|")))
#as.data.frame(table(unlist(strsplit(as.character(IMDBdata$genres),"\\|"))))