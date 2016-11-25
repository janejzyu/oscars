rm(list = ls())

this.dir = dirname(parent.frame(2)$ofile)
setwd(this.dir)

load("../data/IMDBdata.RData")
#metascore = NULL
for(i in 386:nrow(IMDBdata)) {
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

