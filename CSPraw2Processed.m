function CSPraw2Processed(site)
%function CSPraw2Processed(site)
%
%Function that renames the image data from the raw filename downloaded from
%the internet and stored in the Raw Image folder. Image data is renamed
%according to Argus file naming convention and then moved to the Processed Image folder
%
%Created by Mitch Harley
%1/2/2018

%First, load paths
CSPloadPaths

%First find path of DB Excel file and read database
siteDB = CSPreadSiteDB(site); %Read metadata
CSPloadPaths
dbfile = fullfile([DB_path filesep 'CoastSnapDB.xlsx']);
[data,txt] = xlsread(dbfile,'database');

%Read image times - make sure Excel format is as below
imtimes = datenum(char(txt{2:end,3}),'dd/mm/yyyy HH:MM:SS AM');

%Convert to GMT time
imtimesGMT = imtimes;
Idefault= find(strcmp(txt(2:end,4),siteDB.timezone.name)); %AEDT = Australian Eastern Daylight Time
imtimesGMT(Idefault) = imtimesGMT(Idefault)-siteDB.timezone.gmt_offset/24; %Subtract the offset in hours to convert to gmt time
Ialternative = find(strcmp(txt(2:end,4),siteDB.timezone.alternative.name)); %AEDT = Australian Eastern Daylight Time
imtimesGMT(Ialternative) = imtimesGMT(Ialternative)-siteDB.timezone.alternative.gmt_offset/24; %Subtract the offset in hours to convert to default

%Read through images found in Raw file
imagedir = [image_path filesep site filesep 'Raw' filesep];
images = dir([imagedir '*.jpg']);

%%Load Astro tide
%tidedir = strrep(dbfile,['Database' filesep 'CoastSnapDB.xlsx'],'Tide Data');
%load(fullfile(tidedir,siteDB.tide.file))

%Loop through images in Raw data directory
for i = 1:length(images)
    disp(['Renaming image ' num2str(i) ' of ' num2str(length(images))])
    filename = images(i).name;    
    I = find(strcmp(filename,txt(:,5)));
    user = regexprep(txt{I,2},'[^\w'']','');
    imtype = regexprep(txt{I,7},'[^\w'']','');
    gmt_time = imtimesGMT(I-1);
    epochtime = matlab2Epoch(gmt_time);
    newname = CSPargusFilename(epochtime,site,-1,lower(imtype),user,'jpg')
    %newname = [datestr(imtimes(I-1),'yyyymmddHHMM') '_' station '_' user  '_astrotide_' num2str(tide_level,'%0.2f') 'mAHD.jpg']; %Need to subtract one to the index for imtimes
    year = datestr(gmt_time+siteDB.timezone.gmt_offset/24,'YYYY'); %Have subdirectory of years to not get too confusing
    newdir = fullfile(strrep(imagedir,'Raw','Processed'),year);
    movefile([imagedir images(i).name],[newdir filesep newname],'f');
end