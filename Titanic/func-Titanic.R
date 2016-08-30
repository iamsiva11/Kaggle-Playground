#Project working directory
#/Users/iamsiva11/Development/Kaggle/Titanic

#Data location
#/Users/iamsiva11/Development/Kaggle/Titanic/data

library(caret)

LoadData <- function(csv_file, data_path){
#Returns a data of a CSV file loaded
# Args:
#   csv_file: Name of the csv file in srting quotes
#   data_path: The absolute path of the loaction of the data  
  full_path <-paste(data_path, csv_file,sep="")
  train_data <- read.csv(full_path)
}

ShowDescriptiveStat <- function(data)
{  
#Returns Noting , Prints the dimensions ,column nmaes of the dataset to the console
# Args:
#   data : dataset(of type Dataframe)
  cat("dimensions of the data", dim(data), "\n")
  cat("Names of the Columns: ",names(data), "\n")
}

PeekOfData <-function(dataset)
{
#Returns a list of (Data type , first 10 rows , Summary) of the data
# Args:
#   dataset : dataset (of type Dataframe)
  head_data <- head(dataset ,n=5)
  data_type_data <- sapply(dataset, class)  
  summary_data <-summary(dataset)
  return (list(DATA_TYPE=data_type_data, HEAD=head_data, SUMMARY=summary_data))
}

SummaryOfTargetVariable <-function(dataset,target_var)
{
  #Returns a tabl of the frequency of the target variable
  y<- dataset[,target_var]
  target_var_summary <- cbind(freq=table(y), percentage=prop.table(table(y))*100)
 
}

CreateValidationIndex <- function(dataset , column)
{
  #Returns the Validation Index(80%) of the indices
  set.seed(7)
  validationIndex <- createDataPartition(dataset[,column], p=0.80, list=FALSE)    
}  

