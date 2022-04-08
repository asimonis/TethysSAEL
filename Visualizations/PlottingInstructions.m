
addpath('C:\Users\anne.simonis\Tethys')
q= dbInit()
dbSpeciesFmt(q,'Input', 'Abbrev', 'NOAA.NMFS.v4')


project = 'CCES';
deployment = 16 ;
species = 'Zc';


detections = dbGetDetections(q,'Project',project,'Deployment',deployment,'SpeciesID',species);
starttime = min(detections(:,1));
endtime = max(detections(:,2));

sensor = dbDeploymentInfo(q, 'Project',project,'DeploymentID', deployment);

night = dbDiel(q, sensor(1).DeploymentDetails.Latitude{1}, ...
 sensor(1).DeploymentDetails.Longitude{1}, starttime, endtime);

visPresence(q,detections)

UTCOffset = -8; 

nightH = visPresence(night, 'Color', 'black', 'LineStyle',...
 'none', 'Transparency', .15,'Resolution_m', 1/60, ...
 'DateRange',[starttime, endtime],'UTCOffset', UTCOffset);

speciesH = visPresence(detections, 'Color', 'b', ...
 'Resolution_m', 2, 'UTCOffset', UTCOffset);