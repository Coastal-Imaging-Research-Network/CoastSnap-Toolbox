function [epochtimes,filenames,tide_levels] = CSPgetShorelineList(site)
%
%[epochtimes,tide_levels] = CSPgetShorelineList(site)
%
%Function that finds epoch times (in GMT) and associated tide levels of all
%shorelines saved in database for a particular site
%
%Created by Mitch Harley
%June, 2018

%First load paths
CSPloadPaths

%Next, loop through folders of shoreline path to find shorelines stored as
%mat files
folders = dir(fullfile(shoreline_path,site));
epochtimes = [];
p = 1;
for i = 1:length(folders)
    if folders(i).isdir&&length(folders(i).name)==4 %folder is most likely a year here if it has length 4
        files = dir([fullfile(shoreline_path,site,folders(i).name) filesep '*.mat']);
        for j = 1:length(files)
            out = CSPparseFilename(files(j).name);
            epochtimes = [epochtimes str2num(out.epochtime)];
            filenames(p).name = files(j).name;
            p = p+1;
        end
    end
end

%Now get tide_levels associated with epochtimes in shoreline database
tide_levels = CSPgetTideLevel(epochtimes,site);
        


    