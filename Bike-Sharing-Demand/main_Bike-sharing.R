#----------------------------------------------------------------------
# Main Program (Driver)
# Kaggle Bike Sharing Problem Code
# Siva Sundaramoorthy
# @iamsiva11
#----------------------------------------------------------------------

#Load all the required Packages
library(lubridate)
library('dplyr')
library(party) #for ctree

#PREAPARING THE PROBLEM

#importing the functions script file
source('func_Bike-sharing.R')
#Loading the data
train_data <- load_data_train('train.csv',"/Users/iamsiva11/Development/Kaggle/Bike-Demand")
test_data <- load_data_train('test.csv',"/Users/iamsiva11/Development/Kaggle/Bike-Demand")
head(train_data,5)
#Descriptive statistics
basic_desc_stats(train_data)
#We split the data here 20 percent - test , 80 percent - train
ValidationIndex <- Create_ValidationIndex(train_data,'count')
#20% VALIDATION TEST SET
validation <- train_data[-validationIndex,] # select 20% of the data for validation
#80% TRAIN SET
dataset <- train_data[validationIndex,] # use the remaining 80% of data to training and testing the models
#Peeking into the data
data_peek(train_data)
sapply(train_data,class)
sapply(val_fac,class)
#The actual vannila data before any feature engineering ,modifications,processing
dataset_vanilla <- dataset

#############################################
#DATA PREPARATION(CLEANING,TRANSFORMS,etc)
#############################################

#Converting Required Datasets 
dataset<- Convert_to_factor(dataset,'season')
dataset<- Convert_to_factor(dataset,'holiday')
dataset<- Convert_to_factor(dataset,'workingday')
dataset<- Convert_to_factor(dataset,'weather')
#Datatypes after converting 4 features into factors
sapply(dataset,class)
#FEATURE SELECTION/REMOVAL
#Remove Datetime - 1, atemp - 7 , casual,
#registerd (here, count= casual+registered)  -10,11
dataset<- dataset[c(-7,-10,-11)]
#The dataset before feature engineering
dataset_before_FE <- dataset

#############################################
#FEATURE ENGINEERING
#############################################
#Generating multiple Features from datetime feature With lubridate,Base R
#Features to generate from the datetime feature
#2011-01-01 01:00:00  #Sample cell
#1.dayOfWeek , 1.a.dayOfWeekInt
#2.hourofDay
#3.monthOfYear
#4.Weekend
#5.daypart - segment Of the Day 

#FEATURE 1 dayOfWeek
dataset$dayOfWeek <- weekdays(as.Date(dataset$datetime))
dataset$dayOfWeek <- factor(dataset$dayOfWeek, levels = c("Monday", "Tuesday", "Wednesday", 
                          "Thursday", "Friday", "Saturday", "Sunday"),
            ordered = TRUE)

#FEATURE 2 hourOfDay
dataset$hourOfDay <- lubridate::hour(dataset$datetime)
dataset <- Convert_to_factor(dataset,'hourOfDay')

#FEATURE 3.monthOfYear
dataset$monthOfYear <- lubridate::month(dataset$datetime)
dataset <- Convert_to_factor(dataset,'monthOfYear')

#FEATURE 4 weekend
dataset$weekend=0
dataset$weekend[dataset$holiday==0 & dataset$workingday==0]=1 #weekend
dataset$weekend[dataset$holiday==0 & dataset$workingday==1]=0 #working-day ,Not a weekend
#Weekend - yes-1, No-0
dataset <- Convert_to_factor(dataset,'weekend')

#FEATURE 5 daypart
dataset$daypart = 0
dataset$hourOfDay <-as.numeric(dataset$hourOfDay)
#4AM - 9AM = 1
dataset$daypart[(dataset$hourOfDay < 10) & (dataset$hourOfDay > 3)] = 1
#10AM - 3PM = 2
dataset$daypart[(dataset$hourOfDay < 16) & (dataset$hourOfDay > 9)] = 2
#4PM - 9PM = 3
dataset$daypart[( dataset$hourOfDay < 22) & (dataset$hourOfDay > 15)] = 3
#Converting the generated feature into factor
dataset <- Convert_to_factor(dataset,'daypart')
dataset <- Convert_to_factor(dataset,'hourOfDay')

#Replicating the same Data Preparation Process for VALIDATION

validation<- Convert_to_factor(validation,'season')
validation<- Convert_to_factor(validation,'holiday')
validation<- Convert_to_factor(validation,'workingday')
validation<- Convert_to_factor(validation,'weather')

validation<- validation[c(-7,-10,-11)]

#FEATURE GENERATION
#1
validation$dayOfWeek <- weekdays(as.Date(validation$datetime))
validation$dayOfWeek <- factor(validation$dayOfWeek, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"),ordered = TRUE)
#2
validation$hourOfDay <- lubridate::hour(validation$datetime)
validation <- Convert_to_factor(validation,'hourOfDay')
#3
validation$monthOfYear <- lubridate::month(validation$datetime)
validation <- Convert_to_factor(validation,'monthOfYear')
#4
validation$weekend=0
validation$weekend[validation$holiday==0 & validation$workingday==0]=1 #weekend
validation$weekend[validation$holiday==0 & validation$workingday==1]=0 #working-day ,Not a weekend
validation <- Convert_to_factor(validation,'weekend')
#5
validation$daypart <- 0

#For processing purpose, Converting hourOfDay to Numeric
validation$hourOfDay <-as.numeric(validation$hourOfDay)
#4AM - 9AM = 1
validation$daypart[(validation$hourOfDay < 10) & (validation$hourOfDay > 3)] <- 1
#10AM - 3PM = 2
validation$daypart[(validation$hourOfDay < 16) & (validation$hourOfDay > 9)] <- 2
#4PM - 9PM = 3
validation$daypart[( validation$hourOfDay < 22) & (validation$hourOfDay > 15)] <- 3
validation <- Convert_to_factor(validation,'daypart')
validation <- Convert_to_factor(validation,'hourOfDay')

#Replicating the same Data Preparation Process for TEST DATA to make Predictions
test_data<- Convert_to_factor(test_data,'season')
test_data<- Convert_to_factor(test_data,'holiday')
test_data<- Convert_to_factor(test_data,'workingday')
test_data<- Convert_to_factor(test_data,'weather')
test_data<- test_data[c(-7,-10,-11)]

##FEATURE GENERATION
#1
test_data$dayOfWeek <- weekdays(as.Date(test_data$datetime))
test_data$dayOfWeek <- factor(test_data$dayOfWeek, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"),ordered = TRUE)
#2
test_data$hourOfDay <- lubridate::hour(test_data$datetime)
test_data <- Convert_to_factor(test_data,'hourOfDay')
#3
test_data$monthOfYear <- lubridate::month(test_data$datetime)
test_data <- Convert_to_factor(test_data,'monthOfYear')
#4
test_data$weekend=0
test_data$weekend[test_data$holiday==0 & test_data$workingday==0]=1 #weekend
test_data$weekend[test_data$holiday==0 & test_data$workingday==1]=0 #working-day ,Not a weekend
test_data <- Convert_to_factor(test_data,'weekend')
#5
test_data$daypart <- 0
#For processing purpose, Converting hourOfDay to Numeric
test_data$hourOfDay <-as.numeric(test_data$hourOfDay)
#4AM - 9AM = 1
test_data$daypart[(test_data$hourOfDay < 10) & (test_data$hourOfDay > 3)] <- 1
#10AM - 3PM = 2
test_data$daypart[(test_data$hourOfDay < 16) & (test_data$hourOfDay > 9)] <- 2
#4PM - 9PM = 3
test_data$daypart[( test_data$hourOfDay < 22) & (test_data$hourOfDay > 15)] <- 3
test_data <- Convert_to_factor(test_data,'daypart')
test_data <- Convert_to_factor(test_data,'hourOfDay')

test_data_for_model<- test_data[c(-1)]

##################
#APPLYING MODELS
##################

dataset_for_model<-dataset[c(-1)]
names(dataset_for_model)
#Run algorithms using 10-fold cross validation
trainControl <- trainControl(method="repeatedcv", number=10, repeats=3)
metric <- "RMSE"

#Linear Model(lm )
set.seed(7)
fit.lm <- train(count~., data=dataset_for_model, method="lm", metric=metric, preProc=c("center",
                                                                              "scale"), trControl=trainControl)
#Conditional Inference Trees (ctree)
set.seed(7)
fit.ctree <- train(count~., data=dataset_for_model, method="ctree", metric=metric,
                   preProc=c("center", "scale"), trControl=trainControl)

###########################
#Actual Prediction
###########################

test_predict_ctree <- predict(fit.ctree, newdata = test_data_for_model)
submit_ctree <- data.frame(datetime = test_data$datetime, count=test_predict_ctree)
write.csv(submit_ctree, file= 'output_ctree.csv' , row.names=FALSE)
#output_ctree.csv is the file ready for Submission
