function CSPGmapShoreline(handles)

%Get info stored in oblq_image UserData
data = get(handles.oblq_image,'UserData');
siteDB = data.siteDB;

%First check if shoreline has already been mapped
CSPloadPaths %Load data paths
fileparts = CSPparseFilename(data.fname);
site = fileparts.site;
sldir = fullfile(shoreline_path,site,fileparts.year);
sl_fname = strrep(data.fname,'snap','shoreline');
sl_fname = strrep(sl_fname,'.jpg','.mat');
go = 1;
if exist(fullfile(sldir,sl_fname),'file')
    ButtonName = questdlg('Shoreline already exists. Do you want to map a new shoreline?','Continue?','Yes','No','No');
    switch ButtonName
        case 'No'
            go = 0;
            disp('Shoreline chosen to not be mapped')
        case 'Yes'
            go = 1;
    end  
end

if go ==1
    
    %Get geom data from plan_image
    data_plan = get(handles.plan_image,'UserData');
    metadata = data_plan.metadata;
    
    %Remove any existing shorelines plotted on the figure
    if exist('data_plan.sl_handle_plan')
     
    delete(data_plan.sl_handle_oblq);
    end
    
    %Load transect dir from DB
    load(fullfile(transect_dir,siteDB.sl_settings.transect_file)) %transect_dir found from CSPloadPaths
    
    %Map Shoreline
    addpath('../Shoreline-Mapping-Toolbox') %Relevant file (mapShorelineCCD.m) found in shoreline mapping toolbox
    type = 'CCD'; %Only consider CCD here
    if strcmp(type,'CCD')
       sl = mapShorelineCCD(data_plan.xgrid,data_plan.ygrid,data_plan.Iplan,SLtransects,0,0); %Turn edit and plot mode off in GUI
        elseif strcmp(type,'HUE')
       sl = mapShorelineHUE(data_plan.xgrid,data_plan.ygrid,data_plan.Iplan,SLtransects,0,0);
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
    out.QA = 1; %Boolean to say whether data has been QA'd or not (for autoshoreline mapping)
    sl = out;
    data_plan.sl = sl;
    
    
    %Plot data on both oblq and plan image
    axes(handles.plan_image)
    hold on
    sl_handle_plan = plot(sl.xyz(:,1),sl.xyz(:,2),'y','linewidth',4);
    data_plan.sl_handle_plan = sl_handle_plan;
    axes(handles.oblq_image)
    hold on
    sl_handle_oblq = plot(sl.UV(:,1),sl.UV(:,2),'y','linewidth',4);
    data.sl_handle_oblq = sl_handle_oblq;

    %Update user data
    set(handles.plan_image,'UserData',data_plan);
    set(handles.oblq_image,'UserData',data);
end
  