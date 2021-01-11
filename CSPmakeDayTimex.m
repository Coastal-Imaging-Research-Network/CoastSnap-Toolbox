function CSPmakeDayTimex(site,matlabday1,matlabday2)

[epochtimes,filenames,filepaths,tide_levels] = CSPgetImageList(site,'Processed');
siteDB = CSPreadSiteDB(site);
matlabtimes = epoch2Matlab(epochtimes)+siteDB.timezone.gmt_offset/24; %Convert to local time
matlabdays = matlabday1:matlabday2;

for i = 1:length(matlabdays)
    disp(['Doing days ' num2str(i) ' of ' num2str(length(matlabdays))])
    Iday = find(floor(matlabtimes)==matlabdays(i));
    if length(Iday)>2
        II = uint32(imread(fullfile(filepaths(Iday(1)).name,filenames(Iday(1)).name)));
        for j = 2:length(Iday)
            %Snap = uint32(imread(fullfile(filepaths(Iday(j)).name,filenames(Iday(j)).name)));
            II = imadd(II,uint32(imread(fullfile(filepaths(Iday(j)).name,filenames(Iday(j)).name))));
        end
        I = imdivide(II,length(Iday));
        fparts = CSPparseFilename(filenames(Iday(j)).name);
        epochtime = matlab2Epoch(matlabdays(i)+siteDB.timezone.gmt_offset/24);
        fparts.type = 'daytimex';
        newname = CSPargusFilename(epochtime,site,-1,fparts.type,fparts.user,'jpg');
        imwrite(uint8(I),fullfile(filepaths(Iday(j)).name,newname),'jpg','quality',100);
    end
end

    
    