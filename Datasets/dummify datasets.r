require(caret)

#load("Datasets/TreeTrainData.RData")
#load("Datasets/GrandMasterData.RData")
load("Datasets/TreeTestData.RData")
#load("Datasets/Eval.RData")

t <- TreeTestData
rm(TreeTestData)


labels(t)[2]

#d <- GrandMasterData
#t <- FinalTestData
#rm(GrandMasterData)
#rm(FinalTestData)

#d <- d[,-which(names(d) %in% c("weekday"))]

#t <- t[,-which(names(t) %in% c("Store","dayofYear","weekday","Date","StateCode","StateName"))]

#t <- t[order(t$Id),]
#t[t$Id==907,]

#t$State <- t$StateCode


# 
# states <- unique(d$State)
# states
# st <- "HE"
# d <- d[d$State==st,]
# # d<-d[,-1]
# # t <- t[t$State==st & t$Open==1,]
# # t <- t[,-1]

# d <- d[,-3]
# d <- d[d$quarter %in% c(2,3),]
# d<- d[,-which(names(d) %in% c("Promo2"))]

# levels(t$Open_L1) <- levels(d$Open_L1)
# levels(t$promovalid_L1) <- levels(d$promovalid_L1)
# levels(t$promovalid_L2) <- levels(d$promovalid_L2)
# levels(t$StateHoliday_L1) <- levels(d$StateHoliday_L1)
# levels(t$StateHoliday_L2) <- levels(d$StateHoliday_L2)
# levels(t$StateHoliday_L3) <- levels(d$StateHoliday_L3)
# levels(t$StateHoliday_L4) <- levels(d$StateHoliday_L4)
# levels(t$StateHoliday_L5) <- levels(d$StateHoliday_L5)
# levels(t$SchoolHoliday_L1) <- levels(d$SchoolHoliday_L1)
# levels(t$SchoolHoliday_L2) <- levels(d$SchoolHoliday_L2)
# levels(t$SchoolHoliday_L3) <- levels(d$SchoolHoliday_L3)
# levels(t$SchoolHoliday_L4) <- levels(d$SchoolHoliday_L4)
# levels(t$SchoolHoliday_L5) <- levels(d$SchoolHoliday_L5)
# levels(t$Promo2Valid_L1) <- levels(d$promovalid_L1)
# levels(t$promovalid_L2) <- levels(d$promovalid_L2)

#d$Date <- as.Date(paste(d$year,d$month,d$dayofMonth,sep = "-"))
# last date is 06-19-2015
# 5-8-2015 would be ~ 6 weeks earlier

d$inTraining <- ifelse(d$Date<"2015-05-08",1,0)
training <- d[d$inTraining==1,]
testing <- d[d$inTraining==0,]


# set.seed(686)
# inTraining <- createDataPartition(d$Sales, p = .6, list = FALSE)
# training <- d[ inTraining,]
# testing  <- d[-inTraining,]
inEval <- createDataPartition(testing$Sales,p=.5,list=FALSE)
eval <- testing[ inEval,]
testing <- testing[ -inEval,]

rm(inTraining)
rm(inEval)
rm(d)

X <- training$X
Store <- training$Store
State <- training$State
Open <- training$Open
Sales <- training$Sales
training <- training[,-which(names(training) %in% c("X","Store","State","Date","inTraining"))]

#sparse_matrix = sparse.model.matrix(Sales~.-1, data = training)

dmyCoding <- dummyVars(~.,data=training)
training <- data.frame(predict(dmyCoding,newdata = training))
training <- cbind(Store,training)
training <- cbind(State,training)
training <- cbind(Open,training)
training <- cbind(Sales,training)
training <- cbind(X,training)
save(training,file="Datasets/TreeTraining.RData",compress = TRUE)

X <- testing$X
Store <- testing$Store
State <- testing$State
Open <- testing$Open
Sales <- testing$Sales
testing <- testing[,-which(names(testing) %in% c("X","Store","State","Date","inTraining"))]
#dmyCoding <- dummyVars(~.,data=testing)
testing <- data.frame(predict(dmyCoding,newdata = testing))
testing <- cbind(Store,testing)
testing <- cbind(State,testing)
testing <- cbind(Open,testing)
testing <- cbind(Sales,testing)
testing <- cbind(X,testing)
save(testing,file="Datasets/TreeTesting.RData",compress = TRUE)

X <- eval$X
Store <- eval$Store
State <- eval$State
Open <- eval$Open
Sales <- eval$Sales
eval <- eval[,-which(names(eval) %in% c("X","Store","State","Date","inTraining"))]
eval <- data.frame(predict(dmyCoding,newdata = eval))
eval <- cbind(Store,eval)
eval <- cbind(State,eval)
eval <- cbind(Open,eval)
eval <- cbind(Sales,eval)
eval <- cbind(X,eval)
save(eval,file="Datasets/TreeEval.RData",compress = TRUE)


X <- t$Id
Store <- t$Store
State <- t$State
Date <- t$Date
Open <- t$Open

t$StateHoliday <- factor(t$StateHoliday,levels=c("0","1"))

t <- t[,-which(names(t) %in% c("Id","Store","State","Date","Open"))]
dmyCoding <- dummyVars(~.,data=t)
t <- data.frame(predict(dmyCoding,newdata = t))
t <- cbind(Store,t)
t <- cbind(State,t)
t <- cbind(Open,t)
t <- cbind(Sales,t)
t <- cbind(X,t)
t<-t[order(t$X,t$Store),]
t[t$X==907,]

TreeFinalTestData <- t

save(TreeFinalTestData,file="Datasets/TreeFinalTestData.RData",compress = TRUE)







