LoadData <- function(csv_file, data_path){
#Returns a data of a CSV file loaded
# Args:
#   csv_file: Name of the csv file in srting quotes
#   data_path: The absolute path of the loaction of the data
  
  full_path <-paste(data_path, csv_file,sep="")
  train_data <- read.csv(full_path)
}


setwd("/home/hadoop/rdir/titanic")

FullTrainData <- LoadData("train.csv", "/home/hadoop/rdir/titanic/")
TestData<-LoadData("test.csv", "/home/hadoop/rdir/titanic/")

TestData$Survived <- 0

CombinedData <- rbind(FullTrainData, TestData)


#Feature Engineering
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

CombinedData$Title[CombinedData$Title %in% c('Mme', 'Mlle')] <- 'Mlle'
CombinedData$Title[CombinedData$Title %in% c('Capt', 'Don', 'Major', 'Sir')] <- 'Sir'
CombinedData$Title[CombinedData$Title %in% c('Dona', 'Lady', 'the Countess', 'Jonkheer')] <- 'Lady'


CombinedData$Title <- factor(CombinedData$Title)

#integer vs numeric in R

#Just for Preprocessing
CombinedData$SibSp <-as.integer(CombinedData$SibSp)
CombinedData$Parch <-as.integer(CombinedData$Parch)

CombinedData$FamilySize <- CombinedData$SibSp + CombinedData$Parch + 1


#FamilySizeType<-0
CombinedData$FamilySizeType[CombinedData$FamilySize<=5]<-'small'
#FamilySize[6<=FamilySize<=8]<-'med'
CombinedData$FamilySizeType[CombinedData$FamilySize>=6&FamilySize<=8]<-'med'
CombinedData$FamilySizeType[CombinedData$FamilySize>=9]<-'large'


#Convert FamilySizeType to a factor again
CombinedData$FamilySize <- factor(CombinedData$FamilySize)
CombinedData$FamilySizeType <- factor(CombinedData$FamilySizeType)


CombinedData$Parch <-  as.factor(CombinedData$Parch)
CombinedData$SibSp<-  as.factor(CombinedData$SibSp)

#Adding FamilyID2

# Engineered variable: Family
CombinedData$Surname <- sapply(CombinedData$Name, FUN=function(x) {strsplit(x, split='[,.]')[[1]][1]})
CombinedData$FamilyID <- paste(as.character(CombinedData$FamilySize), CombinedData$Surname, sep="")
CombinedData$FamilyID[CombinedData$FamilySize <= 2] <- 'Small'
# Delete erroneous family IDs
famIDs <- data.frame(table(CombinedData$FamilyID))
famIDs <- famIDs[famIDs$Freq <= 2,]
CombinedData$FamilyID[CombinedData$FamilyID %in% famIDs$Var1] <- 'Small'
# Convert to a factor
CombinedData$FamilyID <- factor(CombinedData$FamilyID)


# New factor for Random Forests, only allowed <32 levels, so reduce number
CombinedData$FamilyID2 <- CombinedData$FamilyID
# Convert back to string
CombinedData$FamilyID2 <- as.character(CombinedData$FamilyID2)
CombinedData$FamilyID2[CombinedData$FamilySize <= 3] <- 'Small'
# And convert back to factor






###############
#Modelling
###############

FullTrainData <-CombinedData[1:891,]
TestData <-CombinedData[892:1309,]

TestData$Survived <- NULL

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
               "FamilySize", "FamilyID2")


SelectedFeaturesofTrainData <- FullTrainData[,features3]

fit.ctree <- cforest(as.factor(Survived) ~ Pclass + Sex + Age + SibSp + Parch + Fare +  
	Embarked + Title + FamilySize + FamilySizeType + FamilyID2, data = SelectedFeaturesofTrainData, controls=cforest_unbiased(ntree=2000, mtry=3))

cat(fit.ctree)

Prediction <- predict(fit, TestData, OOB=TRUE, type = "response")
submit <- data.frame(PassengerId = TestData$PassengerId, Survived = Prediction)
write.csv(submit, file = “titanic-ctree.csv", row.names = FALSE)














