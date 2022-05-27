#Sourcemap: SWFSC.Detections.Analyst.v1
#Create worksheet with 3 tabs: Detections, MetaData, Effort
#Optional (add later?): AdhocDetections

#required packages
library(dplyr)
library(xlsx)
library(openxlsx)


#Prepare detections for Tethys
#Anne Simonis
#8April2022
#Function inputs
userID<-'jtrickey'
Project<-'CCES'
Dep<-c(7,8,10,12,13,14,16,18,19,20,21,22,23)
Software<-'Pamguard'
Version<-'2.00.16'
PlotWin<-2
savedir<-'C:/Users/anne.simonis.NMFS/Documents/GitHub/TethysSAEL/Detection Worksheets/'

#Load detections
load('H:/NBHF/NBHF_cces/databases_wGPS/CCES2018_NBHF_Detections.rda')
EventInfo$Call<-as.factor('Clicks/>100kHz')

#load deployment info
load('H:/CCES/CCES PAMGUARD Analyses 2_00_16/Databases/Final Databases_wGPS/CCES2018_Deployment_Metadata.rda')

for(d in 1:length(Dep)){ 
  DepID<-Dep[d]
  DriftFile<-paste0(savedir,Project,'0',DepID,'_NBHF_Detections.xlsx')
  Effort<-CCES2018%>%
  filter(DeploymentID==DepID)%>%
  select(Data_Start_UTC,Data_End_UTC,Site)%>%
  rename(EffortStart=Data_Start_UTC,EffortEnd=Data_End_UTC)

#Load effort sheet
EffortSheet<-read.xlsx2('C:/Users/anne.simonis.NMFS/Documents/GitHub/TethysSAEL/Detection Worksheets/SWFSC_NBHF_effort.xlsx',sheetName='Effort')

#Translate species codes from Barlow to NOAA.NMFS.v1
EventInfo$species<-as.factor(EventInfo$species)
# EventInfo$species<-recode_factor(EventInfo$species,NBHF="NBHF")

#Create dataframes for each tab
Detections<-EventInfo %>%
  filter(Deployment==DepID)%>%
  select(Id,species,Call,StartTime,EndTime,nClicks,minNumber,bestNumber,maxNumber,Latitude,Longitude)%>%
  mutate(across(where(is.character),as.numeric))%>%
  rename('Event Number'='Id',	'Species Code'='species',	'Call'='Call',	
         'Start time'='StartTime','End time'='EndTime',	'Count'='nClicks')
Detections$Count<-as.integer(round(Detections$Count))

AdhocDetections<-Detections[0,]#Don't currently have adhoc detections

MetaData<-data.frame(userID,Project,DepID,Software,Version,PlotWin) 
MetaData<-cbind(MetaData,Effort)
MetaData<-MetaData%>%
  rename('User ID'='userID',	'Deployment'='DepID',	
         'Click Viewer plot time m'='PlotWin',	'Effort Start'='EffortStart',
         'Effort End'='EffortEnd') 

EffortSheet<-rename(EffortSheet,'Common Name'='Common.Name',	
                    'Species Code'='Species.Code','Count'='Count')

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
}

