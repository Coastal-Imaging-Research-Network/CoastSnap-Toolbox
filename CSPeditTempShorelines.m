function CSPeditTempShorelines(site)
%
%function CSPeditTempShorelines(site)

%Load paths
CSPloadPaths

%Check how many shorelines in temporary directory for that site
temp_path = fullfile(shoreline_path,site,'temp');
files = dir([temp_path filesep '*.mat']);
disp(sprintf('%s temporary shorelines found in directory for site %s',num2str(length(files)),site))
siteDB = CSPreadSiteDB(site);

%Loop through temporary shorelines
for i = 1:length(files)
    fileparts = CSPparseFilename(files(i).name);
    rect_path = [image_path filesep site filesep 'Rectified' filesep fileparts.year filesep]; %Path where rectified image is located
    rect_fname = strrep(files(i).name,'shoreline','plan');
    
    %Load rectified image and shoreline data
    load(fullfile(rect_path,rect_fname))
    load(fullfile(temp_path,files(i).name))
    
    %Plot rectified image and shoreline
    f1=figure;
    image(xgrid,ygrid,Iplan)
    axis image; axis xy
    hold on
    h = impoly(gca,[sl.xyz(:,1) sl.xyz(:,2)],'closed',0);
    disp('Please edit your shoreline now or press any key to continue')
    pause
    newpos = getPosition(h);
    button = questdlg('Do you want to crop any points using the polygon tool?','Crop points?','Yes','No','No');
    switch button
        case 'Yes'
            h1 = impoly(gca,'closed',0);
            api = iptgetapi(h1);
            api.setColor('red');
            crop = getPosition(h1);
            I = find(inpolygon(newpos(:,1),newpos(:,2),crop(:,1),crop(:,2)));
            h2 = plot(newpos(I,1),newpos(I,2),'rx');
            delete(h1)
            button2 = questdlg('Do you want to delete these points?','Delete points?','Yes','No','No');
            switch button2
                case 'Yes'
                    newpos(I,:) = []; %Delete points in polygon
                    delete(h) %Clear shoreline from plot
                    delete(h2) %Clear crosses from plot
                    h = impoly(gca,newpos,'closed',0);
            end
    end
    
    %Update new data to sl structure
    sl.whenDone = matlab2Epoch(now-siteDB.timezone.gmt_offset/24); %Get time when done in epochtime (similar to argus)
    sl.xyz = [newpos(:,1) newpos(:,2) metadata.rectz*ones(size(newpos(:,1)))]; %Output as a Mx3 matrix to be the same as
    UV = findUVnDOF(metadata.geom.betas,sl.xyz,metadata.geom); %Its good practise to store the original Image UV data of the shoreline so you don't have to redo the geometry
    sl.UV = reshape(UV,length(sl.xyz),2);
    save(fullfile(temp_path,files(i).name),'sl') %Save updated info to file but still in temp directory
    
    %Ask if you want to move to Actual DB or delete from temp
    %database
    button = questdlg('What do you want to do?','What to do?','Save to actual DB','Delete from temp DB','Nothing','Nothing');
    switch button
        case 'Save to actual DB'
            savedir = [shoreline_path filesep site filesep fileparts.year filesep];
            movefile(fullfile(temp_path,files(i).name),fullfile(savedir,files(i).name),'f')
            disp('Shoreline saved to DB!!')
        case 'Delete from temp DB'
            delete(fullfile(temp_path,files(i).name)); %Delete from temp DB
            disp('Shoreline deleted from temp DB')
    end
    close all
end







    
    