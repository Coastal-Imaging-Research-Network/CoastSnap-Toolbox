function out = CSPmapShoreline(rect_fname,type,option)
%
%function out = CSPmapShoreline(rect_fname,type,option)
%
%rect_fname = .mat filename of rectfied image you wish to map the shoreline
%type = 'CCD' for using Colour Channel Divergence shoreline mapping
%     = 'HUE' for mapping shorelines on the HUE channel
%option = 'manual' (default) for individual shoreline mapping and editing
%       = 'auto' for mapping shorelines automatically and storing it in a
%       temp directory to be QA'd at a later dat
%
%Created by Mitch Harley
% June 2018


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
    option = 'manual';
elseif nargin == 1
    type = 'CCD';
    option = 'manual';
end

go = 1;

%Check if shoreline has already been mapped
fileparts = CSPparseFilename(rect_fname);
site = fileparts.site;
rectdir = fullfile(image_path,site,'Rectified',fileparts.year);
sldir = fullfile(shoreline_path,site,fileparts.year);
sl_fname = strrep(rect_fname,'plan','shoreline'); %Rectified is called plan to keep with Argus conventions
sldirtemp = fullfile(shoreline_path,site,'temp'); %Check temp directory as well
if exist(fullfile(sldir,sl_fname),'file')||exist(fullfile(sldirtemp,sl_fname),'file')
    if strcmp(option,'manual') %If in manual mode, ask user if they want to map the shoreline even though it exists
        ButtonName = questdlg('Shoreline already exists. Do you want to map it anyway?','Continue?','Yes','No','No');
        switch ButtonName
            case 'No'
                go = 0;
                disp('Shoreline not mapped')
            case 'Yes'
                go = 1;
        end
    elseif strcmp(option,'auto') %If in auto mode, skip the shoreline
        disp('Shoreline already exists for this time. Shoreline will not be mapped')
        go = 0;
    end
end


if go ==1
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
        if strcmp(option,'manual') %In manual mode, user manually edits shoreline before saving shoreline
            sl = mapShorelineCCD(xgrid,ygrid,Iplan,SLtransects,1);
        elseif strcmp(option,'auto') %In auto mode, user does not manually edit shoreline before saving shoreline (this is done later in batch editing)
            sl = mapShorelineCCD(xgrid,ygrid,Iplan,SLtransects,0); %editmode set to 0
        end
    elseif strcmp(type,'HUE')
        if strcmp(option,'manual') %In manual mode, user manually edits shoreline before saving shoreline
            sl = mapShorelineHUE(xgrid,ygrid,Iplan,SLtransects,1);
        elseif strcmp(option,'auto') %In auto mode, user does not manually edit shoreline before saving shoreline (this is done later in batch editing)
            sl = mapShorelineHUE(xgrid,ygrid,Iplan,SLtransects,0); %editmode set to 0
        end
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
    
    %Save shoreline
    if strcmp(option,'manual') %Ask user if they want to save shoreline if in manual mode
        button = questdlg('Do you want to save this shoreline to the database?','Save to DB?','Yes','No','No');
    switch button
        case 'Yes'
            savedir = [shoreline_path filesep site filesep fileparts.year filesep];
            savefname = strrep(rect_fname,'plan','shoreline');
            save(fullfile(savedir,savefname),'sl')
            disp('Shoreline saved to DB!!')
            close all
    end
    elseif strcmp(option,'auto')
         savedir = [shoreline_path filesep site filesep 'temp' filesep]; %Shorelines saved to a temporary directory
            savefname = strrep(rect_fname,'plan','shoreline');
            save(fullfile(savedir,savefname),'sl')
            disp('Shoreline saved to temporary DB')
            close all
    end
end