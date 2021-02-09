function data = CSPGloadImage(handles,pname,fname)

%First clear all figures and data
axes(handles.oblq_image)
hold off
axes(handles.plan_image)
hold off
%Get the "navigation" info from previous image if you have already loaded
%image previously
if nargin==3
    data = get(handles.oblq_image,'UserData');  
    navigation = data.navigation;
end
set(handles.oblq_image, 'UserData',[]);%Reset data
set(handles.plan_image, 'UserData',[]);%Reset data
CSPloadPaths
data.path = image_path;
set(handles.oblq_image, 'UserData',data);

%Prompt user to select processed image
if nargin==1 %If this is being called from the load image button
    [fname,pname]=uigetfile([data.path filesep '*.jpg'],'Select CoastSnap Image .jpg file from Processed Folder');
end

if isnumeric(fname)|isnumeric(pname)
   data=[];
   error('No file selected!!')
end
I = imread(fullfile(pname,fname)); %Read image
disp('Image loaded to GUI')
axes(handles.oblq_image) %Plot to oblq image axis
set(handles.oblq_image, 'Visible','on');
imagesc(I)
hold on
title(fname,'Interpreter','none')
axis off
data.I = I;
data.fname = fname;
data.pname = pname;
set(handles.plan_image,'Visible','off');%Hide axis of plan image

%Check if image has already been rectified and shoreline mapped
rect_path = strrep(pname,'Processed','Rectified');
rect_path = strrep(rect_path,'Registered','Rectified'); %For Registered images
rect_name = strrep(fname,'snap','plan'); %Rectified is called plan to keep with Argus conventions
rect_name = strrep(rect_name,'timex','plan'); %For timex images
if exist(fullfile(rect_path,rect_name),'file')
    load(strrep(fullfile(rect_path,rect_name),'.jpg','.mat'));
    set(handles.plan_image, 'Visible','on');%Show axis of plan image
    axes(handles.plan_image)
    imagesc(xgrid,ygrid,Iplan);
    hold on
    xlabel('Eastings [m]'); ylabel('Northings [m]'); title('Rectified Image');
    axis xy;axis image; grid on
    data_plan.xgrid = xgrid;
    data_plan.ygrid = ygrid;
    data_plan.Iplan = Iplan;
    data_plan.metadata = metadata;
    axes(handles.oblq_image) %Plot to oblq image axis
    if ~isnan(metadata.gcps.UVpicked) %If rectification was done using bulk mode, this is set to NaN
        gcp_handle_oblq = plot(metadata.gcps.UVpicked(:,1),metadata.gcps.UVpicked(:,2),'go','markerfacecolor', 'g', 'markersize', 3);
    else
        gcp_handle_oblq =NaN;
        disp('Image appears to have been rectified using bulk mapper. Manually-picked points will not be shown')
    end
    data.gcp_handle_oblq = gcp_handle_oblq;
    set(handles.plan_image,'UserData',data_plan) %Store rectified info in userdata of plan_image
end
imdata = CSPparseFilename(fname);
sldir = fullfile(shoreline_path,imdata.site,imdata.year);
sl_fname = strrep(fname,'snap','shoreline');
sl_fname = strrep(sl_fname,'timex','shoreline'); %To deal with timex images as well
sl_fname = strrep(sl_fname,'.jpg','.mat');
if exist(fullfile(sldir,sl_fname),'file')
    shoreline = load(fullfile(sldir,sl_fname));
    axes(handles.plan_image)
    if isfield(shoreline.sl,'QA')&&shoreline.sl.QA==0
        sl_color = 'r'; %Make shoreline colour red if it is nonQA'd
    else
        sl_color = 'y';
    end
        
    sl_handle_plan = plot(shoreline.sl.xyz(:,1),shoreline.sl.xyz(:,2),sl_color,'linewidth',2);
    axes(handles.oblq_image)
    sl_handle_oblq = plot(shoreline.sl.UV(:,1),shoreline.sl.UV(:,2),sl_color,'linewidth',2);
    data_plan.sl_handle_plan = sl_handle_plan;
    data_plan.sl = shoreline.sl;
    data.sl_handle_oblq = sl_handle_oblq;
    set(handles.plan_image,'UserData',data_plan) %Store rectified info in userdata of plan_image
end

%Get site information
data.site = imdata.site;
data.epoch = str2num(imdata.epochtime);
data.siteDB = CSPreadSiteDB(data.site);

%Get tide level of this loaded image and all tide levels within a certain
%tolerance

tideZ = CSPgetTideLevel(str2num(imdata.epochtime),imdata.site); %Tide level for loaded image
data.tide_level = tideZ;
disp(['Tide level of image is ' num2str(tideZ,'%0.2f') ' m'])
if nargin==1 %Only reset this if user is loading a new image
    disp('Finding all images within tidal tolerance...')
    tide_tol = str2num(get(handles.tidetolerance,'String')); %Tolerance to find images of similar tide levels (default 0.2m)
    if contains(imdata.user,'_registered')
       type = 'Registered';
    else
        type = 'Processed';
    end
    [epochs_im,im_files,im_paths,im_tides]=CSPgetImageList(data.site,type);
    Iim = find(im_tides>(tideZ-tide_tol)&im_tides<(tideZ+tide_tol)); %find images within a similar tide level according to
    navepochs = epochs_im(Iim); %epochs of images within tidal tolerance of loaded image
    [navepochs,Iunique] = unique(navepochs); %Just in case there are two of the same images in the database
    Iim = Iim(Iunique);
    navfiles = im_files(Iim);
    navpaths = im_paths(Iim);
    navtides = im_tides(Iim);
    disp('Done')
    data.navigation.tide_tol = tide_tol;
    data.navigation.epochs = navepochs;
    data.navigation.files = navfiles;
    data.navigation.paths = navpaths;
    data.navigation.tides = navtides;
else
    data.navigation = navigation;
end

%Send data to handle
set(handles.oblq_image,'UserData',data);