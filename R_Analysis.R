# 1. Clear workspace 
rm(list=ls())
# 2. Set working Directory
setwd("/Users/Abhishek/Documents/R_prgming")
# 3. Downoad Datafiles and extract in a folder
if(!file.exists("./data"))
{dir.create("./data")
}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")
unzip(zipfile="./data/Dataset.zip",exdir="./data")
p_path <- file.path("./data" , "UCI HAR Dataset")
p_files<-list.files(p_path, recursive=TRUE)

# 4. Load all requied Data files in Working environment

DtFeatrTest  <- read.table(file.path(p_path, "test" , "X_test.txt" ),header = FALSE)
DtFeatrTrain <- read.table(file.path(p_path, "train", "X_train.txt"),header = FALSE)
DtSubTrain <- read.table(file.path(p_path, "train", "subject_train.txt"),header = FALSE)
DtSubTest  <- read.table(file.path(p_path, "test" , "subject_test.txt"),header = FALSE)
DtActTest  <- read.table(file.path(p_path, "test" , "Y_test.txt" ),header = FALSE)
DtActTrain <- read.table(file.path(p_path, "train", "Y_train.txt"),header = FALSE)
DtFeatrNms <- read.table(file.path(p_path, "features.txt"),head=FALSE)
ActLbls <- read.table(file.path(p_path, "activity_labels.txt"),header = FALSE)

# 5. Merges the training and the test sets to create one data set.
DtSub <- rbind(DtSubTrain, DtSubTest)
names(DtSub)<-c("Subject")
DtAct<- rbind(DtActTrain, DtActTest)
names(DtAct)<- c("Activity")
DtFeatr<- rbind(DtFeatrTrain, DtFeatrTest)
names(DtFeatr)<-DtFeatrNms$V2

DtBind<-cbind(DtSub,DtAct)
Dataset<- cbind(DtFeatr,DtBind)

# 6. Extracts only the measurements on the mean and standard deviation for each measurement. 
# Created new Dataset 'SubsetDataset'
SubsetFeatrNms<-DtFeatrNms$V2[grep("mean\\(\\)|std\\(\\)", DtFeatrNms$V2)]
SubsetDataset<-Dataset[,c(as.character(SubsetFeatrNms),"Activity","Subject")]


# 7. Uses descriptive activity names to name the activities in the data set

SubsetDataset$Activity<-factor(SubsetDataset$Activity,labels=ActLbls$V2)
#Show changed names
head(SubsetDataset$Activity,5)

# 8. Appropriately labels the data set with descriptive variable names.

names(SubsetDataset)<-gsub("BodyBody", "Body", names(SubsetDataset))
names(SubsetDataset)<-gsub("Mag", "Magnitude", names(SubsetDataset))
names(SubsetDataset)<-gsub("Acc", "Accelerometer", names(SubsetDataset))
names(SubsetDataset)<-gsub("^t", "time", names(SubsetDataset))
names(SubsetDataset)<-gsub("Gyro", "Gyroscope", names(SubsetDataset))
names(SubsetDataset)<-gsub("^f", "frequency", names(SubsetDataset))
#Show changed new names
names(SubsetDataset)

# 9. creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(plyr);
TidyData<-aggregate(. ~Subject + Activity, SubsetDataset, mean)
TidyData<-TidyData[order(TidyData$Subject,TidyData$Activity),]

# 10. Extract Tidy Dataset in an text file for upload purpose.
write.table(TidyData, file = "TidyData.txt",row.name=FALSE)

# Processing Complete.