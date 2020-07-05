function out = CSPreadSiteDB(site)
%
%function out = CSPreadSiteDB(site)
%
%Function that reads the station metadata stored in the Excel Spreadsheet
%'CoastSnapDB.xlsx' and stores it as a matlab structure. Refer to the file
%CSPloadPaths for the location of the Database
%
%site = name of site you want to read (should be same as name of sheet in
%Excel file)
%
%Created by Mitch Harley
%1/2/2018

%Find path of DB file
CSPloadPaths
dbfile = fullfile([DB_path filesep 'CoastSnapDB.xlsx']);

%Read xlsx file at sheet corresponding to site of interest
[data,txt,raw] = xlsread(dbfile,site);

%Read station origin
I = find(strcmp(raw(:,1),'Station Data'));
out.origin.eastings = cell2mat(raw(I+1,2)); %Origin eastings should be first row after Station Data
out.origin.northings = cell2mat(raw(I+2,2));
out.origin.z = cell2mat(raw(I+3,2));
I = find(strcmp(raw(:,1),'UTM Zone'));
out.UTMzone = char(raw(I,2));

%Read station timezone info
I = find(strcmp(raw(:,1),'Default Timezone'));
out.timezone.name = char(raw(I,2));
I = find(strcmp(raw(:,1),'Default Timezone Offset From GMT'));
out.timezone.gmt_offset = cell2mat(raw(I,2));
I = find(strcmp(raw(:,1),'Alternative Timezone'));
out.timezone.alternative.name = char(raw(I,2));
I = find(strcmp(raw(:,1),'Alternative Timezone Offset From GMT'));
out.timezone.alternative.gmt_offset = cell2mat(raw(I,2));

%Read rectification settings
I1 = find(strcmp(raw(:,1),'Xlimit left'));
I2 = find(strcmp(raw(:,1),'Xlimit right'));
out.rect.xlim = [cell2mat(raw(I1,2)) cell2mat(raw(I2,2))];
I1 = find(strcmp(raw(:,1),'Ylimit lower'));
I2 = find(strcmp(raw(:,1),'Ylimit upper'));
out.rect.ylim = [cell2mat(raw(I1,2)) cell2mat(raw(I2,2))];
I = find(strcmp(raw(:,1),'Resolution'));
out.rect.res = cell2mat(raw(I,2));
I = find(strcmp(raw(:,1),'Initial Azimuth Estimate'));
out.rect.initial.azimuth = cell2mat(raw(I,2));
I = find(strcmp(raw(:,1),'Initial Tilt Estimate'));
out.rect.initial.tilt = cell2mat(raw(I,2));
I = find(strcmp(raw(:,1),'Initial Roll Estimate'));
out.rect.initial.roll = cell2mat(raw(I,2));
I = find(strcmp(raw(:,1),'Tidal offset'));
out.rect.tidal_offset = cell2mat(raw(I,2));
I1 = find(strcmp(raw(:,1),'Min FOV'));
I2 = find(strcmp(raw(:,1),'Max FOV'));
out.rect.FOVlims = [cell2mat(raw(I1,2)) cell2mat(raw(I2,2))];
I = find(strcmp(raw(:,1),'Acceptable Accuracy'));
out.rect.accuracylim = cell2mat(raw(I,2));

%Calculate rotation angle TO BE ADDED IN THE FUTURE

%Get tidal data file
I = find(strcmp(raw(:,1),'Tide file'));
out.tide.file = char(raw(I,2));

%Get shoreline mapping settings
I = find(strcmp(raw(:,1),'Transect file'));
out.sl_settings.transect_file = char(raw(I,2));
I = find(strcmp(raw(:,1),'Transect averaging region')); 
out.sl_settings.transect_averaging_region = str2num(cell2mat(raw(I,2)));
I = find(strcmp(raw(:,1),'Characteristic beach slope')); 
out.sl_settings.beach_slope = cell2mat(raw(I,2));

%Get GCPs
I = find(strcmp(raw(:,1),'GCP name'));
for i = 1:length(I)
    out.gcp(i).name = char(raw(I(i),2));
    out.gcp(i).eastings = cell2mat(raw(I(i)+1,2));
    out.gcp(i).northings = cell2mat(raw(I(i)+2,2));
    out.gcp(i).z = cell2mat(raw(I(i)+3,2));
end

%Get GCP combos
I = find(strcmp(raw(:,1),'GCP combo'));
out.gcp_combo = str2num(cell2mat(raw(I,2)));

