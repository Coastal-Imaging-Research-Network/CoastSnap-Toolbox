%This file contains all the necessary path information for your local
%CoastSnap database. It is called in almost all files in the CoastSnap
%Toolbox
%
%Mitch Harley, June 2018

%Load various paths
base_path = 'C:\Users\z2273773\Google Drive\CoastSnap\';
DB_path = fullfile(base_path,'Database'); %Path where database is located
image_path = fullfile(base_path,'Images'); %Path where all images are stored
shoreline_path = fullfile(base_path,'Shorelines'); %Path where shorelines are stored
tide_path = fullfile(base_path,'Tide Data'); %Path where tide data are stored
transect_dir = fullfile(base_path,'Shorelines','Transect Files'); %Path where transects are stored for shoreline mapping

%Add relevant paths to Matlab
support_routines_path = 'C:\Users\z2273773\OneDrive - UNSW\RESEARCH2\GitHub\Support-Routines'; %Path where support routines are stored (e.g. matlab2Epoch)
shoreline_mapping_toolbox_path = 'C:\Users\z2273773\OneDrive - UNSW\RESEARCH2\GitHub\CoastSnap-Toolbox'; %Path where the shoreline mapping toolbox is located
addpath(support_routines_path)
addpath(shoreline_mapping_toolbox_path)