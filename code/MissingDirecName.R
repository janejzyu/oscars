### Handling missing directornames
### The dataset we revise here is: IMDBdata.RData
load('IMDBdata.Rdata')
attach(IMDBdata)
MissingNames_index <-which(director_name == '')  ## 39 director names missing!!
### check these one by one
### #3 Life is a TV series
IMDBdata <- IMDBdata[-MissingNames_index,]
save(IMDBdata, file = 'IMDBdata_nomiss.RData')
