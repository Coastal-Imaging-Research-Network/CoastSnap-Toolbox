function CSPmapShorelineLoop(site,epochtime1,epochtime2)

[epochtimes,filenames,tide_levels] = CSPgetImageList(site,'Rectified');

%Only find rectified images between specified timeframe
I = find(epochtimes>epochtime1&epochtimes<epochtime2);
disp(sprintf('%s rectified images found between specified timeframe',num2str(length(I))))


%Loop through images
for i = 1:length(I)
    disp(['Doing shoreline ' num2str(i) ' of ' num2str(length(I))])
    rectname = strrep(filenames(I(i)).name,'jpg','mat');      
    CSPmapShoreline(rectname,'CCD','auto');
end
