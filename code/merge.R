rm(list = ls())
library(gdata)
this.dir = dirname(parent.frame(2)$ofile)
setwd(this.dir)


load("../data/IMDBdata_nomiss.RData")

#globes = read.xls("../data/Golden_Globes_2006.xls", sheet = "Golden_Globes", header = TRUE)
#globes = globes[, 1:13] #remove extra NA columns
#save(globes, file = "../data/golden_globes.RData")
load("../data/golden_globes.RData")

IMDB_globes = merge(IMDBdata, subset(globes, Category=="Director"), by.x = "title", by.y = "Film.Title")
save(IMDB_globes, file = "IMDB_globes.RData")
