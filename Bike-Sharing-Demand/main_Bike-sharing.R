#----------------------------------------------------------------------
# Main Program (Driver)
# Kaggle Bike Sharing Problem Code
# Siva Sundaramoorthy
# @iamsiva11
#----------------------------------------------------------------------

#importing the functions script file
source('func_Bike-sharing.R')

#Loading the data
train_data <- load_data_train('train.csv',"/Users/iamsiva11/Development/Kaggle/Bike-Demand")

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

val_fac<- Convert_to_factor(train_data,'season')

sapply(train_data,class)
sapply(val_fac,class)
