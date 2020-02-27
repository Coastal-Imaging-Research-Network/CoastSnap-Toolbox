[data,txt] = xlsread(dbfile,'database');
%Read image times - make sure Excel format is as below
if isempty(strfind(txt{2,3},'PM'))||isempty(strfind(txt{2,3},'AM')) %if using AM/PM
    imtimes = datenum(char(txt{2:end,3}),'dd/mm/yyyy HH:MM:SS AM');
else
    imtimes = datenum(char(txt{2:end,3}),'dd/mm/yyyy HH:MM:SS'); %if using 24 hour clock
end

I = find(strcmp(txt(2:end,4),'AEST')&imtimes>datenum(2019,10,6));

for i = 261:length(I)
    i
    imtimeGMT = imtimes(I(i))-10/24;
    M = datevec(imtimeGMT+10/24);
    epochtime = matlab2Epoch(datevec(imtimeGMT));
    site = char(txt(I(i)+1,1));
    user = char(txt(I(i)+1,2)); user = strrep(user,'_',''); user = strrep(user,'.','');user = strrep(user,' ','') %Get rid of underscore or full stops if any exists
    imtype = char(txt(I(i)+1,7));
    imname = CSPargusFilename(epochtime,site,-1,lower(imtype),char(user),'jpg');
    newimname = CSPargusFilename(epochtime-3600,site,-1,lower(imtype),user,'jpg');
    dir = fullfile(image_path,site,'Processed',num2str(M(1)));
    movefile(fullfile(dir,imname),fullfile(dir,newimname),'f')
end
    
