rm(list = ls())

this.dir = dirname(parent.frame(2)$ofile)
setwd(this.dir)
library(magrittr)
library(rvest)
#metascore
load("IMDBdata.RData")
metascore = NULL
for(i in 1:nrow(IMDBdata)) {
  print(i)
  link = as.character(IMDBdata[i,]$movie_imdb_link)
  score = read_html(link) %>%
    html_nodes(".metacriticScore span") %>%
    html_text %>%
    as.numeric()
  if (identical(score, numeric(0))) {
    score = NA
  }
  metascore = c(metascore, score)
}


IMDBdata$metascore = metascore
write.csv(IMDBdata, "IMDBdata.csv", row.names=FALSE)
save(IMDBdata, file = "IMDBdata.RData")

releasedate = NULL
for(i in 1:nrow(IMDBdata)) {
  print(paste(i, "iteration"))
  
  link = as.character(IMDBdata[i,]$movie_imdb_link)
  txt = read_html(link) %>% 
    html_nodes(xpath = "//div/h4[contains(text(),'Release Date:')]/..") %>%
    html_text()
  
  date = gsub("\\n.*", "",gsub(".*Release Date: ", "", txt))
  if (identical(date, character(0))) {
    date = NA
  }
  releasedate = c(releasedate, date)
}
IMDBdata$releasedate = releasedate
save(IMDBdata, file = "IMDBdata.RData")