function [epochtimes,filenames,filepaths,tide_levels] = CSPgetImageList(site,type)
%
%[epochtimes,filenames,filepaths,tide_levels] = CSPgetImageList(site,type)
%
%Function that finds epoch times (in GMT) and associated tide levels of all
%processed images in database for a particular site
%
%site = sitename (e.g. 'byron')
%type = 'Processed' for processed images, 'Registered' for registered images or 'Rectified' for rectified
%images
%
%Created by Mitch Harley
%June, 2018


%First load paths
CSPloadPaths

%Next, loop through folders of image path to find shorelines stored as
%mat files
folders = dir(fullfile(image_path,site,type));
epochtimes = [];
p = 1;
for i = 1:length(folders)
    if folders(i).isdir&&length(folders(i).name)==4 %folder is most likely a year here if it has length 4
        files = dir([fullfile(image_path,site,type,folders(i).name) filesep '*.jpg']);
        for j = 1:length(files)
            out = CSPparseFilename(files(j).name);
            epochtimes = [epochtimes str2num(out.epochtime)];
            filenames(p).name = files(j).name;
            filepaths(p).name = fullfile(image_path,site,type,folders(i).name);
            p = p+1;
        end
    end
end

%Now get tide_levels associated with epochtimes in shoreline database
tide_levels = CSPgetTideLevel(epochtimes,site);
        


    