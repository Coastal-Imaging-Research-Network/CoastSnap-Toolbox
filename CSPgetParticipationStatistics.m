function out = CSPgetParticipationStatistics(site,startdate,enddate,rootID)

%Find path of DB file
CSPloadPaths
dbfile = fullfile([DB_path filesep 'CoastSnapDB.xlsx']);
exportfile = fullfile([DB_path filesep 'spotteron_export.xlsx']); %File exported from spotteron db, converted to Excel first
[data,txt] = xlsread(dbfile,'database');
siteDB = CSPreadSiteDB(site); %Read metadata

%Read image times - make sure Excel format is as below
if isempty(strfind(txt{2,3},'PM'))||isempty(strfind(txt{2,3},'AM')) %if using AM/PM
    imtimes = datenum(char(txt{2:end,3}),'dd/mm/yyyy HH:MM:SS AM');
else
    imtimes = datenum(char(txt{2:end,3}),'dd/mm/yyyy HH:MM:SS'); %if using 24 hour clock
end

%Convert to GMT time
imtimesGMT = imtimes;
Idefault= find(strcmp(txt(2:end,4),siteDB.timezone.name)); %e.g. AEDT = Australian Eastern Daylight Time
imtimesGMT(Idefault) = imtimesGMT(Idefault)-siteDB.timezone.gmt_offset/24; %Subtract the offset in hours to convert to gmt time
Ialternative = find(strcmp(txt(2:end,4),siteDB.timezone.alternative.name)); %e.g. AEDT = Australian Eastern Daylight Time
imtimesGMT(Ialternative) = imtimesGMT(Ialternative)-siteDB.timezone.alternative.gmt_offset/24; %Subtract the offset in hours to convert to default
imtimesLocal = imtimesGMT+siteDB.timezone.gmt_offset/24;

% %Get images coming from App not listed in DB
% [epochtimes,filenames,~,~] = CSPgetImageList(site,'Processed');
% I = NaN(length(epochtimes),1);
% for i = 1:length(epochtimes)
%     Iapp = strfind(filenames(i).name,'+'); %If taken by app, filename has a + in it instead of AEST
%     if isempty(Iapp)
%         I(i) = 0;
%     else
%         I(i) = 1;
%     end
% end
% Iapp = find(I==1);
% apptimes = CSPepoch2LocalMatlab(epochtimes(Iapp),siteDB.timezone.gmt_offset);

%Get images coming from App not listed in DB
[data1,txt1] = xlsread(exportfile);
Iroot = find(data1(:,2)==rootID); %RootID is 2nd column in export file
apptimes=datenum(char(txt1{Iroot+1,12}),'dd/mm/yyyy HH:MM:SS AM');

subtypes = {'Email','Facebook','Instagram','Twitter','App','Internal'};
dd = startdate:enddate;
M = NaN(length(dd),length(subtypes)); %Matrix of number of submissions for each type
for i = 1:length(dd)
J1 = find(floor(imtimesLocal)==dd(i)&strcmp(txt(2:end,1),site)&strcmp(txt(2:end,6),subtypes{1}));
J2 = find(floor(imtimesLocal)==dd(i)&strcmp(txt(2:end,1),site)&strcmp(txt(2:end,6),subtypes{2}));
J3 = find(floor(imtimesLocal)==dd(i)&strcmp(txt(2:end,1),site)&strcmp(txt(2:end,6),subtypes{3}));
J4 = find(floor(imtimesLocal)==dd(i)&strcmp(txt(2:end,1),site)&strcmp(txt(2:end,6),subtypes{4}));
J5=find(floor(apptimes)==dd(i));
J6 = find(floor(imtimesLocal)==dd(i)&strcmp(txt(2:end,1),site)&strcmp(txt(2:end,6),subtypes{6}));
M(i,1) = length(J1);
M(i,2) = length(J2);
M(i,3) = length(J3);
M(i,4) = length(J4);
M(i,5) = length(J5);
M(i,6) = length(J6);
end

out.dates = dd;
out.subtypes = subtypes;
out.stats_matrix = M;
