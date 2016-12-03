rm(list = ls())
library(rvest)

this.dir = dirname(parent.frame(2)$ofile)
setwd(this.dir)

html = read_html("https://en.wikipedia.org/wiki/Golden_Globe_Award_for_Best_Director")
t2000 = (html %>% 
         html_nodes(xpath = "//*[@id='mw-content-text']/table[8]") %>%
         html_table())[[1]]
t2010 = (html %>% 
         html_nodes(xpath = "//*[@id='mw-content-text']/table[9]") %>%
         html_table())[[1]]

globesScrap = rbind(t2000, t2010)
globesScrap$isWinner = FALSE
globesScrap$isWinner[match(unique(globesScrap$Year), globesScrap$Year)] = TRUE

save(globesScrap, file = "../data/globesScrap.RData")
