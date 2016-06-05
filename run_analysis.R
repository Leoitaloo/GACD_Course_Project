library(reshape2)
library(dplyr)

filename <- "getdata-projectfiles-UCI HAR Dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename)
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Load activity labels
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
str(activity_labels)
# Factor into char
activity_labels[,2] <- as.character(activity_labels[,2])
#str(activity_labels)
# Load features
features <- read.table("UCI HAR Dataset/features.txt")
#str(features)
# Factor into char
features[,2] <- as.character(features[,2])
#str(features)

# 2 - Extracts only the measurements on the mean and standard deviation for each measurement
features_wanted <- grep(".*mean.*|.*std.*", features[,2])
features_wanted_names <- features[features_wanted,2]

# 4 - Appropriately labels the data set with descriptive variable names
features_wanted_names = gsub('-mean', 'Mean', features_wanted_names)
features_wanted_names = gsub('-std', 'Std', features_wanted_names)
features_wanted_names <- gsub('[-()]', '', features_wanted_names)


# Load datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[features_wanted]
train_activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(train_subjects, train_activities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[features_wanted]
test_activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(test_subjects, test_activities, test)

# 1 - Merges the training and the test sets to create one data set.
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", features_wanted_names)

# Activities and subjects into factors
allData$activity <- factor(allData$activity, levels = activity_labels[,1], labels = activity_labels[,2])
allData$subject <- as.factor(allData$subject)
#str(allData)

allData_melted <- melt(allData, id = c("subject", "activity"))
allData_mean <- dcast(allData_melted, subject + activity ~ variable, mean)

write.table(allData_mean, "tidy.txt", row.names = FALSE, quote = FALSE)
