#Prepare detections for Tethys
#Anne Simonis
#8April2022

#Sourcemap: SWFSC.Detections.Analyst.v1
#Create worksheet with 3 tabs: Detections, MetaData, Effort
#Optional (add later?): AdhocDetections

#required packages
library(dplyr)
library(xlsx)
library(openxlsx)

#Function inputs
userID<-'asimonis'
Project<-'CCES'
DepID<-4
Software<-'Pamguard'
Version<-'2.00.16'
PlotWin<-2
DriftFile<-paste0(Project,'0',DepID,'_BW_Detections.xlsx')
savedir<-'C:/Users/anne.simonis.NMFS/Documents/GitHub/TethysSAEL/Detection Worksheets/'

#Load detections
load('H:/CCES/CCES PAMGUARD Analyses 2_00_16/Databases/Final Databases_wGPS/CCES2018_BW_Detections.rda')
EventInfo$Call<-as.factor('Clicks/>20kHz')

#load deployment info
load('H:/CCES/CCES PAMGUARD Analyses 2_00_16/Databases/Final Databases_wGPS/CCES2018_Deployment_Metadata.rda')
Effort<-CCES2018%>%
  filter(DeploymentID==DepID)%>%
  select(Data_Start_UTC,Data_End_UTC,Site)%>%
  rename(EffortStart=Data_Start_UTC,EffortEnd=Data_End_UTC)
  
#Load effort sheet
EffortSheet<-read.xlsx2('SWFSC_bw_detections_test.xlsx',sheetName='Effort')

#Translate species codes from Barlow to NOAA.NMFS.v1
EventInfo$species<-as.factor(EventInfo$species)
EventInfo$species<-recode_factor(EventInfo$species,BB="Bb1",ZC="Zc",MS="Ms",'?BW'="UBW")

#Create dataframes for each tab
Detections<-EventInfo %>%
  filter(Deployment==DepID)%>%
  select(Id,species,Call,StartTime,EndTime,nClicks,minNumber,bestNumber,maxNumber,Latitude,Longitude)%>%
  mutate(across(where(is.character),as.numeric))%>%
  rename('Event Number'='Id',	'Species Code'='species',	'Call'='Call',	
         'Start time'='StartTime','End time'='EndTime',	'Parameter 1'='nClicks',
         'Parameter 2'='minNumber',	'Parameter 3'='bestNumber',
         'Parameter 4'='maxNumber',	'Parameter 5'='Latitude',	
         'Parameter 6'='Longitude')

AdhocDetections<-Detections[0,]#Don't currently have adhoc detections

MetaData<-data.frame(userID,Project,DepID,Site,Software,Version,PlotWin) 
MetaData<-cbind(MetaData,Effort)
MetaData<-MetaData%>%
rename('User ID'='userID',	'Deployment'='DepID',	
              'Click Viewer plot time m'='PlotWin',	'Effort Start'='EffortStart',
                 'Effort End'='EffortEnd') 

EffortSheet<-rename(EffortSheet,'Common Name'='Common.Name',	
                    'Species Code'='Species.Code','Parameter 1'='Parameter.1',
                    'Parameter 2'='Parameter.2','Parameter 3'='Parameter.3',
                    'Parameter 4'='Parameter.4','Parameter 5'='Parameter.5',
                    'Parameter 6'='Parameter.6')

#Create worksheet
wb = createWorkbook()

shtMetaData = addWorksheet(wb, "MetaData")
shtEffort = addWorksheet(wb, "Effort")
shtDetections = addWorksheet(wb, "Detections")
shtAdhocDetections = addWorksheet(wb, "AdhocDetections")

writeData(wb,shtMetaData,MetaData)
writeData(wb,shtEffort,EffortSheet)
writeData(wb,shtDetections,Detections)
writeData(wb,shtAdhocDetections,AdhocDetections) 
saveWorkbook(wb,DriftFile,overwrite=TRUE)
