function CSPraw2ProcessedNoDB(site,user)
%function CSPraw2ProcessedNoDB(site,user)
%
%Function that renames the image data from the raw filename and stored in the Raw Image folder. Image data is renamed
%according to Argus file naming convention and then moved to the Processed
%Image folder. This version does not rely on the CoastSnap database and is
%intended for other camera systems (not CoastSnap)
%
%Created by Mitch Harley
%28/2/2020

%First, load paths
CSPloadPaths

%First find path of DB Excel file and read database
siteDB = CSPreadSiteDB(site); %Read metadata

%Read image times - make sure Excel format is as below
if isempty(strfind(txt{2,3},'PM'))||isempty(strfind(txt{2,3},'AM')) %if using AM/PM
    imtimes = datenum(char(txt{2:end,3}),'dd/mm/yyyy HH:MM:SS AM');
else
    imtimes = datenum(char(txt{2:end,3}),'dd/mm/yyyy HH:MM:SS'); %if using 24 hour clock
end

%Read through images found in Raw file
imagedir = [image_path filesep site filesep 'Raw' filesep];
images = dir([imagedir '*.jpg']);
lastrow = length(data)+1; %Last row where data exists in the CoastSnapDB

%Loop through images in Raw data directory
for i = 1:length(images)
    filename = images(i).name;
    disp(['Renaming image ' num2str(i) ' of ' num2str(length(images)) ' (' filename ')'])
    
    exif = imfinfo(fullfile(imagedir,fname));
    if isfield('DateTime')
        time = datenum(exif.DateTime,'yyyy:mm:dd HH:MM:SS');
    else
        newtime = inputdlg('No image time found in image exif data. Please input a time (format dd/mm/yyyy HH:MM)','Image time','dd/mm/yyyy HH:MM');
        time = datenum(char(newtime),'dd/mm/yyyy HH:MM');
    end
    gmt_time = time-siteDB.timezone.gmt_offset/24;
    epochtime = matlab2Epoch(gmt_time);
    user = strrep(user,'_',''); user = strrep(user,'.',''); %Get rid of underscore or full stops if any exists
    newname = CSPargusFilename(epochtime,site,-1,lower(imtype),char(user),'jpg');
    year = datestr(gmt_time+siteDB.timezone.gmt_offset/24,'YYYY'); %Have subdirectory of years to not get too confusing
    newdir = fullfile(strrep(imagedir,'Raw','Processed'),year);
    movefile([imagedir images(i).name],[newdir filesep newname],'f');
end
disp('All raw files successfully moved to the processed folder')