#----------------------------------------------------------------------
# Function definitions file
# Kaggle Bike Sharing Problem Code
# Siva Sundaramoorthy
# @iamsiva11
#----------------------------------------------------------------------

#Pass Working directory path
load_data_train <- function(csv_file, wd_path)
{
  setwd(wd_path)
  train_data <- read.csv(csv_file)
  }

#To load both the test and train data
load_data_both <- function(csv_file_train,csv_file_test, wd_path)
{
  setwd(wd_path)
  train_data<- read.csv(csv_file_train)
  test_data<- read.csv(csv_file_test)
  #update this, Not returnng anythong Now
}


#Baisc Descriptive statistics of the data
basic_desc_stats <- function(data)
{  
  cat("dimensions of the data", dim(data), "\n")
  cat("Names of the Columns: ",names(data), "\n")
}

#Peek into the data 
data_peek<-function(dataset)
{
  head_data <- head(dataset ,n=5)
  data_type_data <- sapply(dataset, class)  
  summary_data <-summary(dataset)
  y<-dataset$count
  target_var_summary<- cbind(freq=table(y), percentage=prop.table(table(y))*100)
  return (list(DATA_TYPE=data_type_data, HEAD=head_data, SUMMARY=summary_data, TARGET_VAR_SUMMARY=target_var_summary))
}

#Create a Validation Index
Create_ValidationIndex<- function(dataset , column)
{
#Create A Split out Validation Dataset
set.seed(7)
validationIndex <- createDataPartition(dataset[,column], p=0.80, list=FALSE)    
}  

#Converto data to factor  
Convert_to_factor<- function(dataset,feature)
{
  dataset[,feature]<- as.factor(dataset[,feature])  
  #will returen the dataframe by default
  return (dataset)
}
