function out = CSPGbulkRectAndMap(handles)

data = get(handles.oblq_image,'UserData'); %Get data stored in the userdata in the oblq_image handles
siteDB = data.siteDB;
CSPloadPaths %Load data paths

%First, check if image has already been rectified
fileparts = CSPparseFilename(data.fname);
rect_path = strrep(data.pname,'Processed','Rectified');
rect_path = strrep(rect_path,'Registered','Rectified'); %For Registered images
rect_name = strrep(data.fname,'snap','plan'); %Rectified is called plan to keep with Argus conventions
rect_name = strrep(rect_name,'timex','plan'); %For timex images
rect_name = strrep(rect_name,'jpg','mat'); %Need to load mat file

%Only continue if image has a geometry
if ~exist(fullfile(rect_path,rect_name),'file')
    warndlg('Image has not been rectified. Please rectify image (Step 2) and try again','Image not rectified')
else
    load(fullfile(rect_path,rect_name)) %Load geometry
    [fname,~]=uigetfile([data.pname filesep '*.jpg'],'Select last image of bulk rectify and map');
    endfile = CSPparseFilename(fname);
    endepoch = str2num(endfile.epochtime);
    
    %Check if user has selected image before start image
    if endepoch<data.epoch
        warndlg('End image selected is before start image. Please try again')
    else
        %Now loop over images
        II = find(data.navigation.epochs>data.epoch&data.navigation.epochs<=endepoch); %Find images between these two dates
        for i = 1:length(II)
            disp(['Rectifying and mapping ' num2str(i) ' of ' num2str(length(II)) ' images'])
            
            %First step is to rectify
            %First check if rectify image already exists
            newfname = data.navigation.files(II(i)).name;
            newpname = data.navigation.paths(II(i)).name;
            I = imread(fullfile(newpname,newfname)); %Read image
            if i== 1
                ImSizeCheck = [size(I,1) size(I,2)]; %To check that all images are the same size
            end
            ImSize = [size(I,1) size(I,2)];
            fileparts = CSPparseFilename(newfname);
            rect_path = strrep(newpname,'Processed','Rectified');
            rect_path = strrep(rect_path,'Registered','Rectified'); %For images coming from registered folder
            rect_name = strrep(newfname,'snap','plan'); %Rectified is called plan to keep with Argus conventions
            rect_name = strrep(rect_name,'timex','plan'); %For timex images
            if exist(fullfile(rect_path,rect_name),'file')
                disp('Rectification already detected...skipping this image')
                continue
            elseif (ImSize(1)~=ImSizeCheck(1))||(ImSize(2)~=ImSizeCheck(2))
                disp(['Warning: wrong image size detected in image ' newfname '. Check your registered images'])
                continue
            end
            
            %% Rectify image
            tide_level = CSPgetTideLevel(str2num(fileparts.epochtime),data.site);
            inputs.rectxy = [siteDB.rect.xlim(1) siteDB.rect.res siteDB.rect.xlim(2) siteDB.rect.ylim(1) siteDB.rect.res siteDB.rect.ylim(2)]; % rectification specs
            inputs.tide_offset = siteDB.rect.tidal_offset;
            inputs.rectz = tide_level+inputs.tide_offset; % rectification z-leve
            images.xy = inputs.rectxy;
            images.z = inputs.rectz;
            images = buildRectProducts(1, images, I, metadata.geom.betas, metadata.geom); %Metadata from original image
            finalImages = makeFinalImages(images);
            clear images
            
            %Build matrix
            xgrid = finalImages.x;
            ygrid = finalImages.y;
            Iplan = finalImages.timex;
            metadata.whenDone = matlab2Epoch(now-siteDB.timezone.gmt_offset/24);
            metadata.rectz = inputs.rectz;
            %metadata.gcps.xyzMeas = xyz;
            metadata.gcps.UVpicked = NaN;
            %metadata.geom.betas = betas;
            %metadata.geom.CI = meta.CI;
            %metadata.geom.MSE = meta.MSE;
            %metadata.geom.lcp = globs.lcp;
            %metadata.geom.knownFlags = globs.knownFlags;
            %metadata.geom.knowns = globs.knowns;
            
            %% Map shoreline
            load(fullfile(transect_dir,siteDB.sl_settings.transect_file)) %transect_dir found from CSPloadPaths
            addpath('../Shoreline-Mapping-Toolbox') %Relevant file (mapShorelineCCD.m) found in shoreline mapping toolbox
            type = 'CCD'; %Only consider CCD here
            if strcmp(type,'CCD')
                sl = mapShorelineCCD(xgrid,ygrid,Iplan,SLtransects,0,0); %Turn edit and plot mode off in GUI
            elseif strcmp(type,'HUE')
                sl = mapShorelineHUE(xgrid,ygrid,Iplan,SLtransects,0,0);
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
            out.QA = 0; %Switch to say whether shoreline has been QA'd or not
            sl = out;
            
            %% Plot results
            if ~exist('newfig')
                newfig = figure; %pop up new figure
            else
                figure(newfig)
            end
            axheight = 10;
            width1 = axheight*size(I,2)/size(I,1); %Width of oblique image
            width2 = axheight*(siteDB.rect.xlim(2)-siteDB.rect.xlim(1))/(siteDB.rect.ylim(2)-siteDB.rect.ylim(1)); %Width of rectified image
            ver_mar = [0.5 0.5];
            hor_mar = [0.5 0.5];
            mid_mar = [0.5 0.5];
            hor_mar1 = [hor_mar(1) mid_mar(1)+width2+hor_mar(2)];
            hor_mar2 = [hor_mar(1)+width1+mid_mar(1) hor_mar(2)];
            width = width1+mid_mar(1)+width2+sum(hor_mar);
            geomplot(1,1,1,1,width,axheight,hor_mar1,ver_mar,mid_mar)
            image(I)
            hold on
            plot(sl.UV(:,1),sl.UV(:,2),'y')
            axis off
            hold off            
            geomplot(1,1,1,1,width,axheight,hor_mar2,ver_mar,mid_mar)
            imagesc(finalImages.x,finalImages.y,finalImages.timex);
            hold on
            plot(sl.xyz(:,1),sl.xyz(:,2),'y')
            hold off
            xlabel('Eastings [m]'); ylabel('Northings [m]'); title('Rectified Image');
            axis xy;axis image; grid on
            set(gcf,'color','w')
            %pause(0.3)
                      
            
            %%Save rectified data to file
            imwrite(flipud(Iplan),fullfile(rect_path,rect_name))
            fname_rectified_mat = strrep(rect_name,'.jpg','.mat');
            save(fullfile(rect_path,fname_rectified_mat),'xgrid', 'ygrid', 'Iplan', 'metadata')
            
            %Save shoreline to file
            savedir = [shoreline_path filesep fileparts.site filesep fileparts.year filesep];
            savefname = strrep(newfname,'snap','shoreline');
            savefname = strrep(savefname,'timex','shoreline');
            savefname = strrep(savefname,'.jpg','.mat');
            save(fullfile(savedir,savefname),'sl')
            disp('Shoreline saved to DB!')
        end     
    end
end
