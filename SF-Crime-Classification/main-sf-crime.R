#Project working directory
#/Users/iamsiva11/Development/Kaggle/Restaurant-Revenue
#Data location
#/Users/iamsiva11/Development/Kaggle/Restaurant-Revenue/data

################
#Prepare Problem
################

setwd("/Users/iamsiva11/Development/Kaggle/SF-Crime/")

#Loading Required libraries
library(caret)
library(dplyr)
library(lubridate)
library(ggplot2)
library(corrplot)
library(reshape2)

source('func-sf-crime.R')

train_data <- load_data("train.csv", "/Users/iamsiva11/Development/Kaggle/SF-Crime/data/")
test_data <- load_data("test.csv", "/Users/iamsiva11/Development/Kaggle/SF-Crime/data/")
basic_desc_stats(train_data)
data_peek(train_data)

#Split-out validation dataset
#We split the data here 20 percent - test , 80 percent - train
ValidationIndex <- Create_ValidationIndex(train_data,'Category')

#Since the data is too large , lets go with 60/40 split
#40% VALIDATION TEST SET
validation <- train_data[-ValidationIndex,] #Select 40% of the data for validation
#60% TRAIN SET
dataset <- train_data[ValidationIndex,] #Use the remaining 60% of data to training and testing the models

nrow(dataset)
nrow(validation)

# #20% VALIDATION TEST SET
# validation <- train_data[-ValidationIndex,] #Select 20% of the data for validation
# #80% TRAIN SET
# dataset <- train_data[ValidationIndex,] #Use the remaining 80% of data to training and testing the models

################
#EDA
################
names(train_data)

#Category
category_stat<- target_var_summary(train_data,'Category')
category_stat
nrow(category_stat)#39 
#train_data$Category

#Descript
Descript_stat <- target_var_summary(train_data,'Descript')
nrow(Descript_stat) #879
train_data$Descript
#nrow(train_data$Category)
nrow(train_data)
Descript_stat

#PdDistrict
PdDistrict_stat <- target_var_summary(train_data,'PdDistrict')
PdDistrict_stat
nrow(PdDistrict_stat) #10

#Resolution
Resolution_stat <- target_var_summary(train_data,'Resolution')
Resolution_stat
nrow(Resolution_stat) #17

#Address
Address_stat <- target_var_summary(train_data,'Address')
Address_stat
nrow(Address_stat) #23228

# uniq_descrip_perc <- (nrow(Descript_stat)/nrow(train_data))*100
# uniq_descrip_perc
# 
# uniq_Categ_perc <- (nrow(category_stat)/nrow(train_data))*100
# uniq_Categ_perc

#####################
#EDA - with dplyr
#####################

#"Descript"   "DayOfWeek"  "PdDistrict" "Resolution" "Address" "Category"  

#"Category" #39 
#"Descript" #879

#Select # filter # mutate # group_by # arrange
#Piping Operator %>%

# category_stat
# Descript_stat

dplyr_desc_cat <- select(train_data,Descript ,Category)

head(dplyr_desc_cat,20)

assault_desc <- filter(dplyr_desc_cat, Descript=="ASSAULT")
assault_desc

nrow(assault_desc)

noncriminal_desc <- filter(dplyr_desc_cat, Category=="NON-CRIMINAL")
noncriminal_desc
nrow(noncriminal_desc)

noncriminal_desc_stat <- target_var_summary(noncriminal_desc,'Descript')
noncriminal_desc_stat

noncriminal_desc_stat_df<- data.frame(noncriminal_desc_stat)

filter(noncriminal_desc_stat_df, freq!=0)
#Want also the name of the description

addr<- select(train_data, Address)
head(addr)

unique(train_data$Descript)
unique(train_data$Category)


#####################
#Data Visualisation
####################

#Bar plot of all the factor variables(almost all except the X,Y)
par(mfrow=c(2,4))

names(train_data)

for(i in 2:6) {
  counts <- table(train_data[,i])
  name <- names(train_data)[i]
  barplot(counts, main=name)
}

#reset
par(mfrow=c(1,1))

table(train_data[,2])

names(train_data)
sapply(train_data,class)

barplot(table(train_data[,2]), main=name) #Category  #Target Variable
barplot(table(train_data[,3]), main=name) #Descript
barplot(table(train_data[,4]), main=name) #DayOfWeek
barplot(table(train_data[,5]), main=name) #PdDistrict
barplot(table(train_data[,6]), main=name) #Resolution
#barplot(table(train_data[,7]), main=name) #Address 

#####################
#Feature Engineering
####################

dataset$hourOfDay <- lubridate::hour(dataset$Dates)#hour
dataset$minute <- lubridate::minute(dataset$Dates)#minute
dataset$month <- lubridate::month(dataset$Dates)#month
dataset$day <- lubridate::day(dataset$Dates) #day of month
dataset$year <- lubridate::year(dataset$Dates)#year


#PdDistrict - reshape
PdDistrict_tidy<- data.frame(model.matrix( ~ PdDistrict - 1, data=dataset ))
head(PdDistrict_tidy)

#DayOfWeek - reshape
DayOfWeek_tidy<- data.frame( model.matrix( ~ DayOfWeek- 1, data=dataset ))
head(DayOfWeek_tidy)

PdDist_Day_reshaped <- cbind(PdDistrict_tidy,DayOfWeek_tidy)

names(PdDist_Day_reshaped)
names(dataset)

#removing the features not sure about ,keeping just the sure of features
#selcted_features.dataset<- dataset[c(-1,-3,-4,-5,-6,-7,-8)]
selected_features.dataset<- dataset[c(2,10,11,12,13,14)]
names(selected_features.dataset)

dataset.first_iteration <- cbind(selected_features.dataset, PdDist_Day_reshaped )
names(dataset.first_iteration)
sapply(dataset.first_iteration,class)
#covert all the columns in the data frame to a factor r

# col_names <- names(mydata)
# mydata[,col_names] <- lapply(mydata[,col_names] , factor)

dataset.first_iteration_fac <- lapply(dataset.first_iteration , factor)
sapply(dataset.first_iteration_fac,class)


#Replicate same features for the validation dataset
###################################################

validation$hourOfDay <- lubridate::hour(validation$Dates)#hour
validation$minute <- lubridate::minute(validation$Dates)#minute
validation$month <- lubridate::month(validation$Dates)#month
validation$day <- lubridate::day(validation$Dates) #day of month
validation$year <- lubridate::year(validation$Dates)#year

validation_PdDistrict_tidy<- data.frame(model.matrix( ~ PdDistrict - 1, data=validation ))
validation_DayOfWeek_tidy<- data.frame( model.matrix( ~ DayOfWeek- 1, data=validation ))
validation_PdDist_Day_reshaped <- cbind(validation_PdDistrict_tidy,validation_DayOfWeek_tidy)

selected_features.validation <- validation[c(2,10,11,12,13,14)]

validation.first_iteration <- cbind(selected_features.validation, validation_PdDist_Day_reshaped )
names(validation.first_iteration)
sapply(validation.first_iteration,class)

validation.first_iteration_fac <- lapply(validation.first_iteration , factor)
sapply(validation.first_iteration_fac,class)


#Replicate same features for the Test
###################################################

names(test_data)
#[1] "Id"         "Dates"      "DayOfWeek"  "PdDistrict" "Address"    "X"          "Y"         

test_data$hourOfDay <- lubridate::hour(test_data$Dates)#hour
test_data$minute <- lubridate::minute(test_data$Dates)#minute
test_data$month <- lubridate::month(test_data$Dates)#month
test_data$day <- lubridate::day(test_data$Dates) #day of month
test_data$year <- lubridate::year(test_data$Dates)#year

test_data_PdDistrict_tidy<- data.frame(model.matrix( ~ PdDistrict - 1, data=test_data ))
test_data_DayOfWeek_tidy<- data.frame( model.matrix( ~ DayOfWeek- 1, data=test_data ))
test_data_PdDist_Day_reshaped <- cbind(test_data_PdDistrict_tidy,test_data_DayOfWeek_tidy)

names(test_data)
selected_features.test_data <- test_data[c(8,9,10,11,12)]

test_data.first_iteration <- cbind(selected_features.test_data, test_data_PdDist_Day_reshaped )
names(test_data.first_iteration)
sapply(test_data.first_iteration,class)

test_data.first_iteration_fac <- lapply(test_data.first_iteration , factor)
sapply(test_data.first_iteration_fac,class)

sapply(dataset.first_iteration_fac,class)


