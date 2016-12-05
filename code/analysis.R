rm(list = ls())
library(MASS)
library(survival)
library(ordinal)
load("../data/IMDBanal.Rdata")

#create winner indicator
IMDBanal$isWinner = as.numeric(IMDBanal$AAstatus == 2)
#create nominee indicator
IMDBanal$isNominee = as.numeric(IMDBanal$AAstatus > 0)

#group month by quater
IMDBanal$r_quater = ceiling(IMDBanal$r_month/3)
IMDBanal$lateRelease = as.numeric(IMDBanal$r_quater == 4)
#group content rating 1 is R or PG13
IMDBanal$isPopularContent = as.numeric(IMDBanal$content_rating == "R" | IMDBanal$content_rating == "PG-13")
#country isUSA
IMDBanal$isUSA = as.numeric(IMDBanal$country == "USA")
#impute metascore
naIndex = which(is.na(IMDBanal$metascore))
IMDBanal$metascore[naIndex] = (IMDBanal$imdb_score * 10)[naIndex]
rm(naIndex)
#marginal profile (gross - budget) / budget
IMDBanal$profit = (IMDBanal$gross - IMDBanal$budget) / IMDBanal$budget
IMDBanal$profit[is.na(IMDBanal$profit)] = 0
#scale duration and metascore
IMDBanal$duration = IMDBanal$duration/60
IMDBanal$metascore = IMDBanal$metascore/10


"
Model 1 direct model

We first fit a logistic model to directly predict winner out of all movies in the data set. 
The variables under consideration are famous_director, famous_actor, isUSA, isPopularContent (R or PG-13), 
duration, metascore, scale(profit), BW, lateRelease, GGstatus, Drama, Musical, War, History , Sci-Fi, Horror

We assign the winner in the testing data set to be the one that has the highest predicted probability in that year.

"

modWin = glm(isWinner ~ famous_director + famous_actor + isUSA + isPopularContent
                     + duration + metascore + scale(profit) + BW + lateRelease + GGstatus
                     + Drama + Musical + War + History + `Sci-Fi` + Horror, data = IMDBanal, family=binomial(link="logit"))

stepAIC(modWin)


setCV = function(i){
  set.seed(841)
  YEARS = 1996:2015
  perm = sample(1:length(YEARS), length(YEARS))
  yearMatrix = matrix(perm, nrow = 5)
  testYearIndex = yearMatrix[i,]
  #sample(1:length(YEARS), as.integer(0.2 * length(YEARS)))
  
  testYear = YEARS[testYearIndex]
  trainYear = YEARS[-testYearIndex]
  
  testData = IMDBanal[IMDBanal$r_year %in% testYear, ]
  trainData = IMDBanal[!IMDBanal$r_year %in% testYear, ]  
  return(list(trainData, testData))
}



getTopResult = function(mod, tdat, topnum) {
  pred = predict(mod, tdat, type="response")
  dat = data.frame(tdat$r_year, tdat$AAstatus, pred)
  t =  dat[order(-dat$pred), ]
  d = by(t, t["tdat.r_year"], head, n=topnum)
  result = Reduce(rbind, d)
  return(result)
}

accListLogit = NULL
for(i in 1:5) {
  trainData = setCV(i)[[1]]
  testData = setCV(i)[[2]]
  modWinSelect = glm(formula = isWinner ~ famous_director + famous_actor + metascore + 
                       BW + GGstatus + Drama + War, 
                     family = binomial(link = "logit"), 
                     data = trainData)
  result = getTopResult(modWinSelect,testData, 1)
  acc = mean(result$tdat.AAstatus == 2)   
  accListLogit = c(accListLogit, acc)
}




"
Model 2 stepwise model

We fit a logistic model to first predict nominees out of all movies in the data set. 
The variables under consideration is the same as the first model.

Then

We assign the winner in the testing data set to be the one that has the highest predicted probability in that year.

"

modNom = glm(isNominee ~ famous_director + famous_actor + isUSA + isPopularContent
                         + duration + metascore + scale(profit) + BW + lateRelease + GGstatus
                         + Drama + Musical + War + History + `Sci-Fi` + Horror, data = trainData, family=binomial(link="logit"))

pred = predict(modNom, testData, type="response")

dat = data.frame(testData$r_year, testData$AAstatus, pred)
t =  dat[order(-dat$pred), ]
d = by(t, t["testData.r_year"], head, n=5)
View(Reduce(rbind, d))


stepAIC(modNom)

#cloglog proportional hazard
modHazardCLL = clm(factor(AAstatus, ordered = T)  ~ famous_director + famous_actor + isUSA + isPopularContent
                  + duration + metascore + scale(profit) + BW + lateRelease + GGstatus
                  + Drama + Musical + War + History + `Sci-Fi` + Horror, data=IMDBanal,
                  link = c("cloglog"))
stepAIC(modHazardCLL)


getTopProp = function(mod, tdat, topnum) {
  pred = predict(mod, tdat, type = "prob")
  dat = data.frame(tdat$r_year, tdat$title,tdat$AAstatus, pred)
  t =  dat[order(-dat$X2), ]
  d = by(t, t["tdat.r_year"], head, n=topnum)
  result = Reduce(rbind, d)
  return(result)
}

accListCLL = NULL
for(i in 1:5) {
  trainData = setCV(i)[[1]]
  testData = setCV(i)[[2]]
  modHazardCLLSelect = polr(factor(AAstatus,ordered = T)  ~ famous_director + duration + metascore + lateRelease + GGstatus + Drama + War + `Sci-Fi`, 
                            data=trainData,
                            method = c("cloglog"), Hess=TRUE)
  result = getTopProp(modHazardCLLSelect, testData, 1)
  acc = mean(result$tdat.AAstatus == 2)   
  accListCLL = c(accListCLL, acc)
}


#loglog
modHazardLL = clm(as.factor(AAstatus)  ~ famous_director + famous_actor + isUSA + isPopularContent
                  + duration + metascore + scale(profit) + BW + lateRelease + GGstatus
                  + Drama + Musical + War + History + `Sci-Fi` + Horror, 
                  data=IMDBanal,
                  link = c("loglog"))
stepAIC(modHazardLL)

accListLL = NULL
for(i in 1:5) {
  trainData = setCV(i)[[1]]
  testData = setCV(i)[[2]]
  modHazardLLSelect = polr(factor(AAstatus,ordered = T)  ~ duration + metascore + lateRelease + GGstatus + Drama + War + History,
                           data=trainData,
                           method = c("loglog"), 
                           Hess=TRUE)
  result = getTopProp(modHazardLLSelect, testData, 1)
  acc = mean(result$tdat.AAstatus == 2)  
  accListLL = c(accListLL, acc)
}



#proportional odds
modOdds = clm(as.factor(AAstatus)  ~ famous_director + famous_actor + isUSA + isPopularContent
                 + duration + metascore + scale(profit) + BW + lateRelease + GGstatus
                 + Drama + Musical + War + History + `Sci-Fi` + Horror, data=trainData,
                 link = c("logit"))
stepAIC(modOdds)
modOddsSelect = polr(as.factor(AAstatus)  ~ duration + metascore + lateRelease + GGstatus + Drama, data=trainData,
                    method = c("logistic"), Hess=TRUE)
result = getTopProp(modOddsSelect, testData, 1)
acc = mean(result$tdat.AAstatus == 2) 

subtestData = subset(testData, isNominee == 1)
subtrainData = subset(trainData, isNominee == 1)

modWFN = glm(isWinner ~ famous_director + famous_actor + isUSA + isPopularContent
             + duration + metascore + scale(profit) + BW + lateRelease + GGstatus
             + Drama + Musical + War + History + `Sci-Fi` + Horror, data = subtrainData, family=binomial(link="logit"))
pred = predict(modWFN, subtestData, type="response")

dat = data.frame(subtestData$r_year, subtestData$AAstatus, pred)
t =  dat[order(-dat$pred), ]
d = by(t, t["subtestData.r_year"], head, n=5)
View(Reduce(rbind, d))

vglm()
