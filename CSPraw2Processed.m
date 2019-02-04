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
dbfile = fullfile([DB_path filesep 'CoastSnapDB.xlsx']);
[data,txt] = xlsread(dbfile,'database');

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

%Read through images found in Raw file
imagedir = [image_path filesep site filesep 'Raw' filesep];
images = dir([imagedir '*.jpg']);
lastrow = length(data)+1; %Last row where data exists in the CoastSnapDB

%Loop through images in Raw data directory
for i = 1:length(images)
    disp(['Renaming image ' num2str(i) ' of ' num2str(length(images))])
    filename = images(i).name;
    
    %Automatically write database xls file if the 4K STogram program has
    %been used to get the hashtag
    if length(filename)==58 %Filename lengths for 4KStogram are 58 characters lonog
        lastrow = lastrow+1;
        fourKstogramdate = datenum(filename(1:16),'yyyy-mm-dd HH.MM');
        II = imread(fullfile(imagedir,filename));
        imagefig=figure;
        image(II) %Display image for user
        axis image
        user = inputdlg(['What is the instagram username for this image uploaded on the ' datestr(fourKstogramdate,'dd/mm/yyyy HH:MM') '?']);
        close(imagefig)
        timezone = questdlg('Please select the appropriate time zone','Timezone selection',siteDB.timezone.name,siteDB.timezone.alternative.name,siteDB.timezone.name);
        timequality = questdlg('Please select the accuracy of the image time (1 = stated time, 2 = good upload time, 3 = poor upload time)','Image time accuracy',1,2,3,2);
        if timequality~=2 %If the user actually stated the time
            newtime = inputdlg('Please input the time as indicated by the user, or if quality=3 take a guess (format dd/mm/yyyy HH:MM)','New time',1,{datestr(fourKstogramdate,'dd/mm/yyyy HH:MM')});
            fourKstogramdate = datenum(char(newtime),'dd/mm/yyyy HH:MM');
        end
        startcell = ['A' num2str(lastrow)];
        imtype = 'Snap'; %Assume it is a snap
        newdata = [site,user, datestr(fourKstogramdate,'dd/mm/yyyy HH:MM'),timezone,filename,'Instagram',imtype,timequality];
        xlswrite(dbfile,newdata,'database',startcell) %Write new line in spreadsheet
        %Get GMT Time
        if strcmp(timezone,siteDB.timezone.name);
            gmt_time = fourKstogramdate-siteDB.timezone.gmt_offset/24;
        elseif strcmp(timezone,siteDB.timezone.alternative.name);
            gmt_time = fourKstogramdate-siteDB.timezone.alternative.gmt_offset/24;
        end
    else
        I = find(strcmp(filename,txt(:,5)));
        user = regexprep(txt{I,2},'[^\w'']','');
        imtype = regexprep(txt{I,7},'[^\w'']','');
        gmt_time = imtimesGMT(I-1);
    end
    
    epochtime = matlab2Epoch(gmt_time);
    user = strrep(user,'_',''); user = strrep(user,'.',''); %Get rid of underscore or full stops if any exists
    newname = CSPargusFilename(epochtime,site,-1,lower(imtype),char(user),'jpg');
    year = datestr(gmt_time+siteDB.timezone.gmt_offset/24,'YYYY'); %Have subdirectory of years to not get too confusing
    newdir = fullfile(strrep(imagedir,'Raw','Processed'),year);
    movefile([imagedir images(i).name],[newdir filesep newname],'f');
end
disp('All raw files successfully moved to the processed folder')