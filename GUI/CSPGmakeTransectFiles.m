function CSPGmakeTransectFiles(handles)

CSPloadPaths
%Get data from handles
data = get(handles.oblq_image,'UserData');
data_plan = get(handles.plan_image,'UserData');

%First, check if image has already been rectified
fileparts = CSPparseFilename(data.fname);
rect_path = strrep(data.pname,'Processed','Rectified');
rect_path = strrep(rect_path,'Registered','Rectified'); %For Registered images
rect_name = strrep(data.fname,'snap','plan'); %Rectified is called plan to keep with Argus conventions
rect_name = strrep(rect_name,'timex','plan'); %For timex images
if ~exist(fullfile(rect_path,rect_name),'file')
    ButtonName = warndlg('Image has not been rectified. To make a transect file you need to first rectify an image','Image has not been rectified');
else
    disp('1) Welcome to the Transect File Creator. To start, click on the area in the rectified image on right that evenly spans the beach and water. This forms the region of interest where shorelines can be detected.')
    title(handles.plan_image,'Draw region of interest, equally between sand/water')
    %h = impoly(handles.plan_image,'closed',1);
    %ROI = getPosition(h);
    ROI = drawpolygon(handles.plan_image,'InteractionsAllowed','none'); %Use drawpolygon as it is cleaner. Might have some issues if people dont have certain toolboxes or matlab versions?
    title(handles.plan_image,'Draw representative shoreline (starting from nearest station)')
    disp('2) Now draw a line that approximates the coastline, starting closest to the station and moving away to the farfield. This will be used to determine the orientation of the transects.')
    %h = impoly(handles.plan_image,'closed',0);
    %sl = getPosition(h);
    sl = drawpolyline(handles.plan_image,'Color','Green','InteractionsAllowed','none');
    marker_dist = 5; %Spacings of the transects. Set nominally to 5m but could be higher resolution
    %x = sl(:,1)';
    %y = sl(:,2)';
    x = sl.Position(:,1)'; %For when using drawpolyline
    y = sl.Position(:,2)'; %For when using drawpolyline
    dist_from_start = cumsum( [0, sqrt((x(2:end)-x(1:end-1)).^2 + (y(2:end)-y(1:end-1)).^2)] );
    marker_locs = 0 : marker_dist : dist_from_start(end);   %replace with specific distances if desired
    marker_indices = interp1( dist_from_start, 1 : length(dist_from_start), marker_locs);
    marker_base_pos = floor(marker_indices);
    weight_second = marker_indices - marker_base_pos;
    marker_x = x(marker_base_pos) .* (1-weight_second) + x(marker_base_pos+1) .* weight_second;
    marker_y = y(marker_base_pos) .* (1-weight_second) + y(marker_base_pos+1) .* weight_second;
    m = (marker_y(2:end)-marker_y(1:end-1))./(marker_x(2:end)-marker_x(1:end-1));
    marker_locs(end) = []; %Needed to get alongshore distances correct
    d = -500:0.1:500;
    X = NaN(length(d),length(m));
    Y = X;
    for i = 1:length(marker_x)-1
        tangent = -(1/m(i));
        r = sqrt(1+tangent^2);
        xx = marker_x(i)+d./r;
        yy = marker_y(i)+d.*(tangent/r);
        X(:,i) = xx';
        Y(:,i) = yy';
    end
    %I = find(~inpolygon(X,Y,ROI(:,1),ROI(:,2)));
    I = find(~inpolygon(X,Y,ROI.Position(:,1),ROI.Position(:,2))); %For when using drawpolygon
    X(I) = NaN;
    Y(I) = NaN;
    X2ends = NaN(2,length(m));
    Y2ends = NaN(2,length(m));
    Icut = [];
    for i = 1:length(m)
        I = find(~isnan(X(:,i)));
        if ~isempty(I)
            X2ends(1,i) = X(I(1),i);
            X2ends(2,i) = X(I(end),i);
            Y2ends(1,i) = Y(I(1),i);
            Y2ends(2,i) = Y(I(end),i);
            hold on
            plot(X2ends(:,i),Y2ends(:,i),'r')
        else
            Icut = [Icut i];
        end
    end
    marker_locs(Icut) = [];
    I = find(isnan(X2ends(1,:)));
    X2ends(:,I) = [];
    Y2ends(:,I) = [];
    marker_locs(I) = [];
    plot(X2ends(1,:),Y2ends(1,:),'ro')
    plot(X2ends(2,:),Y2ends(2,:),'bo')
    SLtransects.x = X2ends;
    SLtransects.y = Y2ends;
    SLtransects.alongshore_distances = marker_locs;
    
    %Save transect file?
    button = questdlg('Do you want to save this transect file? Double-check that blue circles indicate seaward extents. If they are the other way round, choose "Flip and save!"','Save transect file?','Yes','No','Flip and save!','No');
    switch button
        case 'Yes'
            savefname = inputdlg('Please write filename of transect file. The standard convention for this filename is "SLtransects_(sitename)"','Transect file name');
            save([transect_dir filesep savefname{1} '.mat'],'SLtransects')
            msgbox(['Transect file saved!! There are ' num2str(size(X2ends,2)) ' transects in this transect file'])
            disp('Transect file has been saved! Please make sure you update the database accordingly')
        case 'Flip and save!'
            X2ends = flipud(X2ends);
            Y2ends = flipud(Y2ends);
            plot(X2ends(1,:),Y2ends(1,:),'ro')
            plot(X2ends(2,:),Y2ends(2,:),'bo')
            savefname = inputdlg('Please write filename of transect file. The standard convention for this filename is "SLtransects_(sitename)"','Transect file name');
            save([transect_dir filesep savefname{1} '.mat'],'SLtransects')
            msgbox(['Transect file saved!! There are ' num2str(size(X2ends,2)) ' transects in this transect file'])
            disp('Transect file has been saved! Please make sure you update the database accordingly')
    end
end