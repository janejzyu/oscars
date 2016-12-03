library(dplyr)
## Merging Oscars with IMDBdata
Oscars2006 <- read.csv("~/Documents/STA841/project/new_project/oscars/data/Oscars2006.csv", stringsAsFactors=FALSE)
unique(Oscars2006$Year) 
## years with a dash are 1927-1928,1928 - 1929, 1929 - 1930, 1930-1931
## 1932-1933. Since we are only interested in the years [1996, 2015]
Oscars96_06 <- Oscars2006 %>% filter(Year >= 1996)
BestDirec_index <- which(Oscars96_06$Category %in% 'Best Director')
Oscars96_06 <- Oscars96_06[BestDirec_index,1:10]
names(Oscars96_06)[10] <- 'ceremony'
names(Oscars96_06)[9] <- 'nominees'
names(Oscars96_06[8] <- 'winner'
# recode the winning situation into 0 or 1
Oscars96_06$winner <- ifelse(Oscars96_06$winner %in% "X", 1,0)
save(Oscars96_06, file = 'Oscars96_06.RData')
