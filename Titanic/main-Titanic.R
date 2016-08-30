###########################
#Getting the Problem Ready
###########################

#Project working directory
#/Users/iamsiva11/Development/Kaggle/Titanic

#Data location
#/Users/iamsiva11/Development/Kaggle/Titanic/data

setwd("/Users/iamsiva11/Development/Kaggle/Titanic")
source('func-Titanic.R')

#To remove all the variables in the working space
#rm(list=ls())

#full_train_data - train data before any splitting
FullTrainData <- LoadData("train.csv", "/Users/iamsiva11/Development/Kaggle/titanic/data/")
#891

TestData<-LoadData("test.csv", "/Users/iamsiva11/Development/Kaggle/titanic/data/")
TestData$Survived <- 0 #To maintain the homogenity with the training dataset
#As,we will be processing the train,test data together up next
nrow(TestData)

#Combining the train and test data into a single dataframe to make the 
#Pre processing , cleaning of data much faster in a single iteration
CombinedData <- rbind(FullTrainData, TestData)
#Train 1:891
#Test 892-1309


#Loading the required Packages
library(caret)
library(dplyr)
library(lubridate)
library(ggplot2)
library(corrplot)
library(reshape2)
library(randomForest)
library(kernlab)

#Create Validation Index
#Create_ValidationIndex

###########################
#Data Exploration
###########################

ShowDescriptiveStat(FullTrainData)

PeekOfData(FullTrainData)

str(FullTrainData)

names(FullTrainData)

sapply(FullTrainData[,c(2,3,5,6)],unique)

targetSummary <- SummaryOfTargetVariable(FullTrainData,'Survived')
targetSummary

# range(!is.na(FullTrainData$Age))
length(FullTrainData$Age)

length(FullTrainData$Age[!is.na(FullTrainData$Age)])

range(FullTrainData$Age[!is.na(FullTrainData$Age)])

min(FullTrainData$Age[!is.na(FullTrainData$Age)])

#7-12 Variables

sapply(FullTrainData[,c(10)],unique)
sapply(FullTrainData[,c(10)],range)

range(FullTrainData[,c(10)])

head(FullTrainData[,c(11,12)])
sapply(FullTrainData[,c(11,12)],unique)

NonCategoricalFeatures <-c( 'Name',
                            'Fare',
                            'Age',
                            'Cabin',
                            'Ticket')

NonCategoricalFeatures_nocabin<-c( 'Name',
                                   'Fare',
                                   'Age',
                                   'Ticket')

head(FullTrainData[,NonCategoricalFeatures])

head(FullTrainData[,NonCategoricalFeatures],20)

length(FullTrainData$Cabin)

nrow(FullTrainData)

FullTrainData$Cabin[FullTrainData$Ticket=='113803']

FullTrainData$Cabin

head(FullTrainData[,NonCategoricalFeatures_nocabin],20)

FullTrainData[is.na(FullTrainData)]

sapply(FullTrainData[,NonCategoricalFeatures_nocabin],is.na)

NAValuesinAge<-FullTrainData$Age[sapply(FullTrainData$Age,is.na)]
length(NAValuesinAge)

length(FullTrainData$Embarked)
unique(FullTrainData$Embarked)
table(FullTrainData$Embarked)

table(FullTrainData$Embarked)


#Name - To process as text
#Feature Engineer , Extract Features from "Name"
#Age - Many of the age Values are not NA - 177/891
#Convert the NA into some Mean , Meadian Value , depending on Male  name Features
#Fare - Numeric and ranges between  0.0000 512.3292 
#doesnt repeat itself , all of them are unique
#Ticket - 681 Levels , looks like a Not so meaningful feature. ignore for now
#Cabin - Not so clear, many rows are empty
#Come back on it later  ignore this feature for now
#Left out features
# "Cabin" "Name" "Ticket" 

FeaturesNotinModel <- c("Cabin" ,"Name" ,"Ticket")

head(FullTrainData[,FeaturesNotinModel])

head(FullTrainData$Name,20)

####################
#Data Visualisation
####################

CategoricalFeatures <-c('Sex',
                        'Pclass',
                        'SibSp',
                        'Parch',
                        'Embarked')

#BarPlot
par(mfrow=c(3,4))
par(mfrow=c(2,4))

for(i in CategoricalFeatures) {
  counts <- table(FullTrainData[,i])
  #name <- names(FullTrainData[i])
  name<-i
  barplot(counts, main=name)
}

##############################
#Feature Engineering,Selection
##############################

#Categorical Variables
#Sex, Pclass, SibSp, parch, embarked

sapply(FullTrainData,class)
#Convert the below features into factors

#CombinedData

#5 + 1(target) are factors now
#Sex and embarked are already factors
CombinedData$Pclass <-  as.factor(CombinedData$Pclass)
CombinedData$Parch <-  as.factor(CombinedData$Parch)
CombinedData$SibSp<-  as.factor(CombinedData$SibSp)
CombinedData$Survived <-  as.factor(CombinedData$Survived)

# Passenger on row 62 and 830 do not have a value for embarkment. 
# Since many passengers embarked at Southampton, we give them the value S.
# We code all embarkment codes as factors.
CombinedData$Embarked[c(62,830)] <- "S"
CombinedData$Embarked <- factor(CombinedData$Embarked)

#To Feature Engineer
#Name, Age ,Fare

#Age, Fare - Handling missing features in R 
CombinedData$Age[is.na(CombinedData$Age)] <- -1
CombinedData$Fare[is.na(CombinedData$Fare)] <- median(CombinedData$Fare, na.rm=TRUE)

sapply(CombinedData,class)

#Feature Extraction with Name

head(FullTrainData$Name)
FullTrainData$Name[1]

class(FullTrainData$Name)

#Convert the Name to Character
CombinedData$Name<-as.character(CombinedData$Name)
CombinedData$Name[1]
#Excellent, no more levels, now it's just pure text

strsplit(CombinedData$Name[1], split='[,.]')
strsplit(CombinedData$Name[1], split='[,.]')[[1]]

strsplit(CombinedData$Name[1], split='[,.]')[[1]][2]

CombinedData$Title <- sapply(CombinedData$Name, FUN=function(x) {strsplit(x, split='[,.]')[[1]][2]})
class(CombinedData$Title)
#length(Title)
head(CombinedData$Title,20)

CombinedData$Title <- sub(' ', '', Title)

table(CombinedData$Title)

CombinedData$Title[CombinedData$Title %in% c('Mme', 'Mlle')] <- 'Mlle'
CombinedData$Title[CombinedData$Title %in% c('Capt', 'Don', 'Major', 'Sir')] <- 'Sir'
CombinedData$Title[CombinedData$Title %in% c('Dona', 'Lady', 'the Countess', 'Jonkheer')] <- 'Lady'

table(CombinedData$Title)

CombinedData$Title <- factor(CombinedData$Title)

class(CombinedData$Title)

#FamilySize Feature
class(CombinedData$SibSp)
class(CombinedData$Parch)


#Just for Preprocessing
CombinedData$SibSp <-as.integer(CombinedData$SibSp)
CombinedData$Parch <-as.integer(CombinedData$Parch)

head(CombinedData[,c('SibSp','Parch')])

CombinedData$FamilySize <- CombinedData$SibSp + CombinedData$Parch + 1

sort(unique(CombinedData$FamilySize))
#3  4  5  6  7  8  9 10 11
#<=5 ,6<=x<=9 , >=10

table(CombinedData$FamilySize)

#FamilySizeType<-0
CombinedData$FamilySizeType[CombinedData$FamilySize<=5]<-'small'
#FamilySize[6<=FamilySize<=8]<-'med'
CombinedData$FamilySizeType[CombinedData$FamilySize>=6&FamilySize<=8]<-'med'
CombinedData$FamilySizeType[CombinedData$FamilySize>=9]<-'large'

table(CombinedData$FamilySizeType)
sum(table(CombinedData$FamilySizeType))

#Convert FamilySizeType to a factor again
CombinedData$FamilySize <- factor(CombinedData$FamilySize)
CombinedData$FamilySizeType <- factor(CombinedData$FamilySizeType)

###############
#Modelling
###############

#Preaparing the data , Getting the data ready for Modelling
#Split the train and test data from the combinedData Dataframe after feature Engineering
FullTrainData <-CombinedData[1:891,]
TestData <-CombinedData[892:1309,]

names(TestData)
#Removing the 'Survived' feature
TestData$Survived <- NULL
names(TestData)

features <- c("Pclass",
              "Age",
              "Sex",
              "Parch",
              "SibSp",
              "Fare",
              "Embarked",
              "Survived")

#Adding Title
features2 <- c("Pclass",
              "Age",
              "Sex",
              "Parch",
              "SibSp",
              "Fare",
              "Embarked",
              "Survived",
              "Title")

#add familysize , FamilyId (small tc details)
features3 <- c("Pclass",
               "Age",
               "Sex",
               "Parch",
               "SibSp",
               "Fare",
               "Embarked",
               "Survived",
               "Title",
               "FamilySizeType",
               "FamilySize")

#Left out Features
#"PassengerId" "Survived" (id and target)  
#"Pclass" "Sex" "Age" "SibSp" "Parch" "Fare" "Embarked"
#"Cabin" "Name" "Ticket" 

#Try out Random Forest
#SelectedFeaturesofTrainData <- FullTrainData[,features]
#SelectedFeaturesofTrainData <- FullTrainData[,features2]
SelectedFeaturesofTrainData <- FullTrainData[,features3]

#Training the model with default parameter RF
control <- trainControl(method="repeatedcv", number=10, repeats=3)
seed <- 7
metric <- "Accuracy"
set.seed(seed)
mtry <- sqrt(ncol(SelectedFeaturesofTrainData)-1)
tunegrid <- expand.grid(.mtry=mtry)
rf_default <- train(Survived~., data=SelectedFeaturesofTrainData, method="rf", metric=metric, tuneGrid=tunegrid, trControl=control)
print(rf_default)

head(SelectedFeaturesofTrainData$Survived)
head(FullTrainData$Survived)

sapply(SelectedFeaturesofTrainData,class)

# CART
set.seed(7)
fit.cart <- train(Survived~., data=SelectedFeaturesofTrainData, method="rpart", metric=metric
                  , preProc=c("center", "scale"), trControl=control)
print(fit.cart)

#ctree
library(party)
fit.ctree <- train(Survived~., data=SelectedFeaturesofTrainData, method="ctree", metric=metric,
                   preProc=c("center", "scale"), trControl=control)
print(fit.ctree)

#Feature Importance in Caret R
#Estimate variable importance
importance <- varImp(rf_default, scale=FALSE)
# summarize importance
print(importance)
# plot importance
plot(importance)


############################
#Predict
############################

test_predictRF <- predict(rf_default, newdata = TestData)
submit_rf <- data.frame(PassengerId = TestData$PassengerId, Survived=test_predictRF)
write.csv(submit_rf, file= 'output_rf.csv' , row.names=FALSE)

test_predictRF <- predict(rf_default, newdata = TestData)
submit_rf <- data.frame(PassengerId = TestData$PassengerId, Survived=test_predictRF)
write.csv(submit_rf, file= 'output_rf_features2.csv' , row.names=FALSE)

test_predictRF <- predict(rf_default, newdata = TestData)
submit_rf <- data.frame(PassengerId = TestData$PassengerId, Survived=test_predictRF)
write.csv(submit_rf, file= 'output_rf_features3.csv' , row.names=FALSE)


