this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

html <- html("http://www.goldderby.com/odds/user-odds/oscars-nominations-2017/")
director_node <- html_nodes(html, "#7 p")
dir = html_text(director_node)[c(TRUE, FALSE)]
movie = html_text(director_node)[c(FALSE, TRUE)]

content_node = html_nodes(html, "#7 div.predictions-odds")
pred = html_text(content_node)[c(FALSE, TRUE, FALSE)]
odds = html_text(content_node)[c(FALSE, FALSE, TRUE)]

goldderby = data.frame(dir, movie, pred, odds)
write.csv(goldderby, "../data/goldderby.csv", row.names=FALSE)
