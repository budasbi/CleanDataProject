library(dplyr)
#Merges the training and the test sets to create one data set.
urlInitialFiles<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
DestPath<-paste0(getwd(),"/InitialFile.zip")
download.file(url =  urlInitialFiles, destfile = DestPath)
listFiles<-unzip(DestPath, list = TRUE)
#1.2 Exract Files
unzip(DestPath)

trainlist<-list.files(paste0(getwd(),"/UCI HAR Dataset","/train"),recursive = TRUE)

listfiles<-paste0(getwd(),"/UCI HAR Dataset","/train/",trainlist)
resultdirectory<-paste0(getwd(),"/UCI HAR Dataset","/result/")
dir.create(resultdirectory)
##Merge Files
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
##Cleaning Variables
rm(listfiles, DestFile, splitnamesList, Data1Archivo, Data2Archivo, resultdata, trainfile, archivo2,trainlist )
#Agregar Actividad y(Id actividad) con X cBind
DataX<-read.table(paste0(resultdirectory, "X.txt"), header = FALSE, sep = ",", skip = 1)#Se carga el Archivo de las Observaciones
encabezados<-read.table(paste0(getwd(),"/UCI HAR Dataset/features.txt"), header = FALSE, sep = " ")##Se cargan Los encabezados
names(DataX)<-c("Num", encabezados[,2]) ##Se añaden encabezados
Subject<-read.table(paste0(resultdirectory, "subject.txt"), header = FALSE, sep = ",", skip = 1)##Se Cargan los Sujetos
subjects<-Subject[,2]##Se selecciona la columna con el Sujeto ID
DataX<-cbind(subjects,DataX)##Se añade como primera columna, la columna de los sujetos id


DataActivity<-read.table(paste0(resultdirectory, "y.txt"), header = FALSE, sep = ",", skip = 1)##Se Cargan las Actividades
Activitylabels<-read.table(paste0(getwd(),"/UCI HAR Dataset/activity_labels.txt"), header = FALSE, sep = "")##Se Cargan las Actividades
ActivityWithLabels<-merge(DataActivity,Activitylabels, by.x = "V2", by.y = "V1")

select(ActivityWithLabels, V1, V2.y)%>%arrange(V1)
ActivitiesOrdered<-select(ActivityWithLabels, V1, V2.y)%>%arrange(V1)
ActivitiesOrdered<-ActivitiesOrdered[,2]
DataX<-cbind(ActivitiesOrdered,DataX)

rm(ActivitiesOrdered,Activitylabels,DataActivity,encabezados,Subject,subjects)
#length(grep("([Mm]ean|[Ss]td)|subjects|ActivitiesOrdered", names(DataX)))
TidyDataX<-DataX[,grep("([Mm]ean|[Ss]td)|subjects|ActivitiesOrdered", names(DataX))]


###############################TidyData for X
tidydatadftb<-tbl_df(TidyDataX)

############Gruped by Subject and Activity and getss the mean of all Columns
groupedByActivityAndSubj<-group_by(TidyDataX,ActivitiesOrdered, subjects )%>%summarise_all(list(mean))









  












