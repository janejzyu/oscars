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

globesScrap = rbind(t1990, t2000, t2010)
globesScrap = subset(globesScrap, Year >= 1997)
globesScrap$`Winners and nominees` = sub(" †| ‡", "", globesScrap$`Winners and nominees`)

globesScrap$isWinner = FALSE
globesScrap$isWinner[match(unique(globesScrap$Year), globesScrap$Year)] = TRUE

save(globesScrap, file = "../data/globesScrap.RData")


#academy awards best director

html = read_html("https://en.wikipedia.org/wiki/Academy_Award_for_Best_Director")
aa = (html %>% 
      html_nodes(xpath = "//*[@id='mw-content-text']/table[3]") %>%
      html_table())[[1]]
aa$Year = substring(aa$Year, 1, 4)
aa = subset(aa, Year >= 1997)
aa = aa[ , !(names(aa) %in% c("Ref."))]
aa$`Director(s)` = sub(".*!", "", aa$`Director(s)`)
aa$Film = sub(".*!", "", aa$Film)
aa$isWinner = FALSE
aa$isWinner[match(unique(aa$Year), aa$Year)] = TRUE



save(aa, file = "../data/aaScrap.RData")
