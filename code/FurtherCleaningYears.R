## This script is intended for further cleaning of release year: r_year, r_month, country
rm(list= ls())
library(dplyr)
load('IMDB_globes.Rdata')
IMDBdata <- IMDB_globes
IMDBdata <- arrange(IMDB_globes, r_year, r_month)
### !!!!! year discrepancy
yearinconsis_idx = which(IMDBdata$year != IMDBdata$r_year)
nonUSA_idx = which(!(IMDBdata$country[yearinconsis_idx] %in% "USA"))
YearLess1_idx = which(IMDBdata$year[yearinconsis_idx[nonUSA_idx]] ==
                        (IMDBdata$r_year[yearinconsis_idx[nonUSA_idx]] - 1))
nonUSAJan_idx = which(IMDBdata$r_month[yearinconsis_idx[nonUSA_idx[YearLess1_idx]]] == 1)
IMDBdata$movie_imdb_link[yearinconsis_idx[nonUSA_idx[YearLess1_idx[nonUSAJan_idx]]]]
year_index = c(2,3,5,6,7,8,9,10,11,12, 13, 14, 15, 16, 17, 18, 20, 21, 22,23, 24, 25, 26,
               28, 29, 30, 31,32, 33, 34, 35,36, 39, 41)
country2USA_index = c(2,3,5,6,7,8,11,16,17, 20, 21, 23, 24, 26, 28, 30, 32, 33,36, 41)
dateupdate_index = c(2,3,6,7,8,9,10,11,12,13,14,15,16,17,20,22,25,29,
                     30,31,32,34,35,36,41)
month_new = c(12,11,12,12,12,11,12,11,12,12,12,12,12,12,12,11,12,12,12,12,12,12,12,12,10)
IMDBdata$r_year[yearinconsis_idx[nonUSA_idx[YearLess1_idx[nonUSAJan_idx[dateupdate_index]]]]] = 
  IMDBdata$year[yearinconsis_idx[nonUSA_idx[YearLess1_idx[nonUSAJan_idx[dateupdate_index]]]]]
IMDBdata$r_month[yearinconsis_idx[nonUSA_idx[YearLess1_idx[nonUSAJan_idx[dateupdate_index]]]]] = 
  month_new
IMDBdata$country[yearinconsis_idx[nonUSA_idx[YearLess1_idx[nonUSAJan_idx[country2USA_index]]]]] = 
  "USA"
## remove 39, because it is never played in a theater, only in film fest, not eligible
IMDBdata <- IMDBdata[-yearinconsis_idx[nonUSA_idx[YearLess1_idx[nonUSAJan_idx[39]]]],]

save(IMDBdata, file = "IMDBmerged_cleanedalldates.Rdata")
# 2: 12, 1998, USA
# 3: 11, 1998, USA
# 5:USA
# 6: 12, 2000, USA
# 7: 12, 2000, USA
# 8: 12,2000, USA
# 9: 11, 2002
# 10: 12, 2003
# 11:11, 2004, USA
# 12: 12, 2004
# 13: 12, 2006
# 14: 12, 2006
# 15: 12, 2006
# 16: 12, 2006, USA
# 17: 12, 2006, USA
# 18: USA
# 20: 12, 2006, USA
# 21: USA
# 22 : 11, 2006
# 23: USA
# 24: USA
# 25: 12, 2007  
# 26: USA
# 28: USA
# 29: 12, 2009
# 30: 12, 2009,USA
# 31: 12, 2010
# 32: 12, 2010, USA
# 33: USA
# 34: 12, 2011
# 35: 12, 2011
# 36: 12, 2012, USA
# 39: remove
# 41:10, 2015, USA