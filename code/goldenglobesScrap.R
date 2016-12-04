rm(list = ls())
library(rvest)

this.dir = dirname(parent.frame(2)$ofile)
setwd(this.dir)

#golden globes best director

html = read_html("https://en.wikipedia.org/wiki/Golden_Globe_Award_for_Best_Director")

t1990 = (html %>% 
         html_nodes(xpath = "//*[@id='mw-content-text']/table[7]") %>%
         html_table())[[1]]

t2000 = (html %>% 
         html_nodes(xpath = "//*[@id='mw-content-text']/table[8]") %>%
         html_table())[[1]]
t2010 = (html %>% 
         html_nodes(xpath = "//*[@id='mw-content-text']/table[9]") %>%
         html_table())[[1]]
colnames(t1990) = colnames(t2000)

#clean data
globesScrap = rbind(t1990, t2000, t2010)
globesScrap = subset(globesScrap, Year >= 1997)
globesScrap$`Winners and nominees` = sub(" †| ‡", "", globesScrap$`Winners and nominees`)
#status: 1 nominee; 2 winner
globesScrap$GGstatus = 1
globesScrap$GGstatus[match(unique(globesScrap$Year), globesScrap$Year)] = 2

colnames(globesScrap) = c("GGyear", "film", "director", "GGstatus")
save(globesScrap, file = "../data/globesScrap.RData")


#academy awards best director

html = read_html("https://en.wikipedia.org/wiki/Academy_Award_for_Best_Director")
aaScrap = (html %>% 
      html_nodes(xpath = "//*[@id='mw-content-text']/table[3]") %>%
      html_table())[[1]]
#clean data
aaScrap$Year = substring(aaScrap$Year, 1, 4)
aaScrap = subset(aaScrap, Year >= 1997)
aaScrap = aaScrap[ , !(names(aaScrap) %in% c("Ref."))]
aaScrap$`Director(s)` = sub(".*!", "", aaScrap$`Director(s)`)
aaScrap$Film = sub(".*!", "", aaScrap$Film)
#status: 1 nominee; 2 winner
aaScrap$AAstatus = 1
aaScrap$AAstatus[match(unique(aaScrap$Year), aaScrap$Year)] = 2

aaScrap = aaScrap[,c(1,3,2,4)]
colnames(aaScrap) = c("AAyear", "film", "director", "AAstatus")
save(aaScrap, file = "../data/aaScrap.RData")
