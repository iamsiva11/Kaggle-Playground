#Project working directory
#/Users/iamsiva11/Development/Kaggle/Restaurant-Revenue
#Data location
#/Users/iamsiva11/Development/Kaggle/Restaurant-Revenue/Data

# getwd()
# setwd("/Users/iamsiva11/Development/Kaggle/Restaurant-Revenue")

#Load Required packages
library(ggplot2)
library(dplyr)
library(corrplot)
library(lubridate)
library(caret)

#importing the function file
source('function-restaurant.R')

#Data Preparation
train_data <- load_data("train-5.csv","/Users/iamsiva11/Development/Kaggle/Restaurant-Revenue/Data/")

basic_desc_stats(train_data)

data_peek(train_data)

#Error in table(y) : attempt to make a table with >= 2^31 elements




