%First, load paths
CSPloadPaths
user = 'Jake Cosgrove';
%timezone = 'AEDT';
timezone = 'AEST';

%Read files in directory
EZdir = 'C:\Users\z2273773\Google Drive\CoastSnap\Images\share_link\stockton1';
files1 = dir([EZdir filesep '*.jpg']);files2 = dir([EZdir filesep '*.jpeg']);
files = [files1; files2];
dbfile = fullfile([DB_path filesep 'CoastSnapDB.xlsx']);
[data,txt] = xlsread(dbfile,'database');
lastrow = length(data)+1; %Last row where data exists in the CoastSnapDB

%Get lat lon of sites
lats = NaN(length(files),1);
lons = NaN(length(files),1);
sites = {'manly','nthnarra','blacksmiths','byron'};
UTM = {'56 H','56 H','56 H','56 J'};
sitelat = NaN(length(sites),1);
sitelon = NaN(length(sites),1);
for i = 1:length(sites)
    siteDB = CSPreadSiteDB(sites{i}); %Read metadata
    [sitelat(i),sitelon(i)]=utm2deg(siteDB.origin.eastings,siteDB.origin.northings,UTM{i});
end

%Loop through images to classify accordingly
distthresh = 0.05;
for i = 1:length(files)
    lastrow = lastrow+1;
    fname = files(i).name;
    %C = strsplit(fname,'_');
    exif = imfinfo(fullfile(EZdir,fname));
    timequality = 2;
    if isfield(exif,'DateTime') %If there is Exif data on the capture time
        time = datenum(exif.DateTime,'yyyy:mm:dd HH:MM:SS');
        timequality = 1; %Trust the exif data
        %else
        %    time = datenum(C{2},'yyyymmddHHMM'); %Time email was sent
        %    timequality = 2; %Have less trust in time coming from email time sent
    end
    %user = C{3};
    %subject = C{4};
    %C2 = strsplit(user,'@'); %If user is an email address, take part before @ sign
    %user = C2{1};
    if isfield(exif,'GPSInfo')
        if isfield(exif.GPSInfo,'GPSLatitude')
            lat = exif.GPSInfo.GPSLatitude;
            if lat(3)==60
                lat(2) = lat(2)+1;
                lat(3) = 0;
            end
            lats = dms2degrees(lat);
            lons = dms2degrees(exif.GPSInfo.GPSLongitude);
            dists = sqrt((-lats-sitelat).^2+(lons-sitelon).^2);
            I = find(dists<distthresh);
            if length(I)==1;
                thissite = sites{I};
            else thissite = 'unclassified';
            end
        else thissite = 'unclassified';
        end
    else
        thissite = 'unclassified';
    end
    
    %     %Next try to classify sites based on subject
    %     if strcmp(thissite,'unclassified');
    %     if ~isempty(strfind(lower(subject),'manly'))
    %         thissite = 'manly';
    %     elseif ~isempty(strfind(lower(subject),'narra'))
    %         thissite = 'nthnarra';
    %     elseif ~isempty(strfind(lower(subject),'byron'))
    %         thissite = 'byron';
    %     elseif ~isempty(strfind(lower(subject),'black'))
    %         thissite = 'blacksmiths';
    %     end
    
    
    %Next try to classify sites based on user
    if ~isempty(strfind(lower(user),'gnarf'))
        thissite = 'nthnarra';
    elseif ~isempty(strfind(lower(user),'cheryl white'))
        thissite = 'manly';
    elseif ~isempty(strfind(lower(user),'jenny harley'))
        thissite = 'manly';
    elseif ~isempty(strfind(lower(user),'Jady Swinkels'))
        thissite = 'blacksmiths';
          elseif ~isempty(strfind(lower(user),'Jake Cosgrove'))
        thissite = 'stockton2';
    end
    
    
    %Update DB and move file
    startcell = ['A' num2str(lastrow)];
    imtype = 'Snap'; %Assume it is a snap
    filename = files(i).name;
    filename = strrep(filename,'jpeg','jpg'); %Change file extension to jpg
    newdata = {thissite,user, datestr(time,'dd/mm/yyyy HH:MM'),timezone,filename,'Email',imtype,timequality};
    xlswrite(dbfile,newdata,'database',startcell) %Write new line in spreadsheet
    if strcmp(thissite,'unclassified')
        movefile([EZdir filesep files(i).name],[image_path filesep thissite filesep filename],'f')
    else
        movefile([EZdir filesep files(i).name],[image_path filesep thissite filesep 'Raw' filesep filename],'f')
    end
    disp(['File moved to site ' thissite ' Raw directory'])
end







