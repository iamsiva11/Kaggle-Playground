#Project working directory
#/Users/iamsiva11/Development/Kaggle/Restaurant-Revenue

#Data location
#/Users/iamsiva11/Development/Kaggle/Restaurant-Revenue/Data

load_data <- function(csv_file, data_path)
{
  #setwd(wd_path)
  #full_path <- cat("\"",data_path, csv_file,"\"", sep="")
  full_path <-paste(data_path, csv_file,sep="")
  #paste(a, b, sep="")
  #cat(full_path)
  #train_data <- read.csv(csv_file)
  train_data <- read.csv(full_path)
}

basic_desc_stats <- function(data)
{  
  cat("dimensions of the data", dim(data), "\n")
  cat("Names of the Columns: ",names(data), "\n")
}

data_peek <-function(dataset)
{
  head_data <- head(dataset ,n=5)
  data_type_data <- sapply(dataset, class)  
  summary_data <-summary(dataset)
  
  return (list(DATA_TYPE=data_type_data, HEAD=head_data, SUMMARY=summary_data))
}

target_var_summary <-function(dataset,target_var)
{
#y<-dataset$count
y<- dataset[,target_var]
#table(count)
target_var_summary <- cbind(freq=table(y), percentage=prop.table(table(y))*100)
#TARGET_VAR_SUMMARY=target_var_summary
}


#Add data preprocessing Function
#General Recipies,templates
#boilerplate code

#Professional R Code
#java doc type Documentation
#OOPS, Functional Code


