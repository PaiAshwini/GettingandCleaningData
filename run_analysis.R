#To demonstrate the ability to collect, work with, and clean a data set

#Downloading the dataset for analysis
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

#Specify the datatype
unzip(zipfile="./data/Dataset.zip",exdir="./data")
filePath <- file.path("./data" , "UCI HAR Dataset")

#Read from the appropriate files
dataActivityTest  <- read.table(file.path(filePath, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(filePath, "train", "Y_train.txt"),header = FALSE)

dataSubjectTrain <- read.table(file.path(filePath, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(filePath, "test" , "subject_test.txt"),header = FALSE)

dataFeaturesTest  <- read.table(file.path(filePath, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(filePath, "train", "X_train.txt"),header = FALSE)

#Merges the training and the test sets to create one data set.
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(filePath, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

#Extracts only the measurements on the mean and standard deviation for each measurement.
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

#Appropriately labels the data set with descriptive variable names.
activityLabels <- read.table(file.path(filePath, "activity_labels.txt"),header = FALSE)
head(Data$activity,30)

#Appropriately labels the data set with descriptive variable names.
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

#independent tidy data set with the average of each variable for each activity and each subject.
library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)
