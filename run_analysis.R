getwd()

setwd("/Users/tinkleberry28/Desktop/Coursera/03 - Getting and Cleaning Data")
if(!file.exists("project")){
        dir.create("project")
}

##Download and unzip data

fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile = "./project/Proj.Zip", method = "curl")
list.files("./project")

dateDownloaded <- date()
dateDownloaded


##read the data files into R
TestSubject <- read.table("./project/UCI HAR Dataset/test/subject_test.txt")
TestX <- read.table("./project/UCI HAR Dataset/test/X_test.txt")
TestY <- read.table("./project/UCI HAR Dataset/test/Y_test.txt")
TrainSubject <- read.table("./project/UCI HAR Dataset/train/subject_train.txt")
TrainX <- read.table("./project/UCI HAR Dataset/train/X_train.txt")
TrainY <- read.table("./project/UCI HAR Dataset/train/Y_train.txt")

##Take a look at the data

head(TestSubject, n=3)
head(TestX, n=3)
head(TestY, n=3)
head(TrainSubject, n=3)
head(TrainX, n=3)
head(TrainY, n=3)


## Part 1: Merge the training and the test sets to create one data set.
##Row Bind Test + Train
AllX <- rbind(TestX, TrainX)
AllY <- rbind(TestY, TrainY)
AllSubject <- rbind(TestSubject, TrainSubject)

##Column Bind final product
AllFiles <-cbind(AllSubject, AllY, AllX)

##Pull in files with column names
ActLab <- read.table("./project/UCI HAR Dataset/activity_labels.txt")
ActLab[,2] <- as.character(ActLab[,2])
Feat <- read.table("./project/UCI HAR Dataset/features.txt")
Feat[,2] <- as.character(Feat[,2])

##Part 2: Extracts only the measurements on the mean and standard deviation for each measurement. 

##Pull Mean and Std Dev from Feat
MuOrSigma <- grep(".*mean.*|.*std.*", Feat[,2])
MuOrSigma.names <- Feat[MuOrSigma,2]
MuOrSigma.names = gsub('-mean', 'Mean', MuOrSigma.names)
MuOrSigma.names = gsub('-std', 'Std', MuOrSigma.names)
MuOrSigma.names <- gsub('[-()]', '', MuOrSigma.names)

##Add new columns to total data
NewCols <- c("subject", "activity", MuOrSigma.names)
colnames(AllFiles) <- NewCols

##Convert Activity & Subject to factors
AllFiles$activity <- factor(AllFiles$activity, levels = ActLab[,1], labels = ActLab[,2])
AllFiles$subject <- as.factor(AllFiles$subject)
AllFiles.melted <- melt(AllFiles, id = c("subject", "activity"))
AllFiles.mean <- dcast(AllFiles.melted, subject + activity ~ variable, mean)

## txt file created with write.table() using row.name=FALSE
write.table(AllFiles.mean, "TidyData.txt", row.names=FALSE, quote=FALSE)
