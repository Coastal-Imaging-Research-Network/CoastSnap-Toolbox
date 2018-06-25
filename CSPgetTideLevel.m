function tide = CSPgetTideLevel(epochtime,site)
%
%function out = CSPgetTideLevel(epochtime,site)
%
%Function that gets the tide level for the relevant epoch (UNIX) time. Note
%that the tide file is in the local default timezone, whereas the input is
%in GMT epochtime which is easily read from the image file
%
%Created by Mitch Harley
%June, 2018


%Load local path information
CSPloadPaths

%Load siteDB info from CoastSnapDB.xlsx
siteDB = CSPreadSiteDB(site);

%Load relevant tide file
load([tide_path filesep siteDB.tide.file])

%First, convert epoch time to matlab time in default timezone
matlabtimelocal = epoch2Matlab(epochtime)+siteDB.timezone.gmt_offset/24;

%Interpolate tide from record
tide = interp1(tide.time,tide.level,matlabtimelocal);
