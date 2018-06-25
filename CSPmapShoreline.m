function out = CSPmapShoreline(rect_fname,type)
%
%function out = CSPmapShoreline(rect_fname)


%Load paths
CSPloadPaths
rectdir = base_path;

if nargin == 0
        %Prompt user to select rectified mat file
    [rect_fname,pname]=uigetfile([rectdir '*.mat'],...
        'Select rectified CoastSnap .mat file');
    if isnumeric(rect_fname)|isnumeric(pname)
        out=[];
        error('¡¡ No file selected !!')
    end
    type = 'CCD';
elseif nargin == 1
    type = 'CCD';
end

%Read file
fileparts = CSPparseFilename(rect_fname);
site = fileparts.site;
rectdir = fullfile(image_path,site,'Rectified',fileparts.year);

%Load rectified image
load(fullfile(rectdir,rect_fname))

%Display rectified image
%f1 = figure;
%image(xgrid,ygrid,Iplan)
%axis image; axis xy

%Read siteDB
siteDB = CSPreadSiteDB(site);
load(fullfile(transect_dir,siteDB.sl_settings.transect_file)) %transect_dir found from CSPloadPaths

%Map Shoreline
addpath('../Shoreline-Mapping-Toolbox') %Relevant file (mapShorelineCCD.m) found in shoreline mapping toolbox
if strcmp(type,'CCD')
    sl = mapShorelineCCD(xgrid,ygrid,Iplan,SLtransects,1);
elseif strcmp(type,'HUE')
    sl = mapShorelineHUE(xgrid,ygrid,Iplan,SLtransects,1);
end

%Add eastings and northings
out.whenDone = matlab2Epoch(now-siteDB.timezone.gmt_offset/24); %Get time when done in epochtime (similar to argus)
out.xyz = [sl.x sl.y metadata.rectz*ones(size(sl.x))]; %Output as a Mx3 matrix to be the same as 
out.UTM = [sl.x+siteDB.origin.eastings sl.y+siteDB.origin.northings metadata.rectz*ones(size(sl.x))];
out.UTMzone = siteDB.UTMzone;
UV = findUVnDOF(metadata.geom.betas,out.xyz,metadata.geom); %Its good practise to store the original Image UV data of the shoreline so you don't have to redo the geometry
out.UV = reshape(UV,length(out.xyz),2);
out.method = sl.method;
out.threshold = sl.threshold;
sl = out;

%Ask user if they want to save shoreline
button = questdlg('Do you want to save this shoreline to the database?','Save to DB?','Yes','No','No');
switch button
    case 'Yes'
        savedir = [shoreline_path filesep site filesep fileparts.year filesep];
        savefname = strrep(rect_fname,'plan','shoreline');
        save(fullfile(savedir,savefname),'sl')
        close all
end