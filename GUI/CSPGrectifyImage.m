function out = CSPGrectifyImage(handles)

data = get(handles.oblq_image,'UserData'); %Get data stored in the userdata in the oblq_image handles
siteDB = data.siteDB;
gcp_list = CSPgetGCPcombo(siteDB,data.epoch);
I = data.I;
axes(handles.oblq_image) %Plot gpcs on GUI axis

%First, check if image has already been rectified
fileparts = CSPparseFilename(data.fname);
rect_path = strrep(data.pname,'Processed','Rectified');
rect_name = strrep(data.fname,'snap','plan'); %Rectified is called plan to keep with Argus conventions
rect_name = strrep(rect_name,'timex','plan'); %For timex images
go = 1;
if exist(fullfile(rect_path,rect_name),'file')
    ButtonName = questdlg('Image has already been rectified. Do you want to continue?','Continue?','Yes','No','No');
    switch ButtonName
        case 'No'
            go = 0;
        case 'Yes'
            go = 1;
    end
end

if go==1 %If hasn't been previously rectified
    tide_level = CSPgetTideLevel(str2num(fileparts.epochtime),data.site);
    
    
    %% Create inputs structure
    inputs.name = 'dummy';
    inputs.X0 = siteDB.origin.eastings;
    inputs.Y0 = siteDB.origin.northings;
    
    % Translate GCPs. First get gcps that user wants to use based on
    % gcp_list
    gcp = siteDB.gcp(gcp_list);
    for i = 1:length(gcp)
        gcp(i).x = gcp(i).eastings - inputs.X0;
        gcp(i).y = gcp(i).northings - inputs.Y0;
    end
    
    % Camera internal parameters
    inputs.cameraName = 'CoastSnap';
    inputs.cameraRes = [size(I,2) size(I,1)];
    inputs.camInt = makeLCPP3(inputs.cameraName, inputs.cameraRes(1),inputs.cameraRes(2));
    inputs.FOV = 100; % just for plotting the horizon
    
    % Camera initial external parameters
    xyzCam = [0 0 siteDB.origin.z]; % in meters
    aztiltrollCam = [siteDB.rect.initial.azimuth siteDB.rect.initial.tilt siteDB.rect.initial.roll]* (pi/180);   % in radians
    beta0 = [xyzCam aztiltrollCam];
    inputs.knownFlags = [1 1 1 0 0 0]; %Camera origin x y z is fixed, rest is unknown and needs solving
    inputs.beta0 = beta0(~inputs.knownFlags);
    inputs.knowns = beta0(logical(inputs.knownFlags));
    
    % Rectification limits
    inputs.rectxy = [siteDB.rect.xlim(1) siteDB.rect.res siteDB.rect.xlim(2) siteDB.rect.ylim(1) siteDB.rect.res siteDB.rect.ylim(2)]; % rectification specs
    inputs.tide_offset = siteDB.rect.tidal_offset;
    inputs.rectz = tide_level+inputs.tide_offset; % rectification z-level
    
    % Create meta structure
    meta.globals.lcp = inputs.camInt;
    meta.globals.knownFlags = inputs.knownFlags;
    meta.globals.knowns = inputs.knowns;
    
    %% Compute geometry
    NU = inputs.cameraRes(1);
    NV = inputs.cameraRes(2);
    
    global globs
    globs = meta.globals;
    
    % Select GCPs
    nGcps = length(gcp);
    x = [gcp.x];
    y = [gcp.y];
    z = [gcp.z];
    xyz = [x' y' z'];
    
    % click on gcps (if not using old metadata)
    for i = 1: nGcps
        title((['GCP ' num2str(i) ' of ' num2str(nGcps) ': Digitize ' gcp(i).name]));
        % you can zoom with your mouse and when your image is okay, you press any key
        zoom on;
        pause()
        zoom off;
        UV(i,:) = ginput(1);
        hold on
        plot(UV(i,1),UV(i,2),'go', 'markerfacecolor', 'g', 'markersize', 3);
        zoom out
    end
    
    % Perform non-linear fit
    options.Tolfun = 1e-12;
    options.TolX = 1e-12;
    
    %find optimum focal length based on trial values
    fx_mid = interp1([5:5:50000],[5:5:50000],815/960*inputs.cameraRes(1),'nearest'); %Range of trial focal length values depending on image resolution. May need to be modified in the future
    if inputs.cameraRes(1)> 1200 %For larger images
        fx = fx_mid-800:5:fx_mid+800;
    else
        fx = fx_mid-400:5:fx_mid+400;
    end
    
    %Loop through trial values
    wb = waitbar(0,'Optimising camera focal length for image rectification....');

    for i = 1:length(fx)
        waitbar(i/length(fx),wb,'Optimising camera focal length for image rectification....');
        globs.lcp.fx = fx(i);
        globs.lcp.fy = fx(i);
        %Non-linear fit, output geometry, residuals, covariance matrix and mse
        [beta, R, ~, CovB, mse, ~] = ....
            nlinfit(xyz, [UV(:,1); UV(:,2)], 'findUVnDOF', inputs.beta0, options);
        % Compute confidence intervals for each of the fitted parameters
        
        MSEall(i) = mse;
    end
    close(wb)
    
    %Find optimum focal length based on minimum MSE
    [MSEmin,Imin] = min(MSEall);
    disp(['Min RMSE of ' num2str(sqrt(MSEmin)) ' found for fx = ' num2str(fx(Imin))])
    
    globs.lcp.fx = fx(Imin);
    globs.lcp.fy = fx(Imin);
    % Non-linear fit, output geometry, residuals, covariance matrix and mse
    [beta, R, ~, CovB, mse, ~] = ....
        nlinfit(xyz, [UV(:,1); UV(:,2)], 'findUVnDOF', inputs.beta0, options);
    
    ci = nlparci(beta, R, 'covar', CovB);
    
    % Beta (geometry)
    beta6DOF = nan(1,6);
    beta6DOF(find(globs.knownFlags)) = globs.knowns;
    beta6DOF(find(~globs.knownFlags)) = beta;
    betas = beta6DOF;
    
    % Confidence interval (95%)
    ci6DOF = nan(2,6);
    ci6DOF(:, find(globs.knownFlags)) = zeros(2,length(globs.knowns));
    ci6DOF(:, find(~globs.knownFlags)) = ci';
    CI = ci6DOF;
    
    MSE = mse;
    RMSE = sqrt(MSE);
    title(sprintf('RMSE = %.2f pixels', RMSE));
    
    % Save meta structure (if not already there)
    meta.gcpList = 1:nGcps;
    meta.betas = betas;
    meta.CI = CI;
    meta.MSE = MSE;
    meta.globals.lcp = globs.lcp;
    
    % Plot GCPs transformed in image coordinates by the fitted geometry
    UV_computed = findUVnDOF(betas(1,:), xyz, globs);
    UV_computed = reshape(UV_computed,[],2);
    
    plot(UV_computed(:,1),UV_computed(:,2),'ro');
    
    %% Rectify image
    images.xy = inputs.rectxy;
    images.z = inputs.rectz;
    images = buildRectProducts(1, images, I, betas(1,:), meta.globals);
    
    % Plot image
    finalImages = makeFinalImages(images);
    axes(handles.plan_image) %Plot gpcs on GUI axis
    %figure('Name', 'Plan', 'Tag', 'Timex', 'Units', 'normalized','Position', [0 0 1 1]);
    imagesc(finalImages.x,finalImages.y,finalImages.timex);
    xlabel('Eastings [m]'); ylabel('Northings [m]'); title('Rectified Image');
    axis xy;axis image; grid on
    
    %Create output matrix
    xgrid = finalImages.x;
    ygrid = finalImages.y;
    Iplan = finalImages.timex;
    metadata.whenDone = matlab2Epoch(now-siteDB.timezone.gmt_offset/24);
    metadata.rectz = inputs.rectz;
    metadata.gcps.xyzMeas = xyz;
    metadata.gcps.UVpicked = UV;
    metadata.geom.betas = betas;
    metadata.geom.CI = meta.CI;
    metadata.geom.MSE = meta.MSE;
    metadata.geom.lcp = globs.lcp;
    metadata.geom.knownFlags = globs.knownFlags;
    metadata.geom.knowns = globs.knowns;
    
    if RMSE > 10
        msgbox(['RMSE is large (' num2str(RMSE,'%0.1f') 'm). Consider rectifying your image again. tor educe the error'])
    else
        %Save data to file
        imwrite(flipud(Iplan),fullfile(rect_path,rect_name))
        fname_rectified_mat = strrep(rect_name,'.jpg','.mat');
        save(fullfile(rect_path,fname_rectified_mat),'xgrid', 'ygrid', 'Iplan', 'metadata')
    end
        
    data.tide_level = tide_level;
    set(handles.oblq_image,'UserData',data) %Add tide level to UserData
    
    data2.xgrid = xgrid;
    data2.ygrid = ygrid;
    data2.Iplan = Iplan;
    data2.metadata = metadata;
    set(handles.plan_image,'UserData',data2) %Store rectified info in userdata of plan_image
    
    %Save rectified image to file
end