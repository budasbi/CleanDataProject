---
title: "CodeBook"
author: "Oscar Sierra"
date: "25/6/2020"
output: pdf_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

# Tidying Data Project by Budas

This Document will describe the variables in the output of the script called run_analysis.R, the data and transformations that is performed by the mentioned script. This project it's described in the course Getting and Cleaning Data In coursera.org

## Description of the Data

The imput data is about and experiment done by 30 volunteers that performed six activities wearing a SmartPhone. You can find all the informamtion related in the Link: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones. The full dataset it is stored in: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

## Description of the steps in the Script

### Getting the data

```{r getting data}
# Get the url of the data
urlInitialFiles<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# Setting the path an destiny name of the zip file
DestPath<-paste0(getwd(),"/InitialFile.zip")

# Dowloading the file
download.file(url =  urlInitialFiles, destfile = DestPath)

# Getting the list of the zipped files. Step Informative
listFiles<-unzip(DestPath, list = TRUE)

#Unzip the files in the destiny path
unzip(DestPath)

# Getting the file names inside the zip
trainlist<-list.files(paste0(getwd(),"/UCI HAR Dataset","/train"),recursive = TRUE)

# Setting the full path and concatenating with the filename
listfiles<-paste0(getwd(),"/UCI HAR Dataset","/train/",trainlist)

# Setting a result directory
resultdirectory<-paste0(getwd(),"/UCI HAR Dataset","/result/")

# Creating the result directory
dir.create(resultdirectory)

```

### Merging and tidying the data

```{r Merging and tidying the data}
# List the files, For eachone, search the test file, merge with it, and the write a new file. FIrst the train file and then the test file.

  for (trainfile in listfiles) {
    Data1Archivo<-read.table(trainfile, header = FALSE)
    archivo2<-gsub("_train","_test",gsub("/train/", "/test/",trainfile))
    Data2Archivo<-read.table(archivo2, header = FALSE)
    head(Data1Archivo, 2)
    resultdata<-rbind(Data1Archivo, Data2Archivo)
    splitnamesList<-strsplit(trainfile,"/")[length(strsplit(trainfile,"/"))]
    DestFile<-gsub("_train", "",splitnamesList[[1]][length(splitnamesList[[1]])])
    write.csv(resultdata,paste0(resultdirectory, DestFile))
  }

# Read the Measurement file.
DataX<-read.table(paste0(resultdirectory, "X.txt"), header = FALSE, sep = ",", skip = 1)

# read the heads for the file, variable names.
encabezados<-read.table(paste0(getwd(),"/UCI HAR Dataset/features.txt"), header = FALSE, sep = " ")

# Assign the variable names to the measurment dataset
names(DataX)<-c("Num", encabezados[,2]) ##Se añaden encabezados

#Read the subjects file
Subject<-read.table(paste0(resultdirectory, "subject.txt"), header = FALSE, sep = ",", skip = 1)

#Select the column of interest with the subject id
subjects<-Subject[,2]

#Combine the measurement data set with the subjects
DataX<-cbind(subjects,DataX)##Se añade como primera columna, la columna de los sujetos id

#Read the activity id data set
DataActivity<-read.table(paste0(resultdirectory, "y.txt"), header = FALSE, sep = ",", skip = 1)

#Read the Activity catalog, id and labels
Activitylabels<-read.table(paste0(getwd(),"/UCI HAR Dataset/activity_labels.txt"), header = FALSE, sep = "")

#Merge the Activity id's of the measurements to assign the corresponding label
ActivityWithLabels<-merge(DataActivity,Activitylabels, by.x = "V2", by.y = "V1")

#Select the column of interest with the labels of the activities.
select(ActivityWithLabels, V1, V2.y)%>%arrange(V1)
ActivitiesOrdered<-select(ActivityWithLabels, V1, V2.y)%>%arrange(V1)

#Assign them to a dataset
ActivitiesOrdered<-ActivitiesOrdered[,2]

#Combine the column of the activities with the dataset of measurements
DataX<-cbind(ActivitiesOrdered,DataX)

```

### Subsetting the data

```{r Subsetting the data}
#Select the mean and standar deviation variables of all dataset to a new dataset, including the activities and the subjects id's
TidyDataX<-DataX[,grep("([Mm]ean|[Ss]td)|subjects|ActivitiesOrdered", names(DataX))]
```

### Grouping the Data

```{r Grouping the Data}
# Changing format to the data to a table data frame
tidydatadftb<-tbl_df(TidyDataX)

#Group the dataset by Subject and activity and get the mean of all Columns
groupedByActivityAndSubj<-group_by(TidyDataX,ActivitiesOrdered, subjects )%>%summarise_all(list(mean))
str(groupedByActivityAndSubj)

```

## Description of the final Variables

The name of the final variables and the corresponding types are:
*Every measurement are summarize getting the mean grouped by activity and subject id*

ActivitiesOrdered                   : chr  
subjects                            : int  
tBodyAcc-mean()-X                   : num  
tBodyAcc-mean()-Y                   : num  
tBodyAcc-mean()-Z                   : num  
tBodyAcc-std()-X                    : num  
tBodyAcc-std()-Y                    : num  
tBodyAcc-std()-Z                    : num  
tGravityAcc-mean()-X                : num  
tGravityAcc-mean()-Y                : num  
tGravityAcc-mean()-Z                : num  
tGravityAcc-std()-X                 : num  
tGravityAcc-std()-Y                 : num  
tGravityAcc-std()-Z                 : num  
tBodyAccJerk-mean()-X               : num  
tBodyAccJerk-mean()-Y               : num  
tBodyAccJerk-mean()-Z               : num  
tBodyAccJerk-std()-X                : num  
tBodyAccJerk-std()-Y                : num  
tBodyAccJerk-std()-Z                : num  
tBodyGyro-mean()-X                  : num  
tBodyGyro-mean()-Y                  : num  
tBodyGyro-mean()-Z                  : num  
tBodyGyro-std()-X                   : num  
tBodyGyro-std()-Y                   : num  
tBodyGyro-std()-Z                   : num  
tBodyGyroJerk-mean()-X              : num  
tBodyGyroJerk-mean()-Y              : num  
tBodyGyroJerk-mean()-Z              : num  
tBodyGyroJerk-std()-X               : num  
tBodyGyroJerk-std()-Y               : num  
tBodyGyroJerk-std()-Z               : num  
tBodyAccMag-mean()                  : num  
tBodyAccMag-std()                   : num  
tGravityAccMag-mean()               : num  
tGravityAccMag-std()                : num  
tBodyAccJerkMag-mean()              : num  
tBodyAccJerkMag-std()               : num  
tBodyGyroMag-mean()                 : num  
tBodyGyroMag-std()                  : num  
tBodyGyroJerkMag-mean()             : num  
tBodyGyroJerkMag-std()              : num  
fBodyAcc-mean()-X                   : num  
fBodyAcc-mean()-Y                   : num  
fBodyAcc-mean()-Z                   : num  
fBodyAcc-std()-X                    : num  
fBodyAcc-std()-Y                    : num  
fBodyAcc-std()-Z                    : num  
fBodyAcc-meanFreq()-X               : num  
fBodyAcc-meanFreq()-Y               : num  
fBodyAcc-meanFreq()-Z               : num  
fBodyAccJerk-mean()-X               : num  
fBodyAccJerk-mean()-Y               : num  
fBodyAccJerk-mean()-Z               : num  
fBodyAccJerk-std()-X                : num  
fBodyAccJerk-std()-Y                : num  
fBodyAccJerk-std()-Z                : num  
fBodyAccJerk-meanFreq()-X           : num  
fBodyAccJerk-meanFreq()-Y           : num  
fBodyAccJerk-meanFreq()-Z           : num  
fBodyGyro-mean()-X                  : num  
fBodyGyro-mean()-Y                  : num  
fBodyGyro-mean()-Z                  : num  
fBodyGyro-std()-X                   : num  
fBodyGyro-std()-Y                   : num  
fBodyGyro-std()-Z                   : num  
fBodyGyro-meanFreq()-X              : num  
fBodyGyro-meanFreq()-Y              : num  
fBodyGyro-meanFreq()-Z              : num  
fBodyAccMag-mean()                  : num  
fBodyAccMag-std()                   : num  
fBodyAccMag-meanFreq()              : num  
fBodyBodyAccJerkMag-mean()          : num  
fBodyBodyAccJerkMag-std()           : num  
fBodyBodyAccJerkMag-meanFreq()      : num  
fBodyBodyGyroMag-mean()             : num  
fBodyBodyGyroMag-std()              : num  
fBodyBodyGyroMag-meanFreq()         : num  
fBodyBodyGyroJerkMag-mean()         : num  
fBodyBodyGyroJerkMag-std()          : num  
fBodyBodyGyroJerkMag-meanFreq()     : num  
angle(tBodyAccMean,gravity)         : num  
angle(tBodyAccJerkMean),gravityMean): num  
angle(tBodyGyroMean,gravityMean)    : num  
angle(tBodyGyroJerkMean,gravityMean): num  
angle(X,gravityMean)                : num  
angle(Y,gravityMean)                : num  
angle(Z,gravityMean)                : num  